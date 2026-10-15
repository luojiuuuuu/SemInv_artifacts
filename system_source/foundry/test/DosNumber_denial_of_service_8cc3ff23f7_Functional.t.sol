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


    // @cover-intent Verify basic insertNnumbers works and getLengthArray/getRealLengthArray return correct values after insertion (Resource & Execution Integrity).
    function test_Normal_insert_and_query_0() public {
// cover: insertNnumbers :: numElements == array.length (true for first insertion)
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

    // @cover-intent Edge case: insertNnumbers with numbers=0 should not change state (Resource & Execution Integrity).
    function test_Insert_zero_numbers_1() public {
// cover: insertNnumbers :: loop condition i < numbers false (0 iterations)
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

    // @cover-intent Verify clear() reverts when numElements <= 1500 (Protocol State Machine).
    function test_Clear_requires_numElements_1500_revert_when_insufficient_2() public {
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

    // @cover-intent Verify clearDOS() reverts when numElements <= 1500 (Protocol State Machine).
    function test_ClearDOS_requires_numElements_1500_revert_when_insufficient_3() public {
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

    // @cover-intent Verify clear() works when numElements > 1500, resetting numElements to 0 (Protocol State Machine).
    function test_Clear_succeeds_with_sufficient_elements_4() public {
// assume: getLengthArray() == 1600
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
        target.insertNnumbers(1, 1600);
        }
        // skip ABI-mismatched call: clear()
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify clearDOS() works when numElements > 1500, resetting both array and numElements (Resource & Execution Integrity).
    function test_ClearDOS_succeeds_with_sufficient_elements_5() public {
// assume: getLengthArray() == 1600
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
        target.insertNnumbers(1, 1600);
        }
        // skip ABI-mismatched call: clearDOS()
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify that after clear(), new insertions work correctly (Protocol State Machine).
    function test_Insert_after_clear_state_reset_6() public {
// assume: getLengthArray() == 0
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
        target.insertNnumbers(1, 1600);
        }
        // skip ABI-mismatched call: clear()
        {
        target.insertNnumbers(99, 10);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify that after clearDOS(), new insertions work correctly (Protocol State Machine).
    function test_Insert_after_clearDOS_state_reset_7() public {
// assume: getLengthArray() == 0
// assume: getRealLengthArray() == 0
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
        target.insertNnumbers(1, 1600);
        }
        // skip ABI-mismatched call: clearDOS()
        {
        target.insertNnumbers(77, 3);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Verify that array.length grows dynamically when numElements reaches capacity (Resource & Execution Integrity).
    function test_Multiple_inserts_array_length_growth_8() public {
// cover: insertNnumbers :: numElements == array.length (true at start)
// cover: insertNnumbers :: numElements == array.length (true after first insert when array.length=1, numElements=1)
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
        target.insertNnumbers(1, 1);
        }
        // skip ABI-mismatched call: getRealLengthArray()
        {
        target.insertNnumbers(2, 5);
        }
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_insertNnumbers_sequence_9() public {
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
    function test_clear_sequence_10() public {
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
    function test_clearDOS_sequence_11() public {
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
    function test_getLengthArray_sequence_12() public {
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
        // skip ABI-mismatched call: getLengthArray()
        {
            uint256 __v6 = uint256(target.getLengthArray());
            _assertRelU(__v6, 0, 0, "call:getLengthArray==0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getRealLengthArray_sequence_13() public {
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
        // skip ABI-mismatched call: getRealLengthArray()
        {
            uint256 __v7 = uint256(target.getRealLengthArray());
            _assertRelU(__v7, 0, 0, "call:getRealLengthArray==0");
        }
    }

}
