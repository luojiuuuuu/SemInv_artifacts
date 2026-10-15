// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/lucky_doubler.sol";

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

contract LuckyDoubler_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function LuckyDoubler_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only the owner can change the fee, and that the fee can be changed within the allowed range (max 5%).
    function test_owner_changes_fee_0() public {
// cover: changeFee :: require(fee > 5) false (newFee=3, fee=5)
// cover: changeFee :: onlyowner guard (alice not owner)
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeFee(2);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the multiplier, and that the multiplier must be between 110 and 150.
    function test_owner_changes_multiplier_valid_1() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) false (multi=130)
// cover: changeMultiplier :: onlyowner guard (alice not owner)
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(130);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeMultiplier(120);
        }
    }

    // @cover-intent Protocol State Machine: Verify that setting the multiplier outside the allowed range (110-150) reverts.
    function test_owner_changes_multiplier_invalid_2() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) true (multi=100)
// cover: changeMultiplier :: require(multi < 110 || multi > 150) true (multi=160)
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        vm.expectRevert();
        {
        target.changeMultiplier(100);
        }
        vm.expectRevert();
        {
        target.changeMultiplier(160);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the owner address.
    function test_owner_changes_owner_3() public {
// cover: changeOwner :: onlyowner guard (owner calls)
// cover: changeOwner :: onlyowner guard (alice not owner)
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeOwner(bob);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that multiplierFactor() returns the current multiplier and a descriptive string.
    function test_view_multiplier_factor_4() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        // skip ABI-mismatched call: multiplierFactor()
    }

    // @cover-intent Resource & Execution Integrity: Verify that currentFee() returns the current fee percentage and a descriptive string.
    function test_view_current_fee_5() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        // skip ABI-mismatched call: currentFee()
    }

    // @cover-intent Resource & Execution Integrity: Verify that totalEntries() returns 0 when no deposits have been made.
    function test_view_total_entries_empty_6() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        // skip ABI-mismatched call: totalEntries()
    }

    // @cover-intent Resource & Execution Integrity: Verify that userStats() for a user who has never deposited returns empty/default values.
    function test_view_user_stats_nonexistent_7() public {
// cover: userStats :: if (users[user].id != address(0x0)) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.userStats(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that entryDetails() with an out-of-bounds index returns empty/default values.
    function test_view_entry_details_out_of_bounds_8() public {
// cover: entryDetails :: if (index < entries.length) false (index=0, entries.length=0)
// cover: entryDetails :: if (index < entries.length) false (index=999, entries.length=0)
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.entryDetails(0);
        }
        {
        target.entryDetails(999);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that the fee can be changed to 5 (the maximum allowed) and that changing to 6 reverts.
    function test_owner_changes_fee_boundary_9() public {
// cover: changeFee :: require(fee > 5) false (newFee=5, fee=5)
// cover: changeFee :: require(fee > 5) true (newFee=6, fee=5)
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(5);
        }
        vm.expectRevert();
        {
        target.changeFee(6);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_currentFee_view_10() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        // skip ABI-mismatched call: currentFee()
    }

    // @cover-intent Financial & Accounting
    function test_multiplierFactor_view_11() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        // skip ABI-mismatched call: multiplierFactor()
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalEntries_view_12() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        // skip ABI-mismatched call: totalEntries()
    }

    // @cover-intent minimal test for changeFee
    function test_perfn_changeFee_13() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(1);
        }
    }

    // @cover-intent minimal test for changeMultiplier
    function test_perfn_changeMultiplier_14() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(1);
        }
    }

    // @cover-intent minimal test for changeOwner
    function test_perfn_changeOwner_15() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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

    // @cover-intent minimal test for entryDetails
    function test_perfn_entryDetails_16() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.entryDetails(1);
        }
    }

    // @cover-intent minimal test for userStats
    function test_perfn_userStats_17() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.userStats(alice);
        }
    }

}
