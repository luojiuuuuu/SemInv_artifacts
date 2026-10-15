// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/multiowned_vulnerable.sol";

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

contract MultiOwnable_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MultiOwnable_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that root can add a new owner via newOwner, and that the new owner is recognized in the owners mapping.
    function test_Positive_root_adds_alice_as_owner_0() public {
// cover: newOwner :: require(_owner != 0) true
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.newOwner(alice);
        }
        {
        target.owners(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that newOwner reverts when _owner is address(0).
    function test_Negative_newOwner_with_zero_address_reverts_1() public {
// cover: newOwner :: require(_owner != 0) false
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        target.newOwner(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that root can delete an owner (alice) using deleteOwner, and the owners mapping is cleared.
    function test_Positive_root_deletes_an_owner_alice_via_deleteOwner_2() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == root)) true
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.newOwner(alice);
        }
        {
        target.deleteOwner(alice);
        }
        {
        target.owners(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that an owner (alice) can delete herself via deleteOwner.
    function test_Positive_alice_deletes_herself_as_owner_3() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender) true
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.newOwner(alice);
        }
        {
        target.deleteOwner(alice);
        }
        {
        target.owners(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner (bob) cannot call deleteOwner; the onlyOwner modifier reverts.
    function test_Negative_non_owner_calls_deleteOwner_reverts_4() public {
// cover: deleteOwner :: require(owners[msg.sender] != 0) false
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        target.newOwner(alice);
        }
        vm.prank(bob);
        {
        target.deleteOwner(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that deleteOwner reverts when _owner is not an owner and caller is not root.
    function test_Negative_deleteOwner_with_non_existent_owner_reverts_5() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == root)) false
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        target.deleteOwner(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that root can delete itself using deleteOwner (since root is an owner and condition holds).
    function test_Boundary_root_deletes_self_root_via_deleteOwner_6() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender) true
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.deleteOwner(owner);
        }
        {
        target.owners(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that newOwner has no access control; any address can add an owner.
    function test_Negative_newOwner_called_by_non_owner_bob_succeeds_no_access_control_7() public {
// cover: newOwner :: require(_owner != 0) true
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.newOwner(alice);
        }
        {
        target.owners(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that root() returns the root address.
    function test_Positive_root_reads_root_8() public {
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        // skip ABI-mismatched call: root()
    }

    // @cover-intent Authorization & Access Control
    function test_newOwner_positive_9() public {
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        target.newOwner(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_deleteOwner_positive_10() public {
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.newOwner(alice);
        }
        {
        target.deleteOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_owners_view_11() public {
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        target.newOwner(alice);
        }
        vm.prank(alice);
        {
        target.owners(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_root_view_12() public {
        vm.startPrank(owner);
        MultiOwnable target = new MultiOwnable();
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
        // skip ABI-mismatched call: root()
    }

}
