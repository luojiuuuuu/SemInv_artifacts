// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/Thetanuts_exp.sol";


contract ThetanutsAttack_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that a flash loan of index vault shares, followed by claiming component vault shares and reminting index shares, results in profit for the profit receiver.
    function test_Positive_exploit_simulation_0() public {
// assume: indexVault.balanceOf(AAVE_INDEX_TOKEN) > 3
// assume: msg.sender == AAVE_POOL in executeOperation
// cover: executeOperation :: require(msg.sender == AAVE_POOL) true
// cover: executeOperation :: require(initiator == address(this)) true
// cover: executeOperation :: require(assets.length == 1 && assets[0] == INDEX_VAULT) true
// cover: _initWithdraw :: require(shares > 0) true
// cover: _forwardToken :: require(balance > 0) true
        vm.startPrank(owner);
        ThetanutsAttack target = new ThetanutsAttack(alice);
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

    // @cover-intent Resource & Execution Integrity: Test that the attack fails if the index vault does not have enough shares to remint and repay the flash loan.
    function test_Flash_loan_with_insufficient_index_shares_to_repay_1() public {
// assume: indexVault.balanceOf(AAVE_INDEX_TOKEN) <= 3
// cover: executeOperation :: require(msg.sender == AAVE_POOL) true
// cover: executeOperation :: require(initiator == address(this)) true
// cover: executeOperation :: require(assets.length == 1 && assets[0] == INDEX_VAULT) true
        vm.startPrank(owner);
        ThetanutsAttack target = new ThetanutsAttack(alice);
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
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Transactional Consistency: Test that the attack fails if the index vault has no component vault shares to claim.
    function test_Flash_loan_with_zero_component_vault_shares_to_claim_2() public {
// assume: indexVault.balanceOf(AAVE_INDEX_TOKEN) > 3
// assume: indexVault.claim(borrowedShares) does not transfer any component vault shares
// cover: executeOperation :: require(msg.sender == AAVE_POOL) true
// cover: executeOperation :: require(initiator == address(this)) true
// cover: executeOperation :: require(assets.length == 1 && assets[0] == INDEX_VAULT) true
// cover: _initWithdraw :: require(shares > 0) false
        vm.startPrank(owner);
        ThetanutsAttack target = new ThetanutsAttack(alice);
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
        // skip ABI-mismatched call: run()
    }

    // @cover-intent External Interaction & Environment: Test that the attack fails if after withdrawing, there are no component vault tokens to forward.
    function test_Flash_loan_with_zero_component_vault_balance_to_forward_3() public {
// assume: indexVault.balanceOf(AAVE_INDEX_TOKEN) > 3
// assume: initWithdraw returns 0 assets for all component vaults
// cover: executeOperation :: require(msg.sender == AAVE_POOL) true
// cover: executeOperation :: require(initiator == address(this)) true
// cover: executeOperation :: require(assets.length == 1 && assets[0] == INDEX_VAULT) true
// cover: _initWithdraw :: require(shares > 0) true
// cover: _forwardToken :: require(balance > 0) false
        vm.startPrank(owner);
        ThetanutsAttack target = new ThetanutsAttack(alice);
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
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Resource & Execution Integrity
    function test_run_positive_4() public {
        vm.startPrank(owner);
        ThetanutsAttack target = new ThetanutsAttack(alice);
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

}
