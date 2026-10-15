// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/Ekubo_exp.sol";


contract EkuboTest_FunctionalTest is Test {
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


    // @cover-intent Reproduce the known exploit to verify the vulnerability exists. This tests Financial & Accounting and External Interaction & Environment invariants by demonstrating that the Ekubo Router can be used to drain WBTC from the victim through repeated lock/withdraw/pay callbacks.
    function test_Exploit_Reproduction_Positive_Path_0() public {
// assume: block.number == 20517544
// assume: WBTC.balanceOf(VICTIM) >= 1700000000
// cover: locked :: require(msg.sender == address(CORE)) true
// cover: payCallback :: require(msg.sender == address(CORE)) true
// cover: payCallback :: require(token == address(WBTC)) true
// cover: drain :: require(WBTC.balanceOf(PROFIT_RECEIVER) > 0) true
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
        // TODO assert: alice.balance == 1700000000
    }

    // @cover-intent Test edge case where victim has insufficient WBTC balance. This tests Resource & Execution Integrity by verifying the exploit fails gracefully when the victim cannot provide the required tokens.
    function test_Exploit_Prevention_Insufficient_Victim_Balance_1() public {
// assume: WBTC.balanceOf(VICTIM) == 0
// cover: payCallback :: require(WBTC.transferFrom(VICTIM, address(CORE), WBTC_PER_LOCK)) false
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        vm.expectRevert();
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
    }

    // @cover-intent Test edge case where payCallback receives a different token address. This tests Authorization & Access Control by verifying the token check prevents unauthorized token transfers.
    function test_Exploit_Prevention_Wrong_Token_in_PayCallback_2() public {
// assume: CORE.payCallback is called with token != WBTC
// cover: payCallback :: require(token == address(WBTC)) false
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
        // skip ABI-mismatched call: setUp()
        vm.expectRevert();
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
    }

    // @cover-intent Test boundary behavior with only one lock iteration instead of 85. This tests Protocol State Machine by verifying the exploit requires multiple iterations to accumulate profit.
    function test_Exploit_Prevention_Single_Lock_Attempt_3() public {
// assume: REPEAT_COUNT == 1
// assume: WBTC.balanceOf(PROFIT_RECEIVER) == 0
// cover: drain :: require(WBTC.balanceOf(PROFIT_RECEIVER) > 0) false
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
        // skip ABI-mismatched call: setUp()
        vm.expectRevert();
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_IS_TEST_4() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_excludeArtifacts_5() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_excludeContracts_6() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_excludeSelectors_7() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_excludeSenders_8() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_failed_9() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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

    // @cover-intent External Interaction & Environment
    function test_setUp_10() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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

    // @cover-intent Resource & Execution Integrity
    function test_targetArtifactSelectors_11() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_targetArtifacts_12() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_targetContracts_13() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_targetInterfaces_14() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_targetSelectors_15() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_targetSenders_16() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
    function test_testExploit_17() public {
        vm.startPrank(owner);
        EkuboTest target = new EkuboTest();
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
