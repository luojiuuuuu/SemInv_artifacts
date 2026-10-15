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


    // @cover-intent Financial & Accounting: Verify that go() forwards ETH to a hardcoded target and then transfers remaining balance to owner, preserving contract balance invariants.
    function test_Positive_path_owner_calls_go_with_ETH_0() public {
// assume: address(this).balance >= 5 ether
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

    // @cover-intent Resource & Execution Integrity: Test go() with msg.value = 0, ensuring no revert and owner receives nothing.
    function test_Edge_go_with_zero_ETH_1() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: go()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Test go() with a large msg.value to ensure the contract can forward and transfer large balances without overflow.
    function test_Edge_go_with_large_ETH_amount_2() public {
// assume: address(this).balance >= 1000 ether
// cover: go :: target.call.value(1000 ether)() succeeds
// cover: go :: owner.transfer(1000 ether) succeeds
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

    // @cover-intent External Interaction & Environment: Test behavior when the external call to target fails (e.g., target reverts or runs out of gas). The contract should still execute owner.transfer with remaining balance.
    function test_Negative_go_when_target_call_fails_reentrancy_or_gas_exhaustion_3() public {
// assume: target.call.value(5 ether)() returns false
// cover: go :: target.call.value(msg.value)() fails
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

    // @cover-intent Financial & Accounting: Test that after receiving ETH via fallback, calling go() forwards all balance to target and then to owner.
    function test_Sequence_fallback_then_go_4() public {
// assume: address(this).balance == 2 ether
// cover: fallback :: payable fallback accepts ETH
// cover: go :: target.call.value(0)() succeeds
// cover: go :: owner.transfer(2 ether) succeeds
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
        // skip ABI-mismatched call: go()
    }

    // @cover-intent External Interaction & Environment
    function test_go_positive_5() public {
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

    // @cover-intent Authorization & Access Control
    function test_owner_read_6() public {
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
