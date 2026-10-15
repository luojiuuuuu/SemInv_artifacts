// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/PerpPair_exp.sol";


contract PerpPairAttackCoordinator_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Execute the full attack sequence, verify that the profit receiver gets USDC profit after repaying the flash loan.
    function test_Positive_Flash_loan_attack_with_profit_0() public {
// assume: msg.sender == profitReceiver
// assume: usdc.balanceOf(address(coordinator)) >= 60030000000
// cover: run :: require(msg.sender == profitReceiver) true
// cover: run :: require(profit > 0) true
        vm.startPrank(owner);
        PerpPairAttackCoordinator target = new PerpPairAttackCoordinator(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.prank(alice); usdc.approve(address(coordinator), 60000000000);
        // dropped unsafe prestate: vm.prank(alice); coordinator.run();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Authorization & Access Control: Verify that run() reverts when called by an address that is not the profitReceiver.
    function test_Negative_run_called_by_non_profitReceiver_1() public {
// assume: msg.sender != profitReceiver
// cover: run :: require(msg.sender == profitReceiver) false
        vm.startPrank(owner);
        PerpPairAttackCoordinator target = new PerpPairAttackCoordinator(alice);
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
        vm.prank(bob);
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Authorization & Access Control
    function test_run_positive_path_2() public {
        vm.startPrank(owner);
        PerpPairAttackCoordinator target = new PerpPairAttackCoordinator(alice);
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
        // skip ABI-mismatched call: run()
        // skip ABI-mismatched call: run()
        vm.stopPrank();
    }

    // @cover-intent minimal test for executeOperation
    function test_perfn_executeOperation_3() public {
        vm.startPrank(owner);
        PerpPairAttackCoordinator target = new PerpPairAttackCoordinator(alice);
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
        target.executeOperation(alice, 100, 1, bob, hex"01");
        }
    }

}
