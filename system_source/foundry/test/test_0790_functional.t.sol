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


    // @cover-intent Authorization & Access Control: Verify that calling draw with a seed updates leader and timestamp when msg.value >= 1 ether, and that a subsequent call with a different seed can trigger payout if condition met.
    function test_Positive_path_draw_with_seed_triggers_payOut_and_updates_leader_0() public {
// assume: block.timestamp > 100 + 24 hours
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
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Protocol State Machine: Verify that when msg.value >= 1 ether and the time condition fails, leader and timestamp are updated.
    function test_Edge_draw_with_seed_that_does_not_trigger_payout_but_updates_leader_1() public {
// assume: block.timestamp - 500 <= 24 hours
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that when seed is 0, the condition rand > 0 fails, and msg.value < 1 ether, so no state change occurs.
    function test_Edge_draw_with_zero_seed_does_not_trigger_payout_and_does_not_update_leader_2() public {
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

    // @cover-intent Authorization & Access Control: Verify that when msg.value < 1 ether and time condition fails, no state change occurs.
    function test_Edge_draw_with_seed_but_msg_value_less_than_1_ether_no_state_change_3() public {
// assume: block.timestamp - 100 <= 24 hours
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

    // @cover-intent Financial & Accounting: Verify that when payout condition is met and contract has balance, leader receives the contract balance.
    function test_Boundary_draw_with_seed_that_triggers_payout_when_contract_has_balance_4() public {
// assume: block.timestamp > 200 + 24 hours
// assume: address(target).balance >= 1 ether
// cover: payOut :: this.balance > 0 true
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
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that when payout condition is met but contract balance is zero, no send to leader occurs (no revert).
    function test_Negative_draw_with_seed_that_triggers_payout_but_contract_has_no_balance_5() public {
// assume: block.timestamp > 200 + 24 hours
// assume: address(target).balance == 0
// cover: payOut :: this.balance > 0 false
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
        vm.prank(bob);
        {
        target.draw(200);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that randomGen returns the current block timestamp.
    function test_View_randomGen_returns_block_timestamp_6() public {
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
    function test_draw_sequence_7() public {
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
    function test_randomGen_sequence_8() public {
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
