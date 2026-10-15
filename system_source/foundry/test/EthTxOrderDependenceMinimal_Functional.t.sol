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


    // @cover-intent Protocol State Machine: Verify that owner can set reward and a claimant can claim it before claimed flag is set.
    function test_Positive_path_owner_sets_reward_and_claimant_claims_0() public {
// assume: claimed == false
// assume: owner.balance >= 5 ether
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
        {
        target.setReward.value(5 ether)();
        }
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Authorization & Access Control: Only owner can call setReward.
    function test_Revert_when_non_owner_calls_setReward_1() public {
// assume: alice != owner
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
        {
        target.setReward.value(1 ether)();
        }
    }

    // @cover-intent Protocol State Machine: claimReward reverts if claimed is already true.
    function test_Revert_when_claiming_after_already_claimed_2() public {
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
        {
        target.setReward.value(5 ether)();
        }
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

    // @cover-intent Protocol State Machine: setReward reverts if claimed is already true.
    function test_Revert_when_setReward_called_after_claim_3() public {
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
        {
        target.setReward.value(5 ether)();
        }
        vm.prank(alice);
        {
        target.claimReward(0);
        }
        vm.expectRevert();
        vm.prank(owner);
        {
        target.setReward.value(1 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity: claimReward reverts if submission is not less than 10.
    function test_Revert_when_claimReward_submission_10_4() public {
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
        {
        target.setReward.value(5 ether)();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.claimReward(10);
        }
    }

    // @cover-intent Transactional Consistency: Demonstrate that reward can be changed between setReward and claimReward, affecting payout.
    function test_Front_running_scenario_owner_changes_reward_after_claimant_sees_it_5() public {
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
        {
        target.setReward.value(5 ether)();
        }
        {
        target.setReward.value(10 ether)();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_claimReward_sequence_6() public {
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
        {
        target.setReward.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_claimed_sequence_7() public {
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
        {
        target.claimed();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_sequence_8() public {
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
        {
        target.owner();
        }
    }

    // @cover-intent Financial & Accounting
    function test_reward_sequence_9() public {
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
        {
        target.setReward.value(200)();
        }
        vm.prank(alice);
        {
        target.reward();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_sequence_10() public {
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
        {
        target.setReward.value(100)();
        }
    }

}
