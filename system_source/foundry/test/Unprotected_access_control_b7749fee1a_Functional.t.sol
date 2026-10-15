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


    // @cover-intent Verify that changeOwner can be called by any address (not just the current owner) due to missing onlyowner modifier, violating access control.
    function test_Authorization_Access_Control_Unprotected_owner_change_by_any_caller_0() public {
// cover: changeOwner :: owner = _newOwner
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

    // @cover-intent Show that the original deployer (owner) can change owner, and then a non-owner can also change owner, demonstrating lack of protection.
    function test_Authorization_Access_Control_Owner_change_by_original_deployer_then_by_another_1() public {
// cover: changeOwner :: owner = _newOwner
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
        vm.prank(owner);
        {
        target.changeOwner(alice);
        }
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Verify that a non-owner can set themselves as owner, which should be restricted.
    function test_Authorization_Access_Control_Owner_change_to_self_by_non_owner_2() public {
// cover: changeOwner :: owner = _newOwner
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

    // @cover-intent Test edge case where owner is set to address(0), which could lock ownership.
    function test_Authorization_Access_Control_Owner_change_to_zero_address_3() public {
// cover: changeOwner :: owner = _newOwner
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

    // @cover-intent Verify that owner can be changed multiple times by different callers, showing no access control.
    function test_Authorization_Access_Control_Multiple_owner_changes_in_sequence_4() public {
// cover: changeOwner :: owner = _newOwner
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
        vm.prank(bob);
        {
        target.changeOwner(carol);
        }
        vm.prank(carol);
        {
        target.changeOwner(alice);
        }
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
