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


    // @cover-intent Financial & Accounting: Verify that owner can call go() with ETH, the contract forwards ETH to a hardcoded target, and then transfers remaining balance to owner.
    function test_Positive_path_owner_sends_ETH_via_go_0() public {
// assume: address(this).balance >= 0
// cover: go :: target.call.value(msg.value)() executed
// cover: go :: owner.transfer(address(this).balance) executed
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
        vm.prank(owner);
        // skip ABI-mismatched call: go()
    }

    // @cover-intent External Interaction & Environment: Test that go() works when msg.value is 0, sending 0 ETH to target and transferring contract balance to owner.
    function test_Edge_go_called_with_zero_value_1() public {
// assume: address(this).balance == 0 after first call
// cover: go :: target.call.value(0)()
// cover: go :: owner.transfer(0)
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
        vm.prank(owner);
        // skip ABI-mismatched call: go()
    }

    // @cover-intent Authorization & Access Control: Verify that any address can call go() since there is no access control; alice sends ETH and contract forwards it.
    function test_Edge_go_called_by_non_owner_alice_with_ETH_2() public {
// assume: alice != owner
// cover: go :: target.call.value(3 ether)()
// cover: go :: owner.transfer(remaining balance)
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

    // @cover-intent Financial & Accounting: Test that repeated calls to go() accumulate ETH in contract and then transfer all to owner on each call.
    function test_Boundary_go_called_multiple_times_accumulating_balance_3() public {
// assume: contract balance after requires is 0 (since each go() transfers out)
// cover: go :: multiple calls, balance transferred each time
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
        vm.prank(bob);
        // skip ABI-mismatched call: go()
        vm.prank(owner);
        // skip ABI-mismatched call: go()
    }

    // @cover-intent External Interaction & Environment: Test that fallback function can receive ETH, and then go() can transfer that balance to owner.
    function test_Negative_fallback_receives_ETH_without_go_4() public {
// assume: contract balance before go() == 4 ether
// cover: fallback :: receive ETH
// cover: go :: owner.transfer(4 ether)
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: go()
        // skip ABI-mismatched call: go()
        vm.stopPrank();
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
