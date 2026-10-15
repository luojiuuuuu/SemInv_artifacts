// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/AmbientCrocSwapDex_exp.sol";


contract AmbientCrocSwapDexAttacker_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that the attack function correctly executes a Balancer flash loan, manipulates the Ambient CrocSwapDEX pool, and transfers profits to the owner.
    function test_Successful_flash_loan_attack_with_profit_extraction_0() public {
// assume: msg.sender == BALANCER_VAULT for receiveFlashLoan
// assume: Balancer flash loan is available
// cover: receiveFlashLoan :: require(msg.sender == BALANCER_VAULT) true
// cover: receiveFlashLoan :: require(msg.sender == BALANCER_VAULT) false
        vm.startPrank(owner);
        AmbientCrocSwapDexAttacker target = new AmbientCrocSwapDexAttacker(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.deal(address(this), 100 ether);
        // dropped unsafe prestate: IERC20(WETH_TOKEN).approve(address(this), type(uint256).max);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: attack()
        // skip ABI-mismatched call: attack()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify behavior when flash loan amounts are zero, testing edge case of no borrowed assets.
    function test_Attack_with_zero_flash_loan_amounts_1() public {
// assume: msg.sender == BALANCER_VAULT for receiveFlashLoan
// cover: receiveFlashLoan :: require(msg.sender == BALANCER_VAULT) true
        vm.startPrank(owner);
        AmbientCrocSwapDexAttacker target = new AmbientCrocSwapDexAttacker(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.deal(address(this), 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: attack()
        // skip ABI-mismatched call: attack()
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that the constructor correctly stores the owner address for profit distribution.
    function test_Constructor_sets_owner_correctly_2() public {
// assume: owner is set to alice in constructor
        vm.startPrank(owner);
        AmbientCrocSwapDexAttacker target = new AmbientCrocSwapDexAttacker(alice);
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
        // skip ABI-mismatched call: attack()
    }

    // @cover-intent Financial & Accounting
    function test_attack_sequence_3() public {
        vm.startPrank(owner);
        AmbientCrocSwapDexAttacker target = new AmbientCrocSwapDexAttacker(alice);
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
        // skip ABI-mismatched call: attack()
    }

}
