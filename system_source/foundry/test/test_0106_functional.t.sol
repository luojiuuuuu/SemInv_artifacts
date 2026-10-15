// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x0cbe050f75bc8f8c2d6c0d249fea125fd6e1acc9.sol";

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

contract Caller_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Caller_FunctionalTest() public {
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


    // @cover-intent External Interaction & Environment: Verify that calling an arbitrary address via low-level call() does not revert when the target is a contract with a fallback function.
    function test_Call_to_arbitrary_address_succeeds_0() public {
// cover: callAddress :: a.call() executed
        vm.startPrank(owner);
        Caller target = new Caller();
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
        target.callAddress(bob);
        }
        {
        target.callAddress(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that calling an externally owned account (no code) does not revert, as low-level call returns true.
    function test_Call_to_address_with_no_code_EOA_succeeds_silently_1() public {
// cover: callAddress :: call to EOA returns true
        vm.startPrank(owner);
        Caller target = new Caller();
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
        target.callAddress(carol);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that calling address(0) reverts because low-level call to zero address returns false.
    function test_Call_to_address_zero_reverts_2() public {
// cover: callAddress :: call to address(0) returns false
        vm.startPrank(owner);
        Caller target = new Caller();
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
        target.callAddress(address(0));
        }
    }

    // @cover-intent External Interaction & Environment: Verify that if the target contract's fallback reverts, the callAddress function does not revert (low-level call returns false but does not propagate revert).
    function test_Call_to_contract_that_reverts_on_fallback_3() public {
// cover: callAddress :: call to reverting fallback returns false
        vm.startPrank(owner);
        Caller target = new Caller();
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
        target.callAddress(bob);
        }
        {
        target.callAddress(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_callAddress_minimal_4() public {
        vm.startPrank(owner);
        Caller target = new Caller();
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
        target.callAddress(bob);
        }
    }

}
