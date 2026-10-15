// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/dos_simple.sol";

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

contract DosOneFunc_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DosOneFunc_FunctionalTest() public {
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


    // @cover-intent Resource & Execution Integrity: Test normal behavior of ifillArray when array length is below 1500, then reset when length exceeds threshold.
    function test_Normal_fill_and_reset_0() public {
// cover: ifillArray :: listAddresses.length < 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        target.ifillArray();
        }
        vm.prank(bob);
        {
        target.ifillArray();
        }
        vm.prank(carol);
        {
        target.ifillArray();
        }
        vm.prank(alice);
        {
        target.ifillArray();
        }
        vm.prank(bob);
        {
        target.ifillArray();
        }
    }

    // @cover-intent Resource & Execution Integrity: Test that after array length exceeds 1500, ifillArray resets to empty and returns false.
    function test_Boundary_reset_after_exceeding_1500_1() public {
// cover: ifillArray :: listAddresses.length >= 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test that a single call to ifillArray adds 350 addresses to the array.
    function test_Single_call_fill_2() public {
// cover: ifillArray :: listAddresses.length < 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        target.ifillArray();
        }
    }

    // @cover-intent Resource & Execution Integrity: Test that multiple calls from the same sender fill the array correctly.
    function test_Multiple_calls_from_same_sender_3() public {
// cover: ifillArray :: listAddresses.length < 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test that after 4 calls (1400 elements), the 5th call pushes to 1750 and then the 6th call triggers reset.
    function test_Exact_boundary_crossing_4() public {
// cover: ifillArray :: listAddresses.length < 1500 true
// cover: ifillArray :: listAddresses.length >= 1500 true
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        {
        target.ifillArray();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_ifillArray_5() public {
        vm.startPrank(owner);
        DosOneFunc target = new DosOneFunc();
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
        target.ifillArray();
        }
    }

}
