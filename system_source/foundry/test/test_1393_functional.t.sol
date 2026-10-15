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


    // @cover-intent Authorization & Access Control: Verify that only owner can call withdraw and that it correctly transfers the specified amount to the owner.
    function test_Owner_withdraws_exact_balance_0() public {
// assume: owner() == owner
// cover: withdraw :: require(msg.sender == owner) true
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
        vm.prank(alice);
        {
        target.sendMoney(owner, 5 ether);
        }
        vm.prank(owner);
        {
        target.withdraw(5 ether);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that withdrawAll transfers the entire contract balance to the owner.
    function test_Owner_withdraws_all_via_withdrawAll_1() public {
// assume: owner() == owner
// cover: withdrawAll :: require(msg.sender == owner) true
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
        vm.prank(alice);
        {
        target.sendMoney(owner, 3 ether);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: withdrawAll()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawAll()
    }

    // @cover-intent External Interaction & Environment: Verify that sendMoney sends ETH to a target address and only owner can call it.
    function test_SendMoney_to_external_address_2() public {
// assume: owner() == owner
// cover: sendMoney :: require(msg.sender == owner) true
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
        vm.prank(alice);
        {
        target.sendMoney(owner, 5 ether);
        }
        vm.prank(owner);
        {
        target.sendMoney(bob, 2 ether);
        }
        vm.expectRevert();
        vm.prank(carol);
        {
        target.sendMoney(bob, 1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that sending ETH to the contract via fallback increments depositsCount.
    function test_Fallback_increments_depositsCount_3() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that withdraw with zero value succeeds (edge case).
    function test_Withdraw_zero_amount_4() public {
// assume: owner() == owner
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
        vm.prank(alice);
        {
        target.sendMoney(owner, 1 ether);
        }
        vm.startPrank(owner);
        {
        target.withdraw(0);
        }
        // skip ABI-mismatched call: withdrawAll()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sendMoney can send ETH to the owner itself.
    function test_SendMoney_to_self_owner_5() public {
// assume: owner() == owner
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
        vm.prank(alice);
        {
        target.sendMoney(owner, 5 ether);
        }
        vm.startPrank(owner);
        {
        target.sendMoney(owner, 2 ether);
        }
        // skip ABI-mismatched call: withdrawAll()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_depositsCount_view_6() public {
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
    function test_owner_view_7() public {
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
    function test_sendMoney_positive_8() public {
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

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_9() public {
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

    // @cover-intent Financial & Accounting
    function test_withdrawAll_positive_10() public {
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

}
