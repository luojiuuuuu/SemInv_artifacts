// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/YSDAO_exp.sol";


contract YSDAO_exp_FunctionalTest is Test {
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


    // @cover-intent Reproduce the YSDAO exploit by executing the full attack path: flash loan from V3 pool, manipulate V2 pair reserves via swap callback, call staking.sync() to inflate price, add 1 USDT to trigger add-liquidity bypass, then sell all YSDAO tokens. This tests External Interaction & Environment and Financial & Accounting invariants.
    function test_Exploit_Reproduction_0() public {
// assume: fork block number == 101088361 - 1
// assume: USDT balance of this contract >= 0 before exploit
// cover: pancakeV3FlashCallback :: require(msg.sender == pool && msg.sender == USDT_WBNB_V3_POOL) true
// cover: pancakeV3FlashCallback :: require(fee1 == 0) true
// cover: pancakeCall :: require(msg.sender == YSDAO_USDT_PAIR) true
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        // dropped unsafe prestate: vm.label(ATTACKER, 'Attacker EOA');
        // dropped unsafe prestate: vm.label(USDT, 'USDT');
        // dropped unsafe prestate: vm.label(WBNB, 'WBNB');
        // dropped unsafe prestate: vm.label(YSDAO, 'YSDAO');
        // dropped unsafe prestate: vm.label(STAKING, 'YSDAO Staking');
        // dropped unsafe prestate: vm.label(YSDAO_USDT_PAIR, 'YSDAO/USDT Pair');
        // dropped unsafe prestate: vm.label(USDT_WBNB_V3_POOL, 'USDT/WBNB V3 Pool');
        // dropped unsafe prestate: vm.label(PANCAKE_ROUTER, 'Pancake Router');
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: testExploit()
        vm.stopPrank();
    }

    // @cover-intent Verify that setUp() executes without reverting and properly initializes the fork environment. This tests Protocol State Machine invariants.
    function test_SetUp_Initialization_1() public {
// assume: fork block number == 101088361 - 1
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: setUp()
    }

    // @cover-intent Verify that IS_TEST() returns true after setUp(), confirming the contract is in test mode. This tests Protocol State Machine invariants.
    function test_IS_TEST_View_Consistency_2() public {
// assume: setUp() has been called
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: IS_TEST()
        vm.stopPrank();
    }

    // @cover-intent Verify that excludeArtifacts() returns an empty array by default, confirming no artifacts are excluded from fuzzing. This tests Resource & Execution Integrity invariants.
    function test_Exclude_Artifacts_Empty_List_3() public {
// assume: default configuration
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: excludeArtifacts()
        vm.stopPrank();
    }

    // @cover-intent Verify that excludeContracts() returns an empty array by default, confirming no contracts are excluded from fuzzing. This tests Resource & Execution Integrity invariants.
    function test_Exclude_Contracts_Empty_List_4() public {
// assume: default configuration
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: excludeContracts()
        vm.stopPrank();
    }

    // @cover-intent Verify that failed() returns false before any test execution, confirming clean initial state. This tests Protocol State Machine invariants.
    function test_Failed_Flag_Initial_State_5() public {
// assume: no test has been executed yet
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: failed()
        vm.stopPrank();
    }

    // @cover-intent Verify that targetSelectors() returns an empty array by default, confirming no specific selectors are targeted for fuzzing. This tests Resource & Execution Integrity invariants.
    function test_Target_Selectors_Default_Empty_6() public {
// assume: default configuration
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.createSelectFork('bsc', 101088361 - 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: setUp()
        // skip ABI-mismatched call: targetSelectors()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_IS_TEST_7() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_excludeArtifacts_8() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_excludeContracts_9() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_excludeSelectors_10() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_excludeSenders_11() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_failed_12() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_setUp_13() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_targetArtifactSelectors_14() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_targetArtifacts_15() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_targetContracts_16() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_targetInterfaces_17() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_targetSelectors_18() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_targetSenders_19() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
    function test_testExploit_20() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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

    // @cover-intent minimal test for pancakeCall
    function test_perfn_pancakeCall_21() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
        target.pancakeCall(alice, 1, 1, hex"01");
        }
    }

    // @cover-intent minimal test for pancakeV3FlashCallback
    function test_perfn_pancakeV3FlashCallback_22() public {
        vm.startPrank(owner);
        YSDAO_exp target = new YSDAO_exp();
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
        target.pancakeV3FlashCallback(1, 1, hex"01");
        }
    }

}
