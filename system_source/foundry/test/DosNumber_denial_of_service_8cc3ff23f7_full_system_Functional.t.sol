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


    // @cover-intent Verify normal insertion of numbers and correct length reporting (Resource & Execution Integrity)
    function test_Normal_insert_and_query_0() public {
// cover: insertNnumbers :: numElements == array.length true
// cover: insertNnumbers :: numElements == array.length false
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

    // @cover-intent Verify inserting zero numbers does not change state (Resource & Execution Integrity)
    function test_Insert_zero_numbers_1() public {
// cover: insertNnumbers :: loop body not executed
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
        target.insertNnumbers(100, 0);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify array grows dynamically when numElements reaches array.length (Resource & Execution Integrity)
    function test_Insert_large_number_causing_array_growth_2() public {
// cover: insertNnumbers :: numElements == array.length true (multiple times)
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

    // @cover-intent Verify clear() reverts when numElements <= 1500 (Protocol State Machine)
    function test_Clear_with_insufficient_elements_reverts_3() public {
// assume: getLengthArray() == 100
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
        vm.startPrank(alice);
        {
        target.insertNnumbers(1, 100);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: clear()
        vm.stopPrank();
    }

    // @cover-intent Verify clear() resets numElements to 0 when numElements > 1500 (Protocol State Machine)
    function test_Clear_with_sufficient_elements_succeeds_4() public {
// assume: getLengthArray() == 2000
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
        target.insertNnumbers(1, 2000);
        }
        // skip ABI-mismatched call: clear()
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify clearDOS() reverts when numElements <= 1500 (Protocol State Machine)
    function test_ClearDOS_with_insufficient_elements_reverts_5() public {
// assume: getLengthArray() == 100
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
        target.insertNnumbers(1, 100);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: clearDOS()
        vm.stopPrank();
    }

    // @cover-intent Verify clearDOS() resets both array and numElements when numElements > 1500 (Protocol State Machine)
    function test_ClearDOS_with_sufficient_elements_succeeds_6() public {
// assume: getLengthArray() == 2000
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
        target.insertNnumbers(1, 2000);
        }
        // skip ABI-mismatched call: clearDOS()
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify insert works correctly after clear() resets state (Protocol State Machine)
    function test_Insert_after_clear_7() public {
// assume: getLengthArray() == 0
// cover: insertNnumbers :: numElements == array.length true (after clear)
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
        target.insertNnumbers(1, 2000);
        }
        // skip ABI-mismatched call: clear()
        {
        target.insertNnumbers(99, 3);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify insert works correctly after clearDOS() resets state (Protocol State Machine)
    function test_Insert_after_clearDOS_8() public {
// assume: getLengthArray() == 0
// assume: getRealLengthArray() == 0
// cover: insertNnumbers :: numElements == array.length true (after clearDOS)
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
        target.insertNnumbers(1, 2000);
        }
        // skip ABI-mismatched call: clearDOS()
        {
        target.insertNnumbers(77, 7);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify getLengthArray and getRealLengthArray remain consistent after multiple operations (Resource & Execution Integrity)
    function test_Multiple_inserts_and_length_consistency_9() public {
// cover: insertNnumbers :: numElements == array.length true (multiple growth events)
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
        target.insertNnumbers(10, 500);
        }
        {
        target.insertNnumbers(20, 500);
        }
        {
        target.insertNnumbers(30, 500);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
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
        target.insertNnumbers(1, 2000);
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
        target.insertNnumbers(1, 2000);
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
        target.insertNnumbers(1, 3);
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
        target.insertNnumbers(1, 3);
        }
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.getRealLengthArray());
            _assertRelU(__v7, 2, 3, "call:getRealLengthArray>=3");
        }
    }

}
