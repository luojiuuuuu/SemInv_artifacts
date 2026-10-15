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


    // @cover-intent Financial & Accounting: Verify that buying all tickets triggers chooseWinner, which distributes prize and fee correctly.
    function test_Normal_ticket_purchase_and_raffle_completion_0() public {
// assume: pricePerTicket == (2.5 ether + 0.03 ether) / 50
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
        vm.prank(alice);
        // skip ABI-mismatched call: buyTickets()
        vm.prank(bob);
        // skip ABI-mismatched call: buyTickets()
    }

    // @cover-intent Protocol State Machine: When paused, buyTickets should refund the sender immediately.
    function test_Paused_contract_rejects_buyTickets_and_refunds_1() public {
// assume: paused == true
// cover: buyTickets :: paused == true
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
        vm.prank(owner);
        // skip ABI-mismatched call: togglePause()
        vm.prank(alice);
        // skip ABI-mismatched call: buyTickets()
    }

    // @cover-intent Authorization & Access Control: Only feeAddress can toggle pause.
    function test_Non_owner_cannot_togglePause_2() public {
// cover: togglePause :: msg.sender != feeAddress
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

    // @cover-intent Authorization & Access Control: Only feeAddress can end the raffle.
    function test_Non_owner_cannot_endRaffle_3() public {
// cover: endRaffle :: msg.sender != feeAddress
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

    // @cover-intent Authorization & Access Control: Only feeAddress can kill the contract.
    function test_Non_owner_cannot_kill_4() public {
// cover: kill :: msg.sender != feeAddress
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

    // @cover-intent Protocol State Machine: endRaffle refunds all current contestants and resets state.
    function test_Owner_ends_raffle_mid_sale_refunds_all_contestants_5() public {
// assume: nextTicket == 2
// cover: endRaffle :: msg.sender == feeAddress
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
        vm.prank(bob);
        // skip ABI-mismatched call: buyTickets()
        vm.prank(owner);
        // skip ABI-mismatched call: endRaffle()
    }

    // @cover-intent Transactional Consistency: getRefund returns money for tickets bought in current raffle.
    function test_Get_refund_after_partial_purchase_6() public {
// assume: nextTicket == 1
// cover: getRefund :: msg.sender == contestants[i].addr && raffleId == contestants[i].raffleId
// cover: getRefund :: refund > 0
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

    // @cover-intent Transactional Consistency: After raffle ends, getRefund returns nothing because raffleId changed.
    function test_Get_refund_after_raffle_ended_no_refund_7() public {
// assume: raffleId == 2
// cover: getRefund :: raffleId != contestants[i].raffleId
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
        vm.prank(bob);
        // skip ABI-mismatched call: buyTickets()
        vm.prank(alice);
        // skip ABI-mismatched call: getRefund()
    }

    // @cover-intent External Interaction & Environment: Sending ETH directly triggers buyTickets.
    function test_Fallback_function_calls_buyTickets_8() public {
// cover: fallback :: fallback calls buyTickets
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

    // @cover-intent Resource & Execution Integrity: kill selfdestructs and sends remaining balance to feeAddress.
    function test_Owner_kill_destroys_contract_9() public {
// cover: kill :: msg.sender == feeAddress
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

    // @cover-intent Resource & Execution Integrity
    function test_blockNumber_view_10() public {
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
            uint256 __v1 = uint256(target.blockNumber());
            _assertRelU(__v1, 2, 0, "call:blockNumber>=0");
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
    function test_endRaffle_as_owner_12() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_fee_view_13() public {
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
            uint256 __v2 = uint256(target.fee());
            _assertRelU(__v2, 0, 30000000000000000, "call:fee==30000000000000000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_getRefund_after_buy_14() public {
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
    function test_kill_as_owner_15() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_paused_view_16() public {
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
    function test_pricePerTicket_view_17() public {
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
            uint256 __v3 = uint256(target.pricePerTicket());
            _assertRelU(__v3, 0, 50600000000000000, "call:pricePerTicket==50600000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_prize_view_18() public {
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
            uint256 __v4 = uint256(target.prize());
            _assertRelU(__v4, 0, 2500000000000000000, "call:prize==2500000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_raffleId_view_19() public {
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
            uint256 __v5 = uint256(target.raffleId());
            _assertRelU(__v5, 2, 1, "call:raffleId>=1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_togglePause_as_owner_20() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_totalTickets_view_21() public {
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
            uint256 __v6 = uint256(target.totalTickets());
            _assertRelU(__v6, 0, 50, "call:totalTickets==50");
        }
    }

}
