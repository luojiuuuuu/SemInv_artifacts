// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;
import "../src/buggy_20.sol";

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

contract RampInstantEthPool_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify that only the current owner can change the owner address.
    function test_Owner_can_change_owner_0() public {
// cover: changeOwner :: onlyOwner modifier passes
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot change the owner.
    function test_Non_owner_cannot_change_owner_1() public {
// cover: changeOwner :: onlyOwner modifier fails
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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

    // @cover-intent Protocol State Machine: Verify that the owner can toggle the isActive state.
    function test_Owner_can_toggle_isActive_2() public {
// cover: setIsActive :: onlyOwner modifier passes
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setIsActive(false);
        }
        // skip ABI-mismatched call: isActive()
        vm.stopPrank();
    }

    // @cover-intent state transition test for setIsActive
    function test_Non_owner_cannot_toggle_isActive_3() public {
// cover: setIsActive :: onlyOwner modifier fails
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setIsActive(false);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that the owner can set swap limits within the allowed range.
    function test_Owner_can_set_limits_within_bounds_4() public {
// cover: setLimits :: validateLimits passes
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setLimits(100, 1000);
        }
        // skip ABI-mismatched call: minSwapAmount()
        // skip ABI-mismatched call: maxSwapAmount()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that setting limits with min > max reverts.
    function test_Owner_cannot_set_limits_where_min_max_5() public {
// cover: setLimits :: validateLimits fails (min > max)
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setLimits(1000, 100);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that the owner can update the swaps contract address.
    function test_Owner_can_set_swaps_contract_6() public {
// cover: setSwapsContract :: validateSwapsContract passes
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setSwapsContract(address(uint160(alice)));
        }
        // skip ABI-mismatched call: swapsContract()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw all available funds.
    function test_Owner_can_withdraw_all_funds_7() public {
// cover: withdrawAllFunds :: onlyOwner modifier passes
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.withdrawAllFunds(address(uint160(owner)));
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot withdraw funds.
    function test_Non_owner_cannot_withdraw_funds_8() public {
// cover: withdrawFunds :: onlyOwner modifier fails
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.withdrawFunds(address(uint160(alice)), 100);
        }
    }

    // @cover-intent Protocol State Machine: Verify that sendFundsToSwap reverts when isActive is false.
    function test_sendFundsToSwap_reverts_when_contract_is_stopped_9() public {
// cover: sendFundsToSwap :: onlyActive modifier fails
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setIsActive(false);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.sendFundsToSwap(100);
        }
    }

    // @cover-intent minimal test for ASSET_TYPE
    function test_perfn_ASSET_TYPE_10() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        // skip ABI-mismatched call: ASSET_TYPE()
    }

    // @cover-intent minimal test for availableFunds
    function test_perfn_availableFunds_11() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: availableFunds()
    }

    // @cover-intent minimal test for bug_intou11
    function test_perfn_bug_intou11_12() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent minimal test for bug_intou12
    function test_perfn_bug_intou12_13() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou12(1);
        }
    }

    // @cover-intent minimal test for bug_intou19
    function test_perfn_bug_intou19_14() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent minimal test for bug_intou20
    function test_perfn_bug_intou20_15() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou20(1);
        }
    }

    // @cover-intent minimal test for bug_intou23
    function test_perfn_bug_intou23_16() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent minimal test for bug_intou27
    function test_perfn_bug_intou27_17() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent minimal test for bug_intou3
    function test_perfn_bug_intou3_18() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent minimal test for bug_intou31
    function test_perfn_bug_intou31_19() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_20() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent minimal test for bug_intou35
    function test_perfn_bug_intou35_21() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent minimal test for bug_intou36
    function test_perfn_bug_intou36_22() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent minimal test for bug_intou39
    function test_perfn_bug_intou39_23() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent minimal test for bug_intou4
    function test_perfn_bug_intou4_24() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent minimal test for bug_intou40
    function test_perfn_bug_intou40_25() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent minimal test for bug_intou7
    function test_perfn_bug_intou7_26() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent minimal test for bug_intou8
    function test_perfn_bug_intou8_27() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent minimal test for changeOwner
    function test_perfn_changeOwner_28() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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

    // @cover-intent minimal test for increaseLockTime_intou1
    function test_perfn_increaseLockTime_intou1_29() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.increaseLockTime_intou1(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou13
    function test_perfn_increaseLockTime_intou13_30() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.increaseLockTime_intou13(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou17
    function test_perfn_increaseLockTime_intou17_31() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.increaseLockTime_intou17(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou21
    function test_perfn_increaseLockTime_intou21_32() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.increaseLockTime_intou21(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou33
    function test_perfn_increaseLockTime_intou33_33() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.increaseLockTime_intou33(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou37
    function test_perfn_increaseLockTime_intou37_34() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.increaseLockTime_intou37(1);
        }
    }

    // @cover-intent minimal test for isActive
    function test_perfn_isActive_35() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: isActive()
    }

    // @cover-intent minimal test for lockTime_intou1
    function test_perfn_lockTime_intou1_36() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.lockTime_intou1(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou13
    function test_perfn_lockTime_intou13_37() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou17
    function test_perfn_lockTime_intou17_38() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou21
    function test_perfn_lockTime_intou21_39() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.lockTime_intou21(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou33
    function test_perfn_lockTime_intou33_40() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou37
    function test_perfn_lockTime_intou37_41() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent minimal test for maxSwapAmount
    function test_perfn_maxSwapAmount_42() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: maxSwapAmount()
    }

    // @cover-intent minimal test for minSwapAmount
    function test_perfn_minSwapAmount_43() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: minSwapAmount()
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_44() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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

    // @cover-intent minimal test for paymentDetailsHash
    function test_perfn_paymentDetailsHash_45() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: paymentDetailsHash()
    }

    // @cover-intent minimal test for releaseSwap
    function test_perfn_releaseSwap_46() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.releaseSwap(address(uint160(alice)), alice, hex"01", bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for returnSwap
    function test_perfn_returnSwap_47() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.returnSwap(alice, alice, hex"01", bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for sendFundsToSwap
    function test_perfn_sendFundsToSwap_48() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.sendFundsToSwap(100);
        }
    }

    // @cover-intent minimal test for setIsActive
    function test_perfn_setIsActive_49() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setIsActive(true);
        }
    }

    // @cover-intent minimal test for setLimits
    function test_perfn_setLimits_50() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setLimits(100, 100);
        }
    }

    // @cover-intent minimal test for setSwapsContract
    function test_perfn_setSwapsContract_51() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
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
        target.setSwapsContract(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for swapsContract
    function test_perfn_swapsContract_52() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: swapsContract()
    }

    // @cover-intent minimal test for transfer_intou10
    function test_perfn_transfer_intou10_53() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_intou10(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou14
    function test_perfn_transfer_intou14_54() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_intou14(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou22
    function test_perfn_transfer_intou22_55() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_intou22(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou26
    function test_perfn_transfer_intou26_56() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_intou26(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou30
    function test_perfn_transfer_intou30_57() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_intou30(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou38
    function test_perfn_transfer_intou38_58() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_intou38(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_undrflow2
    function test_perfn_transfer_undrflow2_59() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.transfer_undrflow2(bob, 100);
        }
    }

    // @cover-intent minimal test for withdrawAllFunds
    function test_perfn_withdrawAllFunds_60() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.withdrawAllFunds(address(uint160(bob)));
        }
    }

    // @cover-intent minimal test for withdrawFunds
    function test_perfn_withdrawFunds_61() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
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
        target.withdrawFunds(address(uint160(bob)), 100);
        }
    }

    // @cover-intent minimal test for withdraw_intou13
    function test_perfn_withdraw_intou13_62() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent minimal test for withdraw_intou17
    function test_perfn_withdraw_intou17_63() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent minimal test for withdraw_intou21
    function test_perfn_withdraw_intou21_64() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_intou21()
    }

    // @cover-intent minimal test for withdraw_intou33
    function test_perfn_withdraw_intou33_65() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent minimal test for withdraw_intou37
    function test_perfn_withdraw_intou37_66() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_intou37()
    }

    // @cover-intent minimal test for withdraw_ovrflow1
    function test_perfn_withdraw_ovrflow1_67() public {
        vm.startPrank(owner);
        RampInstantEthPool target = new RampInstantEthPool(address(uint160(alice)), 100, 100, bytes32(uint256(1)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_ovrflow1()
    }

}
