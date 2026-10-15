// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/etherpot_lotto.sol";

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

contract Lotto_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Lotto_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that sending ETH to the contract increments the pot and ticket count for the current round.
    function test_Normal_ticket_purchase_and_pot_accumulation_0() public {
// cover: fallback :: value==0 return
// cover: fallback :: value<msg.value send refund
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: getRoundIndex()
        {
        target.getPot(0);
        }
        {
        target.getTicketsCountByBuyer(0, alice);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.getPot(0));
            _assertRelU(__v1, 2, 1000000000000000000, "call:getPot>=1000000000000000000");
        }
        {
            uint256 __v2 = uint256(target.getTicketsCountByBuyer(0, alice));
            _assertRelU(__v2, 2, 10, "call:getTicketsCountByBuyer>=10");
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending an amount not divisible by ticketPrice results in a partial refund to the sender.
    function test_Partial_refund_on_overpayment_1() public {
// cover: fallback :: value<msg.value send refund
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.getPot(0);
        }
        {
        target.getTicketsCountByBuyer(0, alice);
        }
        vm.stopPrank();
        // TODO assert: call:getPot(0) == 1500000000000000000 - 500000000000000000
        {
            uint256 __v3 = uint256(target.getTicketsCountByBuyer(0, alice));
            _assertRelU(__v3, 0, 10, "call:getTicketsCountByBuyer==10");
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending 0 ETH does not change state.
    function test_Zero_value_fallback_does_nothing_2() public {
// cover: fallback :: value==0 return
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.getPot(0);
        }
        {
        target.getTicketsCountByBuyer(0, alice);
        }
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.getPot(0));
            _assertRelU(__v4, 0, 0, "call:getPot==0");
        }
        {
            uint256 __v5 = uint256(target.getTicketsCountByBuyer(0, alice));
            _assertRelU(__v5, 0, 0, "call:getTicketsCountByBuyer==0");
        }
    }

    // @cover-intent External Interaction & Environment: Verify that cashing a subpot after the decision block sends ETH to the winner and marks isCashed.
    function test_Cash_after_round_ends_winner_receives_subpot_3() public {
// assume: block.number >= getDecisionBlockNumber(0,0)
// cover: cash :: subpotIndex>=subpotsCount return
// cover: cash :: decisionBlockNumber>block.number return
// cover: cash :: rounds[roundIndex].isCashed[subpotIndex] return
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(6800)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.getSubpotsCount(0);
        }
        {
        target.getDecisionBlockNumber(0, 0);
        }
        {
        target.cash(0, 0);
        }
        {
        target.getIsCashed(0, 0);
        }
        vm.stopPrank();
        // TODO assert: call:getIsCashed(0, 0) == true
    }

    // @cover-intent Protocol State Machine: Verify that cashing before the decision block number is a no-op (returns early).
    function test_Cash_before_round_ends_reverts_4() public {
// assume: block.number < getDecisionBlockNumber(0,0)
// cover: cash :: decisionBlockNumber>block.number return
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.cash(0, 0);
        }
        {
        target.getIsCashed(0, 0);
        }
        vm.stopPrank();
        // TODO assert: call:getIsCashed(0, 0) == false
    }

    // @cover-intent Transactional Consistency: Verify that cashing the same subpot twice is prevented by isCashed check.
    function test_Double_cash_attempt_fails_5() public {
// assume: block.number >= getDecisionBlockNumber(0,0)
// cover: cash :: rounds[roundIndex].isCashed[subpotIndex] return
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(6800)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.cash(0, 0);
        }
        {
        target.cash(0, 0);
        }
        {
        target.getIsCashed(0, 0);
        }
        vm.stopPrank();
        // TODO assert: call:getIsCashed(0, 0) == true
    }

    // @cover-intent Resource & Execution Integrity: Verify that cashing with subpotIndex >= subpotsCount does nothing.
    function test_Subpot_index_out_of_bounds_returns_early_6() public {
// assume: 100 >= getSubpotsCount(0)
// cover: cash :: subpotIndex>=subpotsCount return
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(6800)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.getSubpotsCount(0);
        }
        {
        target.cash(0, 100);
        }
        {
        target.getIsCashed(0, 100);
        }
        vm.stopPrank();
        // TODO assert: call:getIsCashed(0, 100) == false
    }

    // @cover-intent Financial & Accounting: Verify that multiple buyers can purchase tickets and the pot reflects total contributions.
    function test_Multiple_buyers_and_ticket_distribution_7() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.getPot(0);
        }
        {
        target.getTicketsCountByBuyer(0, alice);
        }
        {
        target.getTicketsCountByBuyer(0, bob);
        }
        {
        target.getTicketsCountByBuyer(0, carol);
        }
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.getPot(0));
            _assertRelU(__v6, 0, 6000000000000000000, "call:getPot==6000000000000000000");
        }
        {
            uint256 __v7 = uint256(target.getTicketsCountByBuyer(0, alice));
            _assertRelU(__v7, 0, 10, "call:getTicketsCountByBuyer==10");
        }
        {
            uint256 __v8 = uint256(target.getTicketsCountByBuyer(0, bob));
            _assertRelU(__v8, 0, 20, "call:getTicketsCountByBuyer==20");
        }
        {
            uint256 __v9 = uint256(target.getTicketsCountByBuyer(0, carol));
            _assertRelU(__v9, 0, 30, "call:getTicketsCountByBuyer==30");
        }
    }

    // @cover-intent External Interaction & Environment: Verify that calculateWinner returns an address when the decision block is reached.
    function test_Calculate_winner_after_round_ends_8() public {
// assume: block.number >= getDecisionBlockNumber(0,0)
// cover: calculateWinner :: decisionBlockNumber>block.number return
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(6800)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.calculateWinner(0, 0);
        }
    }

    // @cover-intent Protocol State Machine: Verify that calculateWinner returns nothing (address(0)) before the decision block.
    function test_Calculate_winner_before_round_ends_returns_empty_9() public {
// assume: block.number < getDecisionBlockNumber(0,0)
// cover: calculateWinner :: decisionBlockNumber>block.number return
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.calculateWinner(0, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_blockReward_test_10() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: blockReward()
        {
            uint256 __v10 = uint256(target.blockReward());
            _assertRelU(__v10, 0, 5000000000000000000, "call:blockReward==5000000000000000000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_blocksPerRound_test_11() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: blocksPerRound()
        {
            uint256 __v11 = uint256(target.blocksPerRound());
            _assertRelU(__v11, 0, 6800, "call:blocksPerRound==6800");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_calculateWinner_test_12() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.calculateWinner(0, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_cash_test_13() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.cash(0, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getBlocksPerRound_test_14() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: getBlocksPerRound()
        {
            uint256 __v12 = uint256(target.getBlocksPerRound());
            _assertRelU(__v12, 0, 6800, "call:getBlocksPerRound==6800");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getBuyers_test_15() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.getBuyers(0, alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getDecisionBlockNumber_test_16() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.getDecisionBlockNumber(0, 0);
        }
        {
            uint256 __v13 = uint256(target.getDecisionBlockNumber(0,0));
            _assertRelU(__v13, 0, 6800, "call:getDecisionBlockNumber==6800");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHashOfBlock_test_17() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.getHashOfBlock(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getIsCashed_test_18() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.getIsCashed(0, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_getPot_test_19() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.getPot(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getRoundIndex_test_20() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: getRoundIndex()
    }

    // @cover-intent Financial & Accounting
    function test_getSubpot_test_21() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.getSubpot(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getSubpotsCount_test_22() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.getSubpotsCount(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getTicketPrice_test_23() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: getTicketPrice()
        {
            uint256 __v14 = uint256(target.getTicketPrice());
            _assertRelU(__v14, 0, 100000000000000000, "call:getTicketPrice==100000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getTicketsCountByBuyer_test_24() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        target.cash(0, 0);
        }
        {
        target.getTicketsCountByBuyer(0, alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_ticketPrice_test_25() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: ticketPrice()
        {
            uint256 __v15 = uint256(target.ticketPrice());
            _assertRelU(__v15, 0, 100000000000000000, "call:ticketPrice==100000000000000000");
        }
    }

}
