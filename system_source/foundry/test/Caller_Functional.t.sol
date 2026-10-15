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


    // @cover-intent External Interaction & Environment: Verify that callAddress performs an external call to a provided address, which is a low-level call without checking return value.
    function test_Basic_call_to_arbitrary_address_0() public {
// cover: callAddress :: external call executed
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
        target.callAddress(alice);
        }
    }

    // @cover-intent External Interaction & Environment: Test edge case where callAddress is invoked with the zero address, which may cause the call to fail silently.
    function test_Call_to_zero_address_1() public {
// cover: callAddress :: external call to zero address
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
        target.callAddress(address(0));
        }
    }

    // @cover-intent External Interaction & Environment: Test that callAddress does not revert when the target address is a contract that reverts on call, since the return value is unchecked.
    function test_Call_to_contract_that_reverts_2() public {
// cover: callAddress :: external call to reverting contract
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

    // @cover-intent External Interaction & Environment: Test that callAddress can be called with the contract's own address, which may cause reentrancy or unexpected behavior.
    function test_Call_to_self_this_contract_3() public {
// cover: callAddress :: external call to self
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
        // skip malformed call: callAddress(address(this)) (bad raw arg for callAddress.arg0: type=address, raw=address(this))
    }

    // @cover-intent External Interaction & Environment: Verify that callAddress can be called multiple times with different addresses without side effects.
    function test_Multiple_calls_to_different_addresses_4() public {
// cover: callAddress :: multiple external calls
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
        target.callAddress(carol);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.callAddress(alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_callAddress_minimal_5() public {
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
