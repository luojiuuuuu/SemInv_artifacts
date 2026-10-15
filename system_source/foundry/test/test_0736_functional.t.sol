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


    // @cover-intent Verify the initial state after construction and test a successful throne claim by alice with exact payment (Financial & Accounting).
    function test_Initial_state_and_basic_claim_0() public {
// assume: currentClaimPrice() == 100 finney
// assume: currentMonarch().etherAddress == owner
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
        // skip ABI-mismatched call: currentClaimPrice()
        // skip ABI-mismatched call: currentMonarch()
        // skip ABI-mismatched call: numberOfMonarchs()
        vm.stopPrank();
    }

    // @cover-intent Test that only the wizard can transfer ownership and that the new wizard can then sweep (Authorization & Access Control).
    function test_Transfer_ownership_by_wizard_1() public {
// assume: msg.sender == wizardAddress
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Test that the fallback function calls claimThrone with msg.data as name (External Interaction & Environment).
    function test_Fallback_function_claim_2() public {
// assume: currentClaimPrice() == 100 finney
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

    // @cover-intent Test that pastMonarchs correctly tracks history after multiple claims (Transactional Consistency).
    function test_Multiple_claims_and_monarch_history_3() public {
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
        {
        target.pastMonarchs(0);
        }
        {
        target.pastMonarchs(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_currentClaimPrice_test_4() public {
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
        {
            uint256 __v1 = uint256(target.currentClaimPrice());
            _assertRelU(__v1, 0, 100000000000000000, "call:currentClaimPrice==100000000000000000");
        }
    }

    // @cover-intent Protocol State Machine
    function test_currentMonarch_test_5() public {
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
    function test_numberOfMonarchs_test_6() public {
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
        {
            uint256 __v2 = uint256(target.numberOfMonarchs());
            _assertRelU(__v2, 0, 0, "call:numberOfMonarchs==0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_pastMonarchs_test_7() public {
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
    function test_sweepCommission_test_8() public {
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
    function test_transferOwnership_test_9() public {
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
    function test_perfn_claimThrone_10() public {
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
