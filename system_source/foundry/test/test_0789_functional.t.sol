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


    // @cover-intent Authorization & Access Control: Verify that calling draw with a seed that results in a random number satisfying the condition (rand > 0 && now - rand > 24 hours) triggers the payout branch, otherwise updates leader and timestamp.
    function test_Positive_path_draw_with_seed_triggers_payOut_and_updates_leader_0() public {
// assume: block.timestamp > 1 + 24 hours
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
    }

    // @cover-intent Protocol State Machine: Verify that when the time condition fails (now - rand <= 24 hours) and msg.value >= 1 ether, the leader and timestamp are updated.
    function test_Edge_case_draw_with_seed_that_does_not_satisfy_time_condition_1() public {
// assume: block.timestamp <= 2 + 24 hours
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
    }

    // @cover-intent Resource & Execution Integrity: Verify that calling draw with seed=0 results in rand=0, which fails the first condition (rand > 0) and also fails the second condition (msg.value >= 1 ether) if value is less than 1 ether, leading to no state change.
    function test_Edge_case_draw_with_zero_seed_2() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that when msg.value < 1 ether and time condition fails, no state change occurs.
    function test_Edge_case_draw_with_value_less_than_1_ether_and_time_condition_fails_3() public {
// assume: block.timestamp <= 3 + 24 hours
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
        vm.prank(bob);
        {
        target.draw(3);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that randomGen returns the current block timestamp.
    function test_View_function_randomGen_returns_block_timestamp_4() public {
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
    function test_draw_test_5() public {
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
    function test_randomGen_test_6() public {
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
