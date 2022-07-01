%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.protocol.libraries.types.data_types import DataTypes

@contract_interface
namespace IPool:
    func supply(asset : felt, amount : Uint256, on_behalf_of : felt, referral_code : felt):
    end

    func withdraw(asset : felt, amount : Uint256, to : felt):
    end

    func init_reserve(asset : felt, a_token_address : felt):
    end

    func drop_reserve(asset : felt):
    end

    func get_reserve_data(asset : felt) -> (reserve_data : DataTypes.ReserveData):
    end

    func get_reserves_list() -> (assets_len : felt, assets : felt*):
    end
end