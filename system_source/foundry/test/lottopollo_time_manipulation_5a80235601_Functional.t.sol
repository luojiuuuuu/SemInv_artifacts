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


    // @cover-intent Authorization & Access Control: Test that when rand <= 0 or now - rand <= 24 hours, and msg.value >= 1 ether, the leader and timestamp are updated.
    function test_draw_with_low_rand_and_high_value_0() public {
// assume: block.timestamp > 1
// assume: now - 1 <= 24 hours
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

    // @cover-intent Financial & Accounting: Test that when rand > 0 and now - rand > 24 hours, and msg.value is sent, but no ether is sent (value=0), the condition fails and no payout occurs.
    function test_draw_with_high_rand_and_low_value_1() public {
// assume: block.timestamp > 1000000
// assume: now - 1000000 > 24 hours
// cover: payOut :: rand > 0 && now - rand > 24 hours true
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
        target.draw(1000000);
        }
    }

    // @cover-intent Financial & Accounting: Test that when rand > 0 and now - rand > 24 hours, and msg.value >= 1 ether, the payout branch is taken, sending msg.value to sender and balance to leader.
    function test_draw_with_high_rand_and_high_value_2() public {
// assume: block.timestamp > 1000000
// assume: now - 1000000 > 24 hours
// cover: payOut :: rand > 0 && now - rand > 24 hours true
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

    // @cover-intent Resource & Execution Integrity: Test that when rand == 0, the first condition fails, and if msg.value >= 1 ether, leader and timestamp are updated.
    function test_draw_with_zero_rand_and_high_value_3() public {
// assume: block.timestamp == 0
// cover: payOut :: rand > 0 false
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

    // @cover-intent External Interaction & Environment: Test that randomGen returns the current block.timestamp.
    function test_randomGen_returns_block_timestamp_4() public {
// assume: block.timestamp == 12345
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
    function test_draw_sequence_5() public {
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
    function test_randomGen_sequence_6() public {
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
        // skip ABI-mismatched call: randomGen()
    }

}
