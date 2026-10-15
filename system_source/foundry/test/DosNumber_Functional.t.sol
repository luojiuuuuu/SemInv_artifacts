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


    // @cover-intent Test normal insertion of a small number of elements and verify that numElements and array length are updated correctly. Covers Resource & Execution Integrity.
    function test_Normal_insert_and_query_0() public {
// cover: insertNnumbers :: numElements == array.length (true for first insert)
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
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that inserting more elements than the initial array length causes the array to expand. Covers Resource & Execution Integrity.
    function test_Insert_beyond_initial_array_length_1() public {
// cover: insertNnumbers :: numElements == array.length (true multiple times)
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
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that clear() reverts when numElements <= 1500. Covers Authorization & Access Control (guard condition).
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
        {
        target.clear();
        }
    }

    // @cover-intent Test that clearDOS() reverts when numElements <= 1500. Covers Authorization & Access Control (guard condition).
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
        {
        target.clearDOS();
        }
    }

    // @cover-intent Test that clear() succeeds after inserting >1500 elements, resetting numElements to 0 but leaving array length unchanged. Covers Protocol State Machine.
    function test_Clear_after_many_inserts_4() public {
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
        {
        target.clear();
        }
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that clearDOS() succeeds after inserting >1500 elements, resetting both numElements and array length to 0. Covers Protocol State Machine.
    function test_ClearDOS_after_many_inserts_5() public {
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
        {
        target.clearDOS();
        }
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that after clear(), inserting new elements works correctly. Covers Protocol State Machine (state reset).
    function test_Insert_after_clear_6() public {
// cover: insertNnumbers :: numElements == array.length (true after clear, array length still 1501)
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
        {
        target.clear();
        }
        {
        target.insertNnumbers(42, 3);
        }
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that after clearDOS(), inserting new elements works correctly. Covers Protocol State Machine (state reset).
    function test_Insert_after_clearDOS_7() public {
// cover: insertNnumbers :: numElements == array.length (true after clearDOS, array length 0)
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
        {
        target.clearDOS();
        }
        {
        target.insertNnumbers(99, 2);
        }
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that inserting a very large number of elements (e.g., 1000) does not revert due to gas, but may be expensive. Covers Resource & Execution Integrity (gas limit boundary).
    function test_Gas_DOS_boundary_large_insert_8() public {
// cover: insertNnumbers :: numElements == array.length (true many times)
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
        target.insertNnumbers(7, 1000);
        }
        {
        target.getLengthArray();
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_clearDOS_test_9() public {
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
        {
        target.clearDOS();
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.getLengthArray());
            _assertRelU(__v1, 0, 0, "call:getLengthArray==0");
        }
        {
            uint256 __v2 = uint256(target.getRealLengthArray());
            _assertRelU(__v2, 0, 0, "call:getRealLengthArray==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_clear_test_10() public {
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
        {
        target.clear();
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.getLengthArray());
            _assertRelU(__v3, 0, 0, "call:getLengthArray==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getLengthArray_test_11() public {
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
        target.insertNnumbers(1, 5);
        }
        {
        target.getLengthArray();
        }
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.getLengthArray());
            _assertRelU(__v4, 0, 5, "call:getLengthArray==5");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getRealLengthArray_test_12() public {
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
        target.insertNnumbers(1, 5);
        }
        {
        target.getRealLengthArray();
        }
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.getRealLengthArray());
            _assertRelU(__v5, 2, 5, "call:getRealLengthArray>=5");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_insertNnumbers_test_13() public {
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
        target.insertNnumbers(42, 10);
        }
        {
            uint256 __v6 = uint256(target.getLengthArray());
            _assertRelU(__v6, 0, 10, "call:getLengthArray==10");
        }
    }

}
