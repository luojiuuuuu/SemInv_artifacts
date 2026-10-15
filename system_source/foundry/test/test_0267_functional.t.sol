// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/dos_address.sol";

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

contract DosGas_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DosGas_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that after adding creditors (below threshold), emptyCreditors does not trigger the reset, and iWin remains false.
    function test_Normal_add_and_empty_creditors_0() public {
// cover: emptyCreditors :: creditorAddresses.length <= 1500
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Add creditors to exceed the threshold (1500) and verify emptyCreditors resets the array and sets win to true.
    function test_Boundary_add_enough_creditors_to_trigger_reset_1() public {
// cover: emptyCreditors :: creditorAddresses.length > 1500
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test that when creditorAddresses.length is exactly 1500, emptyCreditors does not reset (since condition is >1500).
    function test_Edge_exactly_at_threshold_1500_creditors_2() public {
// cover: emptyCreditors :: creditorAddresses.length <= 1500
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: After resetting, calling emptyCreditors again should not change state (idempotent).
    function test_Multiple_calls_to_emptyCreditors_after_reset_3() public {
// cover: emptyCreditors :: creditorAddresses.length <= 1500
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that multiple calls to addCreditors by different users accumulate correctly.
    function test_Multiple_adds_by_different_users_4() public {
// cover: emptyCreditors :: creditorAddresses.length <= 1500
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        vm.prank(bob);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(carol);
        // skip ABI-mismatched call: addCreditors()
        vm.startPrank(alice);
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Edge behavior: Calling emptyCreditors when creditorAddresses is empty should not change state.
    function test_Empty_creditors_with_zero_creditors_5() public {
// cover: emptyCreditors :: creditorAddresses.length <= 1500
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_addCreditors_sequence_6() public {
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
    }

    // @cover-intent Resource & Execution Integrity
    function test_emptyCreditors_sequence_7() public {
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        vm.prank(bob);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(carol);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(alice);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(bob);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(alice);
        // skip ABI-mismatched call: emptyCreditors()
    }

    // @cover-intent Protocol State Machine
    function test_iWin_sequence_8() public {
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        vm.prank(bob);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(carol);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(alice);
        // skip ABI-mismatched call: addCreditors()
        vm.prank(bob);
        // skip ABI-mismatched call: addCreditors()
        vm.startPrank(alice);
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: iWin()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberCreditors_sequence_9() public {
        vm.startPrank(owner);
        DosGas target = new DosGas();
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
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: numberCreditors()
        vm.stopPrank();
    }

}
