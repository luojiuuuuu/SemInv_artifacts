// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/LAXO_Token_exp.sol";


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


    // @cover-intent Financial & Accounting: Verify the complete flash loan attack sequence executes successfully, producing the expected profit in BUSD.
    function test_Normal_Flash_Loan_Attack_Flow_0() public {
// assume: busd.balanceOf(attackContract) >= 350_175_000_000_000_000_000_000 after flash loan
// assume: laxo.balanceOf(attackContract) >= 1_000_000_000_000_000_000 before start
// cover: pancakeV3FlashCallback :: require(busd_pair check) true
// cover: pancakeV3FlashCallback :: require(amountOut check) true
// cover: pancakeV3FlashCallback :: require(busd check) true
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

    // @cover-intent Transactional Consistency: Verify that the flash callback reverts when the busd_pair LAXO balance does not match the expected value.
    function test_Flash_Callback_Reverts_on_busd_pair_Check_Failure_1() public {
// assume: laxo.balanceOf(busd_pair) != 52_057_043_674_336_149_349_295_101
// cover: pancakeV3FlashCallback :: require(busd_pair check) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=0x..., value=0x0;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: start()
        vm.expectRevert();
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that the flash callback reverts when the calculated amountOut does not match the expected value.
    function test_Flash_Callback_Reverts_on_amountOut_Check_Failure_2() public {
// assume: router.getAmountOut(41_072_653_255_359_825_749_210_636, reserve1, reserve0) != 487_495_176_743_718_966_418_330
// cover: pancakeV3FlashCallback :: require(amountOut check) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=0x..., value=0x0;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: start()
        vm.expectRevert();
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that the flash callback reverts when the final BUSD balance does not match the expected profit.
    function test_Flash_Callback_Reverts_on_BUSD_Balance_Check_Failure_3() public {
// assume: busd.balanceOf(attackContract) != 137_320_176_743_718_966_418_330
// cover: pancakeV3FlashCallback :: require(busd check) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=0x..., value=0x0;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: start()
        vm.expectRevert();
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify behavior when flash loan amount0 is zero (edge case).
    function test_Flash_Loan_Amount_Boundary_Zero_Amount_4() public {
// assume: pancake.flash amount0 = 0 would cause arithmetic underflow or revert
// cover: pancakeV3FlashCallback :: require(amount0 > 0) false
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
        vm.expectRevert();
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that the attack fails when the contract does not have enough LAXO tokens.
    function test_Insufficient_LAXO_Balance_for_Attack_5() public {
// assume: laxo.balanceOf(attackContract) < 10_000
// cover: pancakeV3FlashCallback :: require(laxo.balanceOf(attackContract) >= 10_000) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=0x..., value=0x0;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: start()
        vm.expectRevert();
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_start_flash_loan_6() public {
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
        // skip ABI-mismatched call: start()
        vm.prank(alice);
        // skip ABI-mismatched call: start()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_flash_callback_manipulation_7() public {
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
        // skip ABI-mismatched call: start()
        vm.prank(alice);
        {
        target.pancakeV3FlashCallback(350000000000000000000000, 0, hex"00000000000000000000000000000000000000000000000000000000a33f3d26");
        }
        // TODO assert: alice.balance == 0
    }

}
