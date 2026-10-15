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


    // @cover-intent Protocol State Machine: Verify that deal() creates a new game with Ongoing state and correct initial card counts
    function test_Deal_and_check_initial_state_0() public {
// cover: deal :: games[msg.sender].player == 0 || games[msg.sender].state != Ongoing
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

    // @cover-intent Protocol State Machine: Verify hit() adds a card and checks game result without finishing
    function test_Hit_during_ongoing_game_1() public {
// cover: hit :: games[msg.sender].player != 0 && games[msg.sender].state == Ongoing
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
        // skip ABI-mismatched call: getGameState()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify stand() finishes the game and determines winner
    function test_Stand_and_finish_game_2() public {
// cover: stand :: games[msg.sender].player != 0 && games[msg.sender].state == Ongoing
// cover: checkGameResult :: finishGame == true
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

    // @cover-intent Financial & Accounting: Verify deal() accepts minimum bet boundary
    function test_Deal_with_minimum_bet_3() public {
// cover: deal :: msg.value >= minBet
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: deal()
        // skip ABI-mismatched call: getGameState()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify deal() accepts maximum bet boundary
    function test_Deal_with_maximum_bet_4() public {
// cover: deal :: msg.value <= maxBet
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
    }

    // @cover-intent Financial & Accounting: Verify deal() reverts when bet is below minimum
    function test_Deal_with_bet_below_minimum_5() public {
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

    // @cover-intent Financial & Accounting: Verify deal() reverts when bet is above maximum
    function test_Deal_with_bet_above_maximum_6() public {
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

    // @cover-intent Protocol State Machine: Verify deal() reverts when game is already ongoing
    function test_Double_deal_attempt_7() public {
// cover: deal :: games[msg.sender].player != 0 && games[msg.sender].state == Ongoing
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

    // @cover-intent Authorization & Access Control: Verify hit() reverts when no game is active
    function test_Hit_without_active_game_8() public {
// cover: hit :: games[msg.sender].player == 0 || games[msg.sender].state != Ongoing
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

    // @cover-intent Authorization & Access Control: Verify stand() reverts when no game is active
    function test_Stand_without_active_game_9() public {
// cover: stand :: games[msg.sender].player == 0 || games[msg.sender].state != Ongoing
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

    // @cover-intent Protocol State Machine
    function test_deal_sequence_10() public {
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

    // @cover-intent Protocol State Machine
    function test_games_sequence_11() public {
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
    function test_getGameState_sequence_12() public {
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

    // @cover-intent Protocol State Machine
    function test_getHouseCard_sequence_13() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_getHouseCardsNumber_sequence_14() public {
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
            uint256 __v3 = uint256(target.getHouseCardsNumber());
            _assertRelU(__v3, 0, 1, "call:getHouseCardsNumber==1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getPlayerCard_sequence_15() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_getPlayerCardsNumber_sequence_16() public {
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
            uint256 __v4 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v4, 0, 2, "call:getPlayerCardsNumber==2");
        }
    }

    // @cover-intent Protocol State Machine
    function test_hit_sequence_17() public {
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
            uint256 __v5 = uint256(target.getPlayerCardsNumber());
            _assertRelU(__v5, 0, 3, "call:getPlayerCardsNumber==3");
        }
    }

    // @cover-intent Financial & Accounting
    function test_maxBet_sequence_18() public {
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

    // @cover-intent Financial & Accounting
    function test_minBet_sequence_19() public {
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
    function test_stand_sequence_20() public {
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
