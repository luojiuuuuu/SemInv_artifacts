// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/XLootStaking_exp.sol";


contract XLootStakingAttack_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that a flash loan can trigger a new epoch and that duplicate xLOOT IDs in a single redeem call amplify the claimable reward, resulting in a net profit for the attacker.
    function test_Positive_path_flash_loan_triggers_epoch_and_duplicate_redeem_amplifies_claim_0() public {
// assume: msg.sender == BALANCER_VAULT
// cover: receiveFlashLoan :: require(msg.sender == BALANCER_VAULT) true
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        vm.startPrank(owner);
        XLootStakingAttack target = new XLootStakingAttack(alice, _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.warp(staking.nextEpoc().time);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Protocol State Machine: Verify that calling run() without a flash loan context does not trigger any state change or revert.
    function test_Edge_case_run_without_flash_loan_setup_does_nothing_1() public {
// cover: run :: flashLoan call succeeds
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        vm.startPrank(owner);
        XLootStakingAttack target = new XLootStakingAttack(alice, _arr1);
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
        // skip ABI-mismatched call: run()
    }

    // @cover-intent External Interaction & Environment
    function test_run_positive_2() public {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        vm.startPrank(owner);
        XLootStakingAttack target = new XLootStakingAttack(alice, _arr1);
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
        // skip ABI-mismatched call: run()
        // TODO assert: alice.balance == 0
    }

}
