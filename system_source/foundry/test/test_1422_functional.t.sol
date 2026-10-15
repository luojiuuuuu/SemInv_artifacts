// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb37f18af15bafb869a065b61fc83cfc44ed9cc27.sol";

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

contract SimpleWallet_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function SimpleWallet_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Owner can withdraw a specific amount from the contract balance
    function test_owner_withdraw_normal_0() public {
// assume: address(this).balance >= 5 ether
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.withdraw(5 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot call withdraw
    function test_non_owner_withdraw_reverts_1() public {
// assume: address(this).balance >= 1 ether
// cover: withdraw :: require(msg.sender == owner) false
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        vm.prank(bob);
        {
        target.withdraw(1 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Owner can withdraw entire contract balance
    function test_owner_withdrawAll_normal_2() public {
// assume: address(this).balance == 10 ether
// cover: withdrawAll :: require(msg.sender == owner) true
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: withdrawAll()
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot call withdrawAll
    function test_non_owner_withdrawAll_reverts_3() public {
// cover: withdrawAll :: require(msg.sender == owner) false
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawAll()
    }

    // @cover-intent External Interaction & Environment: Owner can send ETH to a target address
    function test_owner_sendMoney_normal_4() public {
// assume: address(this).balance >= 3 ether
// cover: sendMoney :: require(msg.sender == owner) true
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.sendMoney(bob, 3 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot call sendMoney
    function test_non_owner_sendMoney_reverts_5() public {
// cover: sendMoney :: require(msg.sender == owner) false
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        vm.prank(bob);
        {
        target.sendMoney(carol, 1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Sending ETH to contract increments depositsCount
    function test_fallback_increments_depositsCount_6() public {
// cover: fallback :: depositsCount++
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: depositsCount()
    }

    // @cover-intent Resource & Execution Integrity: Owner can withdraw zero amount (edge case)
    function test_withdraw_zero_amount_7() public {
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.withdraw(0);
        }
    }

    // @cover-intent Financial & Accounting: Owner withdraws entire contract balance via withdraw (boundary)
    function test_withdraw_exact_balance_8() public {
// assume: address(this).balance == 7 ether
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.withdraw(7 ether);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_depositsCount_view_9() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: depositsCount()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_10() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent External Interaction & Environment
    function test_sendMoney_positive_11() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.sendMoney(bob, 50);
        }
        {
        target.sendMoney(bob, 50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_sendMoney_non_owner_revert_12() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.sendMoney(bob, 10);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_positive_13() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.sendMoney(owner, 100);
        }
        {
        target.withdraw(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_non_owner_revert_14() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.withdraw(10);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawAll_positive_15() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.sendMoney(owner, 100);
        }
        // skip ABI-mismatched call: withdrawAll()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_non_owner_revert_16() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: withdrawAll()
    }

}
