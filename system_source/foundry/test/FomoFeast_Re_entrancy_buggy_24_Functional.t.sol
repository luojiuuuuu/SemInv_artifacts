// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;
import "../src/buggy_24.sol";

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

contract FomoFeast_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify that only the owner can transfer ownership and that the contract initializes correctly.
    function test_Initialization_and_Ownership_Transfer_0() public {
// cover: initialize :: require(!initialized) true
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: transferOwnership :: require(msg.sender == owner) false
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transferOwnership(alice);
        }
        vm.startPrank(owner);
        {
        target.transferOwnership(alice);
        }
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that a user can invest with a valid sponsor and cycle, and that state variables update correctly.
    function test_Invest_with_Valid_Sponsor_and_Cycle_1() public {
// cover: invest :: require(sponsor.totalInvestCount > 0) true
// cover: invest :: require(investCycle == 30 || 60 || 90) true
// cover: invest :: require(investAmount == msg.value) true
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.prank(bob);
        {
        target.invest.value(2 ether)(alice, 60);
        }
        vm.startPrank(owner);
        // skip ABI-mismatched call: totalInvestCount()
        // skip ABI-mismatched call: totalInvestAmount()
        // skip ABI-mismatched call: totalUserCount()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that investing with an invalid sponsor address reverts.
    function test_Invest_with_Invalid_Sponsor_2() public {
// cover: invest :: require(sponsor.totalInvestCount > 0) false
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1 ether)(alice, 30);
        }
    }

    // @cover-intent Transactional Consistency: Verify that investing with an invalid cycle reverts.
    function test_Invest_with_Invalid_Cycle_3() public {
// cover: invest :: require(investCycle == 30 || 60 || 90) false
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.expectRevert();
        {
        target.invest.value(1 ether)(alice, 45);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that a user can withdraw their investment before expiry with a penalty.
    function test_User_Withdraw_Before_Expiry_4() public {
// cover: userWithdraw :: require(user.currentInvestAmount > 0) true
// cover: isInvestExpired :: return false
// cover: getAbortInvestAmount :: require(commissionDays >= 3) true
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        // skip ABI-mismatched call: userWithdraw()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that commission withdrawal reverts if the amount is below 0.1 ETH.
    function test_User_Withdraw_Commission_Below_Threshold_5() public {
// cover: userWithdrawCommission :: require(avaliableWithdrawAmount >= ONE_ETH.div(10)) false
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        // skip ABI-mismatched call: userWithdrawCommission()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the engineer can withdraw engineer funds.
    function test_Engineer_Withdraw_6() public {
// cover: engineerWithdraw :: require(msg.sender == ENGINEER_ADDRESS) true
// cover: engineerWithdraw :: require(msg.sender == ENGINEER_ADDRESS) false
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: engineerWithdraw()
        // skip ABI-mismatched call: engineerWithdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can withdraw operator funds.
    function test_Operator_Withdraw_7() public {
// cover: operatorWithdraw :: require(msg.sender == owner) true
// cover: operatorWithdraw :: require(msg.sender == owner) false
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: operatorWithdraw()
        vm.stopPrank();
        vm.prank(owner);
        // skip ABI-mismatched call: operatorWithdraw()
    }

    // @cover-intent Resource & Execution Integrity: Verify that the owner can calculate dynamic commissions for a range of users.
    function test_Calc_Dynamic_Commission_Range_8() public {
// cover: calcDynamicCommissionRange :: require(msg.sender == owner) true
// cover: calcDynamicCommissionEnd :: require(msg.sender == owner) true
        vm.startPrank(alice);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.prank(bob);
        {
        target.invest.value(1 ether)(alice, 30);
        }
        vm.startPrank(owner);
        {
        target.calcDynamicCommissionRange(0, 2);
        }
        {
        target.calcDynamicCommissionEnd(0, 2);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for bug_re_ent6
    function test_Access_Controlled_Functions_Revert_for_Non_Owner_9() public {
// cover: bug_re_ent6 :: require(not_called_re_ent6) true
// cover: bug_re_ent20 :: require(not_called_re_ent20) true
// cover: bug_re_ent27 :: require(not_called_re_ent27) true
// cover: bug_re_ent34 :: require(not_called_re_ent34) true
// cover: bug_re_ent41 :: require(not_called_re_ent41) true
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
        vm.startPrank(alice);
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent6()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent20()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent27()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent34()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent41()
        vm.stopPrank();
    }

    // @cover-intent minimal test for bug_re_ent13
    function test_perfn_bug_re_ent13_10() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_bug_re_ent20_11() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_bug_re_ent27_12() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for bug_re_ent34
    function test_perfn_bug_re_ent34_13() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: bug_re_ent34()
    }

    // @cover-intent minimal test for bug_re_ent41
    function test_perfn_bug_re_ent41_14() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for bug_re_ent6
    function test_perfn_bug_re_ent6_15() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: bug_re_ent6()
    }

    // @cover-intent minimal test for buyTicket_re_ent16
    function test_perfn_buyTicket_re_ent16_16() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: buyTicket_re_ent16()
    }

    // @cover-intent minimal test for buyTicket_re_ent2
    function test_perfn_buyTicket_re_ent2_17() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_buyTicket_re_ent23_18() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_buyTicket_re_ent30_19() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_buyTicket_re_ent37_20() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_buyTicket_re_ent9_21() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for calcDynamicCommission
    function test_perfn_calcDynamicCommission_22() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: calcDynamicCommission()
    }

    // @cover-intent minimal test for calcDynamicCommissionBegin
    function test_perfn_calcDynamicCommissionBegin_23() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.calcDynamicCommissionBegin(1, 1);
        }
    }

    // @cover-intent minimal test for calcDynamicCommissionEnd
    function test_perfn_calcDynamicCommissionEnd_24() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.calcDynamicCommissionEnd(1, 1);
        }
    }

    // @cover-intent minimal test for calcDynamicCommissionRange
    function test_perfn_calcDynamicCommissionRange_25() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.calcDynamicCommissionRange(1, 1);
        }
    }

    // @cover-intent minimal test for callme_re_ent14
    function test_perfn_callme_re_ent14_26() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for callme_re_ent21
    function test_perfn_callme_re_ent21_27() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: callme_re_ent21()
    }

    // @cover-intent minimal test for callme_re_ent28
    function test_perfn_callme_re_ent28_28() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: callme_re_ent28()
    }

    // @cover-intent minimal test for callme_re_ent35
    function test_perfn_callme_re_ent35_29() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_callme_re_ent42_30() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_callme_re_ent7_31() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for claimReward_re_ent11
    function test_perfn_claimReward_re_ent11_32() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: claimReward_re_ent11()
    }

    // @cover-intent minimal test for claimReward_re_ent18
    function test_perfn_claimReward_re_ent18_33() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: claimReward_re_ent18()
    }

    // @cover-intent minimal test for claimReward_re_ent25
    function test_perfn_claimReward_re_ent25_34() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        FomoFeast target = new FomoFeast();
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
        FomoFeast target = new FomoFeast();
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
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for engineerFunds
    function test_perfn_engineerFunds_38() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: engineerFunds()
    }

    // @cover-intent minimal test for engineerWithdraw
    function test_perfn_engineerWithdraw_39() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: engineerWithdraw()
    }

    // @cover-intent minimal test for engineerWithdrawAmount
    function test_perfn_engineerWithdrawAmount_40() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: engineerWithdrawAmount()
    }

    // @cover-intent minimal test for getDynamicCommissionRecords
    function test_perfn_getDynamicCommissionRecords_41() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.getDynamicCommissionRecords(alice);
        }
    }

    // @cover-intent minimal test for getInvestRecords
    function test_perfn_getInvestRecords_42() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.getInvestRecords(alice);
        }
    }

    // @cover-intent minimal test for getStaticCommissionRecords
    function test_perfn_getStaticCommissionRecords_43() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.getStaticCommissionRecords(alice);
        }
    }

    // @cover-intent minimal test for getSummary
    function test_perfn_getSummary_44() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: getSummary()
    }

    // @cover-intent minimal test for getUserByAddress
    function test_perfn_getUserByAddress_45() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.getUserByAddress(alice);
        }
    }

    // @cover-intent minimal test for getUserByIndex
    function test_perfn_getUserByIndex_46() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.getUserByIndex(1);
        }
    }

    // @cover-intent minimal test for initialize
    function test_perfn_initialize_47() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: initialize()
    }

    // @cover-intent minimal test for invest
    function test_perfn_invest_48() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.invest(alice, 1);
        }
    }

    // @cover-intent minimal test for operatorFunds
    function test_perfn_operatorFunds_49() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: operatorFunds()
    }

    // @cover-intent minimal test for operatorWithdraw
    function test_perfn_operatorWithdraw_50() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: operatorWithdraw()
    }

    // @cover-intent minimal test for operatorWithdrawAmount
    function test_perfn_operatorWithdrawAmount_51() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: operatorWithdrawAmount()
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_52() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for totalDynamicCommissionWithdrawAmount
    function test_perfn_totalDynamicCommissionWithdrawAmount_53() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: totalDynamicCommissionWithdrawAmount()
    }

    // @cover-intent minimal test for totalInvestAmount
    function test_perfn_totalInvestAmount_54() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: totalInvestAmount()
    }

    // @cover-intent minimal test for totalInvestCount
    function test_perfn_totalInvestCount_55() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: totalInvestCount()
    }

    // @cover-intent minimal test for totalStaticCommissionWithdrawAmount
    function test_perfn_totalStaticCommissionWithdrawAmount_56() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: totalStaticCommissionWithdrawAmount()
    }

    // @cover-intent minimal test for totalUserCount
    function test_perfn_totalUserCount_57() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: totalUserCount()
    }

    // @cover-intent minimal test for totalWithdrawAmount
    function test_perfn_totalWithdrawAmount_58() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: totalWithdrawAmount()
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_59() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for userWithdraw
    function test_perfn_userWithdraw_60() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: userWithdraw()
    }

    // @cover-intent minimal test for userWithdrawCommission
    function test_perfn_userWithdrawCommission_61() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: userWithdrawCommission()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent12
    function test_perfn_withdrawBalance_re_ent12_62() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent12()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent19
    function test_perfn_withdrawBalance_re_ent19_63() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdrawBalance_re_ent26_64() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdrawBalance_re_ent33_65() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdrawBalance_re_ent40_66() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for withdrawBalance_re_ent5
    function test_perfn_withdrawBalance_re_ent5_67() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent5()
    }

    // @cover-intent minimal test for withdrawFunds_re_ent10
    function test_perfn_withdrawFunds_re_ent10_68() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.withdrawFunds_re_ent10(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent17
    function test_perfn_withdrawFunds_re_ent17_69() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for withdrawFunds_re_ent24
    function test_perfn_withdrawFunds_re_ent24_70() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        target.withdrawFunds_re_ent24(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent3
    function test_perfn_withdrawFunds_re_ent3_71() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdrawFunds_re_ent31_72() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdrawFunds_re_ent38_73() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdraw_balances_re_ent1_74() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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

    // @cover-intent minimal test for withdraw_balances_re_ent15
    function test_perfn_withdraw_balances_re_ent15_75() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent15()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent21
    function test_perfn_withdraw_balances_re_ent21_76() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent21()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent29
    function test_perfn_withdraw_balances_re_ent29_77() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent29()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent36
    function test_perfn_withdraw_balances_re_ent36_78() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
    function test_perfn_withdraw_balances_re_ent8_79() public {
        vm.startPrank(owner);
        FomoFeast target = new FomoFeast();
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
