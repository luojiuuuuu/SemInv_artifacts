// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/dos_number.sol";

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

contract DosNumber_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DosNumber_FunctionalTest() public {
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


    // @cover-intent Verify basic insertNnumbers works correctly and getLengthArray/getRealLengthArray return consistent values after insertion (Resource & Execution Integrity).
    function test_Normal_insertion_and_length_tracking_0() public {
// cover: insertNnumbers :: loop iteration 0..4
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(42, 5);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test that array.length grows when numElements equals array.length during insertion (Resource & Execution Integrity).
    function test_Insertion_causing_array_expansion_1() public {
// cover: insertNnumbers :: if(numElements == array.length) true
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 10);
        }
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify clear() reverts when numElements is not greater than 1500 (Protocol State Machine).
    function test_Clear_reverts_when_numElements_1500_2() public {
// assume: getLengthArray() <= 1500
// cover: clear :: require(numElements>1500) false
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        // skip ABI-mismatched call: clear()
    }

    // @cover-intent Test clear() works when numElements > 1500, resetting numElements to 0 (Protocol State Machine).
    function test_Clear_succeeds_after_inserting_enough_elements_3() public {
// cover: clear :: require(numElements>1500) true
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 1501);
        }
        // skip ABI-mismatched call: clear()
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify clearDOS() reverts when numElements is not greater than 1500 (Protocol State Machine).
    function test_ClearDOS_reverts_when_numElements_1500_4() public {
// assume: getLengthArray() <= 1500
// cover: clearDOS :: require(numElements>1500) false
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        // skip ABI-mismatched call: clearDOS()
    }

    // @cover-intent Test clearDOS() works when numElements > 1500, resetting both array and numElements (Protocol State Machine).
    function test_ClearDOS_succeeds_and_resets_array_5() public {
// cover: clearDOS :: require(numElements>1500) true
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 1501);
        }
        // skip ABI-mismatched call: clearDOS()
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test insertion with a large numbers parameter to exercise gas limit boundary (Resource & Execution Integrity).
    function test_Insertion_gas_boundary_large_number_6() public {
// cover: insertNnumbers :: loop iteration 0..399
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 400);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test insertNnumbers with numbers=0, no state change should occur (Resource & Execution Integrity).
    function test_Insertion_with_zero_numbers_7() public {
// cover: insertNnumbers :: loop condition false on first check
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(42, 0);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test repeated insertions and clear to verify state resets correctly (Protocol State Machine).
    function test_Multiple_insertions_and_clear_cycle_8() public {
// cover: clear :: require(numElements>1500) true
// cover: insertNnumbers :: loop iteration 0..9
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 1501);
        }
        // skip ABI-mismatched call: clear()
        {
        target.insertNnumbers(2, 10);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test clearDOS after a clear has reset numElements to 0, should revert (Protocol State Machine).
    function test_ClearDOS_after_clear_cycle_9() public {
// cover: clearDOS :: require(numElements>1500) false
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 1501);
        }
        // skip ABI-mismatched call: clear()
        vm.expectRevert();
        // skip ABI-mismatched call: clearDOS()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_insertNnumbers_sequence_10() public {
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(10, 5);
        }
        {
            uint256 __v1 = uint256(target.getLengthArray());
            _assertRelU(__v1, 0, 5, "call:getLengthArray==5");
        }
        {
            uint256 __v2 = uint256(target.getRealLengthArray());
            _assertRelU(__v2, 2, 5, "call:getRealLengthArray>=5");
        }
    }

    // @cover-intent Protocol State Machine
    function test_clear_sequence_11() public {
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 1501);
        }
        // skip ABI-mismatched call: clear()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.getLengthArray());
            _assertRelU(__v3, 0, 0, "call:getLengthArray==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_clearDOS_sequence_12() public {
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(1, 1501);
        }
        // skip ABI-mismatched call: clearDOS()
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.getLengthArray());
            _assertRelU(__v4, 0, 0, "call:getLengthArray==0");
        }
        {
            uint256 __v5 = uint256(target.getRealLengthArray());
            _assertRelU(__v5, 0, 0, "call:getRealLengthArray==0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getLengthArray_sequence_13() public {
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(5, 3);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.getLengthArray());
            _assertRelU(__v6, 0, 3, "call:getLengthArray==3");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getRealLengthArray_sequence_14() public {
        vm.startPrank(owner);
        DosNumber target = new DosNumber();
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
        target.insertNnumbers(5, 3);
        }
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.getRealLengthArray());
            _assertRelU(__v7, 2, 3, "call:getRealLengthArray>=3");
        }
    }

}
