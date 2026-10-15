// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/two_mapppings.sol";

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

contract TwoMappings_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TwoMappings_FunctionalTest() public {
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


    // @cover-intent Verify that check passes when n[a] is zero (default mapping value). This tests normal behavior and the invariant that n[a] is always zero for any input a.
    function test_Positive_check_with_default_n_a_0_0() public {
// cover: check :: assert(n[a] == 0) true
        vm.startPrank(owner);
        TwoMappings target = new TwoMappings();
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
        vm.prank(bob);
        {
        target.check(42);
        }
    }

    // @cover-intent Verify that check passes for boundary values like max uint256, since n[a] is still zero. Tests edge behavior for large inputs.
    function test_Edge_check_with_large_uint256_input_1() public {
// cover: check :: assert(n[a] == 0) true
        vm.startPrank(owner);
        TwoMappings target = new TwoMappings();
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
        target.check(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
    }

    // @cover-intent Verify that check reverts when n[a] is non-zero. This tests the semantic invariant boundary of the assertion. Since the contract has no setter for n, we simulate a non-zero n[a] via vm_stores.
    function test_Negative_check_after_n_a_is_set_to_non_zero_simulated_via_prestate_2() public {
// cover: check :: assert(n[a] == 0) false
        vm.startPrank(owner);
        TwoMappings target = new TwoMappings();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(80084422859880547211683076133703299733277748156566366325829078699459944778998)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.check(0);
        }
    }

    // @cover-intent Transactional Consistency
    function test_check_assertion_pass_3() public {
        vm.startPrank(owner);
        TwoMappings target = new TwoMappings();
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

}
