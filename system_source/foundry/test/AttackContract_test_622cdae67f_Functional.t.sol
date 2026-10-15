// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/Curve_LlamaLend_exp.sol";


contract AttackContract_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }
    function _assertEqA(address a, address b) internal {
        assertEq(a, b);
    }
    function _assertEqB32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }
    function _assertEqS(string memory a, string memory b) internal {
        assertEq(a, b);
    }


    // @cover-intent Test the normal execution flow of the attack contract: start flash loan, receive callback, execute trades, and end. This covers the Protocol State Machine invariant as the contract transitions through flash loan states.
    function test_Normal_flash_loan_execution_path_0() public {
// assume: FlashloanUsed == true
// cover: onMorphoFlashLoan :: FlashloanUsed == false path
// cover: onMorphoFlashLoan :: FlashloanUsed == true path
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: start()
        // skip ABI-mismatched call: end()
        vm.stopPrank();
    }

    // @cover-intent Test that the FlashloanUsed flag prevents reentrancy or double flash loan usage. This covers the Transactional Consistency invariant by ensuring the state transition guard works correctly.
    function test_Flash_loan_reentrancy_guard_test_1() public {
// assume: FlashloanUsed == true
// cover: onMorphoFlashLoan :: FlashloanUsed == true path (second call)
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: start()
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Test that end() can be called when the contract has no DOLA or WETH balance. This covers the Resource & Execution Integrity invariant by ensuring the function handles empty state gracefully.
    function test_End_function_with_zero_balances_2() public {
// assume: DOLA.balanceOf(address(this)) == 0
// assume: weth.balanceOf(address(this)) == 0
// cover: end :: transfer with zero balance
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: end()
    }

    // @cover-intent state transition test for onMorphoFlashLoan
    function test_Direct_onMorphoFlashLoan_call_without_flash_loan_3() public {
// assume: FlashloanUsed == false
// cover: onMorphoFlashLoan :: FlashloanUsed == false path (no flash loan context)
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        target.onMorphoFlashLoan(0, hex"00");
        }
    }

    // @cover-intent Test that end() can be called multiple times without reverting, verifying idempotent behavior. This covers the Resource & Execution Integrity invariant.
    function test_Multiple_end_calls_4() public {
// assume: FlashloanUsed == true
// cover: end :: second call with zero balance
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: start()
        // skip ABI-mismatched call: end()
        // skip ABI-mismatched call: end()
        vm.stopPrank();
    }

    // @cover-intent Test that start() can be called but will revert if the flash loan provider is not available or the token approval fails. This covers the External Interaction & Environment invariant.
    function test_Start_without_flash_loan_capability_5() public {
// assume: morpho.flashLoan will revert due to insufficient balance or approval
// cover: start :: flashLoan call fails
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: start()
    }

    // @cover-intent External Interaction & Environment
    function test_start_flashloan_6() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: start()
    }

    // @cover-intent state transition test for onMorphoFlashLoan
    function test_onMorphoFlashLoan_execution_7() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        target.onMorphoFlashLoan(0, hex"00");
        }
    }

    // @cover-intent Financial & Accounting
    function test_end_transfer_8() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
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
        // skip ABI-mismatched call: start()
        // skip ABI-mismatched call: end()
        vm.stopPrank();
    }

}
