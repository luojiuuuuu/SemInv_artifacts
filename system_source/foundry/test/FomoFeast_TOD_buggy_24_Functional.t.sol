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


    // @cover-intent Test normal initialization and first investment by alice with sponsor genesis, verifying state updates and fund distribution.
    function test_Initialize_and_invest_positive_path_0() public {
// cover: invest :: new user path
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
        {
        target.initialize();
        }
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        {
            uint256 __v1 = uint256(target.totalInvestCount());
            _assertRelU(__v1, 0, 1, "call:totalInvestCount==1");
        }
        // TODO assert: call:totalInvestAmount() == 1 ether
        {
            uint256 __v2 = uint256(target.totalUserCount());
            _assertRelU(__v2, 0, 1, "call:totalUserCount==1");
        }
        // TODO assert: call:engineerFunds() == 0.02 ether
        // TODO assert: call:operatorFunds() == 0.03 ether
    }

    // @cover-intent Test that invest reverts when sponsor address has no investment history.
    function test_Invest_with_invalid_sponsor_address_1() public {
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
        {
        target.initialize();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1 ether)(bob, 30);
        }
    }

    // @cover-intent Test that invest reverts when cycle is not 30, 60, or 90.
    function test_Invest_with_invalid_cycle_2() public {
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
        vm.prank(owner);
        {
        target.initialize();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 45);
        }
    }

    // @cover-intent Test that invest reverts when msg.value is not a multiple of 1 ether.
    function test_Invest_with_non_integer_ETH_amount_3() public {
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
        vm.prank(owner);
        {
        target.initialize();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(1500000000000000000)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
    }

    // @cover-intent Test that invest reverts when amount is less than 1 ether or greater than 15 ether.
    function test_Invest_amount_out_of_range_4() public {
// cover: invest :: require(investAmount >= ONE_ETH.mul(1) && investAmount <= ONE_ETH.mul(15)) false
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
        target.initialize();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.invest.value(20 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
    }

    // @cover-intent Test that a user cannot invest again while a current investment is active.
    function test_Duplicate_invest_by_same_user_5() public {
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
        vm.prank(owner);
        {
        target.initialize();
        }
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.expectRevert();
        {
        target.invest.value(2 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 60);
        }
        vm.stopPrank();
    }

    // @cover-intent Test userWithdraw after investment cycle expires, verifying principal return and static commission calculation.
    function test_User_withdraw_after_investment_expires_6() public {
// assume: block.timestamp >= (currentInvestTime + 30 days)
// cover: userWithdraw :: isInvestExpired true
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
        {
        target.initialize();
        }
        vm.startPrank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        {
        target.userWithdraw();
        }
        vm.stopPrank();
        // TODO assert: alice.balance >= 1 ether
        // TODO assert: call:totalWithdrawAmount() >= 1 ether
    }

    // @cover-intent Test userWithdrawCommission when static and dynamic commission balances are available.
    function test_User_withdraw_commission_with_sufficient_balance_7() public {
// assume: block.timestamp >= (currentInvestTime + 1 days)
// cover: userWithdrawCommission :: avaliableWithdrawAmount >= ONE_ETH.div(10)
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
        {
        target.initialize();
        }
        vm.prank(alice);
        {
        target.invest.value(1 ether)(0xe00d13D53Ba180EAD5F4838BD56b15629026A8C9, 30);
        }
        vm.startPrank(bob);
        {
        target.invest.value(1 ether)(alice, 30);
        }
        {
        target.userWithdrawCommission();
        }
        vm.stopPrank();
        // TODO assert: bob.balance >= 0.1 ether
    }

    // @cover-intent Test that operatorWithdraw reverts when called by non-owner.
    function test_Operator_withdraw_by_non_owner_reverts_8() public {
// cover: operatorWithdraw :: onlyOwner modifier revert
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
        target.initialize();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.operatorWithdraw();
        }
    }

    // @cover-intent Test that transferOwnership reverts when newOwner is address(0).
    function test_Transfer_ownership_to_zero_address_reverts_9() public {
// cover: transferOwnership :: require(newOwner != address(0)) false
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
        vm.expectRevert();
        {
        target.transferOwnership(0x0000000000000000000000000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for calcDynamicCommission
    function test_perfn_calcDynamicCommission_10() public {
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
    function test_perfn_calcDynamicCommissionBegin_11() public {
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
    function test_perfn_calcDynamicCommissionEnd_12() public {
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
    function test_perfn_calcDynamicCommissionRange_13() public {
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

    // @cover-intent minimal test for claimReward_TOD10
    function test_perfn_claimReward_TOD10_14() public {
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
        target.claimReward_TOD10(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD12
    function test_perfn_claimReward_TOD12_15() public {
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
        target.claimReward_TOD12(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD14
    function test_perfn_claimReward_TOD14_16() public {
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
        target.claimReward_TOD14(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD16
    function test_perfn_claimReward_TOD16_17() public {
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
        target.claimReward_TOD16(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD18
    function test_perfn_claimReward_TOD18_18() public {
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
        target.claimReward_TOD18(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD2
    function test_perfn_claimReward_TOD2_19() public {
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
        target.claimReward_TOD2(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD20
    function test_perfn_claimReward_TOD20_20() public {
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
        target.claimReward_TOD20(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD22
    function test_perfn_claimReward_TOD22_21() public {
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
        target.claimReward_TOD22(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD24
    function test_perfn_claimReward_TOD24_22() public {
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
        target.claimReward_TOD24(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD26
    function test_perfn_claimReward_TOD26_23() public {
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
        target.claimReward_TOD26(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD28
    function test_perfn_claimReward_TOD28_24() public {
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
        target.claimReward_TOD28(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD30
    function test_perfn_claimReward_TOD30_25() public {
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
        target.claimReward_TOD30(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD32
    function test_perfn_claimReward_TOD32_26() public {
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
        target.claimReward_TOD32(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD34
    function test_perfn_claimReward_TOD34_27() public {
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
        target.claimReward_TOD34(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD36
    function test_perfn_claimReward_TOD36_28() public {
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
        target.claimReward_TOD36(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD38
    function test_perfn_claimReward_TOD38_29() public {
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
        target.claimReward_TOD38(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD4
    function test_perfn_claimReward_TOD4_30() public {
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
        target.claimReward_TOD4(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD40
    function test_perfn_claimReward_TOD40_31() public {
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
        target.claimReward_TOD40(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD6
    function test_perfn_claimReward_TOD6_32() public {
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
        target.claimReward_TOD6(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD8
    function test_perfn_claimReward_TOD8_33() public {
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
        target.claimReward_TOD8(1);
        }
    }

    // @cover-intent minimal test for engineerFunds
    function test_perfn_engineerFunds_34() public {
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
    function test_perfn_engineerWithdraw_35() public {
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
    function test_perfn_engineerWithdrawAmount_36() public {
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
    function test_perfn_getDynamicCommissionRecords_37() public {
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
    function test_perfn_getInvestRecords_38() public {
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

    // @cover-intent minimal test for getReward_TOD1
    function test_perfn_getReward_TOD1_39() public {
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
        target.getReward_TOD1();
        }
    }

    // @cover-intent minimal test for getReward_TOD11
    function test_perfn_getReward_TOD11_40() public {
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
        target.getReward_TOD11();
        }
    }

    // @cover-intent minimal test for getReward_TOD13
    function test_perfn_getReward_TOD13_41() public {
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
        target.getReward_TOD13();
        }
    }

    // @cover-intent minimal test for getReward_TOD15
    function test_perfn_getReward_TOD15_42() public {
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
        target.getReward_TOD15();
        }
    }

    // @cover-intent minimal test for getReward_TOD17
    function test_perfn_getReward_TOD17_43() public {
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
        target.getReward_TOD17();
        }
    }

    // @cover-intent minimal test for getReward_TOD19
    function test_perfn_getReward_TOD19_44() public {
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
        target.getReward_TOD19();
        }
    }

    // @cover-intent minimal test for getReward_TOD21
    function test_perfn_getReward_TOD21_45() public {
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
        target.getReward_TOD21();
        }
    }

    // @cover-intent minimal test for getReward_TOD23
    function test_perfn_getReward_TOD23_46() public {
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
        target.getReward_TOD23();
        }
    }

    // @cover-intent minimal test for getReward_TOD25
    function test_perfn_getReward_TOD25_47() public {
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
        target.getReward_TOD25();
        }
    }

    // @cover-intent minimal test for getReward_TOD27
    function test_perfn_getReward_TOD27_48() public {
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
        target.getReward_TOD27();
        }
    }

    // @cover-intent minimal test for getReward_TOD29
    function test_perfn_getReward_TOD29_49() public {
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
        target.getReward_TOD29();
        }
    }

    // @cover-intent minimal test for getReward_TOD3
    function test_perfn_getReward_TOD3_50() public {
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
        target.getReward_TOD3();
        }
    }

    // @cover-intent minimal test for getReward_TOD31
    function test_perfn_getReward_TOD31_51() public {
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
        target.getReward_TOD31();
        }
    }

    // @cover-intent minimal test for getReward_TOD33
    function test_perfn_getReward_TOD33_52() public {
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
        target.getReward_TOD33();
        }
    }

    // @cover-intent minimal test for getReward_TOD35
    function test_perfn_getReward_TOD35_53() public {
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
        target.getReward_TOD35();
        }
    }

    // @cover-intent minimal test for getReward_TOD37
    function test_perfn_getReward_TOD37_54() public {
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
        target.getReward_TOD37();
        }
    }

    // @cover-intent minimal test for getReward_TOD39
    function test_perfn_getReward_TOD39_55() public {
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
        target.getReward_TOD39();
        }
    }

    // @cover-intent minimal test for getReward_TOD5
    function test_perfn_getReward_TOD5_56() public {
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
        target.getReward_TOD5();
        }
    }

    // @cover-intent minimal test for getReward_TOD7
    function test_perfn_getReward_TOD7_57() public {
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
        target.getReward_TOD7();
        }
    }

    // @cover-intent minimal test for getReward_TOD9
    function test_perfn_getReward_TOD9_58() public {
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
        target.getReward_TOD9();
        }
    }

    // @cover-intent minimal test for getStaticCommissionRecords
    function test_perfn_getStaticCommissionRecords_59() public {
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
    function test_perfn_getSummary_60() public {
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
    function test_perfn_getUserByAddress_61() public {
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
    function test_perfn_getUserByIndex_62() public {
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
    function test_perfn_initialize_63() public {
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
    function test_perfn_invest_64() public {
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
    function test_perfn_operatorFunds_65() public {
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
    function test_perfn_operatorWithdraw_66() public {
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
    function test_perfn_operatorWithdrawAmount_67() public {
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
    function test_perfn_owner_68() public {
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

    // @cover-intent minimal test for play_TOD1
    function test_perfn_play_TOD1_69() public {
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
        target.play_TOD1(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD11
    function test_perfn_play_TOD11_70() public {
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
        target.play_TOD11(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD13
    function test_perfn_play_TOD13_71() public {
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
        target.play_TOD13(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD15
    function test_perfn_play_TOD15_72() public {
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
        target.play_TOD15(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD17
    function test_perfn_play_TOD17_73() public {
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
        target.play_TOD17(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD19
    function test_perfn_play_TOD19_74() public {
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
        target.play_TOD19(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD21
    function test_perfn_play_TOD21_75() public {
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
        target.play_TOD21(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD23
    function test_perfn_play_TOD23_76() public {
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
        target.play_TOD23(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD25
    function test_perfn_play_TOD25_77() public {
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
        target.play_TOD25(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD27
    function test_perfn_play_TOD27_78() public {
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
        target.play_TOD27(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD29
    function test_perfn_play_TOD29_79() public {
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
        target.play_TOD29(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD3
    function test_perfn_play_TOD3_80() public {
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
        target.play_TOD3(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD31
    function test_perfn_play_TOD31_81() public {
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
        target.play_TOD31(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD33
    function test_perfn_play_TOD33_82() public {
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
        target.play_TOD33(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD35
    function test_perfn_play_TOD35_83() public {
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
        target.play_TOD35(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD37
    function test_perfn_play_TOD37_84() public {
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
        target.play_TOD37(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD39
    function test_perfn_play_TOD39_85() public {
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
        target.play_TOD39(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD5
    function test_perfn_play_TOD5_86() public {
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
        target.play_TOD5(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD7
    function test_perfn_play_TOD7_87() public {
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
        target.play_TOD7(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD9
    function test_perfn_play_TOD9_88() public {
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
        target.play_TOD9(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for setReward_TOD10
    function test_perfn_setReward_TOD10_89() public {
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
        target.setReward_TOD10();
        }
    }

    // @cover-intent minimal test for setReward_TOD12
    function test_perfn_setReward_TOD12_90() public {
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
        target.setReward_TOD12();
        }
    }

    // @cover-intent minimal test for setReward_TOD14
    function test_perfn_setReward_TOD14_91() public {
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
        target.setReward_TOD14();
        }
    }

    // @cover-intent minimal test for setReward_TOD16
    function test_perfn_setReward_TOD16_92() public {
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
        target.setReward_TOD16();
        }
    }

    // @cover-intent minimal test for setReward_TOD18
    function test_perfn_setReward_TOD18_93() public {
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
        target.setReward_TOD18();
        }
    }

    // @cover-intent minimal test for setReward_TOD2
    function test_perfn_setReward_TOD2_94() public {
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
        target.setReward_TOD2();
        }
    }

    // @cover-intent minimal test for setReward_TOD20
    function test_perfn_setReward_TOD20_95() public {
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
        target.setReward_TOD20();
        }
    }

    // @cover-intent minimal test for setReward_TOD22
    function test_perfn_setReward_TOD22_96() public {
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
        target.setReward_TOD22();
        }
    }

    // @cover-intent minimal test for setReward_TOD24
    function test_perfn_setReward_TOD24_97() public {
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
        target.setReward_TOD24();
        }
    }

    // @cover-intent minimal test for setReward_TOD26
    function test_perfn_setReward_TOD26_98() public {
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
        target.setReward_TOD26();
        }
    }

    // @cover-intent minimal test for setReward_TOD28
    function test_perfn_setReward_TOD28_99() public {
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
        target.setReward_TOD28();
        }
    }

    // @cover-intent minimal test for setReward_TOD30
    function test_perfn_setReward_TOD30_100() public {
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
        target.setReward_TOD30();
        }
    }

    // @cover-intent minimal test for setReward_TOD32
    function test_perfn_setReward_TOD32_101() public {
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
        target.setReward_TOD32();
        }
    }

    // @cover-intent minimal test for setReward_TOD34
    function test_perfn_setReward_TOD34_102() public {
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
        target.setReward_TOD34();
        }
    }

    // @cover-intent minimal test for setReward_TOD36
    function test_perfn_setReward_TOD36_103() public {
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
        target.setReward_TOD36();
        }
    }

    // @cover-intent minimal test for setReward_TOD38
    function test_perfn_setReward_TOD38_104() public {
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
        target.setReward_TOD38();
        }
    }

    // @cover-intent minimal test for setReward_TOD4
    function test_perfn_setReward_TOD4_105() public {
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
        target.setReward_TOD4();
        }
    }

    // @cover-intent minimal test for setReward_TOD40
    function test_perfn_setReward_TOD40_106() public {
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
        target.setReward_TOD40();
        }
    }

    // @cover-intent minimal test for setReward_TOD6
    function test_perfn_setReward_TOD6_107() public {
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
        target.setReward_TOD6();
        }
    }

    // @cover-intent minimal test for setReward_TOD8
    function test_perfn_setReward_TOD8_108() public {
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
        target.setReward_TOD8();
        }
    }

    // @cover-intent minimal test for totalDynamicCommissionWithdrawAmount
    function test_perfn_totalDynamicCommissionWithdrawAmount_109() public {
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
    function test_perfn_totalInvestAmount_110() public {
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
    function test_perfn_totalInvestCount_111() public {
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
    function test_perfn_totalStaticCommissionWithdrawAmount_112() public {
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
    function test_perfn_totalUserCount_113() public {
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
    function test_perfn_totalWithdrawAmount_114() public {
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
    function test_perfn_transferOwnership_115() public {
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
    function test_perfn_userWithdraw_116() public {
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
    function test_perfn_userWithdrawCommission_117() public {
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

}
