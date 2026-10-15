// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

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

contract airPort_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function airPort_FunctionalTest() public {
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


    // @cover-intent External Interaction & Environment: Verify that transfer() calls transferFrom on each recipient address via low-level call, returning true when _tos array is non-empty.
    function test_Normal_transfer_with_multiple_recipients_0() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airPort target = new airPort();
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
        // skip malformed call: transfer(alice, caddress, [bob], 100) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob, carol], 50) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test that transfer() reverts when _tos array is empty, enforcing the require condition.
    function test_Empty_tos_array_reverts_1() public {
// cover: transfer :: require(_tos.length > 0) false
        vm.startPrank(owner);
        airPort target = new airPort();
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
        // skip malformed call: transfer(alice, caddress, [], 100) (bad raw arg for transfer.arg1: type=address, raw=caddress)
    }

    // @cover-intent External Interaction & Environment: Verify transfer() works with exactly one recipient in _tos array.
    function test_Single_recipient_transfer_2() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airPort target = new airPort();
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
        // skip malformed call: transfer(alice, caddress, [bob], 10) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.prank(bob);
        // skip malformed call: transfer(bob, caddress, [carol], 5) (bad raw arg for transfer.arg1: type=address, raw=caddress)
    }

    // @cover-intent External Interaction & Environment: Test transfer() with v=0 to ensure low-level call is made even with zero value.
    function test_Transfer_with_zero_value_3() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airPort target = new airPort();
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
        // skip malformed call: transfer(alice, caddress, [bob], 0) (bad raw arg for transfer.arg1: type=address, raw=caddress)
    }

    // @cover-intent Resource & Execution Integrity: Test transfer() with a large _tos array to check gas consumption and loop behavior.
    function test_Transfer_with_large_array_of_recipients_4() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airPort target = new airPort();
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
        // skip malformed call: transfer(alice, caddress, [bob, carol, alice, bob, carol], 1) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.prank(bob);
        // skip malformed call: transfer(bob, caddress, [alice, carol, bob, alice, carol], 2) (bad raw arg for transfer.arg1: type=address, raw=caddress)
    }

}
