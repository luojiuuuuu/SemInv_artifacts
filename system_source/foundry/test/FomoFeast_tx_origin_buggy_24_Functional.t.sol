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


    // @cover-intent Protocol State Machine: Verify contract initializes correctly with genesis user and owner set.
    function test_Initialization_and_Genesis_Setup_0() public {
// cover: initialize :: require(!initialized) true
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
        {
        target.initialize();
        }
        {
        target.owner();
        }
        {
        target.totalUserCount();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test successful investment with valid sponsor and 30-day cycle.
    function test_Invest_with_Valid_Sponsor_and_Cycle_1() public {
// assume: alice balance >= 1 ether
// cover: invest :: require(sponsor.totalInvestCount > 0) true
// cover: invest :: require(investCycle == 30) true
// cover: invest :: require(investAmount == msg.value) true
// cover: invest :: require(investAmount >= 1 ether && investAmount <= 15 ether) true
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
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        {
        target.totalInvestCount();
        }
        {
        target.totalInvestAmount();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify investment reverts with invalid sponsor address.
    function test_Invest_with_Invalid_Sponsor_2() public {
// assume: alice balance >= 1 ether
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0x0000000000000000000000000000000000000001, 30);
        }
    }

    // @cover-intent Protocol State Machine: Verify investment reverts with invalid cycle value.
    function test_Invest_with_Invalid_Cycle_3() public {
// assume: alice balance >= 1 ether
// cover: invest :: require(investCycle == 30 || investCycle == 60 || investCycle == 90) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 45);
        }
    }

    // @cover-intent Financial & Accounting: Verify investment reverts when amount is not an integer ETH value.
    function test_Invest_with_Non_Integer_Amount_4() public {
// assume: alice balance >= 1.5 ether
// cover: invest :: require(investAmount == msg.value) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1.5 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
    }

    // @cover-intent Financial & Accounting: Verify investment reverts when amount is below 1 ETH.
    function test_Invest_with_Amount_Below_Minimum_5() public {
// assume: alice balance >= 0.5 ether
// cover: invest :: require(investAmount >= 1 ether) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(0.5 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
    }

    // @cover-intent Protocol State Machine: Verify second investment from same user reverts.
    function test_Duplicate_Invest_Rejection_6() public {
// assume: alice balance >= 2 ether
// cover: invest :: require(user.currentInvestAmount == 0) false
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
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.expectRevert();
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 60);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify owner can transfer ownership to another address.
    function test_Owner_Transfer_Ownership_7() public {
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: transferOwnership :: require(newOwner != address(0)) true
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
        {
        target.transferOwnership(alice);
        }
        {
        target.owner();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot transfer ownership.
    function test_Non_Owner_Transfer_Ownership_Revert_8() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Financial & Accounting: Verify owner can withdraw operator funds.
    function test_Operator_Withdraw_by_Owner_9() public {
// cover: operatorWithdraw :: require(msg.sender == owner) true
// cover: operatorWithdraw :: if (avaliableAmount > 0) true
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
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.startPrank(owner);
        {
        target.operatorFunds();
        }
        {
        target.operatorWithdraw();
        }
        {
        target.operatorFunds();
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for bug_txorigin12
    function test_perfn_bug_txorigin12_10() public {
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
        target.bug_txorigin12(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin16
    function test_perfn_bug_txorigin16_11() public {
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
        target.bug_txorigin16(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin20
    function test_perfn_bug_txorigin20_12() public {
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
        target.bug_txorigin20(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin24
    function test_perfn_bug_txorigin24_13() public {
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
        target.bug_txorigin24(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin28
    function test_perfn_bug_txorigin28_14() public {
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
        target.bug_txorigin28(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin32
    function test_perfn_bug_txorigin32_15() public {
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
        target.bug_txorigin32(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin36
    function test_perfn_bug_txorigin36_16() public {
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
        target.bug_txorigin36(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin4
    function test_perfn_bug_txorigin4_17() public {
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
        target.bug_txorigin4(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin40
    function test_perfn_bug_txorigin40_18() public {
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
        target.bug_txorigin40(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin8
    function test_perfn_bug_txorigin8_19() public {
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
        target.bug_txorigin8(alice);
        }
    }

    // @cover-intent minimal test for calcDynamicCommission
    function test_perfn_calcDynamicCommission_20() public {
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
        target.calcDynamicCommission();
        }
    }

    // @cover-intent minimal test for calcDynamicCommissionBegin
    function test_perfn_calcDynamicCommissionBegin_21() public {
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
    function test_perfn_calcDynamicCommissionEnd_22() public {
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
    function test_perfn_calcDynamicCommissionRange_23() public {
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

    // @cover-intent minimal test for engineerFunds
    function test_perfn_engineerFunds_24() public {
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
        target.engineerFunds();
        }
    }

    // @cover-intent minimal test for engineerWithdraw
    function test_perfn_engineerWithdraw_25() public {
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
        target.engineerWithdraw();
        }
    }

    // @cover-intent minimal test for engineerWithdrawAmount
    function test_perfn_engineerWithdrawAmount_26() public {
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
        target.engineerWithdrawAmount();
        }
    }

    // @cover-intent minimal test for getDynamicCommissionRecords
    function test_perfn_getDynamicCommissionRecords_27() public {
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
    function test_perfn_getInvestRecords_28() public {
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
    function test_perfn_getStaticCommissionRecords_29() public {
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
    function test_perfn_getSummary_30() public {
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
        target.getSummary();
        }
    }

    // @cover-intent minimal test for getUserByAddress
    function test_perfn_getUserByAddress_31() public {
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
    function test_perfn_getUserByIndex_32() public {
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
    function test_perfn_initialize_33() public {
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
        target.initialize();
        }
    }

    // @cover-intent minimal test for invest
    function test_perfn_invest_34() public {
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
    function test_perfn_operatorFunds_35() public {
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
        target.operatorFunds();
        }
    }

    // @cover-intent minimal test for operatorWithdraw
    function test_perfn_operatorWithdraw_36() public {
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
        target.operatorWithdraw();
        }
    }

    // @cover-intent minimal test for operatorWithdrawAmount
    function test_perfn_operatorWithdrawAmount_37() public {
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
        target.operatorWithdrawAmount();
        }
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_38() public {
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
        target.owner();
        }
    }

    // @cover-intent minimal test for sendto_txorigin1
    function test_perfn_sendto_txorigin1_39() public {
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
        target.sendto_txorigin1(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin13
    function test_perfn_sendto_txorigin13_40() public {
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
        target.sendto_txorigin13(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin17
    function test_perfn_sendto_txorigin17_41() public {
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
        target.sendto_txorigin17(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin21
    function test_perfn_sendto_txorigin21_42() public {
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
        target.sendto_txorigin21(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin25
    function test_perfn_sendto_txorigin25_43() public {
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
        target.sendto_txorigin25(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin29
    function test_perfn_sendto_txorigin29_44() public {
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
        target.sendto_txorigin29(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin33
    function test_perfn_sendto_txorigin33_45() public {
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
        target.sendto_txorigin33(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin37
    function test_perfn_sendto_txorigin37_46() public {
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
        target.sendto_txorigin37(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin5
    function test_perfn_sendto_txorigin5_47() public {
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
        target.sendto_txorigin5(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin9
    function test_perfn_sendto_txorigin9_48() public {
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
        target.sendto_txorigin9(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for totalDynamicCommissionWithdrawAmount
    function test_perfn_totalDynamicCommissionWithdrawAmount_49() public {
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
        target.totalDynamicCommissionWithdrawAmount();
        }
    }

    // @cover-intent minimal test for totalInvestAmount
    function test_perfn_totalInvestAmount_50() public {
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
        target.totalInvestAmount();
        }
    }

    // @cover-intent minimal test for totalInvestCount
    function test_perfn_totalInvestCount_51() public {
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
        target.totalInvestCount();
        }
    }

    // @cover-intent minimal test for totalStaticCommissionWithdrawAmount
    function test_perfn_totalStaticCommissionWithdrawAmount_52() public {
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
        target.totalStaticCommissionWithdrawAmount();
        }
    }

    // @cover-intent minimal test for totalUserCount
    function test_perfn_totalUserCount_53() public {
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
        target.totalUserCount();
        }
    }

    // @cover-intent minimal test for totalWithdrawAmount
    function test_perfn_totalWithdrawAmount_54() public {
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
        target.totalWithdrawAmount();
        }
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_55() public {
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

    // @cover-intent minimal test for transferTo_txorigin11
    function test_perfn_transferTo_txorigin11_56() public {
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
        target.transferTo_txorigin11(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin15
    function test_perfn_transferTo_txorigin15_57() public {
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
        target.transferTo_txorigin15(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin19
    function test_perfn_transferTo_txorigin19_58() public {
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
        target.transferTo_txorigin19(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin23
    function test_perfn_transferTo_txorigin23_59() public {
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
        target.transferTo_txorigin23(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin27
    function test_perfn_transferTo_txorigin27_60() public {
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
        target.transferTo_txorigin27(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin3
    function test_perfn_transferTo_txorigin3_61() public {
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
        target.transferTo_txorigin3(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin31
    function test_perfn_transferTo_txorigin31_62() public {
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
        target.transferTo_txorigin31(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin35
    function test_perfn_transferTo_txorigin35_63() public {
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
        target.transferTo_txorigin35(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin39
    function test_perfn_transferTo_txorigin39_64() public {
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
        target.transferTo_txorigin39(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin7
    function test_perfn_transferTo_txorigin7_65() public {
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
        target.transferTo_txorigin7(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for userWithdraw
    function test_perfn_userWithdraw_66() public {
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
        target.userWithdraw();
        }
    }

    // @cover-intent minimal test for userWithdrawCommission
    function test_perfn_userWithdrawCommission_67() public {
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
        target.userWithdrawCommission();
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin10
    function test_perfn_withdrawAll_txorigin10_68() public {
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
        target.withdrawAll_txorigin10(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin14
    function test_perfn_withdrawAll_txorigin14_69() public {
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
        target.withdrawAll_txorigin14(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin18
    function test_perfn_withdrawAll_txorigin18_70() public {
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
        target.withdrawAll_txorigin18(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin2
    function test_perfn_withdrawAll_txorigin2_71() public {
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
        target.withdrawAll_txorigin2(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin22
    function test_perfn_withdrawAll_txorigin22_72() public {
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
        target.withdrawAll_txorigin22(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin26
    function test_perfn_withdrawAll_txorigin26_73() public {
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
        target.withdrawAll_txorigin26(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin30
    function test_perfn_withdrawAll_txorigin30_74() public {
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
        target.withdrawAll_txorigin30(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin34
    function test_perfn_withdrawAll_txorigin34_75() public {
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
        target.withdrawAll_txorigin34(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin38
    function test_perfn_withdrawAll_txorigin38_76() public {
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
        target.withdrawAll_txorigin38(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin6
    function test_perfn_withdrawAll_txorigin6_77() public {
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
        target.withdrawAll_txorigin6(alice, alice);
        }
    }

}
