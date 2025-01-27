// Core imports
use poseidon::PoseidonTrait;

// Starknet imports
use starknet::ContractAddress;
use starknet::{get_block_timestamp, get_caller_address};

// Dojo imports
// use dojo::world::{world::WORLD, {IWorldDispatcher, IWorldDispatcherTrait}};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use dragark_test_v19::{constants::{DIGITS, characters}, errors::{Error, assert_with_err}};

fn _require_world_owner(world: IWorldDispatcher, address: ContractAddress) {
    // assert_with_err(world.is_owner(WORLD, address), Error::NOT_WORLD_OWNER, Option::None);
    assert_with_err(world.is_owner(0, address), Error::NOT_WORLD_OWNER, Option::None);
}

fn _require_valid_time() {
    let cur_block_timestamp: u64 = get_block_timestamp();
    assert_with_err(cur_block_timestamp >= 1721890800, Error::INVALID_TIME, Option::None);
}

fn _is_playable() -> bool {
    true
}

fn _generate_code(salt: felt252) -> felt252 {
    let cur_timestamp = get_block_timestamp();
    let mut code: ByteArray = "";
    let player_address: felt252 = get_caller_address().into();
    let mut i = 0;
    loop {
        if (i == DIGITS) {
            break;
        }

        // Prepare random seed
        let seed: u256 = poseidon::poseidon_hash_span(
            array![player_address, i.into(), 'invite_code', cur_timestamp.into(), salt].span()
        )
            .try_into()
            .unwrap();

        // Get random index & character
        let random_index: u32 = (seed % 36).try_into().unwrap();
        let random_character = *characters().at(random_index);

        // Append to code
        code.append_word(random_character, 1);

        i += 1;
    };

    let res: felt252 = code.pending_word;

    res
}
