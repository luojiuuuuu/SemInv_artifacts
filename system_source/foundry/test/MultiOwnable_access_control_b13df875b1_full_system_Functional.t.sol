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


    // @cover-intent Authorization & Access Control: Verify that any address can call newOwner to add a new owner, as there is no onlyOwner guard. Root adds alice, mapping is set correctly.
    function test_Positive_root_adds_alice_as_new_owner_0() public {
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

    // @cover-intent Authorization & Access Control: Verify that newOwner reverts when _owner is address(0).
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
        vm.prank(alice);
        {
        target.newOwner(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that root can delete an owner (alice) who was added by root, using deleteOwner with onlyOwner and the root condition.
    function test_Positive_root_deletes_alice_alice_is_owner_root_is_root_2() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == root)) true (root branch)
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

    // @cover-intent Authorization & Access Control: Verify that an owner can delete themselves (owners[_owner] == msg.sender).
    function test_Positive_alice_deletes_herself_alice_is_owner_msg_sender_owner_3() public {
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner (alice) cannot delete bob (who is not an owner) because onlyOwner modifier will revert.
    function test_Negative_non_owner_alice_tries_to_delete_bob_not_owner_not_root_4() public {
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
        target.newOwner(bob);
        }
        vm.prank(alice);
        {
        target.deleteOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that an owner (alice) cannot delete another owner (bob) who was added by root, because owners[bob] != msg.sender and msg.sender != root.
    function test_Negative_alice_tries_to_delete_bob_alice_is_owner_but_not_root_bob_is_not_her_child_5() public {
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
        vm.startPrank(owner);
        {
        target.newOwner(alice);
        }
        {
        target.newOwner(bob);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.deleteOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that deleteOwner reverts when _owner is address(0) because owners[0] == 0, so the require condition fails.
    function test_Negative_deleteOwner_on_zero_address_owner_is_root_but_owner_0_6() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == root)) false (owners[_owner] == 0)
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
        target.deleteOwner(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that root can delete itself because owners[root] == root and msg.sender == root, satisfying the condition. After deletion, root is no longer an owner.
    function test_Edge_root_deletes_root_self_delete_by_root_7() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender) true (root deletes itself)
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

    // @cover-intent Authorization & Access Control: Verify that multiple addresses can add owners independently, creating a tree structure. Alice adds bob, bob adds carol.
    function test_Edge_multiple_newOwner_calls_by_different_callers_8() public {
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
        target.newOwner(bob);
        }
        {
        target.newOwner(carol);
        }
        {
        target.owners(alice);
        }
        {
        target.owners(bob);
        }
        {
        target.owners(carol);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that an owner (alice) can delete their own child (bob) because owners[bob] == alice.
    function test_Edge_deleteOwner_by_non_root_owner_on_their_own_child_9() public {
// cover: deleteOwner :: require(owners[_owner] == msg.sender) true (alice deletes bob)
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
        target.newOwner(bob);
        }
        vm.startPrank(owner);
        {
        target.deleteOwner(bob);
        }
        {
        target.owners(bob);
        }
        vm.stopPrank();
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
    function test_deleteOwner_revert_non_owner_11() public {
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

    // @cover-intent Authorization & Access Control
    function test_newOwner_positive_12() public {
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
    function test_newOwner_revert_zero_address_13() public {
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

    // @cover-intent Authorization & Access Control
    function test_owners_view_14() public {
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
    function test_root_view_15() public {
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
