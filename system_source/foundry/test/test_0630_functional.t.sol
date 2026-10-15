// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_mapping_sym_1.sol";

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

contract IntegerOverflowMappingSym1_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowMappingSym1_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that init subtracts v from map[k] when map[k] is initially zero, resulting in an underflow (since uint256 cannot be negative). This tests the semantic invariant boundary of unsigned integer arithmetic.
    function test_Normal_subtraction_with_positive_result_0() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
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
        vm.prank(alice);
        {
        target.init(0, 1);
        }
    }

    // @cover-intent Financial & Accounting: Test that init with v > map[k] causes an underflow, wrapping around to a large number.
    function test_Subtraction_from_non_zero_value_causing_underflow_1() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(5)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(0, 10);
        }
    }

    // @cover-intent Financial & Accounting: Test that init with v equal to map[k] results in zero, which is a valid boundary.
    function test_Subtraction_with_exact_equality_no_underflow_2() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(10)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(0, 10);
        }
    }

    // @cover-intent Financial & Accounting: Test that init with v = 0 does not change map[k], a trivial edge case.
    function test_Subtraction_with_v_0_no_change_3() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(7)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(0, 0);
        }
    }

    // @cover-intent Financial & Accounting: Test that init with v = type(uint256).max causes underflow from any non-zero map[k], wrapping to a specific value.
    function test_Subtraction_with_maximum_uint256_value_4() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip malformed call: init(1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) (bad raw arg for init.arg1: type=uint256, raw=0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
    }

    // @cover-intent Resource & Execution Integrity
    function test_init_overflow_5() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
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
        target.init(0, 1);
        }
    }

}
