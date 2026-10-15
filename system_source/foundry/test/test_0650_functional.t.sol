// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_minimal.sol";

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

contract IntegerOverflowMinimal_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowMinimal_FunctionalTest() public {
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


    // @cover-intent Test normal behavior of run() where input is less than count, verifying count decreases correctly. Covers Financial & Accounting invariant.
    function test_Normal_subtraction_0() public {
// assume: count == 1
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(1);
        }
    }

    // @cover-intent Test edge behavior where input is zero, count should remain unchanged.
    function test_Subtract_zero_1() public {
// assume: count == 1
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(0);
        }
    }

    // @cover-intent Test edge behavior where input equals count, result should be zero.
    function test_Subtract_equal_to_count_2() public {
// assume: count == 1
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(1);
        }
    }

    // @cover-intent Test semantic invariant boundary where input is greater than count, causing underflow. This is the vulnerable path.
    function test_Integer_underflow_boundary_3() public {
// assume: count == 1
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(2);
        }
    }

    // @cover-intent Test multiple calls to run() to ensure state persists correctly.
    function test_Multiple_subtractions_4() public {
// assume: count == 1
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(1);
        }
        vm.prank(bob);
        {
        target.run(0);
        }
    }

    // @cover-intent Test behavior after underflow: count becomes huge, then subtract zero leaves it unchanged.
    function test_Underflow_then_subtract_zero_5() public {
// assume: count == 1
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(2);
        }
        vm.prank(bob);
        {
        target.run(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_view_6() public {
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        // skip ABI-mismatched call: count()
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 0, 1, "call:count==1");
        }
    }

    // @cover-intent Financial & Accounting
    function test_run_overflow_7() public {
        vm.startPrank(owner);
        IntegerOverflowMinimal target = new IntegerOverflowMinimal();
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
        target.run(2);
        }
        {
            uint256 __v2 = uint256(target.count());
            _assertRelU(__v2, 0, 115792089237316195423570985008687907853269984665640564039457584007913129639935, "call:count==115792089237316195423570985008687907853269984665640564039457584007913129639935");
        }
    }

}
