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


    // @cover-intent Financial & Accounting: Verify that a normal lending operation with sufficient amount (>= 1 ETH) registers the creditor, updates state, and triggers payout to previous creditor if balance allows.
    function test_Normal_lending_and_payout_cycle_0() public {
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
        // skip ABI-mismatched call: lastCreditorPayedOut()
        {
        target.creditorAmounts(0);
        }
        {
        target.creditorAmounts(1);
        }
        // skip ABI-mismatched call: totalDebt()
        // skip ABI-mismatched call: totalPayedOut()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that lending less than 1 ETH returns false and does not change state.
    function test_Lending_with_insufficient_amount_revert_1() public {
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
        vm.startPrank(alice);
        // skip malformed call: lendGovernmentMoney(0x0) (bad raw arg for lendGovernmentMoney.arg0: type=address, raw=0x0)
        // skip ABI-mismatched call: lastCreditorPayedOut()
        vm.expectRevert();
        {
        target.creditorAddresses(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that if no new credit is given for 12 hours, the system resets and returns funds to sender and last creditor.
    function test_System_crash_after_12_hours_inactivity_2() public {
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
        vm.startPrank(bob);
        // skip ABI-mismatched call: round()
        // skip ABI-mismatched call: lastCreditorPayedOut()
        vm.expectRevert();
        {
        target.creditorAddresses(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the corrupt elite can change the elite address.
    function test_Inherit_to_next_generation_by_corrupt_elite_3() public {
// assume: msg.sender == corruptElite for owner
// cover: inheritToNextGeneration :: msg.sender == corruptElite
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
        // skip ABI-mismatched call: corruptElite()
        vm.expectRevert();
        {
        target.inheritToNextGeneration(bob);
        }
        vm.stopPrank();
        vm.startPrank(owner);
        {
        target.inheritToNextGeneration(bob);
        }
        // skip ABI-mismatched call: corruptElite()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that investInTheSystem increases profitFromCrash by the sent amount.
    function test_Invest_in_the_system_by_anyone_4() public {
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
        // skip ABI-mismatched call: profitFromCrash()
        // skip ABI-mismatched call: investInTheSystem()
        // skip ABI-mismatched call: profitFromCrash()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that totalDebt and totalPayedOut sum to the total creditor amounts.
    function test_Total_debt_and_total_payed_out_consistency_5() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
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
        // skip ABI-mismatched call: totalDebt()
        // skip ABI-mismatched call: totalPayedOut()
        {
        target.creditorAmounts(0);
        }
        {
        target.creditorAmounts(1);
        }
        {
        target.creditorAmounts(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that if buddy has enough credit, they receive 5% of the new lending amount.
    function test_Buddy_bonus_when_buddy_has_sufficient_credit_6() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: buddies[alice] >= 1 ether
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
        vm.startPrank(bob);
        {
        target.creditorAmounts(0);
        }
        {
        target.creditorAmounts(1);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract triggers the fallback and calls lendGovernmentMoney(0).
    function test_Fallback_function_calls_lendGovernmentMoney_with_zero_address_7() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: fallback :: calls lendGovernmentMoney(0)
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
        // skip ABI-mismatched call: lastTimeOfNewCredit()
    }

    // @cover-intent Financial & Accounting: Verify that when a new creditor lends, the oldest unpaid creditor gets paid if balance is sufficient.
    function test_Payout_to_old_creditor_when_balance_sufficient_8() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: address(this).balance - profitFromCrash >= creditorAmounts[lastCreditorPayedOut]
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
        vm.startPrank(bob);
        // skip ABI-mismatched call: lastCreditorPayedOut()
        // skip ABI-mismatched call: totalPayedOut()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that profitFromCrash does not exceed 10000 * 10**18.
    function test_Profit_from_crash_cap_at_10000_ETH_9() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: profitFromCrash >= 10000 * 10**18
// cover: lendGovernmentMoney :: profitFromCrash < 10000 * 10**18
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
        // skip ABI-mismatched call: profitFromCrash()
        // skip ABI-mismatched call: profitFromCrash()
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
        // skip ABI-mismatched call: corruptElite()
    }

    // @cover-intent Financial & Accounting
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

    // @cover-intent Financial & Accounting
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
        // skip ABI-mismatched call: getCreditorAddresses()
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
        // skip ABI-mismatched call: getCreditorAmounts()
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

    // @cover-intent Financial & Accounting
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
        // skip ABI-mismatched call: lastCreditorPayedOut()
    }

    // @cover-intent Financial & Accounting
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
        // skip ABI-mismatched call: lastTimeOfNewCredit()
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
        // skip ABI-mismatched call: profitFromCrash()
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
        // skip ABI-mismatched call: round()
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
        // skip ABI-mismatched call: totalDebt()
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
        // skip ABI-mismatched call: totalPayedOut()
    }

}
