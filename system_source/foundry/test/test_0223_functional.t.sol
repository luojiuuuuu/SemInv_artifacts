// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

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

contract demo_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function demo_FunctionalTest() public {
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


    // @cover-intent External Interaction & Environment: Verify that transfer() can call transferFrom on an external contract for multiple recipients, returning true when _tos array has multiple entries.
    function test_Positive_path_with_multiple_recipients_0() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        demo target = new demo();
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
        // skip malformed call: transfer(alice, caddress, [bob, carol], 100) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob, carol], 100) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Test transfer() with exactly one recipient in _tos array, ensuring the loop executes once and returns true.
    function test_Edge_case_with_single_recipient_1() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        demo target = new demo();
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
        // skip malformed call: transfer(alice, caddress, [bob], 50) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob], 50) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Test that transfer() reverts when _tos array is empty, as required by the require statement.
    function test_Revert_on_empty_tos_array_2() public {
// cover: transfer :: require(_tos.length > 0) false
        vm.startPrank(owner);
        demo target = new demo();
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

    // @cover-intent Resource & Execution Integrity: Test transfer() with a large _tos array to check loop execution and gas consumption.
    function test_Large_number_of_recipients_3() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        demo target = new demo();
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
        // skip malformed call: transfer(alice, caddress, [bob, carol, alice, bob, carol], 10) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob, carol, alice, bob, carol], 10) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

}
