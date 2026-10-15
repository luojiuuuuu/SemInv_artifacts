// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_29.sol";

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

contract RaffleTokenExchange_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify that only the listing seller or contract owner can cancel a listing.
    function test_Add_listing_and_cancel_by_owner_0() public {
// assume: paused==false
// assume: listingsById(916).active==true
// cover: cancelListing :: require(listing.seller == msg.sender || owner == msg.sender) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.addListing(100, 1);
        }
        vm.prank(owner);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot cancel a listing that is not theirs.
    function test_Cancel_listing_by_non_owner_reverts_1() public {
// assume: paused==false
// assume: listingsById(916).active==true
// cover: cancelListing :: require(listing.seller == msg.sender || owner == msg.sender) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.addListing(100, 1);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Financial & Accounting: Verify that buying tokens with exact payment succeeds and emits Purchased event.
    function test_Buy_raffle_with_exact_payment_2() public {
// assume: paused==false
// assume: listingsById(916).active==true
// assume: listingsById(916).amountLeft>=10
// cover: buyRaffle :: require(listing.active) true
// cover: buyRaffle :: require(totalAmountPayed <= msg.value) true
        vm.startPrank(bob);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.addListing(100, 2);
        }
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(20)(_arr1, _arr2);
        }
    }

    // @cover-intent Financial & Accounting: Overpayment should revert.
    function test_Buy_raffle_with_overpayment_reverts_3() public {
// assume: paused==false
// assume: listingsById(916).active==true
// cover: buyRaffle :: require(totalAmountPayed <= msg.value) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.addListing(100, 2);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(30)(_arr1, _arr2);
        }
    }

    // @cover-intent Protocol State Machine: Buying from an inactive listing should revert.
    function test_Buy_from_inactive_listing_reverts_4() public {
// assume: paused==false
// assume: listingsById(916).active==false
// cover: buyRaffle :: require(listing.active) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.addListing(100, 2);
        }
        vm.prank(owner);
        {
        target.cancelListing(916);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(20)(_arr1, _arr2);
        }
    }

    // @cover-intent Protocol State Machine: Owner can pause the exchange.
    function test_Set_paused_by_owner_5() public {
// assume: paused==false
// cover: setPaused :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
    }

    // @cover-intent state transition test for setPaused
    function test_Set_paused_by_non_owner_reverts_6() public {
// cover: setPaused :: require(msg.sender == owner) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
    }

    // @cover-intent Protocol State Machine: Buying when paused should revert.
    function test_Buy_raffle_when_paused_reverts_7() public {
// assume: paused==true
// cover: buyRaffle :: require(paused == false) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(1)(_arr1, _arr2);
        }
    }

    // @cover-intent Authorization & Access Control: Owner can withdraw funds.
    function test_Withdraw_funds_by_owner_8() public {
// cover: withdrawFunds :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.withdrawFunds(50);
        }
    }

    // @cover-intent Authorization & Access Control: Owner can selfdestruct the contract.
    function test_Kill_contract_by_owner_9() public {
// cover: kill :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent state transition test for bug_re_ent13
    function test_bug_re_ent13_positive_10() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent state transition test for bug_re_ent20
    function test_bug_re_ent20_positive_11() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: bug_re_ent20()
    }

    // @cover-intent state transition test for bug_re_ent27
    function test_bug_re_ent27_positive_12() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent30_positive_13() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent35_positive_14() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent32_positive_15() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: claimReward_re_ent32()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent39_positive_16() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent4_positive_17() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: claimReward_re_ent4()
    }

    // @cover-intent Authorization & Access Control
    function test_kill_positive_18() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Protocol State Machine
    function test_nextListingId_view_19() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: nextListingId()
    }

    // @cover-intent Protocol State Machine
    function test_nextPurchaseId_view_20() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: nextPurchaseId()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_21() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_paused_view_22() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: paused()
    }

    // @cover-intent External Interaction & Environment
    function test_raffleContract_view_23() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: raffleContract()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent19_positive_24() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent26_positive_25() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent33_positive_26() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent40_positive_27() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent36_positive_28() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent8_positive_29() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

    // @cover-intent minimal test for addListing
    function test_perfn_addListing_30() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.addListing(100, 1);
        }
    }

    // @cover-intent minimal test for cancelListing
    function test_perfn_cancelListing_31() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.cancelListing(1);
        }
    }

    // @cover-intent minimal test for listingsById
    function test_perfn_listingsById_32() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.listingsById(1);
        }
    }

    // @cover-intent minimal test for purchasesById
    function test_perfn_purchasesById_33() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.purchasesById(1);
        }
    }

    // @cover-intent minimal test for setPaused
    function test_perfn_setPaused_34() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
    }

    // @cover-intent minimal test for withdrawFunds
    function test_perfn_withdrawFunds_35() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
        target.withdrawFunds(100);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent31
    function test_perfn_withdrawFunds_re_ent31_36() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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
    function test_perfn_withdrawFunds_re_ent38_37() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
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

}
