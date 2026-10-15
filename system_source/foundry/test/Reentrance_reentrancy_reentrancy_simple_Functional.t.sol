// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/reentrancy_simple.sol";

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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and then withdraw the exact balance, and the balance is zeroed after withdrawal.
    function test_Normal_deposit_and_withdrawal_0() public {
// assume: address(alice).balance >= 5 ether
// cover: withdrawBalance :: call.value succeeds
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(5 ether)();
        }
        {
        target.withdrawBalance();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that a malicious contract can re-enter withdrawBalance before balance is zeroed, draining funds.
    function test_Reentrancy_attack_attempt_1() public {
// assume: address(alice).balance >= 5 ether
// assume: alice is a contract with fallback that calls withdrawBalance again
// cover: withdrawBalance :: call.value succeeds (reentrant)
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(5 ether)();
        }
        {
        target.withdrawBalance();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing when balance is zero sends 0 ETH and does not revert.
    function test_Withdraw_with_zero_balance_2() public {
// assume: getBalance(alice) == 0
// cover: withdrawBalance :: call.value(0) succeeds
        vm.startPrank(owner);
        Reentrance target = new Reentrance();
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
        target.withdrawBalance();
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate and a single withdrawal returns the total.
    function test_Multiple_deposits_and_single_withdrawal_3() public {
// assume: address(alice).balance >= 5 ether
// cover: withdrawBalance :: call.value(5 ether) succeeds
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(2 ether)();
        }
        {
        target.addToBalance.value(3 ether)();
        }
        {
        target.withdrawBalance();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that balances are isolated per user.
    function test_Deposit_from_two_users_and_withdraw_each_4() public {
// assume: address(alice).balance >= 4 ether
// assume: address(bob).balance >= 6 ether
// cover: withdrawBalance :: call.value succeeds for alice
// cover: withdrawBalance :: call.value succeeds for bob
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(4 ether)();
        }
        vm.prank(bob);
        {
        target.addToBalance.value(6 ether)();
        }
        vm.prank(alice);
        {
        target.withdrawBalance();
        }
        vm.prank(bob);
        {
        target.withdrawBalance();
        }
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that getBalance returns correct deposit amount.
    function test_Deposit_then_check_balance_5() public {
// assume: address(alice).balance >= 7 ether
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(7 ether)();
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 7 ether
    }

    // @cover-intent Financial & Accounting
    function test_addToBalance_positive_6() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(1 ether)();
        }
        // TODO assert: call:getBalance(alice) == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_getBalance_positive_7() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(5 ether)();
        }
        vm.prank(bob);
        {
        target.getBalance(alice);
        }
        // TODO assert: call:getBalance(alice) == 5 ether
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_positive_8() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        target.addToBalance.value(2 ether)();
        }
        {
        target.withdrawBalance();
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.getBalance(alice));
            _assertRelU(__v1, 0, 0, "call:getBalance==0");
        }
    }

}
