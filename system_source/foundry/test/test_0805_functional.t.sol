// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/mapping_performance_1.sol";

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

contract MappingPerformance1set_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MappingPerformance1set_FunctionalTest() public {
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


    // @cover-intent Transactional Consistency: verify that setting m0[a] to 5 does not affect m5[a] (always 0) and assert passes.
    function test_Positive_path_set_with_cond_0_then_check_with_same_key_0() public {
// cover: set :: cond == 0 true
// cover: check :: assert(m5[a] == 0) true
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
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
        target.set(bytes32(uint256(1)), 0);
        }
        {
        target.check(bytes32(uint256(1)), 0, bytes32(uint256(2)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: verify that setting m4[a] to 5 does not affect m5[a] (always 0) and assert passes.
    function test_Edge_set_with_cond_4_then_check_with_same_key_1() public {
// cover: set :: cond == 4 true
// cover: check :: assert(m5[a] == 0) true
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.set(bytes32(uint256(255)), 4);
        }
        {
        target.check(bytes32(uint256(255)), 4, bytes32(uint256(170)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: verify that when cond is 5 (no mapping updated), the assert still passes because m5[a] remains 0.
    function test_Boundary_set_with_cond_5_no_mapping_written_then_check_2() public {
// cover: set :: cond == 5 (no branch taken)
// cover: check :: assert(m5[a] == 0) true
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(carol);
        {
        target.set(bytes32(uint256(16)), 5);
        }
        {
        target.check(bytes32(uint256(16)), 5, bytes32(uint256(32)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: verify that check uses a different key for m5 lookup than the one set, so assert passes.
    function test_Negative_check_with_a0_that_was_set_to_a_different_key_assert_still_passes_3() public {
// cover: set :: cond == 2 true
// cover: check :: assert(m5[0xcd] == 0) true
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
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
        target.set(bytes32(uint256(171)), 2);
        }
        {
        target.check(bytes32(uint256(171)), 2, bytes32(uint256(205)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: verify that after multiple sets on different mappings, check with cond0=1 still passes because m5 is untouched.
    function test_Multiple_sets_then_check_with_different_cond0_4() public {
// cover: set :: cond == 0 true
// cover: set :: cond == 1 true
// cover: set :: cond == 2 true
// cover: check :: assert(m5[0xdd] == 0) true
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.set(bytes32(uint256(170)), 0);
        }
        {
        target.set(bytes32(uint256(187)), 1);
        }
        {
        target.set(bytes32(uint256(204)), 2);
        }
        {
        target.check(bytes32(uint256(187)), 1, bytes32(uint256(221)));
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for check
    function test_perfn_check_5() public {
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
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
        target.check(bytes32(uint256(1)), 1, bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for set
    function test_perfn_set_6() public {
        vm.startPrank(owner);
        MappingPerformance1set target = new MappingPerformance1set();
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
        {
        target.set(bytes32(uint256(1)), 1);
        }
    }

}
