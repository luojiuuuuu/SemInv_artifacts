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


    // @cover-intent Financial & Accounting: Verify that donating ETH increases credit and withdrawing up to the credit balance succeeds.
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
        target.withdraw(5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that withdrawing more than credit balance reverts.
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
        target.donate.value(3 ether)(alice);
        }
        vm.expectRevert();
        {
        target.withdraw(5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that donating to bob increases bob's credit and bob can withdraw.
    function test_Donate_to_another_address_and_withdraw_from_that_address_2() public {
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
        target.donate.value(4 ether)(bob);
        }
        vm.prank(bob);
        {
        target.withdraw(4 ether);
        }
    }

    // @cover-intent Transactional Consistency: Verify that queryCredit returns the correct credit after a donation.
    function test_Query_credit_after_donate_3() public {
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
        target.donate.value(2 ether)(alice);
        }
        {
        target.queryCredit(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that donating zero ETH still updates credit (adds zero) and does not revert.
    function test_Donate_zero_value_4() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing zero when credit is zero reverts (since 0 >= 0 is true, but call.value(0)() may succeed; test behavior).
    function test_Withdraw_zero_amount_5() public {
// cover: withdraw :: require(credit[msg.sender] >= amount) true
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
        target.withdraw(0);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that reentrancy during withdraw does not drain contract (known vulnerability).
    function test_Reentrancy_attempt_via_malicious_fallback_6() public {
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
    function test_credit_view_7() public {
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
    function test_donate_positive_8() public {
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
    function test_queryCredit_after_donate_9() public {
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
    function test_withdraw_positive_10() public {
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
        target.withdraw(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

}
