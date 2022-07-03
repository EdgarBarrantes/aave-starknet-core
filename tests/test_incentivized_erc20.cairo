%lang starknet
from starkware.cairo.common.uint256 import Uint256
from contracts.interfaces.i_incentivized_erc20 import IncentivizedERC20

const PRANK_USER1 = 123
const PRANK_USER2 = 456

@view
func __setup__():
    # deploy pool contract first
    %{ context.pool = deploy_contract("./contracts/protocol/pool/Pool.cairo").contract_address %}
    %{ context.name= 1 %}
    %{ context.symbol= 2 %}
    %{ context.decimals= 3 %}
    %{
        context.incentivized_erc_20=deploy_contract("./contracts/protocol/tokenization/base/incentivized_erc20.cairo", 
           [context.pool, context.name, context.symbol, context.decimals]).contract_address
    %}

    return ()
end

@external
func test_incentivizedERC20_initialization{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt
    local name : felt
    local symbol : felt
    local decimals : felt

    %{
        ids.IncentivizedERC20_address = context.incentivized_erc_20
        ids.name=context.name
        ids.symbol=context.symbol
        ids.decimals=context.decimals
    %}

    let (res_name) = IncentivizedERC20.name(contract_address=IncentivizedERC20_address)
    assert res_name = name

    let (res_symbol) = IncentivizedERC20.symbol(contract_address=IncentivizedERC20_address)
    assert res_symbol = symbol

    let (res_decimals) = IncentivizedERC20.decimals(contract_address=IncentivizedERC20_address)
    assert res_decimals = decimals

    return ()
end

@external
func test_incentivizedERC20_setters{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt

    %{ ids.IncentivizedERC20_address = context.incentivized_erc_20 %}

    IncentivizedERC20.set_name(contract_address=IncentivizedERC20_address, name=5)
    IncentivizedERC20.set_symbol(contract_address=IncentivizedERC20_address, symbol=6)
    IncentivizedERC20.set_decimals(contract_address=IncentivizedERC20_address, decimals=7)

    let (res_name) = IncentivizedERC20.name(contract_address=IncentivizedERC20_address)
    assert res_name = 5

    let (res_symbol) = IncentivizedERC20.symbol(contract_address=IncentivizedERC20_address)
    assert res_symbol = 6

    let (res_decimals) = IncentivizedERC20.decimals(contract_address=IncentivizedERC20_address)
    assert res_decimals = 7

    return ()
end

@external
func test_incentivizedERC20_balances{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt

    %{ ids.IncentivizedERC20_address = context.incentivized_erc_20 %}

    IncentivizedERC20.create_state(IncentivizedERC20_address, PRANK_USER1, 100, 1)
    IncentivizedERC20.create_state(IncentivizedERC20_address, PRANK_USER2, 200, 1)

    let (balance1) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER1)
    assert balance1 = 100

    let (balance2) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER2)
    assert balance2 = 200

    IncentivizedERC20.increase_balance(IncentivizedERC20_address, PRANK_USER1, 100)
    let (balance1_new) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER1)
    assert balance1_new = 200

    IncentivizedERC20.decrease_balance(IncentivizedERC20_address, PRANK_USER2, 10)
    let (balance2_new) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER2)
    assert balance2_new = 190

    return ()
end

@external
func test_incentivizedERC20_transfers{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt

    %{ ids.IncentivizedERC20_address = context.incentivized_erc_20 %}

    IncentivizedERC20.create_state(IncentivizedERC20_address, PRANK_USER1, 100, 1)
    IncentivizedERC20.create_state(IncentivizedERC20_address, PRANK_USER2, 200, 1)

    # User 2 sends 50 to User 1
    %{ stop_prank_transfer1= start_prank(ids.PRANK_USER2, target_contract_address=ids.IncentivizedERC20_address) %}

    IncentivizedERC20.transfer(IncentivizedERC20_address, PRANK_USER1, Uint256(50, 0))

    %{ stop_prank_transfer1() %}

    let (balance1) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER1)
    assert balance1 = 150

    let (balance2) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER2)
    assert balance2 = 150

    # User 1 sends User 1 50
    %{ stop_prank_transfer2= start_prank(ids.PRANK_USER1, target_contract_address=ids.IncentivizedERC20_address) %}

    IncentivizedERC20.transfer(IncentivizedERC20_address, PRANK_USER1, Uint256(50, 0))

    %{ stop_prank_transfer2() %}

    let (balance1_new) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, PRANK_USER1)
    assert balance1_new = 150

    # User 2 sends User 1 more than he has in balance- expect revert
    # %{ stop_prank_transfer3= start_prank(ids.PRANK_USER2, target_contract_address=ids.IncentivizedERC20_address) %}

    # %{ expect_revert("Not enough balance") %}
    # IncentivizedERC20.transfer(IncentivizedERC20_address, PRANK_USER1, Uint256(350,0))

    # %{ stop_prank_transfer3() %}

    # let (balance1_new) =  IncentivizedERC20.incentivized_erc20_balanceOf(
    # IncentivizedERC20_address, PRANK_USER2)
    # assert balance1_new = 150

    return ()
end

@external
func test_incentivizedERC20_allowances{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt

    %{ ids.IncentivizedERC20_address = context.incentivized_erc_20 %}

    IncentivizedERC20.create_state(IncentivizedERC20_address, PRANK_USER1, 100, 1)
    IncentivizedERC20.create_state(IncentivizedERC20_address, PRANK_USER2, 200, 1)

    %{ stop_prank_approve= start_prank(ids.PRANK_USER2, target_contract_address=ids.IncentivizedERC20_address) %}

    IncentivizedERC20.approve(IncentivizedERC20_address, PRANK_USER1, Uint256(100, 0))

    %{ stop_prank_approve() %}

    let (allowance) = IncentivizedERC20.allowance(
        IncentivizedERC20_address, PRANK_USER2, PRANK_USER1
    )
    assert allowance = 100

    %{ stop_prank_increase= start_prank(ids.PRANK_USER2, target_contract_address=ids.IncentivizedERC20_address) %}

    IncentivizedERC20.increaseAllowance(IncentivizedERC20_address, PRANK_USER1, Uint256(50, 0))

    %{ stop_prank_increase() %}

    let (allowance2) = IncentivizedERC20.allowance(
        IncentivizedERC20_address, PRANK_USER2, PRANK_USER1
    )
    assert allowance2 = 150

    %{ stop_prank_transferFrom= start_prank(ids.PRANK_USER1, target_contract_address=ids.IncentivizedERC20_address) %}

    IncentivizedERC20.transferFrom(IncentivizedERC20_address, PRANK_USER2, 678, Uint256(150, 0))

    %{ stop_prank_transferFrom() %}

    let (balance) = IncentivizedERC20.balanceOf(IncentivizedERC20_address, 678)
    assert balance = 150

    return ()
end