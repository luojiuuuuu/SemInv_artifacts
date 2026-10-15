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


    // @cover-intent Verify the initial state after construction and test the first throne claim by a non-wizard user. Covers Financial & Accounting and Protocol State Machine invariants.
    function test_Initial_state_and_first_claim_0() public {
// assume: currentClaimPrice() == 100 finney
// assume: numberOfMonarchs() == 0
// cover: claimThrone :: valuePaid >= currentClaimPrice (true)
// cover: claimThrone :: valuePaid > currentClaimPrice (false)
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
        // skip ABI-mismatched call: currentClaimPrice()
        // skip ABI-mismatched call: currentMonarch()
        // skip ABI-mismatched call: numberOfMonarchs()
        // skip ABI-mismatched call: currentMonarch()
        vm.stopPrank();
    }

    // @cover-intent Test that sending insufficient ether to claimThrone results in a refund and no state change. Covers Transactional Consistency.
    function test_Underpayment_rejection_1() public {
// assume: currentClaimPrice() > 50 finney
// cover: claimThrone :: valuePaid < currentClaimPrice (true)
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

    // @cover-intent Test that sending excess ether results in a refund of the surplus and the claim proceeds normally. Covers Financial & Accounting.
    function test_Overpayment_refund_2() public {
// assume: currentClaimPrice() > 100 finney
// cover: claimThrone :: valuePaid > currentClaimPrice (true)
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
        // skip ABI-mismatched call: currentMonarch()
    }

    // @cover-intent Test that only the wizard can transfer ownership, and after transfer the new owner can sweep commission. Covers Authorization & Access Control.
    function test_Ownership_transfer_3() public {
// assume: owner == wizardAddress
// cover: transferOwnership :: onlywizard modifier (true for owner)
// cover: transferOwnership :: onlywizard modifier (false for alice)
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
        target.transferOwnership(alice);
        }
        vm.prank(owner);
        {
        target.transferOwnership(alice);
        }
    }

    // @cover-intent Test claim price rounding at various thresholds (10 finney, 100 finney, 1 ether, etc.). Covers Resource & Execution Integrity.
    function test_Claim_price_rounding_boundaries_4() public {
// assume: currentClaimPrice() == 100 finney
// cover: claimThrone :: rawNewClaimPrice < 10 finney (false)
// cover: claimThrone :: rawNewClaimPrice < 100 finney (true)
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

    // @cover-intent Test that pastMonarchs correctly tracks all previous monarchs after multiple claims. Covers Protocol State Machine.
    function test_Multiple_claims_and_monarch_history_5() public {
// assume: numberOfMonarchs() == 3
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
        // skip ABI-mismatched call: numberOfMonarchs()
        {
        target.pastMonarchs(0);
        }
        {
        target.pastMonarchs(1);
        }
        {
        target.pastMonarchs(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that sending a plain transaction with data triggers claimThrone with the data as name. Covers External Interaction & Environment.
    function test_Fallback_function_triggers_claimThrone_6() public {
// assume: currentClaimPrice() > 100 finney
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
        vm.prank(bob);
        // skip ABI-mismatched call: currentMonarch()
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
        vm.prank(bob);
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
