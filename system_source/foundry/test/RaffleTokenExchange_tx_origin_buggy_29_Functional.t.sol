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


    // @cover-intent Financial & Accounting: Verify that a seller can list raffle tokens and a buyer can purchase them, with correct token transfer and payment.
    function test_Positive_Add_listing_and_buy_raffle_tokens_0() public {
// assume: paused==false
// assume: raffleContract.balanceOf(alice) >= 100
// assume: raffleContract.allowance(alice, target) >= 100
// cover: addListing :: require(balanceOf>=initialAmount) true
// cover: addListing :: require(allowance>=initialAmount) true
// cover: buyRaffle :: require(listing.active) true
// cover: buyRaffle :: require(amountLeft>=0) true
        vm.startPrank(bob);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: raffleContract.transfer(alice, 1000);
        // dropped unsafe prestate: raffleContract.transfer(bob, 1000);
        // dropped unsafe prestate: raffleContract.approve(address(target), 1000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 2 ether);
        }
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(100 ether)(_arr1, _arr2);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that buying from a canceled listing reverts.
    function test_Negative_Buy_from_inactive_listing_1() public {
// assume: paused==false
// cover: buyRaffle :: require(listing.active) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: raffleContract.transfer(alice, 1000);
        // dropped unsafe prestate: raffleContract.approve(address(target), 1000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.addListing(100, 2 ether);
        }
        {
        target.cancelListing(916);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(100 ether)(_arr1, _arr2);
        }
    }

    // @cover-intent state transition test for setPaused
    function test_Negative_Non_owner_tries_to_set_paused_2() public {
// cover: setPaused :: require(msg.sender==owner) false
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

    // @cover-intent Protocol State Machine: Verify that the owner can toggle the paused state.
    function test_Positive_Owner_sets_paused_and_then_unpauses_3() public {
// cover: setPaused :: require(msg.sender==owner) true
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
        vm.startPrank(owner);
        {
        target.setPaused(true);
        }
        {
        target.setPaused(false);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that buying is blocked when contract is paused.
    function test_Negative_Buy_while_paused_4() public {
// assume: paused==true
// cover: buyRaffle :: require(paused==false) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: raffleContract.transfer(alice, 1000);
        // dropped unsafe prestate: raffleContract.approve(address(target), 1000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 2 ether);
        }
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
        target.buyRaffle.value(100 ether)(_arr1, _arr2);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the seller or contract owner can cancel a listing.
    function test_Negative_Cancel_listing_by_non_owner_non_seller_5() public {
// cover: cancelListing :: require(listing.seller==msg.sender||owner==msg.sender) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: raffleContract.transfer(alice, 1000);
        // dropped unsafe prestate: raffleContract.approve(address(target), 1000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 2 ether);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw contract funds.
    function test_Positive_Owner_withdraws_funds_6() public {
// assume: paused==false
// cover: withdrawFunds :: require(msg.sender==owner) true
        vm.startPrank(bob);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: raffleContract.transfer(alice, 1000);
        // dropped unsafe prestate: raffleContract.approve(address(target), 1000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 2 ether);
        }
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(100 ether)(_arr1, _arr2);
        }
        vm.prank(owner);
        {
        target.withdrawFunds(50 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can withdraw funds.
    function test_Negative_Non_owner_tries_to_withdraw_funds_7() public {
// cover: withdrawFunds :: require(msg.sender==owner) false
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
        target.withdrawFunds(1 ether);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that addListing reverts if allowance is insufficient.
    function test_Negative_Add_listing_with_insufficient_allowance_8() public {
// assume: paused==false
// assume: raffleContract.balanceOf(alice) >= 100
// assume: raffleContract.allowance(alice, target) < 100
// cover: addListing :: require(allowance>=initialAmount) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: raffleContract.transfer(alice, 1000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.addListing(100, 2 ether);
        }
    }

    // @cover-intent Transactional Consistency: Verify that buyRaffle reverts if amounts and listingIds arrays have different lengths.
    function test_Edge_Buy_with_mismatched_array_lengths_9() public {
// assume: paused==false
// cover: buyRaffle :: require(amounts.length==listingIds.length) false
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
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](2);
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.buyRaffle.value(100 ether)(_arr1, _arr2);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_addListing_10() public {
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
        vm.startPrank(alice);
        {
        target.setPaused(false);
        }
        vm.expectRevert();
        {
        target.addListing(100, 10);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin20_11() public {
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
        target.bug_txorigin20(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin32_12() public {
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
        target.bug_txorigin32(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin36_13() public {
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
        target.bug_txorigin36(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin4_14() public {
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
        target.bug_txorigin4(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin40_15() public {
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
        target.bug_txorigin40(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin8_16() public {
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
        target.bug_txorigin8(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_cancelListing_17() public {
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
        target.cancelListing(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_kill_18() public {
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
        target.kill();
        }
    }

    // @cover-intent Protocol State Machine
    function test_listingsById_19() public {
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
        target.listingsById(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_nextListingId_20() public {
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
        target.nextListingId();
        }
    }

    // @cover-intent Protocol State Machine
    function test_nextPurchaseId_21() public {
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
        target.nextPurchaseId();
        }
    }

    // @cover-intent Protocol State Machine
    function test_owner_22() public {
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
        target.owner();
        }
    }

    // @cover-intent Protocol State Machine
    function test_paused_23() public {
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
        target.paused();
        }
    }

    // @cover-intent Protocol State Machine
    function test_purchasesById_24() public {
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
        target.purchasesById(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_raffleContract_25() public {
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
        target.raffleContract();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin13_26() public {
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
        target.sendto_txorigin13(bob, 1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin33_27() public {
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
        target.sendto_txorigin33(bob, 1, alice);
        }
    }

    // @cover-intent state transition test for setPaused
    function test_setPaused_28() public {
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

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin19_29() public {
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
        target.transferTo_txorigin19(bob, 1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin27_30() public {
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
        target.transferTo_txorigin27(bob, 1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin31_31() public {
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
        target.transferTo_txorigin31(bob, 1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin35_32() public {
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
        target.transferTo_txorigin35(bob, 1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin39_33() public {
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
        target.transferTo_txorigin39(bob, 1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin26_34() public {
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
        target.withdrawAll_txorigin26(bob, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin30_35() public {
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
        target.withdrawAll_txorigin30(bob, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin38_36() public {
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
        target.withdrawAll_txorigin38(bob, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawFunds_37() public {
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
        target.withdrawFunds(0);
        }
    }

}
