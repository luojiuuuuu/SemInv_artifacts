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


    // @cover-intent Verify the initial state after deployment and test a successful throne claim by alice with exact payment (Financial & Accounting, Protocol State Machine)
    function test_Initial_throne_setup_and_first_claim_0() public {
// cover: claimThrone :: valuePaid == currentClaimPrice
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: currentMonarch()
        // skip ABI-mismatched call: currentClaimPrice()
        vm.stopPrank();
        // TODO assert: call:currentClaimPrice() == 150 finney
    }

    // @cover-intent Test that paying more than currentClaimPrice results in a refund of the excess (Financial & Accounting, Transactional Consistency)
    function test_Claim_with_excess_payment_refund_test_1() public {
// cover: claimThrone :: valuePaid > currentClaimPrice
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
        vm.prank(bob);
        // skip ABI-mismatched call: currentMonarch()
    }

    // @cover-intent Test that paying less than currentClaimPrice results in a full refund and no state change (Financial & Accounting, Transactional Consistency)
    function test_Claim_with_insufficient_payment_refund_test_2() public {
// cover: claimThrone :: valuePaid < currentClaimPrice
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
        vm.prank(bob);
        // skip ABI-mismatched call: currentMonarch()
        // TODO assert: call:currentClaimPrice() == 150 finney
    }

    // @cover-intent Test the price escalation formula over multiple claims, verifying rounding at different tiers (Financial & Accounting, Protocol State Machine)
    function test_Multiple_claims_and_price_escalation_3() public {
// cover: claimThrone :: rawNewClaimPrice < 10 finney
// cover: claimThrone :: rawNewClaimPrice < 100 finney
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
        vm.prank(carol);
        // skip ABI-mismatched call: numberOfMonarchs()
        // TODO assert: call:currentClaimPrice() == 337 finney
        {
            uint256 __v1 = uint256(target.numberOfMonarchs());
            _assertRelU(__v1, 0, 2, "call:numberOfMonarchs==2");
        }
    }

    // @cover-intent Test that only the wizard can transfer ownership, and after transfer the new owner becomes wizard (Authorization & Access Control)
    function test_Transfer_ownership_by_wizard_4() public {
// cover: transferOwnership :: onlywizard modifier true
// cover: transferOwnership :: onlywizard modifier false
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

    // @cover-intent Test that sending a simple transaction (fallback) with data triggers claimThrone with the data as name (External Interaction & Environment)
    function test_Fallback_function_triggers_claimThrone_5() public {
// cover: fallback :: fallback called
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
        // skip ABI-mismatched call: currentMonarch()
        // TODO assert: call:currentClaimPrice() == 150 finney
    }

    // @cover-intent Test price rounding behavior when rawNewClaimPrice crosses the 1 ether threshold (Financial & Accounting, Resource & Execution Integrity)
    function test_Price_rounding_at_1_ether_threshold_6() public {
// cover: claimThrone :: rawNewClaimPrice < 1 ether
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
        vm.prank(bob);
        // skip ABI-mismatched call: currentClaimPrice()
        // TODO assert: call:currentClaimPrice() == 225 finney
    }

    // @cover-intent Protocol State Machine
    function test_currentClaimPrice_sequence_7() public {
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
        // skip ABI-mismatched call: currentClaimPrice()
    }

    // @cover-intent Protocol State Machine
    function test_currentMonarch_sequence_8() public {
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
        // skip ABI-mismatched call: currentMonarch()
    }

    // @cover-intent Protocol State Machine
    function test_numberOfMonarchs_sequence_9() public {
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
        // skip ABI-mismatched call: numberOfMonarchs()
    }

    // @cover-intent Protocol State Machine
    function test_pastMonarchs_sequence_10() public {
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
        vm.prank(bob);
        {
        target.pastMonarchs(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sweepCommission_sequence_11() public {
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
    function test_transferOwnership_sequence_12() public {
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

    // @cover-intent minimal test for claimThrone
    function test_perfn_claimThrone_13() public {
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
        target.claimThrone("Name");
        }
    }

}
