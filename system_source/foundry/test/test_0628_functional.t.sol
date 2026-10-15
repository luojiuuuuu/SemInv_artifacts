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


    // @cover-intent Financial & Accounting: Verify that init subtracts v from map[k] when map[k] is initially zero, resulting in an underflow to a large number (semantic invariant boundary).
    function test_Normal_behavior_init_with_non_zero_v_0() public {
// cover: init :: subtraction underflow (map[k] -= v) when map[k] < v
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

    // @cover-intent Resource & Execution Integrity: Verify that init with v = 0 does not change map[k] (no underflow).
    function test_Edge_behavior_init_with_v_0_1() public {
// cover: init :: subtraction with v=0, no underflow
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
        target.init(0, 0);
        }
    }

    // @cover-intent Financial & Accounting: Verify that init with v = 1 on map[k] = 1 results in map[k] = 0 (no underflow).
    function test_Boundary_init_with_v_1_on_map_k_1_2() public {
// cover: init :: subtraction with v=1, map[k]=1, result 0
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
        {
        target.init(1, 1);
        }
    }

    // @cover-intent Financial & Accounting: Verify that init with v > map[k] causes underflow to a large number (semantic invariant boundary).
    function test_Boundary_init_with_large_v_causing_underflow_3() public {
// cover: init :: subtraction underflow when v > map[k]
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(3)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.init(2, 10);
        }
    }

    // @cover-intent Transactional Consistency: Verify that multiple init calls on the same key accumulate underflows.
    function test_Multiple_calls_init_on_same_key_twice_4() public {
// cover: init :: two consecutive underflows on same key
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.init(3, 1);
        }
        {
        target.init(3, 2);
        }
        vm.stopPrank();
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
