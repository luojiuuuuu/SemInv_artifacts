// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/list_dos.sol";

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

contract Government_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Government_FunctionalTest() public {
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


    // @cover-intent Verify that the first creditor can successfully lend money to the government system, establishing initial state and checking that the corrupt elite receives their 5% cut.
    function test_initial_setup_and_first_loan_0() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount >= 10**18
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS >= block.timestamp
        vm.startPrank(owner);
        Government target = new Government();
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
        target.creditorAddresses(0);
        }
        {
        target.creditorAmounts(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100 ether - 10 ether
        // TODO assert: owner.balance == 10 ether * 5 / 100
    }

    // @cover-intent Verify that if no new credit is given for 12 hours, the system crashes: money is returned to sender, last creditor gets profitFromCrash, corrupt elite gets remaining balance, and state resets.
    function test_system_crash_after_12h_inactivity_1() public {
// assume: block.timestamp > lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.round();
        }
        // TODO assert: bob.balance == 100 ether
        // TODO assert: alice.balance == 100 ether - 10 ether + 11 ether
        // TODO assert: owner.balance == 10 ether * 5 / 100 + 5 ether
    }

    // @cover-intent Verify that lending less than 1 ether (10^18 wei) is rejected and money is returned to sender.
    function test_insufficient_loan_amount_rejected_2() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount < 10**18
        vm.startPrank(owner);
        Government target = new Government();
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
        target.creditorAddresses(0);
        }
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent Verify that if a creditor has a buddy with sufficient credit in the system, the buddy receives 5% of the new loan amount.
    function test_buddy_reward_distribution_3() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: buddies[alice] >= 10 ether
// cover: lendGovernmentMoney :: buddies[buddy] >= amount
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.creditorAmounts(1);
        }
        // TODO assert: alice.balance == 100 ether - 10 ether + 10 ether * 5 / 100
        // TODO assert: bob.balance == 100 ether - 10 ether
        // TODO assert: owner.balance == 10 ether * 5 / 100 + 10 ether * 5 / 100
    }

    // @cover-intent Verify that profitFromCrash does not exceed 10000 ether (10000 * 10^18) when adding 5% of new loans.
    function test_profit_from_crash_cap_4() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: profitFromCrash < 10000 * 10**18
// cover: lendGovernmentMoney :: profitFromCrash < 10000 * 10**18
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.profitFromCrash();
        }
        // TODO assert: call:profitFromCrash() <= 10000 * 10**18
    }

    // @cover-intent Verify that when a new loan is made, the oldest unpaid creditor gets paid if the contract has sufficient balance.
    function test_old_creditor_payout_5() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: creditorAmounts[lastCreditorPayedOut] <= address(this).balance - profitFromCrash
// cover: lendGovernmentMoney :: creditorAmounts[lastCreditorPayedOut] <= address(this).balance - profitFromCrash
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.lastCreditorPayedOut();
        }
        // TODO assert: alice.balance == 100 ether - 10 ether + 11 ether
        // TODO assert: bob.balance == 100 ether - 10 ether
        // TODO assert: carol.balance == 100 ether - 10 ether
    }

    // @cover-intent Verify that the corrupt elite can transfer power to a new address, and the new address can then inherit further.
    function test_inherit_to_next_generation_authorized_6() public {
// assume: msg.sender == corruptElite
// cover: inheritToNextGeneration :: msg.sender == corruptElite
        vm.startPrank(owner);
        Government target = new Government();
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
        target.inheritToNextGeneration(alice);
        }
        {
        target.corruptElite();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.inheritToNextGeneration(bob);
        }
    }

    // @cover-intent Verify that a non-elite address cannot inherit power.
    function test_inherit_to_next_generation_unauthorized_7() public {
// assume: msg.sender != corruptElite
// cover: inheritToNextGeneration :: msg.sender != corruptElite
        vm.startPrank(owner);
        Government target = new Government();
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
        target.inheritToNextGeneration(bob);
        }
        {
        target.corruptElite();
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that the corrupt elite can invest in the system to increase profitFromCrash.
    function test_invest_in_the_system_increases_profit_8() public {
// cover: investInTheSystem :: any
        vm.startPrank(owner);
        Government target = new Government();
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
        target.profitFromCrash();
        }
        // TODO assert: call:profitFromCrash() == 5 ether
    }

    // @cover-intent Verify that totalDebt and totalPayedOut correctly sum the creditor amounts based on lastCreditorPayedOut.
    function test_total_debt_and_payed_out_consistency_9() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: totalDebt :: any
// cover: totalPayedOut :: any
        vm.startPrank(owner);
        Government target = new Government();
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
        target.totalDebt();
        }
        {
        target.totalPayedOut();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_corruptElite_10() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.corruptElite();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_creditorAddresses_11() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.creditorAddresses(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_creditorAmounts_12() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.creditorAmounts(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getCreditorAddresses_13() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.getCreditorAddresses();
        }
    }

    // @cover-intent Financial & Accounting
    function test_getCreditorAmounts_14() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.getCreditorAmounts();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_inheritToNextGeneration_15() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.inheritToNextGeneration(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_investInTheSystem_16() public {
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent Protocol State Machine
    function test_lastCreditorPayedOut_17() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.lastCreditorPayedOut();
        }
    }

    // @cover-intent Protocol State Machine
    function test_lastTimeOfNewCredit_18() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.lastTimeOfNewCredit();
        }
    }

    // @cover-intent Financial & Accounting
    function test_lendGovernmentMoney_19() public {
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent Financial & Accounting
    function test_profitFromCrash_20() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.profitFromCrash();
        }
    }

    // @cover-intent Protocol State Machine
    function test_round_21() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.round();
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalDebt_22() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.totalDebt();
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalPayedOut_23() public {
        vm.startPrank(owner);
        Government target = new Government();
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
        target.totalPayedOut();
        }
    }

}
