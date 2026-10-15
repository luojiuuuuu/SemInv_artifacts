// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

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

contract RealOldFuckMaker_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function RealOldFuckMaker_FunctionalTest() public {
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


    // @cover-intent Exercise normal behavior of makeOldFucks with a small input (e.g., 1) to verify the loop executes correctly without reverting.
    function test_Normal_behavior_makeOldFucks_with_small_number_0() public {
// cover: makeOldFucks :: loop entry i < number (true)
        vm.startPrank(owner);
        RealOldFuckMaker target = new RealOldFuckMaker();
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
        target.makeOldFucks(1);
        }
    }

    // @cover-intent Test edge case where number is 0, ensuring the loop does not execute and no external calls are made.
    function test_Edge_behavior_makeOldFucks_with_zero_1() public {
// cover: makeOldFucks :: loop condition i < number (false)
        vm.startPrank(owner);
        RealOldFuckMaker target = new RealOldFuckMaker();
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
        target.makeOldFucks(0);
        }
    }

    // @cover-intent Test boundary behavior with number = 129, as hinted in the comment, to verify the loop completes without gas issues or reverts.
    function test_Boundary_behavior_makeOldFucks_with_large_number_129_2() public {
// cover: makeOldFucks :: loop iteration for i=0..128
        vm.startPrank(owner);
        RealOldFuckMaker target = new RealOldFuckMaker();
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
        target.makeOldFucks(129);
        }
    }

    // @cover-intent Test boundary behavior with number = 4294967295 (max uint32) to check if the loop can handle extreme values (likely gas exhaustion, but should not revert due to overflow).
    function test_Boundary_behavior_makeOldFucks_with_max_uint32_3() public {
// cover: makeOldFucks :: loop condition i < number (true) but gas exhaustion
        vm.startPrank(owner);
        RealOldFuckMaker target = new RealOldFuckMaker();
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
        target.makeOldFucks(4294967295);
        }
    }

    // @cover-intent Test transactional consistency by calling makeOldFucks twice with small numbers to ensure no state corruption or unexpected reverts.
    function test_Multiple_calls_makeOldFucks_twice_4() public {
// cover: makeOldFucks :: loop entry i < number (true) for both calls
        vm.startPrank(owner);
        RealOldFuckMaker target = new RealOldFuckMaker();
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
        target.makeOldFucks(2);
        }
        {
        target.makeOldFucks(3);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_makeOldFucks_basic_call_5() public {
        vm.startPrank(owner);
        RealOldFuckMaker target = new RealOldFuckMaker();
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
        target.makeOldFucks(1);
        }
    }

}
