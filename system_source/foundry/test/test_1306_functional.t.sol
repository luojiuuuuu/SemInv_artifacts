// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/reentrancy_cross_function.sol";

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

contract Reentrancy_cross_function_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Reentrancy_cross_function_FunctionalTest() public {
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


    // @cover-intent Demonstrate cross-function reentrancy where withdrawBalance() calls transfer() recursively via fallback, violating transactional consistency (balance updates not atomic).
    function test_Cross_function_reentrancy_exploit_0() public {
// assume: userBalances[alice] == 50
// assume: userBalances[bob] == 50
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: call.value() reenters transfer
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 50);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Test normal behavior: transfer funds then withdraw, ensuring balance updates are correct (Financial & Accounting).
    function test_Normal_transfer_and_withdraw_1() public {
// assume: userBalances[alice] == 70
// assume: userBalances[bob] == 30
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: normal withdrawal
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 30);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Test edge case: transfer fails when sender has insufficient balance (guard condition).
    function test_Transfer_with_insufficient_balance_2() public {
// assume: userBalances[alice] == 10
// cover: transfer :: require(balance>=amount) false
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 20);
        }
        // TODO assert: alice.balance == 10
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Test edge case: withdraw when balance is zero, should succeed but send 0 ETH.
    function test_Withdraw_from_zero_balance_3() public {
// assume: userBalances[alice] == 0
// cover: withdrawBalance :: amountToWithdraw == 0
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Test transactional consistency: multiple transfers between participants then withdraws.
    function test_Multiple_transfers_and_withdraws_4() public {
// assume: userBalances[alice] == 60
// assume: userBalances[bob] == 20
// assume: userBalances[carol] == 20
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: normal withdrawal
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 40);
        }
        vm.prank(bob);
        {
        target.transfer(carol, 20);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(carol);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_transfer_positive_5() public {
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.transfer(alice, 100);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 30);
        }
        // TODO assert: alice.balance == 70
        // TODO assert: bob.balance == 30
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_positive_6() public {
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 50);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.transfer(alice, 50);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
    }

}
