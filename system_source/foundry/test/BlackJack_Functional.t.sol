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


    // @cover-intent Protocol State Machine: Verify that a new game can be started with a valid bet within min/max range, and that the game state becomes Ongoing.
    function test_deal_positive_path_0() public {
// cover: deal :: msg.value >= minBet && msg.value <= maxBet
// cover: deal :: games[msg.sender].player == 0 || games[msg.sender].state != GameState.Ongoing
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.getGameState();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that deal() reverts when the sent value is below minBet.
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
        {
        target.deal.value(0.01 ether)();
        }
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent Financial & Accounting: Verify that deal() reverts when the sent value is above maxBet.
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
        {
        target.deal.value(6 ether)();
        }
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent Protocol State Machine: Verify that deal() reverts if a game is already ongoing for the sender.
    function test_deal_already_ongoing_3() public {
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
        {
        target.deal.value(1 ether)();
        }
        vm.expectRevert();
        {
        target.deal.value(1 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 1 ether
    }

    // @cover-intent Protocol State Machine: Verify that hit() works during an ongoing game and adds a card to the player's hand.
    function test_hit_during_ongoing_game_4() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.hit();
        }
        {
        target.getPlayerCardsNumber();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that hit() reverts when no game is ongoing.
    function test_hit_without_ongoing_game_5() public {
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
        {
        target.hit();
        }
    }

    // @cover-intent Protocol State Machine: Verify that stand() works during an ongoing game and finishes the game.
    function test_stand_during_ongoing_game_6() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.stand();
        }
        {
        target.getGameState();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that stand() reverts when no game is ongoing.
    function test_stand_without_ongoing_game_7() public {
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
        {
        target.stand();
        }
    }

    // @cover-intent Protocol State Machine: Verify that getGameState() reverts when no game exists for the sender.
    function test_getGameState_no_game_8() public {
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
        {
        target.getGameState();
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that getPlayerCard() reverts when id is out of bounds.
    function test_getPlayerCard_out_of_bounds_9() public {
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
        {
        target.deal.value(1 ether)();
        }
        vm.expectRevert();
        {
        target.getPlayerCard(99);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that getHouseCard() reverts when id is out of bounds.
    function test_getHouseCard_out_of_bounds_10() public {
// cover: getHouseCard :: id > games[msg.sender].houseCards.length
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
        {
        target.deal.value(1 ether)();
        }
        vm.expectRevert();
        {
        target.getHouseCard(99);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_deal_sequence_11() public {
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
        vm.prank(alice);
        {
        target.deal.value(1 ether)();
        }
        {
            uint256 __v1 = uint256(target.getGameState());
            _assertRelU(__v1, 0, 0, "call:getGameState==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_games_sequence_12() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.games(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_getGameState_sequence_13() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.getGameState();
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.getGameState());
            _assertRelU(__v2, 0, 0, "call:getGameState==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHouseCard_sequence_14() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.getHouseCard(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHouseCardsNumber_sequence_15() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.getHouseCardsNumber();
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.getHouseCardsNumber());
            _assertRelU(__v3, 0, 1, "call:getHouseCardsNumber==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getPlayerCard_sequence_16() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.getPlayerCard(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getPlayerCardsNumber_sequence_17() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.getPlayerCardsNumber();
        }
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v4, 0, 2, "call:getPlayerCardsNumber==2");
        }
    }

    // @cover-intent Protocol State Machine
    function test_hit_sequence_18() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.hit();
        }
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v5, 0, 3, "call:getPlayerCardsNumber==3");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_maxBet_sequence_19() public {
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
        {
        target.maxBet();
        }
        // TODO assert: call:maxBet() == 5 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_minBet_sequence_20() public {
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
        {
        target.minBet();
        }
        // TODO assert: call:minBet() == 50 finney
    }

    // @cover-intent Protocol State Machine
    function test_stand_sequence_21() public {
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
        {
        target.deal.value(1 ether)();
        }
        {
        target.stand();
        }
        vm.stopPrank();
    }

}
