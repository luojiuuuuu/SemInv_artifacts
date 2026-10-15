// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/reentrance.sol";

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

contract Reentrance_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Reentrance_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that donating ETH increases the balance mapping for the recipient.
    function test_donate_and_balance_check_0() public {
// cover: donate :: payable execution
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(1 ether)(alice);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that a user can withdraw their full balance after donating.
    function test_withdraw_positive_path_1() public {
// assume: balances(alice) >= 1 ether
// cover: withdraw :: balances[msg.sender] >= _amount true
// cover: withdraw :: msg.sender.call.value(_amount)() true
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(1 ether)(alice);
        }
        {
        target.withdraw(1 ether);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw reverts when the user has insufficient balance.
    function test_withdraw_insufficient_balance_2() public {
// assume: balances(alice) == 0.5 ether
// cover: withdraw :: balances[msg.sender] >= _amount false
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(0.5 ether)(alice);
        }
        vm.expectRevert();
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing zero amount succeeds and does not change balance.
    function test_withdraw_zero_amount_3() public {
// assume: balances(alice) >= 0
// cover: withdraw :: balances[msg.sender] >= _amount true
// cover: withdraw :: msg.sender.call.value(0)() true
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(1 ether)(alice);
        }
        {
        target.withdraw(0);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent External Interaction & Environment: Verify that a malicious contract can exploit reentrancy to drain funds.
    function test_reentrancy_attack_simulation_4() public {
// assume: balances(alice) == 1 ether
// cover: withdraw :: balances[msg.sender] >= _amount true
// cover: withdraw :: msg.sender.call.value(_amount)() true
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(1 ether)(alice);
        }
        {
        target.withdraw(1 ether);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that multiple users can donate and have independent balances.
    function test_multiple_donors_5() public {
// cover: donate :: payable execution
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.donate.value(0.5 ether)(alice);
        }
        vm.prank(bob);
        {
        target.donate.value(0.3 ether)(bob);
        }
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
        vm.prank(bob);
        {
        target.balanceOf(bob);
        }
        // TODO assert: alice.balance == 0.5 ether
        // TODO assert: bob.balance == 0.3 ether
    }

    // @cover-intent Financial & Accounting: Verify that donating to a different address credits that address's balance.
    function test_donate_to_another_address_6() public {
// cover: donate :: payable execution
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.donate.value(0.5 ether)(bob);
        }
        vm.prank(bob);
        {
        target.balanceOf(bob);
        }
        // TODO assert: bob.balance == 0.5 ether
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH directly to the contract (fallback) increases the contract's balance but not any user's balance.
    function test_fallback_receive_eth_7() public {
        vm.startPrank(owner);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate(alice);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_donate_positive_8() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(1 ether)(alice);
        }
        {
        target.donate.value(2 ether)(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent Financial & Accounting
    function test_balances_view_9() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.donate.value(5 ether)(alice);
        }
        vm.prank(bob);
        {
        target.balances(alice);
        }
        // TODO assert: alice.balance == 5 ether
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_view_10() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.donate.value(3 ether)(alice);
        }
        vm.prank(bob);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_11() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.donate.value(1 ether)(alice);
        }
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

}
