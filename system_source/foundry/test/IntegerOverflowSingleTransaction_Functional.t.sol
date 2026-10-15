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


    // @cover-intent Resource & Execution Integrity
    function test_count_view_0() public {
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
        target.count();
        }
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 0, 1, "call:count==1");
        }
    }

    // @cover-intent Financial & Accounting
    function test_overflowaddtostate_test_1() public {
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
        // skip malformed call: overflowaddtostate(uint256:1) (bad raw arg for overflowaddtostate.arg0: type=uint256, raw=uint256:1)
        {
            uint256 __v2 = uint256(target.count());
            _assertRelU(__v2, 0, 2, "call:count==2");
        }
    }

    // @cover-intent Financial & Accounting
    function test_overflowmultostate_test_2() public {
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
        // skip malformed call: overflowmultostate(uint256:2) (bad raw arg for overflowmultostate.arg0: type=uint256, raw=uint256:2)
        {
            uint256 __v3 = uint256(target.count());
            _assertRelU(__v3, 0, 2, "call:count==2");
        }
    }

    // @cover-intent Financial & Accounting
    function test_underflowtostate_test_3() public {
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
        // skip malformed call: underflowtostate(uint256:2) (bad raw arg for underflowtostate.arg0: type=uint256, raw=uint256:2)
        {
            uint256 __v4 = uint256(target.count());
            _assertRelU(__v4, 0, 115792089237316195423570985008687907853269984665640564039457584007913129639935, "call:count==115792089237316195423570985008687907853269984665640564039457584007913129639935");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_overflowlocalonly_test_4() public {
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
        // skip malformed call: overflowlocalonly(uint256:1) (bad raw arg for overflowlocalonly.arg0: type=uint256, raw=uint256:1)
        {
            uint256 __v5 = uint256(target.count());
            _assertRelU(__v5, 0, 1, "call:count==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_overflowmulocalonly_test_5() public {
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
        // skip malformed call: overflowmulocalonly(uint256:2) (bad raw arg for overflowmulocalonly.arg0: type=uint256, raw=uint256:2)
        {
            uint256 __v6 = uint256(target.count());
            _assertRelU(__v6, 0, 1, "call:count==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_underflowlocalonly_test_6() public {
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
        // skip malformed call: underflowlocalonly(uint256:2) (bad raw arg for underflowlocalonly.arg0: type=uint256, raw=uint256:2)
        {
            uint256 __v7 = uint256(target.count());
            _assertRelU(__v7, 0, 1, "call:count==1");
        }
    }

}
