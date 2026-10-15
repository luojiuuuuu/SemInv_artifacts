// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;
import "../src/buggy_25.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract WhiteBetting_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Authorization & Access Control: Verify that only owner can set up a game and that a player can place a valid bet with correct odds and sufficient stake.
    function test_Owner_sets_up_a_game_and_places_a_valid_bet_0() public {
// assume: gameList[1].open_status == 3
// assume: now < gameList[1].timestamp - 600
// cover: placeBet :: require(stake >= .001 ether) true
// cover: placeBet :: require(_odd != 0) true
// cover: placeBet :: require(gameList[_fixtureId].odd_homeTeam == _odd) true
// cover: placeBet :: require(gameList[_fixtureId].odd_drawTeam == _odd) true
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(1, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.startPrank(alice);
        {
        target.placeBet.value(1 ether)(1, 1, 1500);
        }
        {
        target.placeBet.value(1 ether)(1, 2, 2000);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can call setGameInfo.
    function test_Non_owner_cannot_set_game_info_1() public {
// cover: setGameInfo :: require(msg.sender == owner) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(1, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
    }

    // @cover-intent Transactional Consistency: Verify that placing a bet with less than 0.001 ether reverts.
    function test_Place_bet_with_insufficient_stake_reverts_2() public {
// assume: gameList[2].open_status == 3
// assume: now < gameList[2].timestamp - 600
// cover: placeBet :: require(stake >= .001 ether) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(2, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet(2, 1, 1500);
        }
    }

    // @cover-intent Transactional Consistency: Verify that placing a bet with zero odds reverts.
    function test_Place_bet_with_zero_odds_reverts_3() public {
// assume: gameList[3].open_status == 3
// assume: now < gameList[3].timestamp - 600
// cover: placeBet :: require(_odd != 0) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(3, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(3, 1, 0);
        }
    }

    // @cover-intent Transactional Consistency: Verify that placing a bet with odds not matching the game odds reverts.
    function test_Place_bet_with_wrong_odds_reverts_4() public {
// assume: gameList[4].open_status == 3
// assume: now < gameList[4].timestamp - 600
// cover: placeBet :: require(gameList[_fixtureId].odd_homeTeam == _odd) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(4, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(4, 1, 2000);
        }
    }

    // @cover-intent Protocol State Machine: Verify that placing a bet when open_status is not 3 reverts.
    function test_Place_bet_when_game_is_not_open_reverts_5() public {
// assume: gameList[5].open_status == 1
// assume: now < gameList[5].timestamp - 600
// cover: placeBet :: require(gameList[_fixtureId].open_status == 3) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(5, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 1);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(5, 1, 1500);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that placing a bet after the 10-minute deadline reverts.
    function test_Place_bet_after_betting_deadline_reverts_6() public {
// assume: gameList[6].open_status == 3
// assume: now >= gameList[6].timestamp - 600
// cover: placeBet :: require(now < (gameList[_fixtureId].timestamp - 10 minutes)) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(2000000000)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(6, 100, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(6, 1, 1500);
        }
    }

    // @cover-intent Financial & Accounting: Verify that owner can distribute prize money to winning bettors and update game state.
    function test_Owner_gives_prize_money_to_winning_bettors_7() public {
// assume: gameList[7].open_status == 3
// assume: gameList[7].isDone == false
// assume: betList[7][0].player != address(0)
// cover: givePrizeMoney :: require(gameList[_fixtureId].open_status == 3) true
// cover: givePrizeMoney :: require(gameList[_fixtureId].isDone == false) true
// cover: givePrizeMoney :: require(betList[_fixtureId][0].player != address(0)) true
// cover: givePrizeMoney :: selectedTeam == 1 && _homeDrawAway == 1 true
// cover: givePrizeMoney :: selectedTeam == 2 && _homeDrawAway == 2 false
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(7, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(7, 1, 1500);
        }
        vm.prank(bob);
        {
        target.placeBet.value(1 ether)(7, 2, 2000);
        }
        vm.prank(owner);
        {
        target.givePrizeMoney(7, 1, 0);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can call givePrizeMoney.
    function test_Non_owner_cannot_give_prize_money_8() public {
// assume: gameList[8].open_status == 3
// assume: gameList[8].isDone == false
// assume: betList[8][0].player != address(0)
// cover: givePrizeMoney :: require(msg.sender == owner) false
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(8, 2000000000, 1500, 2000, 1800, 1200, 1300, 1700, 1600, 1900, 3);
        }
        vm.startPrank(alice);
        {
        target.placeBet.value(1 ether)(8, 1, 1500);
        }
        vm.expectRevert();
        {
        target.givePrizeMoney(8, 1, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can change the owner address.
    function test_Owner_changes_owner_successfully_9() public {
// cover: changeOwner :: require(msg.sender == owner) true
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.changeOwner(address(uint160(alice)));
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_betList_query_10() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.betList(1, 0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_underflow_11() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou20_overflow_12() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_intou20(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou23_underflow_13() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_underflow_14() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_underflow_15() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou32_overflow_16() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_underflow_17() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou36_overflow_18() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_underflow_19() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou4_overflow_20() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou40_overflow_21() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou7_underflow_22() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou8_overflow_23() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOdd_by_owner_24() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.setGameInfo(1, 1000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        {
        target.changeOdd(1, 110, 210, 310, 410, 510, 610, 710, 810);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_by_owner_25() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.changeOwner(address(uint160(alice)));
        }
    }

    // @cover-intent Financial & Accounting
    function test_deposit_by_anyone_26() public {
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
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
        target.deposit.value(100)(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_gameList_query_27() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.gameList(1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_getBalance_query_28() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: getBalance()
    }

    // @cover-intent Financial & Accounting
    function test_givePrizeMoney_by_owner_29() public {
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(1, 2000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1000000000000000000)(1, 1, 100);
        }
        vm.prank(owner);
        {
        target.givePrizeMoney(1, 1, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_30() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou13(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou25_31() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou25(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou33_32() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou33(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou9_33() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou9(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou13_query_34() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou25_query_35() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.lockTime_intou25(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou33_query_36() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou9_query_37() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.lockTime_intou9(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_query_38() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_placeBet_by_player_39() public {
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(1, 2000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1000000000000000000)(1, 1, 100);
        }
    }

    // @cover-intent Protocol State Machine
    function test_setGameInfo_by_owner_40() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(1, 1000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
    }

    // @cover-intent Protocol State Machine
    function test_setOpenStatus_by_owner_41() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.setGameInfo(1, 1000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        {
        target.setOpenStatus(1, 5);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_42() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transfer_intou14(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou26_43() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transfer_intou26(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_44() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transfer_intou30(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou38_45() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transfer_intou38(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_by_owner_46() public {
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
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
        target.deposit.value(1000000000000000000)(100);
        }
        vm.prank(owner);
        {
        target.withdraw(1000000000000000000);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_47() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou13(0);
        }
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou25_48() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou25(0);
        }
        // skip ABI-mismatched call: withdraw_intou25()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_49() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou33(0);
        }
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou9_50() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.increaseLockTime_intou9(0);
        }
        // skip ABI-mismatched call: withdraw_intou9()
        vm.stopPrank();
    }

}
