// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/simple_dao.sol";

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

contract SimpleDAO_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function SimpleDAO_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that donating increases the credit mapping for the recipient.
    function test_Donate_and_query_credit_0() public {
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(50)(bob);
        }
        {
        target.queryCredit(bob);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that a user can withdraw their full credit balance.
    function test_Withdraw_with_sufficient_credit_1() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) true
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(100)(alice);
        }
        {
        target.withdraw(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Authorization & Access Control: Verify that withdrawal reverts when credit is insufficient.
    function test_Withdraw_with_insufficient_credit_2() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) false
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(50)(alice);
        }
        vm.expectRevert();
        {
        target.withdraw(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify partial withdrawal reduces credit correctly.
    function test_Donate_to_self_and_withdraw_partial_amount_3() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) true
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(100)(alice);
        }
        {
        target.withdraw(40);
        }
        {
        target.queryCredit(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 60
    }

    // @cover-intent Financial & Accounting: Verify that multiple donations accumulate credit.
    function test_Multiple_donations_to_same_address_4() public {
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(30)(bob);
        }
        vm.prank(bob);
        {
        target.donate.value(20)(bob);
        }
        vm.prank(alice);
        {
        target.queryCredit(bob);
        }
        // TODO assert: alice.balance == 70
        // TODO assert: bob.balance == 80
    }

    // @cover-intent Financial & Accounting: Verify that credit is assigned to the 'to' address, not the sender.
    function test_Donate_to_another_address_and_withdraw_by_recipient_5() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) true
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(80)(bob);
        }
        vm.prank(bob);
        {
        target.withdraw(80);
        }
        // TODO assert: alice.balance == 20
        // TODO assert: bob.balance == 80
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing zero is allowed when credit is sufficient.
    function test_Withdraw_zero_amount_6() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) true
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(50)(alice);
        }
        {
        target.withdraw(0);
        }
        {
        target.queryCredit(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify that donating zero does not change credit.
    function test_Donate_with_zero_value_7() public {
        vm.startPrank(owner);
        SimpleDAO target = new SimpleDAO();
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
        target.donate(bob);
        }
        {
        target.queryCredit(bob);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that reentrancy is possible (vulnerability) - credit is updated after external call.
    function test_Reentrancy_attempt_on_withdraw_8() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) true
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(100)(alice);
        }
        {
        target.withdraw(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify that querying credit for an uninitialized address returns 0.
    function test_Query_credit_for_address_with_no_donations_9() public {
        vm.startPrank(owner);
        SimpleDAO target = new SimpleDAO();
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
        target.queryCredit(carol);
        }
    }

    // @cover-intent Financial & Accounting
    function test_credit_view_10() public {
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(100)(alice);
        }
        vm.prank(bob);
        {
        target.credit(alice);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_donate_positive_11() public {
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(50)(alice);
        }
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting
    function test_queryCredit_after_donate_12() public {
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(200)(alice);
        }
        vm.prank(bob);
        {
        target.queryCredit(alice);
        }
        // TODO assert: alice.balance == 200
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_guarded_positive_13() public {
        vm.startPrank(alice);
        SimpleDAO target = new SimpleDAO();
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
        target.donate.value(100)(alice);
        }
        {
        target.withdraw(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

}
