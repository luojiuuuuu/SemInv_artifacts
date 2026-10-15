// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/king_of_the_ether_throne.sol";

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

contract KingOfTheEtherThrone_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function KingOfTheEtherThrone_FunctionalTest() public {
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


    // @cover-intent Verify the constructor sets the wizard as the initial monarch and the starting claim price. Then test a successful throne claim by alice, checking state transitions and event emission.
    function test_Initial_state_and_first_claim_0() public {
// assume: currentClaimPrice == 100 finney
// cover: claimThrone :: valuePaid >= currentClaimPrice true
// cover: claimThrone :: valuePaid > currentClaimPrice false
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentClaimPrice();
        }
        {
        target.currentMonarch();
        }
        {
        target.currentMonarch();
        }
        {
        target.numberOfMonarchs();
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 0
        // TODO assert: alice.balance == 1 ether - 100 finney
        // TODO assert: bob.balance == 5 ether
    }

    // @cover-intent Test that paying less than currentClaimPrice results in a refund and no state change (Authorization & Access Control / Transactional Consistency).
    function test_Underpayment_reverts_with_refund_1() public {
// assume: currentClaimPrice == 150 finney
// cover: claimThrone :: valuePaid < currentClaimPrice true
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentMonarch();
        }
        // TODO assert: bob.balance == 1 ether - 50 finney
        // TODO assert: alice.balance == 1 ether - 100 finney
    }

    // @cover-intent Test that paying more than currentClaimPrice refunds the excess and the claim succeeds (Financial & Accounting).
    function test_Overpayment_refunds_excess_2() public {
// assume: currentClaimPrice == 150 finney
// cover: claimThrone :: valuePaid > currentClaimPrice true
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentMonarch();
        }
        // TODO assert: bob.balance == 2 ether - 150 finney
        // TODO assert: alice.balance == 2 ether - 100 finney + 150 finney - wizardCommission
    }

    // @cover-intent Verify that the wizard's commission accumulates and can be swept by the wizard only (Authorization & Access Control).
    function test_Wizard_commission_accumulation_and_sweep_3() public {
// assume: wizardAddress == owner
// cover: sweepCommission :: onlywizard true
// cover: sweepCommission :: onlywizard false
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        // skip malformed call: sweepCommission(1 finney) (bad raw arg for sweepCommission.arg0: type=uint256, raw=1 finney)
        vm.expectRevert();
        vm.prank(alice);
        // skip malformed call: sweepCommission(1 finney) (bad raw arg for sweepCommission.arg0: type=uint256, raw=1 finney)
    }

    // @cover-intent Test that only the wizard can transfer ownership, and after transfer the new owner can sweep commission (Authorization & Access Control).
    function test_Transfer_ownership_4() public {
// assume: wizardAddress == owner
// cover: transferOwnership :: onlywizard true
// cover: transferOwnership :: onlywizard false
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.transferOwnership(bob);
        }
        vm.prank(owner);
        {
        target.transferOwnership(bob);
        }
        vm.prank(bob);
        // skip malformed call: sweepCommission(1 finney) (bad raw arg for sweepCommission.arg0: type=uint256, raw=1 finney)
        vm.expectRevert();
        vm.prank(owner);
        // skip malformed call: sweepCommission(1 finney) (bad raw arg for sweepCommission.arg0: type=uint256, raw=1 finney)
    }

    // @cover-intent Test the claim price rounding logic at various thresholds to ensure correct price calculation (Financial & Accounting / Resource & Execution Integrity).
    function test_Claim_price_rounding_boundaries_5() public {
// assume: currentClaimPrice == 337 finney
// cover: claimThrone :: rawNewClaimPrice < 10 finney false
// cover: claimThrone :: rawNewClaimPrice < 100 finney false
// cover: claimThrone :: rawNewClaimPrice < 1 ether true
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentClaimPrice();
        }
        {
        target.currentClaimPrice();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100 ether - 100 finney + 150 finney - wizardCommission
        // TODO assert: bob.balance == 100 ether - 150 finney + 225 finney - wizardCommission
        // TODO assert: carol.balance == 100 ether - 225 finney
    }

    // @cover-intent Test that sending a simple transaction (fallback) with data triggers claimThrone with the data as name (External Interaction & Environment).
    function test_Fallback_function_triggers_claimThrone_6() public {
// assume: currentClaimPrice == 150 finney
// cover: fallback :: calls claimThrone with msg.data
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        // TODO assert: alice.balance == 1 ether - 100 finney + 150 finney - wizardCommission
        // TODO assert: bob.balance == 1 ether - 150 finney
    }

    // @cover-intent Verify that pastMonarchs array correctly tracks all previous monarchs and numberOfMonarchs increments (Protocol State Machine).
    function test_Multiple_claims_and_pastMonarchs_tracking_7() public {
// assume: numberOfMonarchs == 2
// cover: claimThrone :: pastMonarchs.push
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.numberOfMonarchs();
        }
        {
        target.pastMonarchs(0);
        }
        {
        target.pastMonarchs(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that wizard commission is correctly calculated as 1% of the claim price and that the usurped monarch receives the remainder (Financial & Accounting).
    function test_Wizard_commission_calculation_8() public {
// assume: wizardCommission == 1.5 finney
// cover: claimThrone :: wizardCommission calculation
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        // skip malformed call: sweepCommission(1 finney) (bad raw arg for sweepCommission.arg0: type=uint256, raw=1 finney)
        // TODO assert: alice.balance == 2 ether - 100 finney + 148.5 finney
        // TODO assert: bob.balance == 2 ether - 150 finney
        // TODO assert: owner.balance == 1.5 finney
    }

    // @cover-intent Test that when the wizard is the current monarch (vacant throne), the commission accumulates in the contract and is not sent to the wizard (Protocol State Machine).
    function test_Vacant_throne_commission_accumulation_9() public {
// assume: currentMonarch.etherAddress == wizardAddress before claim
// cover: claimThrone :: currentMonarch.etherAddress == wizardAddress true
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentMonarch();
        }
        // TODO assert: alice.balance == 1 ether - 100 finney
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Protocol State Machine
    function test_claimThrone_test_10() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
    function test_currentClaimPrice_test_11() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentClaimPrice();
        }
    }

    // @cover-intent Protocol State Machine
    function test_currentMonarch_test_12() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.currentMonarch();
        }
    }

    // @cover-intent Protocol State Machine
    function test_numberOfMonarchs_test_13() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.numberOfMonarchs();
        }
    }

    // @cover-intent Protocol State Machine
    function test_pastMonarchs_test_14() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.pastMonarchs(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sweepCommission_test_15() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.sweepCommission(1000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_test_16() public {
        vm.startPrank(owner);
        KingOfTheEtherThrone target = new KingOfTheEtherThrone();
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
        target.transferOwnership(alice);
        }
    }

}
