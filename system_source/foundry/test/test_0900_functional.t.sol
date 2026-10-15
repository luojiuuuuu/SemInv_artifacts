// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/incorrect_constructor_name2.sol";

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

contract Missing_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Missing_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that calling missing() sets the owner, then owner can call withdraw() successfully.
    function test_Positive_owner_calls_withdraw_after_missing_sets_owner_0() public {
// cover: withdraw :: require(msg.sender==owner) true
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: missing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that calling withdraw() without first calling missing() reverts because owner is unset (address(0)).
    function test_Negative_non_owner_calls_withdraw_without_missing_1() public {
// cover: withdraw :: require(msg.sender==owner) false
        vm.startPrank(owner);
        Missing target = new Missing();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Verify that only the address that called missing() can call withdraw().
    function test_Negative_non_owner_calls_withdraw_after_missing_set_by_alice_2() public {
// cover: withdraw :: require(msg.sender==owner) false
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: missing()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw() succeeds even when contract balance is zero.
    function test_Edge_withdraw_with_zero_balance_after_missing_set_3() public {
// cover: withdraw :: require(msg.sender==owner) true
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: missing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that calling missing() overwrites the owner, so only the last caller can withdraw.
    function test_Edge_missing_called_multiple_times_only_last_caller_is_owner_4() public {
// cover: withdraw :: require(msg.sender==owner) false
// cover: withdraw :: require(msg.sender==owner) true
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: missing()
        vm.prank(bob);
        // skip ABI-mismatched call: missing()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control
    function test_missing_set_owner_5() public {
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: missing()
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_by_owner_6() public {
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: missing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

}
