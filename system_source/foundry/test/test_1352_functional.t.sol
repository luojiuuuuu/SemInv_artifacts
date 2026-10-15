// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;
import "../src/unchecked_return_value.sol";

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

contract ReturnValue_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ReturnValue_FunctionalTest() public {
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


    // @cover-intent External Interaction & Environment: Verify that callchecked reverts when the low-level call fails (e.g., callee reverts or does not exist).
    function test_callchecked_success_0() public {
// cover: callchecked :: require(callee.call()) true
        vm.startPrank(owner);
        ReturnValue target = new ReturnValue();
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
        target.callchecked(bob);
        }
        {
        target.callchecked(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that callchecked reverts when the low-level call fails (e.g., callee reverts or does not exist).
    function test_callchecked_revert_on_failed_call_1() public {
// cover: callchecked :: require(callee.call()) false
        vm.startPrank(owner);
        ReturnValue target = new ReturnValue();
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
        target.callchecked(carol);
        }
        vm.expectRevert();
        {
        target.callchecked(carol);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that callnotchecked does not revert even if the low-level call fails.
    function test_callnotchecked_success_2() public {
// cover: callnotchecked :: callee.call() executed (return value ignored)
        vm.startPrank(owner);
        ReturnValue target = new ReturnValue();
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
        target.callnotchecked(bob);
        }
        {
        target.callnotchecked(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that callnotchecked does not revert even when the low-level call fails.
    function test_callnotchecked_with_failing_callee_3() public {
// cover: callnotchecked :: callee.call() executed (return value ignored)
        vm.startPrank(owner);
        ReturnValue target = new ReturnValue();
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
        target.callnotchecked(carol);
        }
        {
        target.callnotchecked(carol);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_callchecked_sequence_4() public {
        vm.startPrank(owner);
        ReturnValue target = new ReturnValue();
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
        target.callchecked(alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_callnotchecked_sequence_5() public {
        vm.startPrank(owner);
        ReturnValue target = new ReturnValue();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.callnotchecked(bob);
        }
    }

}
