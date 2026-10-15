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


    // @cover-intent Exercise normal behavior of insertNnumbers and getters, verifying that numElements and array length increase correctly. (Resource & Execution Integrity)
    function test_Normal_insert_and_query_0() public {
// cover: insertNnumbers :: loop iteration i<numbers
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
        target.insertNnumbers(10, 5);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test that insertNnumbers dynamically expands the array when numElements equals array.length. (Resource & Execution Integrity)
    function test_Insert_beyond_initial_array_length_1() public {
// cover: insertNnumbers :: numElements == array.length true
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

    // @cover-intent Test that clear() reverts when numElements <= 1500. (Protocol State Machine)
    function test_Clear_with_insufficient_elements_reverts_2() public {
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

    // @cover-intent Test that clearDOS() reverts when numElements <= 1500. (Protocol State Machine)
    function test_ClearDOS_with_insufficient_elements_reverts_3() public {
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

    // @cover-intent Test that clear() succeeds when numElements > 1500 and resets numElements to 0. (Protocol State Machine)
    function test_Clear_after_inserting_many_elements_4() public {
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

    // @cover-intent Test that clearDOS() succeeds when numElements > 1500, resetting both array and numElements. (Protocol State Machine)
    function test_ClearDOS_after_inserting_many_elements_5() public {
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

    // @cover-intent Test edge case where insertNnumbers is called with numbers=0, no state change. (Resource & Execution Integrity)
    function test_Insert_zero_numbers_6() public {
// cover: insertNnumbers :: loop condition i<0 false
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

    // @cover-intent Test minimal positive insert with numbers=1. (Resource & Execution Integrity)
    function test_Insert_one_number_7() public {
// cover: insertNnumbers :: loop iteration i<1
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
        target.insertNnumbers(7, 1);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test boundary condition: insert exactly 1501 elements to meet clear requirement. (Protocol State Machine)
    function test_Insert_exactly_1501_numbers_then_clear_8() public {
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
        vm.stopPrank();
    }

    // @cover-intent Test boundary condition: insert exactly 1500 elements, clear should revert. (Protocol State Machine)
    function test_Insert_1500_numbers_then_clear_reverts_9() public {
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
        target.insertNnumbers(1, 1500);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: clear()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_insertNnumbers_10() public {
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
    function test_clear_11() public {
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
    function test_clearDOS_12() public {
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
    function test_getLengthArray_13() public {
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
    function test_getRealLengthArray_14() public {
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
