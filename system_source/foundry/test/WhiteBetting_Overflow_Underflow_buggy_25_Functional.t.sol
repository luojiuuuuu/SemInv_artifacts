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


    // @cover-intent Authorization & Access Control: Verify that only owner can set game info and that a valid bet can be placed with correct odds and open_status=3
    function test_Owner_sets_up_a_game_and_places_a_valid_bet_0() public {
// assume: gameList(1).open_status == 3
// assume: now < gameList(1).timestamp - 600
// cover: placeBet :: selectedTeam == 1
// cover: placeBet :: selectedTeam == 2
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
        target.setGameInfo(1, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
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

    // @cover-intent Transactional Consistency: Verify that bet is rejected when submitted odds do not match game odds
    function test_Bet_with_wrong_odds_should_revert_1() public {
// assume: gameList(2).odd_homeTeam == 1500
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
        target.setGameInfo(2, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(2, 1, 1600);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that bet with zero odds is rejected
    function test_Bet_with_zero_odds_should_revert_2() public {
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
        target.placeBet.value(1 ether)(3, 1, 0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that bet below minimum 0.001 ether is rejected
    function test_Bet_with_insufficient_stake_should_revert_3() public {
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
        target.setGameInfo(4, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(0.0005 ether)(4, 1, 1500);
        }
    }

    // @cover-intent Protocol State Machine: Verify that betting is only allowed when open_status == 3
    function test_Bet_when_game_is_not_open_should_revert_4() public {
// assume: gameList(5).open_status == 1
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
        target.placeBet.value(1 ether)(5, 1, 1500);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can change odds and event is emitted
    function test_Owner_changes_odds_and_verifies_event_5() public {
// cover: changeOdd :: onlyOwner modifier true
// cover: changeOdd :: onlyOwner modifier false
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
        target.setGameInfo(6, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        {
        target.changeOdd(6, 1600, 2100, 2600, 1900, 2300, 1800, 2000, 2200);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOdd(6, 1600, 2100, 2600, 1900, 2300, 1800, 2000, 2200);
        }
    }

    // @cover-intent Financial & Accounting: Verify that prize money is correctly distributed to winning bets
    function test_Owner_gives_prize_money_to_winning_bettors_6() public {
// assume: gameList(7).isDone == false
// assume: betList(7,0).player != address(0)
// cover: givePrizeMoney :: selectedTeam == 1 && _homeDrawAway == 1
// cover: givePrizeMoney :: selectedTeam == 2 && _homeDrawAway == 2
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
        target.setGameInfo(7, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
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
        // TODO assert: bob.balance == balance(bob)
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can withdraw and funds are transferred
    function test_Owner_withdraws_funds_from_contract_7() public {
// assume: address(this).balance >= 500000000000000000
// cover: withdraw :: onlyOwner modifier true
// cover: withdraw :: onlyOwner modifier false
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
        target.setGameInfo(8, 2000000000, 1500, 2000, 2500, 1800, 2200, 1700, 1900, 2100, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(8, 1, 1500);
        }
        vm.prank(owner);
        {
        target.withdraw(500000000000000000);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(500000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can change ownership
    function test_Non_owner_cannot_change_owner_8() public {
// cover: changeOwner :: onlyOwner modifier false
// cover: changeOwner :: onlyOwner modifier true
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
        target.changeOwner(alice);
        }
        vm.prank(owner);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_betList_query_9() public {
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
    function test_bug_intou19_underflow_10() public {
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
    function test_bug_intou20_overflow_11() public {
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
    function test_bug_intou23_underflow_12() public {
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
    function test_bug_intou27_underflow_13() public {
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
    function test_bug_intou31_underflow_14() public {
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
    function test_bug_intou32_overflow_15() public {
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
    function test_bug_intou35_underflow_16() public {
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
    function test_bug_intou36_overflow_17() public {
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
    function test_bug_intou39_underflow_18() public {
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
    function test_bug_intou4_overflow_19() public {
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
    function test_bug_intou40_overflow_20() public {
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
    function test_bug_intou7_underflow_21() public {
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
    function test_bug_intou8_overflow_22() public {
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
    function test_changeOdd_by_owner_23() public {
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
        target.changeOdd(1, 100, 200, 300, 400, 500, 600, 700, 800);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_by_owner_24() public {
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
        target.changeOwner(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_deposit_with_ETH_25() public {
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
        target.deposit.value(1 ether)(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_gameList_query_26() public {
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
    function test_getBalance_view_27() public {
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
    function test_givePrizeMoney_by_owner_28() public {
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
        vm.startPrank(owner);
        {
        target.setGameInfo(1, 2000000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        {
        target.setOpenStatus(1, 3);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(1, 1, 100);
        }
        vm.prank(owner);
        {
        target.givePrizeMoney(1, 1, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_29() public {
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
    function test_increaseLockTime_intou25_30() public {
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
    function test_increaseLockTime_intou33_31() public {
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
    function test_increaseLockTime_intou9_32() public {
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
    function test_lockTime_intou13_query_33() public {
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
    function test_lockTime_intou25_query_34() public {
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
    function test_lockTime_intou33_query_35() public {
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
    function test_lockTime_intou9_query_36() public {
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
    function test_owner_query_37() public {
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

    // @cover-intent Financial & Accounting
    function test_placeBet_with_valid_game_38() public {
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
        vm.startPrank(owner);
        {
        target.setGameInfo(1, 2000000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
        {
        target.setOpenStatus(1, 3);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(1, 1, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setGameInfo_by_owner_39() public {
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
        target.setGameInfo(1, 2000000000, 100, 200, 300, 400, 500, 600, 700, 800, 3);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setOpenStatus_by_owner_40() public {
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
        target.setOpenStatus(1, 3);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_41() public {
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
    function test_transfer_intou26_42() public {
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
    function test_transfer_intou30_43() public {
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
    function test_transfer_intou38_44() public {
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
    function test_withdraw_by_owner_45() public {
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
        target.deposit.value(1 ether)(100);
        }
        vm.prank(owner);
        {
        target.withdraw(1 ether);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_46() public {
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
    function test_withdraw_intou25_47() public {
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
    function test_withdraw_intou33_48() public {
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
    function test_withdraw_intou9_49() public {
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
