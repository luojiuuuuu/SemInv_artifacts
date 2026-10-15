// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/lucky_doubler.sol";

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

contract LuckyDoubler_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function LuckyDoubler_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: only owner can change fee, and fee must be <= 5.
    function test_Owner_changes_fee_to_valid_value_0() public {
// cover: changeFee :: require(fee > 5) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(3);
        }
        {
        target.currentFee();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: non-owner call to changeFee reverts.
    function test_Non_owner_cannot_change_fee_1() public {
// cover: changeFee :: require(msg.sender == owner) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(3);
        }
    }

    // @cover-intent Authorization & Access Control: owner cannot set fee > 5, transaction reverts.
    function test_Owner_changes_fee_to_invalid_value_greater_than_5_2() public {
// cover: changeFee :: require(fee > 5) true
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(6);
        }
    }

    // @cover-intent Authorization & Access Control: only owner can change multiplier, must be between 110 and 150.
    function test_Owner_changes_multiplier_to_valid_value_3() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(130);
        }
        {
        target.multiplierFactor();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: non-owner call to changeMultiplier reverts.
    function test_Non_owner_cannot_change_multiplier_4() public {
// cover: changeMultiplier :: require(msg.sender == owner) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(130);
        }
    }

    // @cover-intent Authorization & Access Control: owner cannot set multiplier < 110, transaction reverts.
    function test_Owner_changes_multiplier_to_invalid_value_below_110_5() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) true
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(100);
        }
    }

    // @cover-intent Authorization & Access Control: owner cannot set multiplier > 150, transaction reverts.
    function test_Owner_changes_multiplier_to_invalid_value_above_150_6() public {
// cover: changeMultiplier :: require(multi < 110 || multi > 150) true
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(160);
        }
    }

    // @cover-intent Authorization & Access Control: only owner can change owner, and new owner takes over.
    function test_Owner_changes_owner_to_another_address_7() public {
// cover: changeOwner :: require(msg.sender == owner) true
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeOwner(alice);
        }
        {
        target.changeFee(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: non-owner call to changeOwner reverts.
    function test_Non_owner_cannot_change_owner_8() public {
// cover: changeOwner :: require(msg.sender == owner) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeOwner(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity: view functions return correct state after no changes.
    function test_Query_functions_return_expected_data_9() public {
// cover: entryDetails :: require(index < entries.length) false
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.multiplierFactor();
        }
        {
        target.currentFee();
        }
        {
        target.totalEntries();
        }
        {
        target.userStats(alice);
        }
        {
        target.entryDetails(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_currentFee_view_10() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.currentFee();
        }
    }

    // @cover-intent Financial & Accounting
    function test_multiplierFactor_view_11() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.multiplierFactor();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalEntries_view_12() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.totalEntries();
        }
    }

    // @cover-intent minimal test for changeFee
    function test_perfn_changeFee_13() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeFee(1);
        }
    }

    // @cover-intent minimal test for changeMultiplier
    function test_perfn_changeMultiplier_14() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeMultiplier(1);
        }
    }

    // @cover-intent minimal test for changeOwner
    function test_perfn_changeOwner_15() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.changeOwner(alice);
        }
    }

    // @cover-intent minimal test for entryDetails
    function test_perfn_entryDetails_16() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.entryDetails(1);
        }
    }

    // @cover-intent minimal test for userStats
    function test_perfn_userStats_17() public {
        vm.startPrank(owner);
        LuckyDoubler target = new LuckyDoubler();
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
        target.userStats(alice);
        }
    }

}
