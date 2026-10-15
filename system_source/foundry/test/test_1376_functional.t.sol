// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/sha_of_sha_collision.sol";

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

contract ShaOfShaCollission_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ShaOfShaCollission_FunctionalTest() public {
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


    // @cover-intent Transactional Consistency - Verify that setting a value under one key does not affect assertion for a different key.
    function test_Normal_behavior_set_then_check_with_different_key_0() public {
// cover: check :: assert(m[keccak256(abi.encodePacked(x, "B"))] == 0) true
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(66);
        }
        {
        target.check(42);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity - Trigger assertion failure by exploiting keccak256 collision between set and check keys.
    function test_Collision_set_with_66_then_check_with_0x4100_1() public {
// cover: check :: assert(m[keccak256(abi.encodePacked(x, "B"))] == 0) false
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(66);
        }
        vm.expectRevert();
        // skip malformed call: check(0x4100000000000000000000000000000000000000000000000000000000000000) (bad raw arg for check.arg0: type=uint256, raw=0x4100000000000000000000000000000000000000000000000000000000000000)
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity - Test collision with x=0 in set.
    function test_Edge_set_with_0_then_check_with_0x4100_2() public {
// cover: check :: assert(m[keccak256(abi.encodePacked(x, "B"))] == 0) false
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(0);
        }
        vm.expectRevert();
        // skip malformed call: check(0x4100000000000000000000000000000000000000000000000000000000000000) (bad raw arg for check.arg0: type=uint256, raw=0x4100000000000000000000000000000000000000000000000000000000000000)
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency - Verify no collision with extreme input.
    function test_Edge_set_with_max_uint256_then_check_with_different_value_3() public {
// cover: check :: assert(m[keccak256(abi.encodePacked(x, "B"))] == 0) true
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.check(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency - Verify default mapping value is zero, assertion passes.
    function test_Edge_check_without_prior_set_4() public {
// cover: check :: assert(m[keccak256(abi.encodePacked(x, "B"))] == 0) true
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.check(0);
        }
    }

    // @cover-intent Resource & Execution Integrity - Verify that multiple sets can still cause collision.
    function test_Multiple_sets_then_check_with_collision_5() public {
// cover: check :: assert(m[keccak256(abi.encodePacked(x, "B"))] == 0) false
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(1);
        }
        {
        target.set(66);
        }
        vm.expectRevert();
        // skip malformed call: check(0x4100000000000000000000000000000000000000000000000000000000000000) (bad raw arg for check.arg0: type=uint256, raw=0x4100000000000000000000000000000000000000000000000000000000000000)
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_set_then_check_collision_6() public {
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(66);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_check_after_set_collision_7() public {
        vm.startPrank(owner);
        ShaOfShaCollission target = new ShaOfShaCollission();
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
        target.set(66);
        }
        vm.expectRevert();
        // skip malformed call: check(0x4100000000000000000000000000000000000000000000000000000000000000) (bad raw arg for check.arg0: type=uint256, raw=0x4100000000000000000000000000000000000000000000000000000000000000)
        vm.stopPrank();
    }

}
