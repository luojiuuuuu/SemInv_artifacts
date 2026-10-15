// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/unprotected0.sol";

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

contract Unprotected_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Unprotected_FunctionalTest() public {
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


    // @cover-intent Verify that changeOwner is unprotected and any address (alice) can change the owner, violating the intended access control.
    function test_Authorization_Access_Control_Unprotected_changeOwner_allows_any_caller_to_change_owner_0() public {
// cover: changeOwner :: require(msg.sender==owner) false (no require)
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(alice);
        }
    }

    // @cover-intent Show that after alice changes owner to herself, bob can also change owner, demonstrating persistent lack of access control.
    function test_Authorization_Access_Control_Owner_can_be_changed_by_non_owner_bob_after_alice_changed_it_1() public {
// cover: changeOwner :: require(msg.sender==owner) false (no require)
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(alice);
        }
        vm.prank(bob);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Verify that the original owner (deployer) can be overwritten by any address, including carol.
    function test_Authorization_Access_Control_Original_owner_can_be_overwritten_by_any_address_2() public {
// cover: changeOwner :: require(msg.sender==owner) false (no require)
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.changeOwner(carol);
        }
    }

    // @cover-intent Test edge case where new owner is address(0) – no revert, owner becomes zero address.
    function test_Authorization_Access_Control_changeOwner_with_zero_address_as_new_owner_3() public {
// cover: changeOwner :: require(msg.sender==owner) false (no require)
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Test that setting owner to the same address works without revert.
    function test_Authorization_Access_Control_changeOwner_with_same_address_as_current_owner_4() public {
// cover: changeOwner :: require(msg.sender==owner) false (no require)
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(alice);
        }
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_unprotected_5() public {
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(bob);
        }
    }

}
