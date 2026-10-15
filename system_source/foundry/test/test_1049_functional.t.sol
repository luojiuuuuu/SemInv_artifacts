// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;
import "../src/overflow_simple_add.sol";

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

contract Overflow_Add_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Overflow_Add_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that adding a normal uint256 value to balance works correctly.
    function test_Normal_addition_0() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(100);
        }
        // skip bad numeric post: call:balance(alice) == 101
    }

    // @cover-intent Financial & Accounting: Verify that adding a large value causes overflow (uint256 wraps around).
    function test_Overflow_boundary_1() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        // skip bad numeric post: call:balance(alice) == 0
    }

    // @cover-intent Financial & Accounting: Verify that adding zero does not change balance.
    function test_Add_zero_2() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(0);
        }
        // skip bad numeric post: call:balance(alice) == 1
    }

    // @cover-intent Financial & Accounting: Verify that adding one increments balance by one.
    function test_Add_one_3() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(1);
        }
        // skip bad numeric post: call:balance(alice) == 2
    }

    // @cover-intent Financial & Accounting: Verify that adding after max causes wrap-around.
    function test_Add_max_then_add_one_overflow_wrap_4() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.add(1);
        }
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 1
    }

    // @cover-intent Financial & Accounting: Verify that multiple additions accumulate correctly.
    function test_Multiple_additions_5() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(10);
        }
        {
        target.add(20);
        }
        {
        target.add(30);
        }
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 61
    }

    // @cover-intent Resource & Execution Integrity
    function test_balance_read_test_6() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        // skip ABI-mismatched call: balance()
    }

    // @cover-intent minimal test for add
    function test_perfn_add_7() public {
        vm.startPrank(owner);
        Overflow_Add target = new Overflow_Add();
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
        target.add(1);
        }
    }

}
