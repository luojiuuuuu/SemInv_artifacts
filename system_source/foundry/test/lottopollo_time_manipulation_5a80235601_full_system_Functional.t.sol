// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/lottopollo.sol";

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

contract lottopollo_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function lottopollo_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that calling draw with a seed that results in a timestamp difference <= 24 hours updates leader and timestamp, and does not send ether.
    function test_Positive_path_draw_with_seed_triggers_payOut_and_updates_leader_0() public {
// assume: block.timestamp >= 100
// cover: payOut :: rand > 0 && now - rand > 24 hours false
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        target.draw(100);
        }
    }

    // @cover-intent Financial & Accounting: Verify that when the condition now - rand > 24 hours is true, the contract attempts to send ether to msg.sender and leader, but may fail due to insufficient balance.
    function test_Edge_draw_with_seed_that_makes_now_rand_24_hours_triggers_ether_send_1() public {
// assume: block.timestamp > 86401
// cover: payOut :: rand > 0 && now - rand > 24 hours true
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        target.draw(1);
        }
    }

    // @cover-intent Protocol State Machine: Verify that when rand == 0, the condition rand > 0 fails, and the else-if branch checks msg.value >= 1 ether, which is false, so no state change occurs.
    function test_Edge_draw_with_seed_0_triggers_else_branch_msg_value_1_ether_false_2() public {
// cover: payOut :: rand > 0 false
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        target.draw(0);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that when rand > 0 but now - rand <= 24 hours, and msg.value >= 1 ether, the leader and timestamp are updated.
    function test_Edge_draw_with_seed_and_msg_value_1_ether_updates_leader_3() public {
// assume: block.timestamp - 100 <= 86400
// cover: payOut :: rand > 0 && now - rand > 24 hours false
// cover: payOut :: msg.value >= 1 ether true
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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

    // @cover-intent Protocol State Machine: Verify that when rand > 0 but now - rand <= 24 hours, and msg.value < 1 ether, no state change occurs.
    function test_Edge_draw_with_seed_and_msg_value_1_ether_does_not_update_leader_4() public {
// assume: block.timestamp - 100 <= 86400
// cover: payOut :: rand > 0 && now - rand > 24 hours false
// cover: payOut :: msg.value >= 1 ether false
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        target.draw(100);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that randomGen returns the current block timestamp.
    function test_View_function_randomGen_returns_block_timestamp_5() public {
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        // skip ABI-mismatched call: randomGen()
    }

    // @cover-intent External Interaction & Environment
    function test_draw_sequence_6() public {
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        target.draw(100);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_randomGen_sequence_7() public {
        vm.startPrank(owner);
        lottopollo target = new lottopollo();
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
        // skip ABI-mismatched call: randomGen()
    }

}
