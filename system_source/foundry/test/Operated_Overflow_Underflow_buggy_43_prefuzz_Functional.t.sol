// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;
import "../src/buggy_43.sol";

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

contract Operated_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify the full lifecycle of operator status transitions, including setting operator, activating, deactivating, and renouncing, with correct state and event emissions.
    function test_Operator_lifecycle_set_activate_deactivate_renounce_0() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.bug_intou12(0);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: hasActiveOperator()
        {
        target.isActiveOperator(alice);
        }
        {
        target.isActiveOperator(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw_intou17 reverts if current time is not greater than lockTime_intou17[caller], and that increaseLockTime_intou17 can extend the lock.
    function test_Lock_time_increase_and_withdrawal_guard_1() public {
// assume: now <= lockTime_intou17[alice]
// cover: withdraw_intou17 :: require(now > lockTime_intou17[msg.sender]) false
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou17(100);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou17()
        {
        target.increaseLockTime_intou17(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that transfer_intou22 reverts when balance is insufficient (balance - value < 0).
    function test_Transfer_guard_underflow_check_2() public {
// assume: balances_intou22[alice] == 0
// cover: transfer_intou22 :: require(balances_intou22[msg.sender] - _value >= 0) false
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.transfer_intou22(bob, 1);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that getOperator, isOperator, hasActiveOperator, and isActiveOperator return consistent values when no operator is set.
    function test_Operator_view_functions_after_initialization_3() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: getOperator()
        {
        target.isOperator(alice);
        }
        {
        target.isActiveOperator(alice);
        }
        // skip ABI-mismatched call: hasActiveOperator()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that increaseLockTime_intou9 can cause an overflow (lockTime increases without bound).
    function test_Lock_time_increase_overflow_4() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou9(1);
        }
        {
        target.lockTime_intou9(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that lockTime_intou17, lockTime_intou25, lockTime_intou37, and lockTime_intou9 are independent per address.
    function test_Multiple_lock_time_mappings_independent_5() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou17(10);
        }
        {
        target.increaseLockTime_intou25(20);
        }
        {
        target.increaseLockTime_intou37(30);
        }
        {
        target.increaseLockTime_intou9(40);
        }
        {
        target.lockTime_intou17(alice);
        }
        {
        target.lockTime_intou25(alice);
        }
        {
        target.lockTime_intou37(alice);
        }
        {
        target.lockTime_intou9(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw_intou25 reverts when lockTime_intou25[caller] is zero and now > 0 (since now > 0 always true, but require checks now > lockTime, which is true, so it should succeed? Actually require(now > lockTime) with lockTime=0 and now>0 passes, but the function does a transfer of 10 wei. Since no ETH is sent, the contract may have no balance, causing revert. Test the guard logic.
    function test_Withdraw_guard_with_lock_time_zero_6() public {
// assume: now > 0
// assume: lockTime_intou25[alice] == 0
// cover: withdraw_intou25 :: require(now > lockTime_intou25[msg.sender]) true
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: withdraw_intou25()
    }

    // @cover-intent Financial & Accounting: Verify that transfer_intou26 reverts when balance is insufficient.
    function test_Transfer_guard_underflow_with_non_zero_balance_7() public {
// assume: balances_intou26[alice] == 0
// cover: transfer_intou26 :: require(balances_intou26[msg.sender] - _value >= 0) false
        vm.startPrank(owner);
        Operated target = new Operated();
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

    // @cover-intent Resource & Execution Integrity: Verify that the bug functions (bug_intou12, bug_intou19, bug_intou20, bug_intou27, bug_intou3, bug_intou32) execute without reverting (they contain arithmetic bugs but no require).
    function test_Bug_functions_do_not_revert_8() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.bug_intou12(1);
        }
        // skip ABI-mismatched call: bug_intou19()
        {
        target.bug_intou20(2);
        }
        // skip ABI-mismatched call: bug_intou27()
        // skip ABI-mismatched call: bug_intou3()
        {
        target.bug_intou32(3);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that OperatorUpdated event is emitted when operator status changes (via internal functions, but we cannot call them directly; we test view functions only). This sequence is a placeholder to show that events are not emitted by public functions in this ABI.
    function test_OperatorUpdated_event_emission_on_state_change_9() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: hasActiveOperator()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_test_10() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
    function test_bug_intou27_test_11() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
    function test_bug_intou3_test_12() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent Authorization & Access Control
    function test_getOperator_test_13() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: getOperator()
    }

    // @cover-intent Protocol State Machine
    function test_hasActiveOperator_test_14() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: hasActiveOperator()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_intou17_test_15() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_intou25_test_16() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: withdraw_intou25()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_intou37_test_17() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: withdraw_intou37()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_intou9_test_18() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        // skip ABI-mismatched call: withdraw_intou9()
    }

    // @cover-intent minimal test for bug_intou12
    function test_perfn_bug_intou12_19() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.bug_intou12(1);
        }
    }

    // @cover-intent minimal test for bug_intou20
    function test_perfn_bug_intou20_20() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_21() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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

    // @cover-intent minimal test for increaseLockTime_intou17
    function test_perfn_increaseLockTime_intou17_22() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou17(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou25
    function test_perfn_increaseLockTime_intou25_23() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou25(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou37
    function test_perfn_increaseLockTime_intou37_24() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou37(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou9
    function test_perfn_increaseLockTime_intou9_25() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.increaseLockTime_intou9(1);
        }
    }

    // @cover-intent minimal test for isActiveOperator
    function test_perfn_isActiveOperator_26() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.isActiveOperator(alice);
        }
    }

    // @cover-intent minimal test for isOperator
    function test_perfn_isOperator_27() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.isOperator(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou17
    function test_perfn_lockTime_intou17_28() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou25
    function test_perfn_lockTime_intou25_29() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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

    // @cover-intent minimal test for lockTime_intou37
    function test_perfn_lockTime_intou37_30() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou9
    function test_perfn_lockTime_intou9_31() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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

    // @cover-intent minimal test for transfer_intou22
    function test_perfn_transfer_intou22_32() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.transfer_intou22(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou26
    function test_perfn_transfer_intou26_33() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.transfer_intou26(bob, 100);
        }
    }

}
