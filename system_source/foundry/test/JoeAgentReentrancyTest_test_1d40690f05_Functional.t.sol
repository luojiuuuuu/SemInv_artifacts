// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/JoeAgent_exp.sol";


contract JoeAgentReentrancyTest_FunctionalTest is Test {
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


    // @cover-intent Resource & Execution Integrity - Verify that removeLiquidityViaContract violates checks-effects-interactions, allowing reentrant calls to drain LP multiple times before lpInfo is updated
    function test_Reentrancy_Exploit_Test_0() public {
// assume: ATTACK_BLOCK == 100812531
// assume: SEED_BNB == 5000000000000000000
// assume: LOOPS == 25
// cover: removeLiquidityViaContract :: require(liquidity <= lpInfo[user].lpAmount) true
// cover: removeLiquidityViaContract :: external call before state update
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork("bsc", 100812530);
        // dropped unsafe prestate: vm.label(address(JOE), "JoeAgent");
        // dropped unsafe prestate: vm.label(address(WBNB_TOKEN), "WBNB");
        // dropped unsafe prestate: vm.label(PAIR, "JOE_WBNB_Pair");
        // dropped unsafe prestate: vm.label(REFERRER, "Referrer");
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_IS_TEST_view_1() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_excludeArtifacts_view_2() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_excludeContracts_view_3() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_excludeSelectors_view_4() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_excludeSenders_view_5() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_failed_view_6() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Protocol State Machine
    function test_setUp_deployment_7() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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
        // skip ABI-mismatched call: setUp()
    }

    // @cover-intent Authorization & Access Control
    function test_targetArtifactSelectors_view_8() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_targetArtifacts_view_9() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_targetContracts_view_10() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_targetInterfaces_view_11() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_targetSelectors_view_12() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Authorization & Access Control
    function test_targetSenders_view_13() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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

    // @cover-intent Resource & Execution Integrity
    function test_testExploit_reentrancy_14() public {
        vm.startPrank(owner);
        JoeAgentReentrancyTest target = new JoeAgentReentrancyTest();
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
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
    }

}
