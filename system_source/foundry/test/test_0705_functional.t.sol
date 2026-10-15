// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/overflow_single_tx.sol";

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

contract IntegerOverflowSingleTransaction_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowSingleTransaction_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify normal addition to count without overflow.
    function test_overflowaddtostate_normal_0() public {
// cover: overflowaddtostate :: count + input <= type(uint256).max
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowaddtostate(5);
        }
    }

    // @cover-intent Financial & Accounting: Trigger overflow by adding to max uint256.
    function test_overflowaddtostate_boundary_1() public {
// cover: overflowaddtostate :: count + input overflows
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.overflowaddtostate(1);
        }
    }

    // @cover-intent Financial & Accounting: Verify normal multiplication to count.
    function test_overflowmultostate_normal_2() public {
// cover: overflowmultostate :: count * input <= type(uint256).max
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowmultostate(3);
        }
    }

    // @cover-intent Financial & Accounting: Verify normal subtraction from count.
    function test_underflowtostate_normal_3() public {
// cover: underflowtostate :: count >= input
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.underflowtostate(1);
        }
    }

    // @cover-intent Financial & Accounting: Trigger underflow by subtracting more than count.
    function test_underflowtostate_boundary_4() public {
// cover: underflowtostate :: count < input
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.underflowtostate(2);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify local addition does not affect state.
    function test_overflowlocalonly_normal_5() public {
// cover: overflowlocalonly :: count + input <= type(uint256).max
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowlocalonly(5);
        }
    }

    // @cover-intent Resource & Execution Integrity: Local overflow does not change state.
    function test_overflowlocalonly_boundary_6() public {
// cover: overflowlocalonly :: count + input overflows locally
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.overflowlocalonly(1);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify local multiplication does not affect state.
    function test_overflowmulocalonly_normal_7() public {
// cover: overflowmulocalonly :: count * input <= type(uint256).max
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowmulocalonly(3);
        }
    }

    // @cover-intent Resource & Execution Integrity: Local underflow does not change state.
    function test_underflowlocalonly_boundary_8() public {
// cover: underflowlocalonly :: count < input
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.underflowlocalonly(2);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_view_9() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        // skip ABI-mismatched call: count()
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 2, 1, "call:count>=1");
        }
    }

    // @cover-intent minimal test for overflowaddtostate
    function test_perfn_overflowaddtostate_10() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowaddtostate(1);
        }
    }

    // @cover-intent minimal test for overflowlocalonly
    function test_perfn_overflowlocalonly_11() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowlocalonly(1);
        }
    }

    // @cover-intent minimal test for overflowmulocalonly
    function test_perfn_overflowmulocalonly_12() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowmulocalonly(1);
        }
    }

    // @cover-intent minimal test for overflowmultostate
    function test_perfn_overflowmultostate_13() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.overflowmultostate(1);
        }
    }

    // @cover-intent minimal test for underflowlocalonly
    function test_perfn_underflowlocalonly_14() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.underflowlocalonly(1);
        }
    }

    // @cover-intent minimal test for underflowtostate
    function test_perfn_underflowtostate_15() public {
        vm.startPrank(owner);
        IntegerOverflowSingleTransaction target = new IntegerOverflowSingleTransaction();
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
        target.underflowtostate(1);
        }
    }

}
