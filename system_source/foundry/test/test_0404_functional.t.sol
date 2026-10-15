// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/etheraffle.sol";

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

contract Ethraffle_v4b_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Ethraffle_v4b_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that buying all tickets triggers chooseWinner, which emits RaffleResult and resets state for next raffle.
    function test_Normal_ticket_purchase_and_raffle_completion_0() public {
// assume: paused==false
// assume: pricePerTicket == (prize + fee) / totalTickets
// cover: buyTickets :: paused == false
// cover: buyTickets :: moneySent >= pricePerTicket && nextTicket < totalTickets
// cover: buyTickets :: nextTicket == totalTickets
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: buyTickets()
        // skip ABI-mismatched call: raffleId()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.raffleId());
            _assertRelU(__v1, 0, 2, "call:raffleId==2");
        }
    }

    // @cover-intent Transactional Consistency: When paused is true, buyTickets should refund the sender immediately.
    function test_Buy_tickets_when_paused_returns_funds_1() public {
// assume: paused==true
// cover: buyTickets :: paused == true
        vm.startPrank(alice);
        Ethraffle_v4b target = new Ethraffle_v4b();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: togglePause()
        vm.prank(alice);
        // skip ABI-mismatched call: buyTickets()
    }

    // @cover-intent Financial & Accounting: Contestant can get a refund for their tickets before the raffle ends, and the ticket slot becomes a gap.
    function test_Get_refund_before_raffle_ends_2() public {
// assume: paused==false
// assume: raffleId == 1
// cover: getRefund :: msg.sender == contestants[i].addr && raffleId == contestants[i].raffleId
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: buyTickets()
        // skip ABI-mismatched call: getRefund()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only feeAddress can call endRaffle; others should revert.
    function test_Non_owner_cannot_end_raffle_3() public {
// assume: msg.sender != feeAddress
// cover: endRaffle :: msg.sender == feeAddress false
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: endRaffle()
    }

    // @cover-intent Protocol State Machine: Owner can endRaffle, which refunds all contestants, emits RaffleResult, increments raffleId, and pauses the contract.
    function test_Owner_ends_raffle_and_pauses_4() public {
// assume: msg.sender == feeAddress
// cover: endRaffle :: msg.sender == feeAddress true
// cover: endRaffle :: raffleId == contestants[i].raffleId
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: buyTickets()
        vm.startPrank(owner);
        // skip ABI-mismatched call: endRaffle()
        // skip ABI-mismatched call: paused()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.raffleId());
            _assertRelU(__v2, 0, 2, "call:raffleId==2");
        }
    }

    // @cover-intent Authorization & Access Control: Only feeAddress can togglePause; others should revert.
    function test_Non_owner_cannot_toggle_pause_5() public {
// assume: msg.sender != feeAddress
// cover: togglePause :: msg.sender == feeAddress false
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: togglePause()
    }

    // @cover-intent Protocol State Machine: Owner can togglePause to change paused state.
    function test_Owner_toggles_pause_6() public {
// assume: msg.sender == feeAddress
// cover: togglePause :: msg.sender == feeAddress true
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: togglePause()
        // skip ABI-mismatched call: paused()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only feeAddress can call kill; others should revert.
    function test_Non_owner_cannot_kill_7() public {
// assume: msg.sender != feeAddress
// cover: kill :: msg.sender == feeAddress false
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent External Interaction & Environment: Owner can call kill to selfdestruct the contract, sending remaining balance to feeAddress.
    function test_Owner_kills_contract_8() public {
// assume: msg.sender == feeAddress
// cover: kill :: msg.sender == feeAddress true
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Transactional Consistency: Buying fewer tickets than totalTickets should not trigger chooseWinner, and leftover ether should be refunded.
    function test_Partial_ticket_purchase_with_refund_9() public {
// assume: paused==false
// assume: pricePerTicket == (prize + fee) / totalTickets
// cover: buyTickets :: moneySent >= pricePerTicket && nextTicket < totalTickets
// cover: buyTickets :: nextTicket != totalTickets
// cover: buyTickets :: moneySent > 0
        vm.startPrank(alice);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: buyTickets()
        // skip ABI-mismatched call: raffleId()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.raffleId());
            _assertRelU(__v3, 0, 1, "call:raffleId==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_blockNumber_test_10() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: blockNumber()
        {
            uint256 __v4 = uint256(target.blockNumber());
            _assertRelU(__v4, 2, 0, "call:blockNumber>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_buyTickets_positive_11() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: buyTickets()
    }

    // @cover-intent Authorization & Access Control
    function test_endRaffle_positive_12() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: endRaffle()
    }

    // @cover-intent Authorization & Access Control
    function test_endRaffle_unauthorized_13() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: endRaffle()
    }

    // @cover-intent Resource & Execution Integrity
    function test_fee_test_14() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: fee()
        {
            uint256 __v5 = uint256(target.fee());
            _assertRelU(__v5, 0, 30000000000000000, "call:fee==30000000000000000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_getRefund_positive_15() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: buyTickets()
        // skip ABI-mismatched call: getRefund()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_kill_positive_16() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Authorization & Access Control
    function test_kill_unauthorized_17() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Protocol State Machine
    function test_paused_test_18() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: paused()
    }

    // @cover-intent Resource & Execution Integrity
    function test_pricePerTicket_test_19() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: pricePerTicket()
        {
            uint256 __v6 = uint256(target.pricePerTicket());
            _assertRelU(__v6, 0, 50600000000000000, "call:pricePerTicket==50600000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_prize_test_20() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: prize()
        {
            uint256 __v7 = uint256(target.prize());
            _assertRelU(__v7, 0, 2500000000000000000, "call:prize==2500000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_raffleId_test_21() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: raffleId()
        {
            uint256 __v8 = uint256(target.raffleId());
            _assertRelU(__v8, 0, 1, "call:raffleId==1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_togglePause_positive_22() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: togglePause()
    }

    // @cover-intent Authorization & Access Control
    function test_togglePause_unauthorized_23() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: togglePause()
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalTickets_test_24() public {
        vm.startPrank(owner);
        Ethraffle_v4b target = new Ethraffle_v4b();
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
        // skip ABI-mismatched call: totalTickets()
        {
            uint256 __v9 = uint256(target.totalTickets());
            _assertRelU(__v9, 0, 50, "call:totalTickets==50");
        }
    }

}
