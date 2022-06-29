%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.protocol.libraries.types.data_types import DataTypes
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_check,
    uint256_sub,
    uint256_lt,
)

from contracts.protocol.pool.pool_storage import PoolStorage

namespace ReserveLogic:
    # @notice Initializes a reserve.
    # @param reserve The reserve object
    # @param a_token_address The address of the overlying atoken contract
    func init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve : DataTypes.ReserveData, a_token_address : felt
    ) -> (reserve : DataTypes.ReserveData):
        with_attr error_message("Reserve already initialized"):
            assert reserve.a_token_address = 0
        end

        # Write a_token_address in reserve
        let new_reserve = DataTypes.ReserveData(
            id=reserve.id, a_token_address=a_token_address, liquidity_index=1 * 10 ** 27
        )
        PoolStorage.reserves_write(a_token_address, new_reserve)
        # TODO add other params such as liq index, debt tokens addresses, use RayMath library
        return (new_reserve)
    end
end
