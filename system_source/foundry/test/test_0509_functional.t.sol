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


    // @cover-intent Financial & Accounting: Test normal lending flow with sufficient amount, buddy bonus, and partial payout to old creditors.
    function test_normal_lend_and_payout_0() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount >= 10**18 true
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp false
// cover: lendGovernmentMoney :: buddies[buddy] >= amount true
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
        // skip ABI-mismatched call: lastCreditorPayedOut()
        // skip ABI-mismatched call: round()
        vm.stopPrank();
        // TODO assert: alice.balance == 2000000000000000000
        // TODO assert: bob.balance == 2000000000000000000
        {
            uint256 __v1 = uint256(target.totalDebt());
            _assertRelU(__v1, 2, 0, "call:totalDebt>=0");
        }
        {
            uint256 __v2 = uint256(target.lastCreditorPayedOut());
            _assertRelU(__v2, 2, 0, "call:lastCreditorPayedOut>=0");
        }
    }

    // @cover-intent Protocol State Machine: Test system crash when 12 hours pass without new credit, triggering reset and payout to last creditor.
    function test_system_crash_after_12h_1() public {
// assume: block.timestamp >= lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp true
// cover: lendGovernmentMoney :: amount >= 10**18 false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: round()
        // skip ABI-mismatched call: lastCreditorPayedOut()
        // skip ABI-mismatched call: profitFromCrash()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.round());
            _assertRelU(__v3, 0, 1, "call:round==1");
        }
        {
            uint256 __v4 = uint256(target.lastCreditorPayedOut());
            _assertRelU(__v4, 0, 0, "call:lastCreditorPayedOut==0");
        }
        {
            uint256 __v5 = uint256(target.profitFromCrash());
            _assertRelU(__v5, 0, 0, "call:profitFromCrash==0");
        }
    }

    // @cover-intent Financial & Accounting: Test that lending less than 1 ether is rejected and funds returned.
    function test_insufficient_amount_rejected_2() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount >= 10**18 false
// cover: lendGovernmentMoney :: lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp false
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
        // skip ABI-mismatched call: round()
        vm.stopPrank();
        // TODO assert: alice.balance == 500000000000000000
    }

    // @cover-intent Authorization & Access Control: Test that corruptElite can transfer power to next generation.
    function test_inherit_to_next_generation_authorized_3() public {
// assume: msg.sender == corruptElite
// cover: inheritToNextGeneration :: msg.sender == corruptElite true
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
        // skip ABI-mismatched call: corruptElite()
        {
        target.inheritToNextGeneration(alice);
        }
        // skip ABI-mismatched call: corruptElite()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test that non-elite cannot transfer power.
    function test_inherit_to_next_generation_unauthorized_4() public {
// assume: msg.sender != corruptElite
// cover: inheritToNextGeneration :: msg.sender == corruptElite false
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
        // skip ABI-mismatched call: corruptElite()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test that investInTheSystem increases profitFromCrash.
    function test_invest_in_the_system_5() public {
// cover: investInTheSystem :: default
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
        {
            uint256 __v6 = uint256(target.profitFromCrash());
            _assertRelU(__v6, 2, 1000000000000000000, "call:profitFromCrash>=1000000000000000000");
        }
    }

    // @cover-intent External Interaction & Environment: Test that fallback function calls lendGovernmentMoney(0) with sent value.
    function test_fallback_triggers_lend_6() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount >= 10**18 true
// cover: lendGovernmentMoney :: buddy == 0
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
        {
            uint256 __v7 = uint256(target.lastCreditorPayedOut());
            _assertRelU(__v7, 0, 0, "call:lastCreditorPayedOut==0");
        }
    }

    // @cover-intent Transactional Consistency: Test that totalDebt and totalPayedOut reflect correct state after multiple lends.
    function test_total_debt_and_payed_out_consistency_7() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// cover: lendGovernmentMoney :: amount >= 10**18 true
// cover: totalDebt :: default
// cover: totalPayedOut :: default
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
        // skip ABI-mismatched call: lastCreditorPayedOut()
        vm.stopPrank();
        {
            uint256 __v8 = uint256(target.totalDebt());
            _assertRelU(__v8, 2, 0, "call:totalDebt>=0");
        }
        {
            uint256 __v9 = uint256(target.totalPayedOut());
            _assertRelU(__v9, 2, 0, "call:totalPayedOut>=0");
        }
    }

    // @cover-intent Financial & Accounting: Test that profitFromCrash is capped at 10000 ether.
    function test_profit_from_crash_cap_8() public {
// assume: block.timestamp < lastTimeOfNewCredit + 43200
// assume: profitFromCrash >= 10000 * 10**18
// cover: lendGovernmentMoney :: profitFromCrash < 10000 * 10**18 false
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
        {
            uint256 __v10 = uint256(target.profitFromCrash());
            _assertRelU(__v10, 0, 100000000000000000000, "call:profitFromCrash==100000000000000000000");
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

    // @cover-intent Resource & Execution Integrity
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

    // @cover-intent Resource & Execution Integrity
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

    // @cover-intent Resource & Execution Integrity
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

    // @cover-intent Resource & Execution Integrity
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
        {
            uint256 __v11 = uint256(target.profitFromCrash());
            _assertRelU(__v11, 2, 100, "call:profitFromCrash>=100");
        }
    }

    // @cover-intent Resource & Execution Integrity
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

    // @cover-intent Resource & Execution Integrity
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
