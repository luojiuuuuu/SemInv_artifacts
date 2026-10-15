// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/AztecEscapeHatch_exp.sol";


contract AztecEscapeHatch_exp_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that a forged proof can drain ETH from the Aztec rollup, breaking the value-conservation invariant by transferring pooled ETH to an attacker address with no matching deposit.
    function test_ETH_escape_hatch_exploit_0() public {
// assume: ATTACKER.balance >= 0
// assume: ROLLUP.balance >= 1000 ether
// cover: testExploit_ETH :: assertGt(ATTACKER.balance - before, 1000 ether) true
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork("mainnet", 25_339_093);
        // dropped unsafe prestate: vm.label(ATTACKER, "Attacker");
        // dropped unsafe prestate: vm.label(ROLLUP, "AztecRollup");
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: testExploit_ETH()
        // skip ABI-mismatched call: testExploit_ETH()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that a forged proof can drain DAI tokens from the Aztec rollup, breaking the token-conservation invariant by transferring pooled DAI to an attacker address with no matching deposit.
    function test_DAI_escape_hatch_exploit_1() public {
// assume: IERC20(DAI).balanceOf(ATTACKER) >= 0
// assume: IERC20(DAI).balanceOf(ROLLUP) >= 100000e18
// cover: testExploit_DAI :: assertGt(IERC20(DAI).balanceOf(ATTACKER) - before, 100_000e18) true
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork("mainnet", 25_339_168);
        // dropped unsafe prestate: vm.label(ATTACKER, "Attacker");
        // dropped unsafe prestate: vm.label(ROLLUP, "AztecRollup");
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: testExploit_DAI()
        // skip ABI-mismatched call: testExploit_DAI()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that a forged proof can drain renBTC tokens from the Aztec rollup, breaking the token-conservation invariant by transferring pooled renBTC to an attacker address with no matching deposit.
    function test_renBTC_escape_hatch_exploit_2() public {
// assume: IERC20(RENBTC).balanceOf(ATTACKER) >= 0
// assume: IERC20(RENBTC).balanceOf(ROLLUP) >= 0.4e8
// cover: testExploit_renBTC :: assertGt(IERC20(RENBTC).balanceOf(ATTACKER) - before, 0.4e8) true
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork("mainnet", 25_339_171);
        // dropped unsafe prestate: vm.label(ATTACKER, "Attacker");
        // dropped unsafe prestate: vm.label(ROLLUP, "AztecRollup");
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: testExploit_renBTC()
        // skip ABI-mismatched call: testExploit_renBTC()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_IS_TEST_view_3() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: IS_TEST()
    }

    // @cover-intent Resource & Execution Integrity
    function test_excludeArtifacts_view_4() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: excludeArtifacts()
    }

    // @cover-intent Resource & Execution Integrity
    function test_excludeContracts_view_5() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: excludeContracts()
    }

    // @cover-intent Resource & Execution Integrity
    function test_excludeSelectors_view_6() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: excludeSelectors()
    }

    // @cover-intent Resource & Execution Integrity
    function test_excludeSenders_view_7() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: excludeSenders()
    }

    // @cover-intent Protocol State Machine
    function test_failed_view_8() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: failed()
    }

    // @cover-intent Resource & Execution Integrity
    function test_targetArtifactSelectors_view_9() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: targetArtifactSelectors()
    }

    // @cover-intent Resource & Execution Integrity
    function test_targetArtifacts_view_10() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: targetArtifacts()
    }

    // @cover-intent Resource & Execution Integrity
    function test_targetContracts_view_11() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: targetContracts()
    }

    // @cover-intent Resource & Execution Integrity
    function test_targetInterfaces_view_12() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: targetInterfaces()
    }

    // @cover-intent Resource & Execution Integrity
    function test_targetSelectors_view_13() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: targetSelectors()
    }

    // @cover-intent Resource & Execution Integrity
    function test_targetSenders_view_14() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: targetSenders()
    }

    // @cover-intent Financial & Accounting
    function test_testExploit_DAI_exploit_15() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: testExploit_DAI()
    }

    // @cover-intent Financial & Accounting
    function test_testExploit_ETH_exploit_16() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: testExploit_ETH()
    }

    // @cover-intent Financial & Accounting
    function test_testExploit_renBTC_exploit_17() public {
        vm.startPrank(owner);
        AztecEscapeHatch_exp target = new AztecEscapeHatch_exp();
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
        // skip ABI-mismatched call: testExploit_renBTC()
    }

}
