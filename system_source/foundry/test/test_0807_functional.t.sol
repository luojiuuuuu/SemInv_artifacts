// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/mapping_perfomance_2.sol";

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

contract MappingPerformance2sets_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MappingPerformance2sets_FunctionalTest() public {
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


    // @cover-intent Transactional Consistency: Verify that after setting m0 and m1 for different keys, m5 remains zero for an unrelated key.
    function test_Set_and_check_with_different_keys_and_conditions_0() public {
// cover: set :: cond == 0 true
// cover: set :: cond == 1 true
// cover: check :: assert m5[a] == 0 true
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
        target.set(bytes32(uint256(2)), 1);
        }
        {
        target.check(bytes32(uint256(1)), 0, bytes32(uint256(2)), 1, bytes32(uint256(3)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that setting m2 and m3 does not affect m5.
    function test_Set_with_cond_2_and_cond_3_check_with_unrelated_key_1() public {
// cover: set :: cond == 2 true
// cover: set :: cond == 3 true
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
        target.set(bytes32(uint256(10)), 2);
        }
        {
        target.set(bytes32(uint256(11)), 3);
        }
        {
        target.check(bytes32(uint256(10)), 2, bytes32(uint256(11)), 3, bytes32(uint256(12)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that setting m4 for a key does not affect m5 for the same key.
    function test_Set_with_cond_4_and_check_with_same_key_used_in_set_2() public {
// cover: set :: cond == 4 true
// cover: check :: assert m5[a] == 0 true
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
        target.set(bytes32(uint256(255)), 4);
        }
        {
        target.check(bytes32(uint256(255)), 4, bytes32(uint256(255)), 4, bytes32(uint256(255)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Overwrite m0 for the same key twice, then check m5 for an unrelated key.
    function test_Set_with_cond_0_and_cond_0_for_same_key_check_with_different_key_3() public {
// cover: set :: cond == 0 true
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
        target.set(bytes32(uint256(170)), 0);
        }
        {
        target.set(bytes32(uint256(170)), 0);
        }
        {
        target.check(bytes32(uint256(170)), 0, bytes32(uint256(170)), 0, bytes32(uint256(187)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that set with cond=5 does not write to any mapping, and check still passes.
    function test_Set_with_cond_5_no_mapping_written_check_with_any_key_4() public {
// cover: set :: cond == 5 (no branch taken)
// cover: check :: assert m5[a] == 0 true
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
        target.set(bytes32(uint256(204)), 5);
        }
        {
        target.check(bytes32(uint256(204)), 5, bytes32(uint256(204)), 5, bytes32(uint256(221)));
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for check
    function test_perfn_check_5() public {
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
        target.check(bytes32(uint256(1)), 1, bytes32(uint256(1)), 1, bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for set
    function test_perfn_set_6() public {
        vm.startPrank(owner);
        MappingPerformance2sets target = new MappingPerformance2sets();
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
