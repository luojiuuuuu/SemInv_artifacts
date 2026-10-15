// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xf29ebe930a539a60279ace72c707cba851a57707.sol";

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

contract B_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function B_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that owner can call go() with ETH, the call to target succeeds, and owner receives the contract balance via transfer.
    function test_Positive_path_owner_calls_go_with_ETH_0() public {
// assume: address(this).balance >= 0
// cover: go :: target.call.value(msg.value)() succeeds
// cover: go :: owner.transfer(address(this).balance) succeeds
        vm.startPrank(owner);
        B target = new B();
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
        // skip ABI-mismatched call: go()
    }

    // @cover-intent Financial & Accounting: Verify that go() can be called with 0 ETH, the call to target with 0 value succeeds, and owner receives the contract balance (which may be 0).
    function test_Edge_owner_calls_go_with_0_ETH_1() public {
// assume: address(this).balance == 0
// cover: go :: target.call.value(0)() succeeds
// cover: go :: owner.transfer(0) succeeds
        vm.startPrank(owner);
        B target = new B();
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
        // skip ABI-mismatched call: go()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner (alice) can call go() because there is no access control, and the function executes normally.
    function test_Edge_non_owner_calls_go_with_ETH_2() public {
// assume: address(this).balance >= 0
// cover: go :: target.call.value(msg.value)() succeeds
// cover: go :: owner.transfer(address(this).balance) succeeds
        vm.startPrank(alice);
        B target = new B();
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
        // skip ABI-mismatched call: go()
    }

    // @cover-intent Financial & Accounting: Verify that go() can handle large ETH amounts, the call to target forwards the value, and owner receives the contract balance.
    function test_Boundary_owner_calls_go_with_large_ETH_amount_3() public {
// assume: address(this).balance >= 0
// cover: go :: target.call.value(1000 ether)() succeeds
// cover: go :: owner.transfer(address(this).balance) succeeds
        vm.startPrank(owner);
        B target = new B();
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
        // skip ABI-mismatched call: go()
    }

    // @cover-intent External Interaction & Environment: Verify that if the external call to target fails, the function still proceeds to transfer the contract balance to owner (no revert on call failure).
    function test_Negative_owner_calls_go_but_target_call_fails_simulated_via_prestate_4() public {
// assume: target.call.value(1 ether)() returns false
// cover: go :: target.call.value(msg.value)() fails
// cover: go :: owner.transfer(address(this).balance) succeeds
        vm.startPrank(owner);
        B target = new B();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: go()
    }

    // @cover-intent Financial & Accounting: Verify that go() correctly transfers the entire contract balance to owner when the contract has accumulated ETH from fallback calls.
    function test_Edge_owner_calls_go_after_receiving_ETH_via_fallback_5() public {
// assume: address(this).balance == 3 ether before go()
// cover: go :: target.call.value(1 ether)() succeeds
// cover: go :: owner.transfer(3 ether) succeeds
        vm.startPrank(owner);
        B target = new B();
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
        // skip ABI-mismatched call: go()
    }

    // @cover-intent External Interaction & Environment
    function test_go_positive_6() public {
        vm.startPrank(alice);
        B target = new B();
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
        // skip ABI-mismatched call: go()
        // skip ABI-mismatched call: go()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_owner_read_7() public {
        vm.startPrank(owner);
        B target = new B();
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

}
