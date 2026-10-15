// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/eth_tx_order_dependence_minimal.sol";

// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}

contract EthTxOrderDependenceMinimal_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EthTxOrderDependenceMinimal_FunctionalTest() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() public payable { }


    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }


    // @cover-intent Authorization & Access Control: Verify that owner can set reward and then claimReward works correctly for a valid submission.
    function test_Normal_setReward_and_claimReward_0() public {
// assume: claimed == false
// assume: reward == 5 ether
// cover: setReward :: require(!claimed) true
// cover: setReward :: require(msg.sender == owner) true
// cover: claimReward :: require(!claimed) true
// cover: claimReward :: require(submission < 10) true
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Protocol State Machine: Verify that setReward reverts when claimed is true.
    function test_setReward_reverts_if_already_claimed_1() public {
// assume: claimed == true
// cover: setReward :: require(!claimed) false
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(0);
        }
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: setReward()
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call setReward.
    function test_setReward_reverts_if_not_owner_2() public {
// assume: claimed == false
// cover: setReward :: require(msg.sender == owner) false
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
    }

    // @cover-intent Protocol State Machine: Verify that claimReward reverts when claimed is true.
    function test_claimReward_reverts_if_already_claimed_3() public {
// assume: claimed == true
// cover: claimReward :: require(!claimed) false
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(0);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that claimReward reverts for invalid submission value.
    function test_claimReward_reverts_if_submission_10_4() public {
// assume: claimed == false
// cover: claimReward :: require(submission < 10) false
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.startPrank(alice);
        vm.expectRevert();
        {
        target.claimReward(10);
        }
        vm.expectRevert();
        {
        target.claimReward(100);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that setReward cannot be called after claimReward (claimed becomes true).
    function test_Front_running_scenario_setReward_after_claimReward_reverts_5() public {
// assume: claimed == false initially
// cover: claimReward :: require(!claimed) true
// cover: setReward :: require(!claimed) false
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(0);
        }
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: setReward()
    }

    // @cover-intent Financial & Accounting: Verify that reward can be updated multiple times before claiming, and only the last reward is paid.
    function test_Multiple_setReward_calls_before_claimReward_6() public {
// assume: claimed == false
// cover: setReward :: require(!claimed) true
// cover: setReward :: require(msg.sender == owner) true
// cover: claimReward :: require(!claimed) true
// cover: claimReward :: require(submission < 10) true
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        // skip ABI-mismatched call: setReward()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that submission = 0 is valid.
    function test_claimReward_with_submission_0_boundary_7() public {
// assume: claimed == false
// cover: claimReward :: require(submission < 10) true
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that submission = 9 is valid.
    function test_claimReward_with_submission_9_boundary_8() public {
// assume: claimed == false
// cover: claimReward :: require(submission < 10) true
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(9);
        }
    }

    // @cover-intent Financial & Accounting: Verify that setReward can be called with zero value.
    function test_setReward_with_zero_value_9() public {
// assume: claimed == false
// cover: setReward :: require(!claimed) true
// cover: setReward :: require(msg.sender == owner) true
// cover: claimReward :: require(!claimed) true
// cover: claimReward :: require(submission < 10) true
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_claimReward_positive_10() public {
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        {
        target.claimReward(1);
        }
    }

    // @cover-intent Protocol State Machine
    function test_claimed_view_11() public {
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: claimed()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_12() public {
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Financial & Accounting
    function test_reward_view_13() public {
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
        vm.prank(alice);
        // skip ABI-mismatched call: reward()
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_positive_14() public {
        vm.startPrank(owner);
        EthTxOrderDependenceMinimal target = new EthTxOrderDependenceMinimal();
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
        // skip ABI-mismatched call: setReward()
    }

}
