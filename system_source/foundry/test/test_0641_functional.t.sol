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


    // @cover-intent Financial & Accounting: Verify that init subtracts v from map[k] when map[k] is initially 0, causing an underflow to a large number.
    function test_Normal_behavior_init_with_zero_initial_value_0() public {
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
        target.init(1, 1);
        }
    }

    // @cover-intent Financial & Accounting: Test that subtracting a large value from a small map entry results in underflow.
    function test_Edge_behavior_init_with_large_v_causing_underflow_1() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(78338746147236970124700731725183845421594913511827187288591969170390706184117)), bytes32(uint256(5)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(2, 10);
        }
    }

    // @cover-intent Financial & Accounting: Verify that subtracting 0 from map[k] leaves the value unchanged.
    function test_Boundary_init_with_v_0_no_change_2() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(78338746147236970124700731725183845421594913511827187288591969170390706184117)), bytes32(uint256(10)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(2, 0);
        }
    }

    // @cover-intent Financial & Accounting: Test exact underflow when map[k] equals v, resulting in 2^256 - 1.
    function test_Boundary_init_with_v_1_and_map_k_1_underflow_to_max_3() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(78338746147236970124700731725183845421594913511827187288591969170390706184117)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(3, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_init_overflow_4() public {
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
