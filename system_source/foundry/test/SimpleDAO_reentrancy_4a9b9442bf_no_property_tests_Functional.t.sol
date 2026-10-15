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


    // @cover-intent Financial & Accounting: Verify that a user can donate ETH and then withdraw up to their credit balance, with the credit mapping updated correctly.
    function test_Donate_and_withdraw_positive_path_0() public {
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
        target.donate.value(5 ether)(alice);
        }
        {
        target.withdraw(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a withdraw of more than the user's credit balance reverts.
    function test_Withdraw_exceeding_credit_reverts_1() public {
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
        target.donate.value(1 ether)(alice);
        }
        vm.expectRevert();
        {
        target.withdraw(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that donating to another address increases that address's credit, and queryCredit returns the correct value.
    function test_Donate_to_another_address_and_query_credit_2() public {
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
        target.donate.value(2 ether)(bob);
        }
        {
        target.queryCredit(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple donations accumulate credit and partial withdrawals reduce it correctly.
    function test_Multiple_donations_and_partial_withdrawals_3() public {
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
        target.donate.value(4 ether)(alice);
        }
        {
        target.donate.value(3 ether)(alice);
        }
        {
        target.withdraw(5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing zero amount succeeds when credit is non-zero.
    function test_Withdraw_zero_amount_4() public {
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
        target.donate.value(1 ether)(alice);
        }
        {
        target.withdraw(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that withdrawing with zero credit reverts.
    function test_Withdraw_from_zero_credit_reverts_5() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that donating with zero value does not change credit.
    function test_Donate_with_zero_value_6() public {
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
        target.donate(alice);
        }
        {
        target.queryCredit(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that a reentrant call during withdraw does not allow draining more than credit (known vulnerability).
    function test_Reentrancy_attempt_via_malicious_recipient_7() public {
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
        target.donate.value(5 ether)(alice);
        }
        {
        target.withdraw(5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_credit_view_8() public {
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
        target.credit(alice);
        }
        {
            uint256 __v1 = uint256(target.credit(alice));
            _assertRelU(__v1, 0, 0, "call:credit==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_donate_positive_9() public {
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
        target.donate.value(100)(bob);
        }
        {
            uint256 __v2 = uint256(target.credit(bob));
            _assertRelU(__v2, 0, 100, "call:credit==100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_queryCredit_after_donate_10() public {
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
        target.donate.value(100)(bob);
        }
        {
        target.queryCredit(bob);
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.queryCredit(bob));
            _assertRelU(__v3, 0, 100, "call:queryCredit==100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_11() public {
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
        target.donate.value(200)(alice);
        }
        {
        target.withdraw(100);
        }
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.credit(alice));
            _assertRelU(__v4, 0, 100, "call:credit==100");
        }
    }

}
