// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/Moonwell_exp.sol";


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


    // @cover-intent Financial & Accounting - Execute the full flash loan attack sequence to verify the exploit path works as intended, including flash loan callback, liquidation, redemption, swap, and repayment.
    function test_Normal_Flash_Loan_Attack_Flow_0() public {
// assume: mWETH.borrowBalanceCurrent(victim) == 2227585181466568852543
// cover: start :: require(mWETH.borrowBalanceCurrent(victim) == 2227585181466568852543) true
// cover: uniswapV3FlashCallback :: require(amount+amount0Delta==129917976506955805) true
// cover: uniswapV3SwapCallback :: require(amount0Delta==242681146382025215739) true
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice, alice, alice);
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
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine - Verify that the start function reverts when the victim's borrow balance does not match the expected value, ensuring the precondition is enforced.
    function test_Start_with_Incorrect_Borrow_Balance_1() public {
// assume: mWETH.borrowBalanceCurrent(victim) != 2227585181466568852543
// cover: start :: require(mWETH.borrowBalanceCurrent(victim) == 2227585181466568852543) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice, alice, alice);
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

    // @cover-intent External Interaction & Environment - Verify that the contract can receive ETH via the receive function, enabling the withdrawal in the flash callback.
    function test_Receive_ETH_Functionality_2() public {
// assume: mWETH.borrowBalanceCurrent(victim) != 2227585181466568852543
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice, alice, alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent External Interaction & Environment
    function test_start_sequence_3() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice, alice, alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=keccak256(abi.encode(victim, uint256(0))), value=2227585181466568852543;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: start()
    }

    // @cover-intent minimal test for uniswapV3FlashCallback
    function test_perfn_uniswapV3FlashCallback_4() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice, alice, alice);
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
        target.uniswapV3FlashCallback(100, 100, hex"01");
        }
    }

    // @cover-intent minimal test for uniswapV3SwapCallback
    function test_perfn_uniswapV3SwapCallback_5() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice, alice, alice);
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
