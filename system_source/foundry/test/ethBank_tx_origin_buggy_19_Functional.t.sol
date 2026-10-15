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


    // @cover-intent Authorization & Access Control: Verify that only the owner can call joinFlexible to drain the contract balance.
    function test_Owner_can_withdraw_all_balance_via_joinFlexible_0() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 10
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
        vm.prank(alice);
        // skip malformed call: sendto_txorigin1(ethBank, 10, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.joinFlexible();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.joinFlexible();
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call joinFixed to drain the contract balance.
    function test_Owner_can_withdraw_all_balance_via_joinFixed_1() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 5
// cover: joinFixed :: require(msg.sender == owner) true
// cover: joinFixed :: require(msg.sender == owner) false
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
        // skip malformed call: sendto_txorigin1(ethBank, 5, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.joinFixed();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.joinFixed();
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call staticBonus to drain the contract balance.
    function test_Owner_can_withdraw_all_balance_via_staticBonus_2() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 7
// cover: staticBonus :: require(msg.sender == owner) true
// cover: staticBonus :: require(msg.sender == owner) false
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
        // skip malformed call: sendto_txorigin1(ethBank, 7, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.staticBonus();
        }
        vm.expectRevert();
        vm.prank(carol);
        {
        target.staticBonus();
        }
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call activeBonus to drain the contract balance.
    function test_Owner_can_withdraw_all_balance_via_activeBonus_3() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 3
// cover: activeBonus :: require(msg.sender == owner) true
// cover: activeBonus :: require(msg.sender == owner) false
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
        // skip malformed call: sendto_txorigin1(ethBank, 3, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.activeBonus();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.activeBonus();
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call teamAddBonus to drain the contract balance.
    function test_Owner_can_withdraw_all_balance_via_teamAddBonus_4() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 8
