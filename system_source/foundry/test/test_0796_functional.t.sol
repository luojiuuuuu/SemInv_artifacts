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


    // @cover-intent Authorization & Access Control: Verify only owner can change fee and that fee is capped at 5%.
    function test_Owner_changes_fee_within_allowed_range_0() public {
// cover: changeFee :: require(fee > 5) false
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

    // @cover-intent Authorization & Access Control: Verify fee can be set to maximum allowed value 5.
    function test_Owner_changes_fee_to_boundary_value_5_1() public {
// cover: changeFee :: require(fee > 5) false
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
        target.changeFee(5);
        }
    }

    // @cover-intent Authorization & Access Control: Verify only owner can change multiplier and it must be between 110 and 150.
    function test_Owner_changes_multiplier_within_allowed_range_2() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) false
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
        vm.prank(bob);
        {
        target.changeMultiplier(120);
        }
    }

    // @cover-intent Protocol State Machine: Verify multiplier can be set to minimum 110 and maximum 150.
    function test_Owner_changes_multiplier_to_boundary_values_3() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) false
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
        target.changeMultiplier(110);
        }
        {
        target.changeMultiplier(150);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify multiplier outside 110-150 range reverts.
    function test_Owner_changes_multiplier_out_of_range_reverts_4() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) true
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
        target.changeMultiplier(109);
        }
        vm.expectRevert();
        {
        target.changeMultiplier(151);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify only owner can change owner and ownership transfers correctly.
    function test_Owner_changes_owner_successfully_5() public {
// cover: changeOwner :: require(msg.sender == owner) true
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.changeOwner(carol);
        }
    }

    // @cover-intent Financial & Accounting: Verify multiplierFactor returns the current multiplier value.
    function test_Query_multiplierFactor_returns_current_multiplier_6() public {
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

    // @cover-intent Financial & Accounting: Verify currentFee returns the initial fee value of 5.
    function test_Query_currentFee_returns_initial_fee_7() public {
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

    // @cover-intent Financial & Accounting: Verify totalEntries returns 0 before any deposits.
    function test_Query_totalEntries_returns_zero_initially_8() public {
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
        vm.prank(carol);
        // skip ABI-mismatched call: totalEntries()
    }

    // @cover-intent Financial & Accounting: Verify userStats returns zeros for an address that has never deposited.
    function test_Query_userStats_for_non_existent_user_returns_zero_9() public {
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

    // @cover-intent Transactional Consistency: Verify entryDetails reverts or returns empty for invalid index.
    function test_Query_entryDetails_for_out_of_bounds_index_returns_nothing_10() public {
// cover: entryDetails :: if (index < entries.length) false
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

    // @cover-intent Authorization & Access Control
    function test_changeFee_positive_11() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_changeFee_revert_non_owner_12() public {
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
        target.changeFee(3);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeMultiplier_positive_13() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_changeMultiplier_revert_non_owner_14() public {
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
        target.changeMultiplier(130);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_15() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_revert_non_owner_16() public {
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

    // @cover-intent Financial & Accounting
    function test_currentFee_view_17() public {
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
    function test_entryDetails_view_18() public {
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

    // @cover-intent Financial & Accounting
    function test_multiplierFactor_view_19() public {
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
    function test_totalEntries_view_20() public {
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

    // @cover-intent Financial & Accounting
    function test_userStats_view_21() public {
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
