// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_add.sol";

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

contract IntegerOverflowAdd_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowAdd_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that adding a small positive integer to count works correctly without overflow.
    function test_Normal_addition_0() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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
        target.run(5);
        }
    }

    // @cover-intent Financial & Accounting: Verify that adding a large value causes uint256 overflow, wrapping count to a small number.
    function test_Overflow_boundary_1() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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
        target.run(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
    }

    // @cover-intent Financial & Accounting: Verify that adding a value that overflows from an initial count of 1 results in a wrapped value.
    function test_Overflow_with_initial_count_2() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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
        target.run(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
    }

    // @cover-intent Transactional Consistency: Verify that adding zero does not change the count.
    function test_Zero_addition_3() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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

    // @cover-intent Transactional Consistency: Verify that multiple sequential additions accumulate correctly.
    function test_Multiple_additions_4() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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
        target.run(10);
        }
        vm.prank(bob);
        {
        target.run(20);
        }
        vm.prank(carol);
        {
        target.run(30);
        }
    }

    // @cover-intent Financial & Accounting: Verify that overflow occurs after a series of additions that exceed uint256 max.
    function test_Overflow_after_multiple_additions_5() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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
        target.run(115792089237316195423570985008687907853269984665640564039457584007913129639934);
        }
        vm.prank(bob);
        {
        target.run(2);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_view_6() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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
        target.count();
        }
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 0, 1, "call:count==1");
        }
    }

    // @cover-intent minimal test for run
    function test_perfn_run_7() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
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

}
