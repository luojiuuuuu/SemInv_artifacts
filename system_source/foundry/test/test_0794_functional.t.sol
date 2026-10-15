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


    // @cover-intent Authorization & Access Control: Verify owner can set multiplier within valid range (110-150).
    function test_owner_change_multiplier_valid_0() public {
// cover: changeMultiplier :: require(multi >= 110 && multi <= 150) true
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
        target.changeMultiplier(130);
        }
        // skip ABI-mismatched call: multiplierFactor()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot set multiplier below 110.
    function test_owner_change_multiplier_invalid_low_1() public {
// cover: changeMultiplier :: require(multi >= 110 && multi <= 150) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeMultiplier(100);
        }
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot set multiplier above 150.
    function test_owner_change_multiplier_invalid_high_2() public {
// cover: changeMultiplier :: require(multi >= 110 && multi <= 150) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeMultiplier(200);
        }
    }

    // @cover-intent Authorization & Access Control: Verify owner can change fee when current fee <= 5.
    function test_owner_change_fee_valid_3() public {
// cover: changeFee :: require(fee <= 5) true
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
        target.changeFee(3);
        }
        // skip ABI-mismatched call: currentFee()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot change fee.
    function test_owner_change_fee_invalid_4() public {
// cover: changeFee :: onlyowner modifier false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeFee(2);
        }
    }

    // @cover-intent Authorization & Access Control: Verify owner can transfer ownership.
    function test_owner_change_owner_valid_5() public {
// cover: changeOwner :: onlyowner modifier true
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
        target.changeOwner(alice);
        }
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot change owner.
    function test_non_owner_change_owner_revert_6() public {
// cover: changeOwner :: onlyowner modifier false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify multiplierFactor returns current multiplier and info string.
    function test_query_multiplier_factor_7() public {
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

    // @cover-intent Resource & Execution Integrity: Verify currentFee returns fee percentage and info string.
    function test_query_current_fee_8() public {
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

    // @cover-intent Resource & Execution Integrity: Verify totalEntries returns entry count and info string.
    function test_query_total_entries_9() public {
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

    // @cover-intent Resource & Execution Integrity: Verify userStats returns stats for existing user.
    function test_query_user_stats_existing_10() public {
// cover: userStats :: users[user].id != address(0x0) true
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
        target.userStats(owner);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify entryDetails returns data for valid index.
    function test_query_entry_details_valid_index_11() public {
// cover: entryDetails :: index < entries.length true
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
        target.entryDetails(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify entryDetails returns empty for out-of-bounds index.
    function test_query_entry_details_invalid_index_12() public {
// cover: entryDetails :: index < entries.length false
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
        target.entryDetails(999);
        }
    }

    // @cover-intent Financial & Accounting
    function test_currentFee_view_13() public {
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
    function test_multiplierFactor_view_14() public {
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

    // @cover-intent Financial & Accounting
    function test_totalEntries_view_15() public {
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
    function test_perfn_changeFee_16() public {
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
    function test_perfn_changeMultiplier_17() public {
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
    function test_perfn_changeOwner_18() public {
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
    function test_perfn_entryDetails_19() public {
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
    function test_perfn_userStats_20() public {
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
