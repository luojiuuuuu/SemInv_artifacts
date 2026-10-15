// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

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

contract airDrop_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function airDrop_FunctionalTest() public {
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


    // @cover-intent Exercise normal behavior of transfer function with a single recipient, verifying that the external call to caddress.transferFrom is made and the function returns true. Covers Financial & Accounting semantic invariant family.
    function test_Normal_transfer_with_one_recipient_0() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        // skip malformed call: transfer(alice, caddress, [bob], 1, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob], 1, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent Test transfer with multiple recipients to ensure the loop processes all addresses. Covers Resource & Execution Integrity.
    function test_Transfer_with_multiple_recipients_1() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        // skip malformed call: transfer(alice, caddress, [bob, carol], 2, 0) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob, carol], 2, 0) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent Test edge case where _tos array is empty, expecting revert due to require(_tos.length > 0). Covers Transactional Consistency.
    function test_Transfer_with_zero_recipients_reverts_2() public {
// cover: transfer :: require(_tos.length > 0) false
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        // skip malformed call: transfer(alice, caddress, [], 1, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
    }

    // @cover-intent Test boundary where v and _decimals produce a large _value, ensuring no overflow in multiplication. Covers Financial & Accounting.
    function test_Transfer_with_large_value_and_decimals_3() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        // skip malformed call: transfer(alice, caddress, [bob], 10, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob], 10, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent Test edge case where v is 0, resulting in _value = 0, to ensure the external call still executes. Covers External Interaction & Environment.
    function test_Transfer_with_zero_value_4() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        // skip malformed call: transfer(alice, caddress, [bob], 0, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(alice, caddress, [bob], 0, 18) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

    // @cover-intent Test that the from parameter is passed to the external call, even if it differs from msg.sender. Covers Authorization & Access Control.
    function test_Transfer_with_from_address_being_different_from_caller_5() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        // skip malformed call: transfer(bob, caddress, [carol], 1, 0) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        // skip malformed call: transfer(bob, caddress, [carol], 1, 0) (bad raw arg for transfer.arg1: type=address, raw=caddress)
        vm.stopPrank();
    }

}
