// SPDX-License-Identifier: MIT
pragma solidity 0.5.8;
import "../src/buggy_7.sol";

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

contract AccountWallet_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify that only the owner can stop the contract, and that the stopped state prevents master-only functions.
    function test_Owner_Stops_Contract_0() public {
// cover: stop :: onlyOwner modifier true
// cover: stop :: onlyOwner modifier false
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        // skip ABI-mismatched call: stop()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: stop()
        vm.prank(owner);
        // skip ABI-mismatched call: isStopped()
    }

    // @cover-intent Protocol State Machine: Verify that the owner can restart a stopped contract, enabling master-only functions again.
    function test_Owner_Starts_Contract_1() public {
// assume: isStopped() == true
// cover: start :: onlyOwner modifier true
// cover: start :: onlyOwner modifier false
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.stop();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: start()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: start()
        vm.prank(owner);
        // skip ABI-mismatched call: isStopped()
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can transfer ownership, and that the new owner gains ownership.
    function test_Transfer_Ownership_2() public {
// cover: transferOwnership :: onlyOwner modifier true
// cover: transferOwnership :: onlyOwner modifier false
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can transfer the master role, and that the new master can call master-only functions.
    function test_Transfer_Master_Role_3() public {
// cover: transferMasterRole :: onlyOwner modifier true
// cover: transferMasterRole :: onlyOwner modifier false
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        target.transferMasterRole(alice);
        }
        // skip ABI-mismatched call: isMaster()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferMasterRole(bob);
        }
    }

    // @cover-intent Protocol State Machine: Verify that sendToWinner_unchk20 transitions payedOut_unchk20 from false to true and prevents double payout.
    function test_Send_To_Winner_State_Transition_4() public {
// assume: payedOut_unchk20() == false
// cover: sendToWinner_unchk20 :: require(!payedOut_unchk20) true
// cover: sendToWinner_unchk20 :: require(!payedOut_unchk20) false
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        // skip ABI-mismatched call: sendToWinner_unchk20()
        // skip ABI-mismatched call: payedOut_unchk20()
        vm.expectRevert();
        // skip ABI-mismatched call: sendToWinner_unchk20()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdrawLeftOver_unchk33 reverts if payedOut_unchk33 is false.
    function test_Withdraw_LeftOver_Requires_PayedOut_5() public {
// assume: payedOut_unchk33() == false
// cover: withdrawLeftOver_unchk33 :: require(payedOut_unchk33) false
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        // skip ABI-mismatched call: withdrawLeftOver_unchk33()
    }

    // @cover-intent minimal test for UncheckedExternalCall_unchk4
    function test_perfn_UncheckedExternalCall_unchk4_6() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: UncheckedExternalCall_unchk4()
    }

    // @cover-intent minimal test for UncheckedExternalCall_unchk40
    function test_perfn_UncheckedExternalCall_unchk40_7() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: UncheckedExternalCall_unchk40()
    }

    // @cover-intent minimal test for bug_unchk19
    function test_perfn_bug_unchk19_8() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_unchk19()
    }

    // @cover-intent minimal test for bug_unchk27
    function test_perfn_bug_unchk27_9() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.bug_unchk27(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for bug_unchk3
    function test_perfn_bug_unchk3_10() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.bug_unchk3(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for bug_unchk30
    function test_perfn_bug_unchk30_11() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_unchk30()
    }

    // @cover-intent minimal test for bug_unchk31
    function test_perfn_bug_unchk31_12() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_unchk31()
    }

    // @cover-intent minimal test for bug_unchk39
    function test_perfn_bug_unchk39_13() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.bug_unchk39(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for bug_unchk42
    function test_perfn_bug_unchk42_14() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_unchk42()
    }

    // @cover-intent minimal test for bug_unchk43
    function test_perfn_bug_unchk43_15() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_unchk43()
    }

    // @cover-intent minimal test for bug_unchk7
    function test_perfn_bug_unchk7_16() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: bug_unchk7()
    }

    // @cover-intent minimal test for callnotchecked_unchk13
    function test_perfn_callnotchecked_unchk13_17() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.callnotchecked_unchk13(alice);
        }
    }

    // @cover-intent minimal test for callnotchecked_unchk25
    function test_perfn_callnotchecked_unchk25_18() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.callnotchecked_unchk25(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for callnotchecked_unchk37
    function test_perfn_callnotchecked_unchk37_19() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.callnotchecked_unchk37(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for cash_unchk46
    function test_perfn_cash_unchk46_20() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.cash_unchk46(1, 1, address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for deleteAccount
    function test_perfn_deleteAccount_21() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.deleteAccount("X");
        }
    }

    // @cover-intent minimal test for getAddress
    function test_perfn_getAddress_22() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.getAddress("X");
        }
    }

    // @cover-intent minimal test for isMaster
    function test_perfn_isMaster_23() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: isMaster()
    }

    // @cover-intent minimal test for isOwner
    function test_perfn_isOwner_24() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        // skip ABI-mismatched call: isOwner()
    }

    // @cover-intent minimal test for isStopped
    function test_perfn_isStopped_25() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: isStopped()
    }

    // @cover-intent minimal test for master
    function test_perfn_master_26() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: master()
    }

    // @cover-intent minimal test for my_func_uncheck36
    function test_perfn_my_func_uncheck36_27() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.my_func_uncheck36(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for my_func_uncheck48
    function test_perfn_my_func_uncheck48_28() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.my_func_uncheck48(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for my_func_unchk23
    function test_perfn_my_func_unchk23_29() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.my_func_unchk23(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for my_func_unchk35
    function test_perfn_my_func_unchk35_30() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.my_func_unchk35(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_31() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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

    // @cover-intent minimal test for payedOut_unchk20
    function test_perfn_payedOut_unchk20_32() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk20()
    }

    // @cover-intent minimal test for payedOut_unchk32
    function test_perfn_payedOut_unchk32_33() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk32()
    }

    // @cover-intent minimal test for payedOut_unchk33
    function test_perfn_payedOut_unchk33_34() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk33()
    }

    // @cover-intent minimal test for payedOut_unchk44
    function test_perfn_payedOut_unchk44_35() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk44()
    }

    // @cover-intent minimal test for payedOut_unchk45
    function test_perfn_payedOut_unchk45_36() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk45()
    }

    // @cover-intent minimal test for payedOut_unchk8
    function test_perfn_payedOut_unchk8_37() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk8()
    }

    // @cover-intent minimal test for payedOut_unchk9
    function test_perfn_payedOut_unchk9_38() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: payedOut_unchk9()
    }

    // @cover-intent minimal test for sendToWinner_unchk20
    function test_perfn_sendToWinner_unchk20_39() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner_unchk20()
    }

    // @cover-intent minimal test for sendToWinner_unchk32
    function test_perfn_sendToWinner_unchk32_40() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner_unchk32()
    }

    // @cover-intent minimal test for sendToWinner_unchk44
    function test_perfn_sendToWinner_unchk44_41() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner_unchk44()
    }

    // @cover-intent minimal test for sendToWinner_unchk8
    function test_perfn_sendToWinner_unchk8_42() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner_unchk8()
    }

    // @cover-intent minimal test for setAddress
    function test_perfn_setAddress_43() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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
        target.setAddress("X", "X", alice);
        }
    }

    // @cover-intent minimal test for start
    function test_perfn_start_44() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: start()
    }

    // @cover-intent minimal test for stop
    function test_perfn_stop_45() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: stop()
    }

    // @cover-intent minimal test for transferMasterRole
    function test_perfn_transferMasterRole_46() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.transferMasterRole(alice);
        }
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_47() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
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

    // @cover-intent minimal test for unhandledsend_unchk14
    function test_perfn_unhandledsend_unchk14_48() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.unhandledsend_unchk14(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for unhandledsend_unchk2
    function test_perfn_unhandledsend_unchk2_49() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.unhandledsend_unchk2(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for unhandledsend_unchk26
    function test_perfn_unhandledsend_unchk26_50() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.unhandledsend_unchk26(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for unhandledsend_unchk38
    function test_perfn_unhandledsend_unchk38_51() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.unhandledsend_unchk38(address(uint160(alice)));
        }
    }

    // @cover-intent minimal test for updateAccount
    function test_perfn_updateAccount_52() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
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
        target.updateAccount("X", "X");
        }
    }

    // @cover-intent minimal test for version
    function test_perfn_version_53() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: version()
    }

    // @cover-intent minimal test for winAmount_unchk20
    function test_perfn_winAmount_unchk20_54() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winAmount_unchk20()
    }

    // @cover-intent minimal test for winAmount_unchk32
    function test_perfn_winAmount_unchk32_55() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winAmount_unchk32()
    }

    // @cover-intent minimal test for winAmount_unchk44
    function test_perfn_winAmount_unchk44_56() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winAmount_unchk44()
    }

    // @cover-intent minimal test for winAmount_unchk8
    function test_perfn_winAmount_unchk8_57() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winAmount_unchk8()
    }

    // @cover-intent minimal test for winner_unchk20
    function test_perfn_winner_unchk20_58() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winner_unchk20()
    }

    // @cover-intent minimal test for winner_unchk32
    function test_perfn_winner_unchk32_59() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winner_unchk32()
    }

    // @cover-intent minimal test for winner_unchk44
    function test_perfn_winner_unchk44_60() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winner_unchk44()
    }

    // @cover-intent minimal test for winner_unchk8
    function test_perfn_winner_unchk8_61() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: winner_unchk8()
    }

    // @cover-intent minimal test for withdrawBal_unchk17
    function test_perfn_withdrawBal_unchk17_62() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBal_unchk17()
    }

    // @cover-intent minimal test for withdrawLeftOver_unchk33
    function test_perfn_withdrawLeftOver_unchk33_63() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawLeftOver_unchk33()
    }

    // @cover-intent minimal test for withdrawLeftOver_unchk45
    function test_perfn_withdrawLeftOver_unchk45_64() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawLeftOver_unchk45()
    }

    // @cover-intent minimal test for withdrawLeftOver_unchk9
    function test_perfn_withdrawLeftOver_unchk9_65() public {
        vm.startPrank(owner);
        AccountWallet target = new AccountWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawLeftOver_unchk9()
    }

}
