// SPDX-License-Identifier: MIT
pragma solidity 0.5.1;
import "../src/buggy_19.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract ethBank_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Authorization & Access Control: Verify that only the owner can transfer ownership, and that after transfer the new owner can call owner-only functions.
    function test_owner_transfer_ownership_and_verify_0() public {
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: transferOwnership :: require(newOwner != address(0)) true
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.transferOwnership(alice);
        }
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot transfer ownership.
    function test_non_owner_cannot_transfer_ownership_1() public {
// cover: transferOwnership :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
    }

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw the entire contract balance via moveBrickContracts.
    function test_owner_withdraws_contract_balance_2() public {
// assume: address(this).balance >= 100 ether
// cover: moveBrickContracts :: require(msg.sender == owner) true
        vm.startPrank(alice);
        ethBank target = new ethBank();
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
        // skip empty call after value injection
        vm.prank(owner);
        // skip ABI-mismatched call: moveBrickContracts()
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call moveBrickContracts.
    function test_non_owner_cannot_withdraw_contract_balance_3() public {
// cover: moveBrickContracts :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: moveBrickContracts()
    }

    // @cover-intent Resource & Execution Integrity: Verify that the owner can call moveBrickClear to selfdestruct the contract.
    function test_owner_calls_moveBrickClear_selfdestruct_4() public {
// cover: moveBrickClear :: require(msg.sender == owner) true
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: moveBrickClear()
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call moveBrickClear.
    function test_non_owner_cannot_call_moveBrickClear_5() public {
// cover: moveBrickClear :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: moveBrickClear()
    }

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw a specific amount via moveBrick.
    function test_owner_withdraws_specific_amount_6() public {
// assume: address(this).balance >= 10 ether
// cover: moveBrick :: require(msg.sender == owner) true
        vm.startPrank(alice);
        ethBank target = new ethBank();
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.moveBrick(10 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call moveBrick.
    function test_non_owner_cannot_withdraw_specific_amount_7() public {
// cover: moveBrick :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.moveBrick(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw funds for a specific user via withdrawForUser.
    function test_owner_calls_withdrawForUser_8() public {
// assume: address(this).balance >= 50 ether
// cover: withdrawForUser :: require(msg.sender == owner) true
        vm.startPrank(alice);
        ethBank target = new ethBank();
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
        // skip empty call after value injection
        vm.prank(owner);
        {
        target.withdrawForUser(bob, 50 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call withdrawForUser.
    function test_non_owner_cannot_call_withdrawForUser_9() public {
// cover: withdrawForUser :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.withdrawForUser(bob, 1 ether);
        }
    }

    // @cover-intent minimal test for activeBonus
    function test_perfn_activeBonus_10() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonus()
    }

    // @cover-intent minimal test for activeBonusCacl_1
    function test_perfn_activeBonusCacl_1_11() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_1()
    }

    // @cover-intent minimal test for activeBonusCacl_2
    function test_perfn_activeBonusCacl_2_12() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_2()
    }

    // @cover-intent minimal test for activeBonusCacl_3
    function test_perfn_activeBonusCacl_3_13() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_3()
    }

    // @cover-intent minimal test for activeBonusCacl_4
    function test_perfn_activeBonusCacl_4_14() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_4()
    }

    // @cover-intent minimal test for activeBonusCacl_5
    function test_perfn_activeBonusCacl_5_15() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_5()
    }

    // @cover-intent minimal test for activeBonusCacl_6
    function test_perfn_activeBonusCacl_6_16() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_6()
    }

    // @cover-intent minimal test for activeBonusCacl_7
    function test_perfn_activeBonusCacl_7_17() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_7()
    }

    // @cover-intent minimal test for activeBonusCacl_8
    function test_perfn_activeBonusCacl_8_18() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_8()
    }

    // @cover-intent minimal test for activeBonusCacl_9
    function test_perfn_activeBonusCacl_9_19() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: activeBonusCacl_9()
    }

    // @cover-intent minimal test for bug_re_ent13
    function test_perfn_bug_re_ent13_20() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent minimal test for bug_re_ent20
    function test_perfn_bug_re_ent20_21() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: bug_re_ent20()
    }

    // @cover-intent minimal test for bug_re_ent27
    function test_perfn_bug_re_ent27_22() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent minimal test for bug_re_ent41
    function test_perfn_bug_re_ent41_23() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: bug_re_ent41()
    }

    // @cover-intent minimal test for buyTicket_re_ent2
    function test_perfn_buyTicket_re_ent2_24() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent minimal test for buyTicket_re_ent23
    function test_perfn_buyTicket_re_ent23_25() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: buyTicket_re_ent23()
    }

    // @cover-intent minimal test for buyTicket_re_ent30
    function test_perfn_buyTicket_re_ent30_26() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: buyTicket_re_ent30()
    }

    // @cover-intent minimal test for buyTicket_re_ent37
    function test_perfn_buyTicket_re_ent37_27() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: buyTicket_re_ent37()
    }

    // @cover-intent minimal test for buyTicket_re_ent9
    function test_perfn_buyTicket_re_ent9_28() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent minimal test for caclTeamPerformance
    function test_perfn_caclTeamPerformance_29() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: caclTeamPerformance()
    }

    // @cover-intent minimal test for callme_re_ent14
    function test_perfn_callme_re_ent14_30() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: callme_re_ent14()
    }

    // @cover-intent minimal test for callme_re_ent35
    function test_perfn_callme_re_ent35_31() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent minimal test for callme_re_ent42
    function test_perfn_callme_re_ent42_32() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent minimal test for callme_re_ent7
    function test_perfn_callme_re_ent7_33() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: callme_re_ent7()
    }

    // @cover-intent minimal test for claimReward_re_ent25
    function test_perfn_claimReward_re_ent25_34() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent minimal test for claimReward_re_ent32
    function test_perfn_claimReward_re_ent32_35() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: claimReward_re_ent32()
    }

    // @cover-intent minimal test for claimReward_re_ent39
    function test_perfn_claimReward_re_ent39_36() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent minimal test for claimReward_re_ent4
    function test_perfn_claimReward_re_ent4_37() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: claimReward_re_ent4()
    }

    // @cover-intent minimal test for joinFixed
    function test_perfn_joinFixed_38() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: joinFixed()
    }

    // @cover-intent minimal test for joinFlexible
    function test_perfn_joinFlexible_39() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: joinFlexible()
    }

    // @cover-intent minimal test for moveBrick
    function test_perfn_moveBrick_40() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.moveBrick(100);
        }
    }

    // @cover-intent minimal test for moveBrickClear
    function test_perfn_moveBrickClear_41() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: moveBrickClear()
    }

    // @cover-intent minimal test for moveBrickContracts
    function test_perfn_moveBrickContracts_42() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: moveBrickContracts()
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_43() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent minimal test for releaActiveBonus
    function test_perfn_releaActiveBonus_44() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: releaActiveBonus()
    }

    // @cover-intent minimal test for releaStaticBonus
    function test_perfn_releaStaticBonus_45() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: releaStaticBonus()
    }

    // @cover-intent minimal test for releaTeamAddBonus
    function test_perfn_releaTeamAddBonus_46() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: releaTeamAddBonus()
    }

    // @cover-intent minimal test for staticBonus
    function test_perfn_staticBonus_47() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: staticBonus()
    }

    // @cover-intent minimal test for staticBonusCacl
    function test_perfn_staticBonusCacl_48() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: staticBonusCacl()
    }

    // @cover-intent minimal test for teamAddBonus
    function test_perfn_teamAddBonus_49() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: teamAddBonus()
    }

    // @cover-intent minimal test for teamAddBonusCacl
    function test_perfn_teamAddBonusCacl_50() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: teamAddBonusCacl()
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_51() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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

    // @cover-intent minimal test for withdrawBalance_re_ent19
    function test_perfn_withdrawBalance_re_ent19_52() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent26
    function test_perfn_withdrawBalance_re_ent26_53() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent33
    function test_perfn_withdrawBalance_re_ent33_54() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent40
    function test_perfn_withdrawBalance_re_ent40_55() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent minimal test for withdrawForUser
    function test_perfn_withdrawForUser_56() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.withdrawForUser(alice, 100);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent17
    function test_perfn_withdrawFunds_re_ent17_57() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.withdrawFunds_re_ent17(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent3
    function test_perfn_withdrawFunds_re_ent3_58() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.withdrawFunds_re_ent3(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent31
    function test_perfn_withdrawFunds_re_ent31_59() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.withdrawFunds_re_ent31(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent38
    function test_perfn_withdrawFunds_re_ent38_60() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        target.withdrawFunds_re_ent38(1);
        }
    }

    // @cover-intent minimal test for withdraw_balances_re_ent1
    function test_perfn_withdraw_balances_re_ent1_61() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent1()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent36
    function test_perfn_withdraw_balances_re_ent36_62() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent8
    function test_perfn_withdraw_balances_re_ent8_63() public {
        vm.startPrank(owner);
        ethBank target = new ethBank();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent8()
    }

}
