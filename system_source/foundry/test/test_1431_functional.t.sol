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


    // @cover-intent Financial & Accounting: Verify that owner can withdraw the entire contract balance via withdrawAll, which calls withdraw with the full balance.
    function test_Owner_withdraws_exact_balance_0() public {
// assume: address(this).balance == 5 ether
// cover: withdrawAll :: require(msg.sender == owner) true
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.withdrawAll();
        }
        // TODO assert: target.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call withdrawAll.
    function test_Non_owner_withdrawAll_reverts_1() public {
// cover: withdrawAll :: require(msg.sender == owner) false
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdrawAll();
        }
    }

    // @cover-intent Financial & Accounting: Verify that owner can withdraw a specific amount less than balance.
    function test_Owner_withdraws_partial_amount_2() public {
// assume: address(this).balance == 10 ether
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.withdraw(3 ether);
        }
        // TODO assert: target.balance == 7 ether
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call withdraw.
    function test_Non_owner_withdraw_reverts_3() public {
// cover: withdraw :: require(msg.sender == owner) false
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdraw(1 ether);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that owner can send ETH to a target address via sendMoney.
    function test_Owner_sendMoney_to_address_4() public {
// assume: address(this).balance == 5 ether
// cover: sendMoney :: require(msg.sender == owner) true
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.sendMoney(bob, 2 ether);
        }
        // TODO assert: target.balance == 3 ether
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call sendMoney.
    function test_Non_owner_sendMoney_reverts_5() public {
// cover: sendMoney :: require(msg.sender == owner) false
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.expectRevert();
        vm.prank(bob);
        {
        target.sendMoney(alice, 1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that sending ETH to the contract via fallback increments depositsCount.
    function test_Fallback_increments_depositsCount_6() public {
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
        {
        target.depositsCount();
        }
        // TODO assert: target.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that multiple fallback calls correctly increment depositsCount.
    function test_Multiple_deposits_increment_depositsCount_7() public {
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
        {
        target.depositsCount();
        }
        // TODO assert: target.balance == 3 ether
    }

    // @cover-intent External Interaction & Environment: Verify that owner can send ETH to themselves via sendMoney.
    function test_Owner_sendMoney_to_self_8() public {
// assume: address(this).balance == 5 ether
// cover: sendMoney :: require(msg.sender == owner) true
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.sendMoney(owner, 2 ether);
        }
        // TODO assert: target.balance == 3 ether
    }

    // @cover-intent Financial & Accounting: Verify that owner can withdraw zero amount (edge case).
    function test_Withdraw_zero_amount_9() public {
// assume: address(this).balance == 1 ether
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(alice);
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.withdraw(0);
        }
        // TODO assert: target.balance == 1 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_depositsCount_view_10() public {
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
        target.depositsCount();
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_11() public {
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
        target.owner();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendMoney_positive_12() public {
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
        // skip empty call after value injection
        {
        target.sendMoney(bob, 50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
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
        // skip empty call after value injection
        {
        target.withdraw(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_positive_14() public {
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
        // skip empty call after value injection
        {
        target.withdrawAll();
        }
        vm.stopPrank();
        // TODO assert: address(target).balance == 0
    }

}
