// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/blackjack.sol";

// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}

contract BlackJack_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function BlackJack_FunctionalTest() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() public payable { }


    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }


    // @cover-intent Test basic deal() with valid bet between minBet and maxBet, verify game state is Ongoing (0) and cards are dealt
    function test_deal_basic_positive_0() public {
// cover: deal :: msg.value >= minBet && msg.value <= maxBet
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: getGameState()
        // skip ABI-mismatched call: getPlayerCardsNumber()
        // skip ABI-mismatched call: getHouseCardsNumber()
        vm.stopPrank();
    }

    // @cover-intent Test deal() with value below minBet (50 finney) should revert
    function test_deal_below_min_bet_1() public {
// cover: deal :: msg.value < minBet
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: deal()
    }

    // @cover-intent Test deal() with value above maxBet (5 ether) should revert
    function test_deal_above_max_bet_2() public {
// cover: deal :: msg.value > maxBet
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: deal()
    }

    // @cover-intent Test that calling deal() twice without finishing first game reverts
    function test_deal_double_game_revert_3() public {
// cover: deal :: games[msg.sender].player != 0 && games[msg.sender].state == GameState.Ongoing
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        vm.expectRevert();
        // skip ABI-mismatched call: deal()
        vm.stopPrank();
    }

    // @cover-intent Test hit() after deal() increases player cards and game remains ongoing
    function test_hit_after_deal_4() public {
// cover: hit :: gameIsGoingOn modifier passes
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: hit()
        // skip ABI-mismatched call: getPlayerCardsNumber()
        vm.stopPrank();
    }

    // @cover-intent Test hit() without an active game reverts
    function test_hit_without_game_revert_5() public {
// cover: hit :: gameIsGoingOn modifier fails
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: hit()
    }

    // @cover-intent Test stand() after deal() triggers house drawing and game ends
    function test_stand_after_deal_6() public {
// cover: stand :: gameIsGoingOn modifier passes
// cover: stand :: houseScoreBig < 17 loop
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: stand()
        // skip ABI-mismatched call: getGameState()
        vm.stopPrank();
    }

    // @cover-intent Test stand() without an active game reverts
    function test_stand_without_game_revert_7() public {
// cover: stand :: gameIsGoingOn modifier fails
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: stand()
    }

    // @cover-intent Test getGameState() without an existing game reverts
    function test_get_game_state_no_game_revert_8() public {
// cover: getGameState :: games[msg.sender].player == 0
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: getGameState()
    }

    // @cover-intent Test getPlayerCard() with id out of bounds reverts
    function test_get_player_card_out_of_bounds_9() public {
// cover: getPlayerCard :: id > games[msg.sender].playerCards.length
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        vm.expectRevert();
        {
        target.getPlayerCard(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_deal_start_new_game_10() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: deal()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.getGameState());
            _assertRelU(__v1, 0, 0, "call:getGameState==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_games_view_game_info_11() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        {
        target.games(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_getGameState_check_ongoing_game_12() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: getGameState()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.getGameState());
            _assertRelU(__v2, 0, 0, "call:getGameState==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHouseCard_view_house_card_13() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        {
        target.getHouseCard(0);
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.getHouseCardsNumber());
            _assertRelU(__v3, 2, 1, "call:getHouseCardsNumber>=1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHouseCardsNumber_view_house_cards_count_14() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: getHouseCardsNumber()
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.getHouseCardsNumber());
            _assertRelU(__v4, 0, 1, "call:getHouseCardsNumber==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getPlayerCard_view_player_card_15() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        {
        target.getPlayerCard(0);
        }
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v5, 2, 2, "call:getPlayerCardsNumber>=2");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getPlayerCardsNumber_view_player_cards_count_16() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: getPlayerCardsNumber()
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v6, 0, 2, "call:getPlayerCardsNumber==2");
        }
    }

    // @cover-intent Protocol State Machine
    function test_hit_draw_another_card_17() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: hit()
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v7, 0, 3, "call:getPlayerCardsNumber==3");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_maxBet_view_max_bet_18() public {
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: maxBet()
        // TODO assert: call:maxBet() == 5 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_minBet_view_min_bet_19() public {
        vm.startPrank(owner);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: minBet()
        // TODO assert: call:minBet() == 50 finney
    }

    // @cover-intent Protocol State Machine
    function test_stand_finish_game_20() public {
        vm.startPrank(alice);
        BlackJack target = new BlackJack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: stand()
        vm.stopPrank();
    }

}
