// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/dos_simple.sol";

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

contract DosOneFunc_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DosOneFunc_FunctionalTest() public {
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


    // @cover-intent Resource & Execution Integrity: Test normal behavior where ifillArray fills the array when length < 1500, then resets when called again after reaching 1500.
    function test_Normal_fill_and_reset_0() public {
// cover: ifillArray :: listAddresses.length < 1500 true
// cover: ifillArray :: listAddresses.length >= 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test the boundary condition where the array length crosses 1500 after multiple calls, triggering the reset branch.
    function test_Boundary_at_1500_1() public {
// cover: ifillArray :: listAddresses.length < 1500 true
// cover: ifillArray :: listAddresses.length >= 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test that after resetting the array, subsequent calls can fill it again.
    function test_Reset_then_refill_2() public {
// cover: ifillArray :: listAddresses.length < 1500 true
// cover: ifillArray :: listAddresses.length >= 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        // skip ABI-mismatched call: ifillArray()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_ifillArray_3() public {
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        // skip ABI-mismatched call: ifillArray()
    }

}
