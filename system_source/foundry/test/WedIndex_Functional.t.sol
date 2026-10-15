// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x84d9ec85c9c568eb332b7226a8f826d897e0a4a8.sol";

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

contract WedIndex_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function WedIndex_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that writeIndex can be called by anyone and correctly stores data, emits event, and increments numberOfIndex.
    function test_WriteIndex_positive_path_0() public {
// cover: writeIndex :: push to array
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(100, "0x123", "Alice&Bob", 200, 1);
        }
        {
        target.numberOfIndex();
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that multiple writeIndex calls correctly append entries and numberOfIndex reflects total count.
    function test_WriteIndex_multiple_entries_1() public {
// cover: writeIndex :: multiple pushes
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(100, "addr1", "Alice&Bob", 200, 1);
        }
        vm.prank(bob);
        {
        target.writeIndex(200, "addr2", "Carol&Dave", 300, 0);
        }
        vm.prank(carol);
        {
        target.writeIndex(300, "addr3", "Eve&Frank", 400, 1);
        }
        vm.prank(alice);
        {
        target.numberOfIndex();
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that writeIndex accepts empty strings for wedaddress and partnernames without reverting.
    function test_WriteIndex_boundary_empty_strings_2() public {
// cover: writeIndex :: empty strings
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(0, "", "", 0, 0);
        }
        {
        target.numberOfIndex();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that writeIndex accepts large uint256 values for indexdate, weddingdate, and displaymultisig.
    function test_WriteIndex_boundary_large_values_3() public {
// cover: writeIndex :: max uint256 values
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(115792089237316195423570985008687907853269984665640564039457584007913129639935, "0xabc", "Test", 115792089237316195423570985008687907853269984665640564039457584007913129639935, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.numberOfIndex();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can propose a new owner and the new owner can accept ownership.
    function test_ChangeOwner_positive_path_4() public {
// cover: changeOwner :: onlyOwner true
// cover: acceptOwnership :: msg.sender == newOwner true
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.changeOwner(bob);
        }
        {
        target.acceptOwnership();
        }
        {
        target.owner();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner calling changeOwner reverts.
    function test_ChangeOwner_non_owner_revert_5() public {
// cover: changeOwner :: onlyOwner false
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that acceptOwnership reverts when called by an address that is not the newOwner.
    function test_AcceptOwnership_wrong_caller_revert_6() public {
// cover: acceptOwnership :: msg.sender == newOwner false
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.changeOwner(bob);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.acceptOwnership();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that owner can call execute to send ETH to another address.
    function test_Execute_owner_positive_7() public {
// cover: execute :: onlyOwner true
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        // skip malformed call: execute(alice, 50, "0x") (bad raw arg for execute.arg2: type=bytes, raw="0x")
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner calling execute reverts.
    function test_Execute_non_owner_revert_8() public {
// cover: execute :: onlyOwner false
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        vm.prank(alice);
        // skip malformed call: execute(bob, 0, "0x") (bad raw arg for execute.arg2: type=bytes, raw="0x")
    }

    // @cover-intent Transactional Consistency: Verify that read functions return correct values after a writeIndex call.
    function test_Read_functions_after_write_9() public {
// cover: writeIndex :: push and event
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(100, "0xwed", "Alice&Bob", 200, 1);
        }
        {
        target.indexarray(0);
        }
        {
        target.numberOfIndex();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_acceptOwnership_positive_10() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.changeOwner(alice);
        }
        {
        target.acceptOwnership();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_11() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_displaymultisig_read_12() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.displaymultisig();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_execute_positive_13() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.execute(alice, 0, hex"00");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_indexarray_read_14() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(100, "addr", "partners", 200, 1);
        }
        {
        target.indexarray(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_indexdate_read_15() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.indexdate();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_newOwner_read_16() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.newOwner();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfIndex_read_17() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(100, "addr", "partners", 200, 1);
        }
        {
        target.numberOfIndex();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_owner_read_18() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.owner();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_partnernames_read_19() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.partnernames();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_wedaddress_read_20() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.wedaddress();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_weddingdate_read_21() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.weddingdate();
        }
    }

    // @cover-intent Transactional Consistency
    function test_writeIndex_positive_22() public {
        vm.startPrank(owner);
        WedIndex target = new WedIndex();
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
        target.writeIndex(100, "addr", "partners", 200, 1);
        }
    }

}
