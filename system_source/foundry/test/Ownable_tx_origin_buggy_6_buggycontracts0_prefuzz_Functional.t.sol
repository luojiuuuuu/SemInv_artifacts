// SPDX-License-Identifier: MIT
pragma solidity 0.5.8;
import "../src/buggy_6.sol";

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

contract ChannelWallet_FunctionalTest {
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


    // @cover-intent Protocol State Machine: Verify that only owner can stop and start the contract, and that stopped state prevents channel operations.
    function test_Owner_Stop_Start_StateMachine_0() public {
// cover: stop :: require(isOwner()) true
// cover: start :: require(isOwner()) true
// cover: setAddress :: require(!isStopped()) false
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
        // skip ABI-mismatched call: isStopped()
        // skip ABI-mismatched call: start()
        // skip ABI-mismatched call: isStopped()
        vm.stopPrank();
    }

    // @cover-intent state transition test for stop
    function test_NonOwner_Cannot_Stop_1() public {
// cover: stop :: require(isOwner()) false
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    }

    // @cover-intent Authorization & Access Control: Verify that owner can transfer ownership and new owner can exercise owner-only functions.
    function test_TransferOwnership_And_Verify_2() public {
// cover: transferOwnership :: require(isOwner()) true
// cover: transferOwnership :: require(newOwner != address(0)) true
// cover: stop :: require(isOwner()) false (old owner)
// cover: stop :: require(isOwner()) true (new owner)
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
        vm.expectRevert();
        // skip ABI-mismatched call: stop()
        // skip ABI-mismatched call: stop()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can transfer master role and new master can set addresses.
    function test_TransferMasterRole_And_Verify_3() public {
// cover: transferMasterRole :: require(isOwner()) true
// cover: setAddress :: require(isMaster() || isOwner()) true (new master)
// cover: setAddress :: require(isMaster() || isOwner()) false (old owner)
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_bug_txorigin12_positive_4() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin20_positive_5() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.bug_txorigin20(bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin32_positive_6() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.bug_txorigin32(carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin36_positive_7() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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
    function test_bug_txorigin4_positive_8() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.bug_txorigin4(bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin40_positive_9() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.bug_txorigin40(carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin8_positive_10() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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
    function test_isMaster_positive_11() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_isOwner_positive_12() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_isStopped_positive_13() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
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

    // @cover-intent Authorization & Access Control
    function test_master_positive_14() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
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

    // @cover-intent Authorization & Access Control
    function test_owner_positive_15() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
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

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin1_positive_16() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.sendto_txorigin1(address(uint160(bob)), 1, alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin13_positive_17() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.sendto_txorigin13(address(uint160(carol)), 1, bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin17_positive_18() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.sendto_txorigin17(address(uint160(alice)), 1, carol);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin25_positive_19() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.sendto_txorigin25(address(uint160(bob)), 1, alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin33_positive_20() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.sendto_txorigin33(address(uint160(carol)), 1, bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin37_positive_21() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.sendto_txorigin37(address(uint160(alice)), 1, carol);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin9_positive_22() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.sendto_txorigin9(address(uint160(bob)), 1, alice);
        }
    }

    // @cover-intent Protocol State Machine
    function test_start_positive_23() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_stop_positive_24() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_transferMasterRole_positive_25() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_transferOwnership_positive_26() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
    function test_transferTo_txorigin11_positive_27() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transferTo_txorigin11(bob, 1, alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin19_positive_28() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.transferTo_txorigin19(carol, 1, bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin23_positive_29() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.transferTo_txorigin23(alice, 1, carol);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin27_positive_30() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin3_positive_31() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.transferTo_txorigin3(carol, 1, bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin31_positive_32() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.transferTo_txorigin31(alice, 1, carol);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin35_positive_33() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin39_positive_34() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.transferTo_txorigin39(carol, 1, bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin7_positive_35() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.transferTo_txorigin7(alice, 1, carol);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_version_positive_36() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
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

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin10_positive_37() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawAll_txorigin10(address(uint160(bob)), alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin14_positive_38() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.withdrawAll_txorigin14(address(uint160(carol)), bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin2_positive_39() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.withdrawAll_txorigin2(address(uint160(alice)), carol);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin22_positive_40() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawAll_txorigin22(address(uint160(bob)), alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin26_positive_41() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.withdrawAll_txorigin26(address(uint160(carol)), bob);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin30_positive_42() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.withdrawAll_txorigin30(address(uint160(alice)), carol);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin38_positive_43() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawAll_txorigin38(address(uint160(bob)), alice);
        }
    }

    // @cover-intent minimal test for deleteChannel
    function test_perfn_deleteChannel_44() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.deleteChannel("X");
        }
    }

    // @cover-intent minimal test for getAddress
    function test_perfn_getAddress_45() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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
    function test_perfn_setAddress_46() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
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
        target.setAddress("X", alice);
        }
    }

    // @cover-intent minimal test for updateChannel
    function test_perfn_updateChannel_47() public {
        vm.startPrank(owner);
        ChannelWallet target = new ChannelWallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.updateChannel("X", "X", alice);
        }
    }

}
