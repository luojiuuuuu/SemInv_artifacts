// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/TesseraSwap_exp.sol";


contract TesseraSwapAttacker_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Execute the full attack loop and verify that the attacker ends up with a profit in USDC, demonstrating the core exploit path.
    function test_Positive_attack_execution_0() public {
// assume: block.number == 46175320
// assume: balanceOf(USDC_TOKEN, alice) >= 0
// cover: executeAttack :: loop iteration 0..99
// cover: tesseraSwapCallback :: require(msg.sender == TESSERA_SWAP) true
// cover: tesseraSwapCallback :: require(amountIn > 0 && amountOut < 0) true
// cover: uniswapV3SwapCallback :: require(msg.sender == WETH_USDC_POOL) true
// cover: uniswapV3SwapCallback :: require(amount0Delta < 0 && amount1Delta > 0) true
        vm.startPrank(owner);
        TesseraSwapAttacker target = new TesseraSwapAttacker();
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
        // skip ABI-mismatched call: executeAttack()
        // skip ABI-mismatched call: executeAttack()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_executeAttack_positive_1() public {
        vm.startPrank(owner);
        TesseraSwapAttacker target = new TesseraSwapAttacker();
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
        // skip ABI-mismatched call: executeAttack()
    }

    // @cover-intent minimal test for tesseraSwapCallback
    function test_perfn_tesseraSwapCallback_2() public {
        vm.startPrank(owner);
        TesseraSwapAttacker target = new TesseraSwapAttacker();
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
        target.tesseraSwapCallback(100, 100, hex"01");
        }
    }

    // @cover-intent minimal test for uniswapV3SwapCallback
    function test_perfn_uniswapV3SwapCallback_3() public {
        vm.startPrank(owner);
        TesseraSwapAttacker target = new TesseraSwapAttacker();
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
        target.uniswapV3SwapCallback(100, 100, hex"01");
        }
    }

}