// cover: teamAddBonus :: require(msg.sender == owner) true
// cover: teamAddBonus :: require(msg.sender == owner) false
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
        // skip malformed call: sendto_txorigin1(ethBank, 8, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.teamAddBonus();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.teamAddBonus();
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call moveBrickContracts to drain the contract balance.
    function test_Owner_can_withdraw_all_balance_via_moveBrickContracts_5() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 12
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
        vm.prank(alice);
        // skip malformed call: sendto_txorigin1(ethBank, 12, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.moveBrickContracts();
        }
        vm.expectRevert();
        vm.prank(carol);
        {
        target.moveBrickContracts();
        }
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call moveBrick to withdraw a specific amount.
    function test_Owner_can_withdraw_specific_amount_via_moveBrick_6() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 20
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
        vm.prank(alice);
        // skip malformed call: sendto_txorigin1(ethBank, 20, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.moveBrick(10);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.moveBrick(5);
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call withdrawForUser to send funds to a specific address.
    function test_Owner_can_withdraw_for_a_user_via_withdrawForUser_7() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 15
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
        vm.prank(alice);
        // skip malformed call: sendto_txorigin1(ethBank, 15, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.withdrawForUser(bob, 7);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdrawForUser(bob, 3);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that transferOwnership changes the owner and the new owner can call owner-only functions.
    function test_Owner_can_transfer_ownership_and_then_new_owner_can_withdraw_8() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 10
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: transferOwnership :: require(newOwner != address(0)) true
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
        vm.prank(alice);
        // skip malformed call: sendto_txorigin1(ethBank, 10, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.startPrank(owner);
        {
        target.transferOwnership(bob);
        }
        {
        target.joinFlexible();
        }
        vm.expectRevert();
        {
        target.joinFlexible();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that only the owner can call moveBrickClear to selfdestruct the contract.
    function test_Owner_can_destroy_contract_via_moveBrickClear_9() public {
// assume: owner() == owner
// assume: address(ethBank).balance >= 5
// cover: moveBrickClear :: require(msg.sender == owner) true
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
        vm.prank(alice);
        // skip malformed call: sendto_txorigin1(ethBank, 5, alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=ethBank)
        vm.prank(owner);
        {
        target.moveBrickClear();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.moveBrickClear();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonus_owner_10() public {
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
        target.owner();
        }
        {
        target.activeBonus();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_1_owner_11() public {
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
        target.activeBonusCacl_1();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_2_owner_12() public {
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
        target.activeBonusCacl_2();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_3_owner_13() public {
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
        target.activeBonusCacl_3();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_4_owner_14() public {
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
        target.activeBonusCacl_4();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_5_owner_15() public {
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
        target.activeBonusCacl_5();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_6_owner_16() public {
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
        target.activeBonusCacl_6();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_7_owner_17() public {
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
        target.activeBonusCacl_7();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_8_owner_18() public {
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
        target.activeBonusCacl_8();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_activeBonusCacl_9_owner_19() public {
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
        target.activeBonusCacl_9();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin12_owner_20() public {
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
        target.bug_txorigin12(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin20_owner_21() public {
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
        target.bug_txorigin20(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin32_owner_22() public {
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
        target.bug_txorigin32(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin36_owner_23() public {
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
        target.bug_txorigin36(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin4_owner_24() public {
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
        target.bug_txorigin4(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin40_owner_25() public {
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
        target.bug_txorigin40(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin8_owner_26() public {
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
        target.bug_txorigin8(owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_caclTeamPerformance_owner_27() public {
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
        target.caclTeamPerformance();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_joinFixed_owner_28() public {
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
        target.joinFixed();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_joinFlexible_owner_29() public {
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
        target.joinFlexible();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_moveBrick_owner_30() public {
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
        target.moveBrick(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_moveBrickClear_owner_31() public {
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
        target.moveBrickClear();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_moveBrickContracts_owner_32() public {
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
        target.moveBrickContracts();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_33() public {
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
        target.owner();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_releaActiveBonus_owner_34() public {
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
        target.releaActiveBonus();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_releaStaticBonus_owner_35() public {
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
        target.releaStaticBonus();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_releaTeamAddBonus_owner_36() public {
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
        target.releaTeamAddBonus();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin1_owner_37() public {
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
        target.sendto_txorigin1(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin13_owner_38() public {
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
        target.sendto_txorigin13(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin17_owner_39() public {
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
        target.sendto_txorigin17(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin25_owner_40() public {
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
        target.sendto_txorigin25(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin33_owner_41() public {
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
        target.sendto_txorigin33(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin37_owner_42() public {
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
        target.sendto_txorigin37(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin9_owner_43() public {
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
        target.sendto_txorigin9(alice, 100, owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_staticBonus_owner_44() public {
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
        target.staticBonus();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_staticBonusCacl_owner_45() public {
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
        target.staticBonusCacl();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_teamAddBonus_owner_46() public {
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
        target.teamAddBonus();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_teamAddBonusCacl_owner_47() public {
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
        target.teamAddBonusCacl();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_owner_48() public {
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

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin11_owner_49() public {
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
        target.transferTo_txorigin11(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin19_owner_50() public {
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
        target.transferTo_txorigin19(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin23_owner_51() public {
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
        target.transferTo_txorigin23(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin27_owner_52() public {
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
        target.transferTo_txorigin27(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin3_owner_53() public {
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
        target.transferTo_txorigin3(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin31_owner_54() public {
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
        target.transferTo_txorigin31(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin35_owner_55() public {
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
        target.transferTo_txorigin35(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin39_owner_56() public {
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
        target.transferTo_txorigin39(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin7_owner_57() public {
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
        target.transferTo_txorigin7(alice, 100, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin14_owner_58() public {
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
        target.withdrawAll_txorigin14(alice, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin2_owner_59() public {
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
        target.withdrawAll_txorigin2(alice, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin26_owner_60() public {
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
        target.withdrawAll_txorigin26(alice, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin30_owner_61() public {
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
        target.withdrawAll_txorigin30(alice, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin38_owner_62() public {
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
        target.withdrawAll_txorigin38(alice, owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawForUser_owner_63() public {
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
        target.withdrawForUser(alice, 100);
        }
    }

}
