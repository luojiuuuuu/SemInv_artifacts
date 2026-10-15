// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
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


    // @cover-intent Protocol State Machine: Verify that owner can set up a game and a player can place a valid bet when all conditions are met.
    function test_setGameInfo_and_placeBet_positive_0() public {
// assume: gameList[1].open_status == 3
// assume: now < gameList[1].timestamp - 600
// cover: placeBet :: require(stake >= .001 ether) true
// cover: placeBet :: require(_odd != 0) true
// cover: placeBet :: require(gameList[_fixtureId].odd_homeTeam == _odd) true
// cover: placeBet :: require(gameList[_fixtureId].open_status == 3) true
// cover: placeBet :: require(now < (gameList[_fixtureId].timestamp - 10 minutes)) true
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
        target.setGameInfo(1, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.prank(alice);
        {
        target.placeBet(1, 1, 1500);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that a bet with stake below 0.001 ether reverts.
    function test_placeBet_revert_low_stake_1() public {
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
        target.setGameInfo(2, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet(2, 1, 1500);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that a bet with odd value 0 reverts.
    function test_placeBet_revert_invalid_odd_2() public {
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
        target.setGameInfo(3, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet(3, 1, 0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that a bet with mismatched odds reverts.
    function test_placeBet_revert_wrong_odd_3() public {
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
        target.setGameInfo(4, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet(4, 1, 2000);
        }
    }

    // @cover-intent Protocol State Machine: Verify that a bet on a game with open_status != 3 reverts.
    function test_placeBet_revert_closed_game_4() public {
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
        target.setGameInfo(5, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 1);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet(5, 1, 1500);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that a bet placed less than 10 minutes before game start reverts.
    function test_placeBet_revert_too_late_5() public {
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
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(6, 1, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet(6, 1, 1500);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that owner can change odds for an existing game.
    function test_changeOdd_owner_positive_6() public {
// cover: changeOdd :: require(msg.sender == owner) true
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
        target.setGameInfo(7, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        {
        target.changeOdd(7, 1600, 2100, 2600, 1900, 2300, 1800, 2000, 2200);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot change odds.
    function test_changeOdd_non_owner_revert_7() public {
// cover: changeOdd :: require(msg.sender == owner) false
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
        target.setGameInfo(8, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOdd(8, 1600, 2100, 2600, 1900, 2300, 1800, 2000, 2200);
        }
    }

    // @cover-intent Financial & Accounting: Verify that owner can distribute prize money to winning bets and state transitions correctly.
    function test_givePrizeMoney_positive_8() public {
// assume: gameList[9].open_status == 3
// assume: gameList[9].isDone == false
// assume: betList[9][0].player != address(0)
// cover: givePrizeMoney :: require(gameList[_fixtureId].open_status == 3) true
// cover: givePrizeMoney :: require(gameList[_fixtureId].isDone == false) true
// cover: givePrizeMoney :: require(betList[_fixtureId][0].player != address(0)) true
// cover: givePrizeMoney :: selectedTeam == 1 && _homeDrawAway == 1 true
// cover: givePrizeMoney :: selectedTeam == 2 && _homeDrawAway == 2 false
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
        target.setGameInfo(9, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.prank(alice);
        {
        target.placeBet(9, 1, 1500);
        }
        vm.prank(bob);
        {
        target.placeBet(9, 2, 2000);
        }
        vm.prank(owner);
        {
        target.givePrizeMoney(9, 1, 1);
        }
    }

    // @cover-intent Protocol State Machine: Verify that givePrizeMoney reverts if isDone is already true.
    function test_givePrizeMoney_revert_already_paid_9() public {
// assume: gameList[10].isDone == true
// cover: givePrizeMoney :: require(gameList[_fixtureId].isDone == false) false
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
        target.setGameInfo(10, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.prank(alice);
        {
        target.placeBet(10, 1, 1500);
        }
        vm.startPrank(owner);
        {
        target.givePrizeMoney(10, 1, 1);
        }
        vm.expectRevert();
        {
        target.givePrizeMoney(10, 1, 1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can withdraw funds from the contract.
    function test_withdraw_owner_positive_10() public {
// assume: address(this).balance >= 500000000000000000
// cover: withdraw :: require(msg.sender == owner) true
// cover: withdraw :: require(_amount > 0 && _amount <= address(this).balance) true
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
        target.deposit.value(1 ether)(1);
        }
        vm.prank(owner);
        {
        target.withdraw(500000000000000000);
        }
    }

    // @cover-intent Query bet list for a fixture
    function test_betList_query_11() public {
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

    // @cover-intent Execute re-entrant bug function (state transition)
    function test_bug_re_ent13_positive_12() public {
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent Execute re-entrant bug function (state transition)
    function test_bug_re_ent20_positive_13() public {
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
        // skip ABI-mismatched call: bug_re_ent20()
    }

    // @cover-intent Execute re-entrant bug function (state transition)
    function test_bug_re_ent27_positive_14() public {
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent Execute buyTicket with re-entrancy pattern
    function test_buyTicket_re_ent23_positive_15() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent23()
    }

    // @cover-intent Execute buyTicket with re-entrancy pattern
    function test_buyTicket_re_ent30_positive_16() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent30()
    }

    // @cover-intent Execute buyTicket with re-entrancy pattern
    function test_buyTicket_re_ent9_positive_17() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent Execute callme with re-entrancy pattern
    function test_callme_re_ent14_positive_18() public {
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
        // skip ABI-mismatched call: callme_re_ent14()
    }

    // @cover-intent Execute callme with re-entrancy pattern
    function test_callme_re_ent35_positive_19() public {
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
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent Execute callme with re-entrancy pattern
    function test_callme_re_ent7_positive_20() public {
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
        // skip ABI-mismatched call: callme_re_ent7()
    }

    // @cover-intent Authorization & Access Control: onlyOwner can change odds
    function test_changeOdd_by_owner_21() public {
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

    // @cover-intent Authorization & Access Control: onlyOwner can change owner
    function test_changeOwner_by_owner_22() public {
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
        target.changeOwner(address(uint160(bob)));
        }
    }

    // @cover-intent Claim reward with re-entrancy pattern
    function test_claimReward_re_ent25_positive_23() public {
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
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent Claim reward with re-entrancy pattern
    function test_claimReward_re_ent32_positive_24() public {
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
        // skip ABI-mismatched call: claimReward_re_ent32()
    }

    // @cover-intent Claim reward with re-entrancy pattern
    function test_claimReward_re_ent39_positive_25() public {
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Claim reward with re-entrancy pattern
    function test_claimReward_re_ent4_positive_26() public {
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
        // skip ABI-mismatched call: claimReward_re_ent4()
    }

    // @cover-intent Financial & Accounting: deposit emits event
    function test_deposit_by_anyone_27() public {
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

    // @cover-intent Query game info for a fixture
    function test_gameList_query_28() public {
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

    // @cover-intent Query contract balance
    function test_getBalance_query_29() public {
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

    // @cover-intent Financial & Accounting: owner distributes prizes
    function test_givePrizeMoney_by_owner_30() public {
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
        target.setGameInfo(1, 1000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
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

    // @cover-intent Query contract owner
    function test_owner_query_31() public {
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

    // @cover-intent Financial & Accounting: place a bet with correct odds
    function test_placeBet_by_alice_32() public {
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
        target.setGameInfo(1, 1000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1000000000000000000)(1, 1, 100);
        }
    }

    // @cover-intent Protocol State Machine: owner sets game info
    function test_setGameInfo_by_owner_33() public {
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

    // @cover-intent Protocol State Machine: owner sets open status
    function test_setOpenStatus_by_owner_34() public {
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

    // @cover-intent Financial & Accounting: owner withdraws funds
    function test_withdraw_by_owner_35() public {
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
        vm.prank(owner);
        {
        target.withdraw(50);
        }
    }

    // @cover-intent Withdraw balance with re-entrancy pattern
    function test_withdrawBalance_re_ent19_positive_36() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent Withdraw balance with re-entrancy pattern
    function test_withdrawBalance_re_ent26_positive_37() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent Withdraw balance with re-entrancy pattern
    function test_withdrawBalance_re_ent33_positive_38() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Withdraw balance with re-entrancy pattern
    function test_withdrawBalance_re_ent40_positive_39() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent Withdraw funds with re-entrancy pattern
    function test_withdrawFunds_re_ent31_positive_40() public {
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
        target.withdrawFunds_re_ent31(0);
        }
    }

    // @cover-intent Withdraw funds with re-entrancy pattern
    function test_withdrawFunds_re_ent38_positive_41() public {
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
        target.withdrawFunds_re_ent38(0);
        }
    }

    // @cover-intent Withdraw balances with re-entrancy pattern
    function test_withdraw_balances_re_ent36_positive_42() public {
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent Withdraw balances with re-entrancy pattern
    function test_withdraw_balances_re_ent8_positive_43() public {
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
        // skip ABI-mismatched call: withdraw_balances_re_ent8()
    }

}
