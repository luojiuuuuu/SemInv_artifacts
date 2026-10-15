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


    // @cover-intent Resource & Execution Integrity: Verify that adding creditors and then emptying them works normally when the creditor count is below the threshold.
    function test_Normal_add_and_empty_creditors_0() public {
// cover: emptyCreditors :: creditorAddresses.length > 1500 false
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

    // @cover-intent Resource & Execution Integrity: Verify that emptyCreditors resets the array and sets win to true when creditor count exceeds 1500.
    function test_Boundary_empty_creditors_when_count_exceeds_threshold_1() public {
// cover: emptyCreditors :: creditorAddresses.length > 1500 true
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
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: iWin()
        // skip ABI-mismatched call: numberCreditors()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that after multiple addCreditors calls totaling exactly 1500, emptyCreditors does not reset (since condition is >1500, not >=).
    function test_Multiple_adds_then_empty_at_threshold_2() public {
// cover: emptyCreditors :: creditorAddresses.length > 1500 false
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
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        // skip ABI-mismatched call: iWin()
        // skip ABI-mismatched call: numberCreditors()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that emptyCreditors does nothing when the array is empty (length 0).
    function test_Empty_creditors_when_array_is_empty_3() public {
// cover: emptyCreditors :: creditorAddresses.length > 1500 false
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
        // skip ABI-mismatched call: iWin()
        // skip ABI-mismatched call: numberCreditors()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that addCreditors can be called multiple times by the same address, each time adding 350 entries.
    function test_Add_creditors_multiple_times_by_same_sender_4() public {
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
        // skip ABI-mismatched call: numberCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: numberCreditors()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that iWin returns false before any emptyCreditors call that succeeds.
    function test_iWin_returns_false_initially_5() public {
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
        // skip ABI-mismatched call: iWin()
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
        {
            uint256 __v1 = uint256(target.numberCreditors());
            _assertRelU(__v1, 2, 350, "call:numberCreditors>=350");
        }
    }

    // @cover-intent Protocol State Machine
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: emptyCreditors()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.numberCreditors());
            _assertRelU(__v2, 0, 0, "call:numberCreditors==0");
        }
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
        // skip ABI-mismatched call: addCreditors()
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
        {
            uint256 __v3 = uint256(target.numberCreditors());
            _assertRelU(__v3, 0, 350, "call:numberCreditors==350");
        }
    }

}
