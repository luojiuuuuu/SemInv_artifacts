// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/sha_of_sha_2_mappings.sol";

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

contract ShaOfSha2Mappings_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ShaOfSha2Mappings_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that check(address) does not revert when the mapping n has no entry for the given address.
    function test_Check_returns_normally_when_mapping_n_is_empty_0() public {
// cover: check :: assert(n[keccak256(abi.encode("BBB", a))] == 0) true
        vm.startPrank(owner);
        ShaOfSha2Mappings target = new ShaOfSha2Mappings();
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
        target.check(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that check(address) reverts if the mapping n has a non-zero value for the given address, violating the assertion.
    function test_Check_reverts_when_mapping_n_has_a_non_zero_entry_for_the_address_1() public {
// cover: check :: assert(n[keccak256(abi.encode("BBB", a))] == 0) false
        vm.startPrank(owner);
        ShaOfSha2Mappings target = new ShaOfSha2Mappings();
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.check(alice);
        }
    }

    // @cover-intent Transactional Consistency: Verify that check(address) succeeds for multiple distinct addresses when none have entries in mapping n.
    function test_Check_with_multiple_addresses_all_empty_2() public {
// cover: check :: assert(n[keccak256(abi.encode("BBB", a))] == 0) true
        vm.startPrank(owner);
        ShaOfSha2Mappings target = new ShaOfSha2Mappings();
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
        target.check(bob);
        }
        vm.prank(bob);
        {
        target.check(carol);
        }
        vm.prank(carol);
        {
        target.check(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that check(address) can be called multiple times on the same address without reverting when mapping n is empty.
    function test_Check_with_same_address_called_twice_3() public {
// cover: check :: assert(n[keccak256(abi.encode("BBB", a))] == 0) true
        vm.startPrank(owner);
        ShaOfSha2Mappings target = new ShaOfSha2Mappings();
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
        target.check(bob);
        }
        {
        target.check(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that check(address) succeeds when called with the zero address, as mapping n is empty for it.
    function test_Check_with_zero_address_4() public {
// cover: check :: assert(n[keccak256(abi.encode("BBB", a))] == 0) true
        vm.startPrank(owner);
        ShaOfSha2Mappings target = new ShaOfSha2Mappings();
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
        target.check(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Transactional Consistency
    function test_check_n_mapping_initial_zero_5() public {
        vm.startPrank(owner);
        ShaOfSha2Mappings target = new ShaOfSha2Mappings();
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
        target.check(alice);
        }
    }

}
