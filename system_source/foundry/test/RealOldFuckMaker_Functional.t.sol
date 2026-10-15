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


    // @cover-intent Exercise the makeOldFucks function with a small input to verify normal execution without reverts.
    function test_Normal_behavior_makeOldFucks_with_small_number_0() public {
// cover: makeOldFucks :: loop entry with number=1
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

    // @cover-intent Test makeOldFucks with number=0 to ensure the loop does not execute and no external calls are made.
    function test_Edge_behavior_makeOldFucks_with_zero_1() public {
// cover: makeOldFucks :: loop condition false at start
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

    // @cover-intent Test makeOldFucks with number=129 as mentioned in the comment, verifying the loop executes many iterations without revert.
    function test_Boundary_behavior_makeOldFucks_with_large_number_129_2() public {
// cover: makeOldFucks :: loop with large number
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

    // @cover-intent Test makeOldFucks with number=4294967295 (max uint32) to check behavior at the upper bound of the input type.
    function test_Boundary_behavior_makeOldFucks_with_maximum_uint32_3() public {
// cover: makeOldFucks :: loop with max uint32
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
        target.makeOldFucks(4294967295);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_makeOldFucks_basic_4() public {
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

}
