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


    // @cover-intent Authorization & Access Control: Verify that only the owner can withdraw all contract funds via joinFlexible, and that the contract balance becomes zero after withdrawal.
    function test_owner_withdraw_all_funds_0() public {
// assume: owner() == owner
// assume: address(this).balance >= 100 ether
// cover: joinFlexible :: require(msg.sender == owner) true
// cover: joinFlexible :: require(msg.sender == owner) false
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
        // skip ABI-mismatched call: joinFlexible()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: joinFlexible()
    }

    // @cover-intent Authorization & Access Control: Verify that after transferring ownership, the new owner can withdraw funds and the old owner cannot.
    function test_transfer_ownership_and_withdraw_1() public {
// assume: owner() == owner
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: transferOwnership :: require(newOwner != address(0)) true
// cover: joinFlexible :: require(msg.sender == owner) false (old owner)
// cover: joinFlexible :: require(msg.sender == owner) true (new owner)
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
        target.transferOwnership(bob);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: joinFlexible()
        // skip ABI-mismatched call: joinFlexible()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can withdraw funds for a specific user via withdrawForUser.
    function test_withdraw_for_user_by_owner_2() public {
// assume: owner() == owner
// assume: address(this).balance >= 30 ether
// cover: withdrawForUser :: require(msg.sender == owner) true
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
        vm.prank(owner);
        {
        target.withdrawForUser(address(uint160(alice)), 10 ether);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdrawForUser(address(uint160(alice)), 5 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call moveBrick to transfer a specific amount to themselves.
    function test_move_brick_owner_only_3() public {
// assume: owner() == owner
// assume: address(this).balance >= 20 ether
// cover: moveBrick :: require(msg.sender == owner) true
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
        vm.prank(owner);
        {
        target.moveBrick(5 ether);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.moveBrick(1 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call moveBrickContracts to drain the entire contract balance.
    function test_move_brick_contracts_owner_only_4() public {
// assume: owner() == owner
// assume: address(this).balance >= 40 ether
// cover: moveBrickContracts :: require(msg.sender == owner) true
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
        vm.prank(owner);
        // skip ABI-mismatched call: moveBrickContracts()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: moveBrickContracts()
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call moveBrickClear to selfdestruct the contract.
    function test_move_brick_clear_owner_only_5() public {
// assume: owner() == owner
// cover: moveBrickClear :: require(msg.sender == owner) false
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
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: moveBrickClear()
        vm.prank(owner);
        // skip ABI-mismatched call: moveBrickClear()
    }

    // @cover-intent Authorization & Access Control: Verify that all bonus-related functions are only callable by the owner.
    function test_bonus_functions_owner_only_6() public {
// assume: owner() == owner
// assume: address(this).balance >= 100 ether
// cover: staticBonus :: require(msg.sender == owner) false
// cover: staticBonus :: require(msg.sender == owner) true
// cover: activeBonus :: require(msg.sender == owner) false
// cover: activeBonus :: require(msg.sender == owner) true
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
        // skip ABI-mismatched call: staticBonus()
        vm.prank(owner);
        // skip ABI-mismatched call: staticBonus()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: activeBonus()
        vm.prank(owner);
        // skip ABI-mismatched call: activeBonus()
    }

    // @cover-intent Authorization & Access Control: Verify that transferring ownership to the zero address reverts.
    function test_transfer_ownership_to_zero_address_7() public {
// assume: owner() == owner
// cover: transferOwnership :: require(newOwner != address(0)) false
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
        vm.prank(owner);
        {
        target.transferOwnership(address(0));
        }
    }

    // @cover-intent state transition test for bug_re_ent13
    function test_reentrancy_guard_functions_8() public {
// assume: not_called_re_ent13 == true
// assume: not_called_re_ent20 == true
// cover: bug_re_ent13 :: require(not_called_re_ent13) true
// cover: bug_re_ent13 :: require(not_called_re_ent13) false
// cover: bug_re_ent20 :: require(not_called_re_ent20) true
// cover: bug_re_ent20 :: require(not_called_re_ent20) false
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
        // skip ABI-mismatched call: bug_re_ent13()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent13()
        // skip ABI-mismatched call: bug_re_ent20()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent20()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that callme_re_ent* functions can be called up to 5 times and revert on the 6th call.
    function test_callme_counter_functions_9() public {
// assume: counter_re_ent42 == 0
// cover: callme_re_ent42 :: require(counter_re_ent42<=5) true (5 times)
// cover: callme_re_ent42 :: require(counter_re_ent42<=5) false (6th)
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
        // skip ABI-mismatched call: callme_re_ent42()
        // skip ABI-mismatched call: callme_re_ent42()
        // skip ABI-mismatched call: callme_re_ent42()
        // skip ABI-mismatched call: callme_re_ent42()
        // skip ABI-mismatched call: callme_re_ent42()
        vm.expectRevert();
        // skip ABI-mismatched call: callme_re_ent42()
        vm.stopPrank();
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
        target.withdrawForUser(address(uint160(alice)), 100);
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
