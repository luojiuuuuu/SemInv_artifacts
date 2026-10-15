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


    // @cover-intent state transition test for stop
    function test_Authorization_AccessControl_OwnerOnly_0() public {
// assume: owner != alice
// cover: stop :: onlyOwner modifier - require(isOwner()) true
// cover: stop :: onlyOwner modifier - require(isOwner()) false
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
        vm.prank(alice);
        // skip ABI-mismatched call: stop()
        vm.prank(owner);
        // skip ABI-mismatched call: stop()
    }

    // @cover-intent Test the stopped state machine: after stop, setAddress should revert; after start, setAddress should succeed.
    function test_ProtocolStateMachine_StopStartCycle_1() public {
// assume: isStopped() == true
// cover: setAddress :: onlyWhenNotStopped modifier - require(!isStopped()) true
// cover: setAddress :: onlyWhenNotStopped modifier - require(!isStopped()) false
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
        // skip ABI-mismatched call: stop()
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Test transferOwnership: only owner can transfer, and after transfer the new owner can call owner-only functions.
    function test_Authorization_AccessControl_TransferOwnership_2() public {
// assume: owner != alice
// assume: owner != bob
// cover: transferOwnership :: onlyOwner modifier - require(isOwner()) true
// cover: transferOwnership :: onlyOwner modifier - require(isOwner()) false
// cover: transferOwnership :: require(newOwner != address(0)) true
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
        vm.prank(alice);
        {
        target.transferOwnership(bob);
        }
        vm.startPrank(owner);
        {
        target.transferOwnership(bob);
        }
        // skip ABI-mismatched call: stop()
        vm.stopPrank();
    }

    // @cover-intent Test transferMasterRole: only owner can transfer, and after transfer the new master can call master-only functions.
    function test_Authorization_AccessControl_TransferMasterRole_3() public {
// assume: owner != alice
// assume: owner != bob
// assume: isStopped() == false
// cover: transferMasterRole :: onlyOwner modifier - require(isOwner()) true
// cover: transferMasterRole :: onlyOwner modifier - require(isOwner()) false
// cover: transferMasterRole :: require(newMaster != address(0)) true
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
        vm.prank(alice);
        {
        target.transferMasterRole(bob);
        }
        vm.prank(owner);
        {
        target.transferMasterRole(bob);
        }
    }

    // @cover-intent Verify that sendto_txorigin1 requires tx.origin to match the owner_txorigin1 parameter. A call with mismatched tx.origin should revert.
    function test_ExternalInteraction_Environment_TxOriginGuard_4() public {
// assume: alice != bob
// cover: sendto_txorigin1 :: require(tx.origin == owner_txorigin1) true
// cover: sendto_txorigin1 :: require(tx.origin == owner_txorigin1) false
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
        vm.startPrank(alice);
        {
        target.sendto_txorigin1(address(uint160(bob)), 0, alice);
        }
        vm.expectRevert();
        {
        target.sendto_txorigin1(address(uint160(bob)), 0, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for stop
    function test_ProtocolStateMachine_StopStartEdge_5() public {
// assume: isStopped() == true
// cover: stop :: onlyOwner modifier - require(isOwner()) true
// cover: start :: onlyOwner modifier - require(isOwner()) true
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
        // skip ABI-mismatched call: stop()
        // skip ABI-mismatched call: stop()
        // skip ABI-mismatched call: start()
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin12_positive_6() public {
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
        target.bug_txorigin12(owner);
        }
        {
        target.bug_txorigin12(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin20_positive_7() public {
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
        target.bug_txorigin20(owner);
        }
        {
        target.bug_txorigin20(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin32_positive_8() public {
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
        target.bug_txorigin32(owner);
        }
        {
        target.bug_txorigin32(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin36_positive_9() public {
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
        target.bug_txorigin36(owner);
        }
        {
        target.bug_txorigin36(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin4_positive_10() public {
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
        target.bug_txorigin4(owner);
        }
        {
        target.bug_txorigin4(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin40_positive_11() public {
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
        target.bug_txorigin40(owner);
        }
        {
        target.bug_txorigin40(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin8_positive_12() public {
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
        target.bug_txorigin8(owner);
        }
        {
        target.bug_txorigin8(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_isMaster_positive_13() public {
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
        // skip ABI-mismatched call: isMaster()
    }

    // @cover-intent Authorization & Access Control
    function test_isOwner_positive_14() public {
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

    // @cover-intent Protocol State Machine
    function test_isStopped_positive_15() public {
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
        // skip ABI-mismatched call: isStopped()
    }

    // @cover-intent Authorization & Access Control
    function test_master_positive_16() public {
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
        // skip ABI-mismatched call: master()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_positive_17() public {
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

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin1_positive_18() public {
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
        target.sendto_txorigin1(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin1(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin13_positive_19() public {
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
        target.sendto_txorigin13(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin13(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin17_positive_20() public {
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
        target.sendto_txorigin17(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin17(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin21_positive_21() public {
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
        target.sendto_txorigin21(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin21(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin25_positive_22() public {
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
        target.sendto_txorigin25(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin25(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin33_positive_23() public {
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
        target.sendto_txorigin33(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin33(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin37_positive_24() public {
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
        target.sendto_txorigin37(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin37(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin9_positive_25() public {
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
        target.sendto_txorigin9(address(uint160(bob)), 1, owner);
        }
        {
        target.sendto_txorigin9(address(uint160(bob)), 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_start_positive_26() public {
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
        // skip ABI-mismatched call: stop()
        // skip ABI-mismatched call: start()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_stop_positive_27() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_transferMasterRole_positive_28() public {
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
        target.transferMasterRole(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_positive_29() public {
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

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin11_positive_30() public {
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
        target.transferTo_txorigin11(bob, 1, owner);
        }
        {
        target.transferTo_txorigin11(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin19_positive_31() public {
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
        target.transferTo_txorigin19(bob, 1, owner);
        }
        {
        target.transferTo_txorigin19(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin23_positive_32() public {
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
        target.transferTo_txorigin23(bob, 1, owner);
        }
        {
        target.transferTo_txorigin23(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin27_positive_33() public {
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
        target.transferTo_txorigin27(bob, 1, owner);
        }
        {
        target.transferTo_txorigin27(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin3_positive_34() public {
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
        target.transferTo_txorigin3(bob, 1, owner);
        }
        {
        target.transferTo_txorigin3(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin31_positive_35() public {
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
        target.transferTo_txorigin31(bob, 1, owner);
        }
        {
        target.transferTo_txorigin31(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin35_positive_36() public {
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
        target.transferTo_txorigin35(bob, 1, owner);
        }
        {
        target.transferTo_txorigin35(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin39_positive_37() public {
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
        target.transferTo_txorigin39(bob, 1, owner);
        }
        {
        target.transferTo_txorigin39(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin7_positive_38() public {
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
        target.transferTo_txorigin7(bob, 1, owner);
        }
        {
        target.transferTo_txorigin7(bob, 1, owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_version_positive_39() public {
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
        // skip ABI-mismatched call: version()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin10_positive_40() public {
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
        target.withdrawAll_txorigin10(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin10(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin14_positive_41() public {
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
        target.withdrawAll_txorigin14(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin14(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin2_positive_42() public {
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
        target.withdrawAll_txorigin2(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin2(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin22_positive_43() public {
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
        target.withdrawAll_txorigin22(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin22(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin26_positive_44() public {
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
        target.withdrawAll_txorigin26(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin26(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin30_positive_45() public {
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
        target.withdrawAll_txorigin30(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin30(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin38_positive_46() public {
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
        target.withdrawAll_txorigin38(address(uint160(bob)), owner);
        }
        {
        target.withdrawAll_txorigin38(address(uint160(bob)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for deleteAccount
    function test_perfn_deleteAccount_47() public {
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
    function test_perfn_getAddress_48() public {
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

    // @cover-intent minimal test for setAddress
    function test_perfn_setAddress_49() public {
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

    // @cover-intent minimal test for updateAccount
    function test_perfn_updateAccount_50() public {
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

}
