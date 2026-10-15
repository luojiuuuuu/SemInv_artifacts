// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "forge-std/Test.sol";
import "../src/SavingsVault_0821.sol";


contract SavingsVault_0821_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }


    // @cover-intent 用户存入ETH后取出部分余额，检验余额变化与事件
    function test_deposit_and_withdraw_0() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.withdraw(200);
        _assertEqU(target.balanceOf(alice), balA0 - 200);
    }

    // @cover-intent 用户取出全部余额，余额归零
    function test_withdraw_all_balance_1() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.withdraw(400);
        _assertEqU(target.balanceOf(alice), balA0 - 400);
    }

    // @cover-intent owner提取合约资金到指定地址，检验余额变化和owner权限
    function test_owner_sweep_funds_2() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        vm.prank(owner);
        target.ownerSweep(payable(bob), 300);
        _assertEqU(target.balanceOf(bob), balB0 + 300);
        _assertEqU(uint160(address(target.owner())), uint160(owner));
    }

    // @cover-intent owner批量记账后，用户取出部分余额
    function test_batch_credit_and_withdraw_3() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        vm.prank(bob);
        target.withdraw(100);
        _assertEqU(target.balanceOf(alice), balA0 + 250);
        _assertEqU(target.balanceOf(bob), balB0 + 50);
    }

    // @cover-intent 用户尝试取出0金额，测试边界条件
    function test_withdraw_zero_amount_4() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.withdraw(0);
        _assertEqU(target.balanceOf(alice), balA0 - 0);
    }

    // @cover-intent 查询 alice 的余额
    function test_seq_5() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.balanceOf(payable(alice));
        _assertEqU(target.balanceOf(alice), 100);
    }

    // @cover-intent 查询合约当前 owner
    function test_seq_6() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.owner();
        _assertEqU(uint160(address(target.owner())), uint160(owner));
    }

    // @cover-intent owner 将 40 单位提取给 bob
    function test_seq_7() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        vm.prank(owner);
        target.ownerSweep(payable(bob), 40);
        _assertEqU(target.balanceOf(bob), balB0 + 40);
    }

    // @cover-intent alice 从 vault 提现 60 单位
    function test_seq_8() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.withdraw(60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
    }

    // @cover-intent minimal test for batchCredit
    function test_perfn_batchCredit_9() public {
        vm.startPrank(owner);
        SavingsVault_0821 target = new SavingsVault_0821();
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
        target.batchCredit(new address, 1000);
    }

}
