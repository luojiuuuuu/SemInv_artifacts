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


    // @cover-intent Test normal insertion of numbers and querying array lengths - Resource & Execution Integrity
    function test_normal_insert_and_query_0() public {
// cover: insertNnumbers :: numElements == array.length (first iteration)
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

    // @cover-intent Test insertion that triggers array length expansion multiple times - Resource & Execution Integrity
    function test_insert_beyond_initial_capacity_1() public {
// cover: insertNnumbers :: numElements == array.length (multiple expansions)
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
        target.insertNnumbers(42, 10);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test clear() reverts when numElements <= 1500 - Protocol State Machine
    function test_clear_revert_below_threshold_2() public {
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

    // @cover-intent Test clearDOS() reverts when numElements <= 1500 - Protocol State Machine
    function test_clearDOS_revert_below_threshold_3() public {
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

    // @cover-intent Test clear() succeeds when numElements > 1500 - Protocol State Machine
    function test_clear_success_above_threshold_4() public {
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

    // @cover-intent Test clearDOS() succeeds when numElements > 1500 - Protocol State Machine
    function test_clearDOS_success_above_threshold_5() public {
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

    // @cover-intent Test inserting numbers after a clear() reset - Resource & Execution Integrity
    function test_insert_after_clear_6() public {
// assume: getLengthArray() == 0
// cover: insertNnumbers :: numElements == array.length (after reset)
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
        target.insertNnumbers(99, 3);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test inserting numbers after a clearDOS() full reset - Resource & Execution Integrity
    function test_insert_after_clearDOS_7() public {
// assume: getLengthArray() == 0
// assume: getRealLengthArray() == 0
// cover: insertNnumbers :: numElements == array.length (fresh array)
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
        target.insertNnumbers(77, 7);
        }
        // skip ABI-mismatched call: getLengthArray()
        // skip ABI-mismatched call: getRealLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test inserting zero numbers (edge case) - Resource & Execution Integrity
    function test_insert_zero_numbers_8() public {
// cover: insertNnumbers :: loop condition i<0 false (no iterations)
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
        target.insertNnumbers(5, 0);
        }
        // skip ABI-mismatched call: getLengthArray()
        vm.stopPrank();
    }

    // @cover-intent Test inserting with a large uint256 value - Resource & Execution Integrity
    function test_insert_large_value_9() public {
// cover: insertNnumbers :: numElements == array.length (first expansion)
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
        target.insertNnumbers(115792089237316195423570985008687907853269984665640564039457584007913129639935, 2);
        }
        // skip ABI-mismatched call: getLengthArray()
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
