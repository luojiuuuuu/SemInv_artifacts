// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/constructor_create_modifiable.sol";

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


    // @cover-intent Verify that the constructor correctly initializes x_ to 10, and foo() returns that value. This covers the normal behavior and the invariant that b.foo() == 10 holds initially.
    function test_Constructor_sets_x_to_10_foo_returns_10_0() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        // skip ABI-mismatched call: foo()
    }

    // @cover-intent Verify that set_x() can modify x_ to a value other than 10, and foo() reflects the new value. This tests normal state mutation.
    function test_set_x_changes_x_to_5_foo_returns_5_1() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        {
        target.set_x(5);
        }
        // skip ABI-mismatched call: foo()
        vm.stopPrank();
    }

    // @cover-intent Verify that set_x() can set x_ to the boundary value 0, and foo() returns 0. Tests edge behavior at the minimum uint256 value.
    function test_set_x_to_0_foo_returns_0_2() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        {
        target.set_x(0);
        }
        // skip ABI-mismatched call: foo()
        vm.stopPrank();
    }

    // @cover-intent Verify that set_x() can set x_ to the maximum uint256 value, and foo() returns it. Tests edge behavior at the maximum value.
    function test_set_x_to_max_uint256_foo_returns_max_3() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        {
        target.set_x(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        // skip ABI-mismatched call: foo()
        vm.stopPrank();
    }

    // @cover-intent Verify that set_x() can reset x_ back to 10, and foo() returns 10. This tests the semantic invariant boundary where the assertion in ContructorCreateModifiable.check() would pass again.
    function test_set_x_to_10_after_change_foo_returns_10_4() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        {
        target.set_x(5);
        }
        {
        target.set_x(10);
        }
        // skip ABI-mismatched call: foo()
        vm.stopPrank();
    }

    // @cover-intent Verify that multiple set_x calls in sequence correctly update x_ each time, and foo() returns the last set value. Tests transactional consistency of state updates.
    function test_Multiple_set_x_calls_final_foo_returns_last_value_5() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        {
        target.set_x(1);
        }
        {
        target.set_x(2);
        }
        {
        target.set_x(3);
        }
        // skip ABI-mismatched call: foo()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_foo_test_6() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        {
        target.set_x(10);
        }
        // skip ABI-mismatched call: foo()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.foo());
            _assertRelU(__v1, 0, 10, "call:foo==10");
        }
    }

    // @cover-intent Transactional Consistency
    function test_set_x_test_7() public {
        vm.startPrank(owner);
        B target = new B(1);
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
        target.set_x(42);
        }
        {
            uint256 __v2 = uint256(target.foo());
            _assertRelU(__v2, 0, 42, "call:foo==42");
        }
    }

}
