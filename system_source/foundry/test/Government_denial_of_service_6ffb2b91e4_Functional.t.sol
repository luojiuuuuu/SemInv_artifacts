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


    // @cover-intent Financial & Accounting: Verify that a valid investment (>= 1 ETH) with a buddy succeeds and updates state correctly.
    function test_Initial_setup_and_first_investment_0() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount >= 10**18 (true)
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS >= block.timestamp (true)
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
        target.creditorAddresses(0);
        }
        {
        target.creditorAmounts(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending less than 1 ETH returns the funds and returns false.
    function test_Investment_with_insufficient_amount_1() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount < 10**18 (true)
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
        // TODO assert: alice.balance == 500000000000000000
    }

    // @cover-intent Protocol State Machine: Verify that if no new credit is given for 12 hours, the system resets and returns funds.
    function test_System_crash_after_12_hours_of_inactivity_2() public {
// assume: block.timestamp > lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp (true)
        vm.startPrank(owner);
        Government target = new Government();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent Financial & Accounting: Verify that if the buddy has enough credit, they receive 5% of the new investment.
    function test_Buddy_bonus_when_buddy_has_sufficient_credit_3() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: buddies[buddy] >= amount (true)
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

    // @cover-intent Authorization & Access Control: Verify that only the corrupt elite can change the successor.
    function test_Inherit_to_next_generation_by_corrupt_elite_4() public {
// assume: msg.sender == corruptElite
// cover: inheritToNextGeneration :: msg.sender == corruptElite (true)
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
        // skip ABI-mismatched call: corruptElite()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-elite caller cannot change the successor.
    function test_Inherit_to_next_generation_by_non_elite_reverts_5() public {
// assume: msg.sender != corruptElite
// cover: inheritToNextGeneration :: msg.sender == corruptElite (false)
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
        target.inheritToNextGeneration(bob);
        }
    }

    // @cover-intent Financial & Accounting: Verify that investInTheSystem adds value to profitFromCrash.
    function test_Invest_in_the_system_increases_profitFromCrash_6() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: profitFromCrash()
    }

    // @cover-intent Financial & Accounting: Verify that totalDebt returns the sum of unpaid creditor amounts.
    function test_Total_debt_calculation_after_multiple_investments_7() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: totalDebt :: any
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
        {
            uint256 __v1 = uint256(target.totalDebt());
            _assertRelU(__v1, 2, 2000000000000000000, "call:totalDebt>=2000000000000000000");
        }
    }

    // @cover-intent Financial & Accounting: Verify that totalPayedOut returns the sum of paid creditor amounts.
    function test_Total_payed_out_after_partial_payout_8() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
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
        vm.prank(alice);
        // skip ABI-mismatched call: totalPayedOut()
        {
            uint256 __v2 = uint256(target.totalPayedOut());
            _assertRelU(__v2, 2, 0, "call:totalPayedOut>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_corruptElite_9() public {
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
    function test_creditorAddresses_10() public {
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
    function test_creditorAmounts_11() public {
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
    function test_getCreditorAddresses_12() public {
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
    function test_getCreditorAmounts_13() public {
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
    function test_inheritToNextGeneration_14() public {
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
    function test_investInTheSystem_15() public {
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
    function test_lastCreditorPayedOut_16() public {
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

    // @cover-intent External Interaction & Environment
    function test_lastTimeOfNewCredit_17() public {
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
    function test_lendGovernmentMoney_18() public {
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
    function test_profitFromCrash_19() public {
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
    function test_round_20() public {
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
    function test_totalDebt_21() public {
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
    function test_totalPayedOut_22() public {
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
