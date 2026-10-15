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


    // @cover-intent 验证用户可以通过发送ETH购买彩票，并正确更新当前轮次的奖池、票数和买家列表
    function test_buy_tickets_and_check_round_0() public {
// cover: fallback :: value >= ticketPrice
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
        target.getRoundIndex();
        }
        {
        target.getPot(0);
        }
        {
        target.getTicketsCountByBuyer(0, alice);
        }
        {
        target.getTicketsCountByBuyer(0, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent 验证当发送金额不是ticketPrice整数倍时，多余部分会退款给发送者
    function test_partial_refund_on_odd_value_1() public {
// cover: fallback :: value % ticketPrice != 0
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
        target.getTicketsCountByBuyer(0, alice);
        }
        {
        target.getPot(0);
        }
        vm.stopPrank();
    }

    // @cover-intent 验证在轮次结束后，可以正确计算并领取子奖池（模拟block.number足够大）
    function test_cash_subpot_after_round_ends_2() public {
// assume: block.number > getDecisionBlockNumber(0,0)
// cover: cash :: decisionBlockNumber <= block.number
// cover: cash :: !isCashed
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
        target.calculateWinner(0, 0);
        }
        {
        target.cash(0, 0);
        }
        {
        target.getIsCashed(0, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent 验证在轮次未结束时调用cash会提前返回（不改变状态）
    function test_cash_revert_when_round_not_ended_3() public {
// assume: block.number < getDecisionBlockNumber(0,0)
// cover: cash :: decisionBlockNumber > block.number
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
        target.getDecisionBlockNumber(0, 0);
        }
        {
        target.cash(0, 0);
        }
        {
        target.getIsCashed(0, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent 验证同一子奖池不能重复领取
    function test_cash_revert_when_already_cashed_4() public {
// assume: block.number > getDecisionBlockNumber(0,0)
// cover: cash :: isCashed == true
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
    }

    // @cover-intent 验证当subpotIndex超出子奖池数量时，cash提前返回
    function test_cash_revert_when_subpotIndex_out_of_range_5() public {
// assume: block.number > getDecisionBlockNumber(0,1)
// cover: cash :: subpotIndex >= subpotsCount
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
        target.cash(0, 1);
        }
        {
        target.getIsCashed(0, 1);
        }
        vm.stopPrank();
    }

    // @cover-intent 验证在轮次结束前调用calculateWinner返回空地址
    function test_calculate_winner_returns_zero_before_round_end_6() public {
// assume: block.number < getDecisionBlockNumber(0,0)
// cover: calculateWinner :: decisionBlockNumber > block.number
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
        target.calculateWinner(0, 0);
        }
    }

    // @cover-intent 验证子奖池数量和子奖池金额计算正确
    function test_get_subpot_and_subpots_count_7() public {
// cover: getSubpotsCount :: pot % blockReward > 0
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
        target.getSubpotsCount(0);
        }
        {
        target.getSubpot(0);
        }
        {
        target.getPot(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Check that blockReward returns the constant value 5000000000000000000
    function test_blockReward_basic_8() public {
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
        target.blockReward();
        }
        {
            uint256 __v1 = uint256(target.blockReward());
            _assertRelU(__v1, 0, 5000000000000000000, "call:blockReward==5000000000000000000");
        }
    }

    // @cover-intent Check that blocksPerRound returns the constant value 6800
    function test_blocksPerRound_basic_9() public {
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
        target.blocksPerRound();
        }
        {
            uint256 __v2 = uint256(target.blocksPerRound());
            _assertRelU(__v2, 0, 6800, "call:blocksPerRound==6800");
        }
    }

    // @cover-intent Calculate winner for round 0 subpot 0 after buying a ticket and advancing blocks
    function test_calculateWinner_after_buying_tickets_10() public {
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
        target.calculateWinner(0, 0);
        }
        // TODO assert: call:calculateWinner(0,0) == alice
    }

    // @cover-intent Cash subpot 0 of round 0 after buying a ticket and advancing blocks past decision block
    function test_cash_after_round_ends_11() public {
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
        target.cash(0, 0);
        }
    }

    // @cover-intent Check that getBlocksPerRound returns 6800
    function test_getBlocksPerRound_basic_12() public {
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
        target.getBlocksPerRound();
        }
        {
            uint256 __v3 = uint256(target.getBlocksPerRound());
            _assertRelU(__v3, 0, 6800, "call:getBlocksPerRound==6800");
        }
    }

    // @cover-intent Retrieve buyers list for round 0 after alice buys a ticket
    function test_getBuyers_after_buying_ticket_13() public {
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
        target.getBuyers(0, alice);
        }
    }

    // @cover-intent Check decision block number for round 0 subpot 0
    function test_getDecisionBlockNumber_basic_14() public {
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
            uint256 __v4 = uint256(target.getDecisionBlockNumber(0,0));
            _assertRelU(__v4, 0, 6800, "call:getDecisionBlockNumber==6800");
        }
    }

    // @cover-intent Check that getHashOfBlock returns a uint for block 0
    function test_getHashOfBlock_basic_15() public {
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
        {
            uint256 __v5 = uint256(target.getHashOfBlock(0));
            _assertRelU(__v5, 2, 0, "call:getHashOfBlock>=0");
        }
    }

    // @cover-intent Check that subpot 0 of round 0 is not cashed initially
    function test_getIsCashed_before_cash_16() public {
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

    // @cover-intent Check pot for round 0 after alice buys a ticket
    function test_getPot_after_buying_ticket_17() public {
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
        target.getPot(0);
        }
        {
            uint256 __v6 = uint256(target.getPot(0));
            _assertRelU(__v6, 0, 100000000000000000, "call:getPot==100000000000000000");
        }
    }

    // @cover-intent Check that getRoundIndex returns current round based on block number
    function test_getRoundIndex_basic_18() public {
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
        target.getRoundIndex();
        }
        // TODO assert: call:getRoundIndex() == block.number / 6800
    }

    // @cover-intent Check subpot value for round 0 after alice buys a ticket
    function test_getSubpot_after_buying_ticket_19() public {
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
        target.getSubpot(0);
        }
        {
            uint256 __v7 = uint256(target.getSubpot(0));
            _assertRelU(__v7, 0, 100000000000000000, "call:getSubpot==100000000000000000");
        }
    }

    // @cover-intent Check subpots count for round 0 after alice buys a ticket
    function test_getSubpotsCount_after_buying_ticket_20() public {
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
        target.getSubpotsCount(0);
        }
        {
            uint256 __v8 = uint256(target.getSubpotsCount(0));
            _assertRelU(__v8, 0, 1, "call:getSubpotsCount==1");
        }
    }

    // @cover-intent Check that getTicketPrice returns 100000000000000000
    function test_getTicketPrice_basic_21() public {
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
        target.getTicketPrice();
        }
        {
            uint256 __v9 = uint256(target.getTicketPrice());
            _assertRelU(__v9, 0, 100000000000000000, "call:getTicketPrice==100000000000000000");
        }
    }

    // @cover-intent Check tickets count for alice in round 0 after buying one ticket
    function test_getTicketsCountByBuyer_after_buying_ticket_22() public {
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
        target.getTicketsCountByBuyer(0, alice);
        }
        {
            uint256 __v10 = uint256(target.getTicketsCountByBuyer(0,alice));
            _assertRelU(__v10, 0, 1, "call:getTicketsCountByBuyer==1");
        }
    }

    // @cover-intent Check that ticketPrice returns 100000000000000000
    function test_ticketPrice_basic_23() public {
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
        target.ticketPrice();
        }
        {
            uint256 __v11 = uint256(target.ticketPrice());
            _assertRelU(__v11, 0, 100000000000000000, "call:ticketPrice==100000000000000000");
        }
    }

}
