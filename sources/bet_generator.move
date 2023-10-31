#[test_only]
module casuino_test_utils::bet_generator {
    use sui::address as addr;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::TxContext;
    use sui::test_random::{Self, Random};

    struct BetGenerator has store, drop {
        random: Random,
        min_stake_amount: u64,
        max_stake_amount: u64,
    }

    public fun new(
        seed: vector<u8>,
        min_stake_amount: u64,
        max_stake_amount: u64,
    ): BetGenerator {
        BetGenerator {
            random: test_random::new(seed),
            min_stake_amount,
            max_stake_amount,
        }
    }

    public fun generate_bet<T>(
        generator: &mut BetGenerator,
    ): (address, Balance<T>, u256) {
        let random = &mut generator.random;
        let player = addr::from_u256(test_random::next_u256(random));
        let stake_amount_diff = generator.max_stake_amount - generator.min_stake_amount;
        let stake = balance::create_for_testing<T>(
            generator.min_stake_amount +
            test_random::next_u64(random) % stake_amount_diff
        );
        let other = test_random::next_u256(random);
        (player, stake, other)
    }

    public fun generate_bet_coin<T>(
        generator: &mut BetGenerator,
        ctx: &mut TxContext,
    ): (address, Coin<T>, u256) {
        let (player, stake, other) = generate_bet<T>(generator);
        let stake = coin::from_balance(stake, ctx);
        (player, stake, other)
    }

    #[test]
    fun test_generate_ten_bets() {
        use sui::sui::SUI;
        let generator = new(vector<u8>[1,2,3,4,5], 1_000, 100_000);
        let player_count: u64 = 50;
        let idx: u64 = 0;
        while(idx < player_count) {
            let (player, stake, other) = generate_bet<SUI>(&mut generator);
            std::debug::print(&player);
            std::debug::print(&other);
            std::debug::print(&stake);
            balance::destroy_for_testing(stake);
            idx = idx + 1;
        };
    }
}
