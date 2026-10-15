// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_31.sol";

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

contract FeeTransactionManager_FunctionalTest {
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


    // @cover-intent Test successful execution of a fee-managed transfer with valid signature, verifying Transactional Consistency and External Interaction & Environment invariants.
    function test_execute_positive_path_0() public {
// assume: relayer() == alice
// assume: token.allowance(alice, target) >= 110
// cover: execute :: require(tx.origin == relayer) true
// cover: execute :: require(marmo.signer() == ECDSA.recover(hash, _signature)) true
// cover: execute :: require(token.transferFrom(msg.sender, _to, _value)) true
// cover: execute :: require(token.transferFrom(msg.sender, relayer, _fee)) true
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.execute(bob, 100, 10, hex"00");
        }
    }

    // @cover-intent Test that execute reverts when tx.origin is not the relayer, verifying Authorization & Access Control invariant.
    function test_execute_invalid_origin_1() public {
// assume: relayer() != bob
// cover: execute :: require(tx.origin == relayer) false
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.execute(alice, 100, 10, hex"00");
        }
    }

    // @cover-intent Test that execute reverts when token transfer fails due to insufficient allowance, verifying Financial & Accounting invariant.
    function test_execute_insufficient_allowance_2() public {
// assume: relayer() == alice
// assume: token.allowance(alice, target) < 110
// cover: execute :: require(token.transferFrom(msg.sender, _to, _value)) false
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.execute(bob, 100, 10, hex"00");
        }
    }

    // @cover-intent Test that owner can successfully change the relayer, verifying Authorization & Access Control and Protocol State Machine invariants.
    function test_setRelayer_owner_success_3() public {
// assume: owner() == owner
// cover: setRelayer :: require(isOwner()) true
// cover: setRelayer :: require(_newRelayer != address(0)) true
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.setRelayer(bob);
        }
    }

    // @cover-intent Test that non-owner cannot change the relayer, verifying Authorization & Access Control invariant.
    function test_setRelayer_non_owner_revert_4() public {
// assume: owner() != alice
// cover: setRelayer :: require(isOwner()) false
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.setRelayer(bob);
        }
    }

    // @cover-intent Test that setting relayer to zero address reverts, verifying Resource & Execution Integrity invariant.
    function test_setRelayer_zero_address_revert_5() public {
// assume: owner() == owner
// cover: setRelayer :: require(_newRelayer != address(0)) false
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.setRelayer(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Test that owner can transfer ownership to another address, verifying Authorization & Access Control and Protocol State Machine invariants.
    function test_transferOwnership_owner_success_6() public {
// assume: owner() == owner
// cover: transferOwnership :: require(isOwner()) true
// cover: _transferOwnership :: require(newOwner != address(0)) true
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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

    // @cover-intent Test that non-owner cannot transfer ownership, verifying Authorization & Access Control invariant.
    function test_transferOwnership_non_owner_revert_7() public {
// assume: owner() != alice
// cover: transferOwnership :: require(isOwner()) false
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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

    // @cover-intent Test that transferring ownership to zero address reverts, verifying Resource & Execution Integrity invariant.
    function test_transferOwnership_zero_address_revert_8() public {
// assume: owner() == owner
// cover: _transferOwnership :: require(newOwner != address(0)) false
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferOwnership(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Test that execute cannot be reentered, verifying Transactional Consistency invariant.
    function test_execute_reentrancy_guard_9() public {
// assume: relayer() == alice
// assume: token.allowance(alice, target) >= 110
// cover: execute :: nonReentrant guard passes
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.execute(bob, 100, 10, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin36_positive_10() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.bug_txorigin36(owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin4_positive_11() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.bug_txorigin4(owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin40_positive_12() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.bug_txorigin40(owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin8_positive_13() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.bug_txorigin8(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_execute_positive_14() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.setRelayer(owner);
        }
        {
        target.execute(bob, 100, 50, hex"");
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_isOwner_positive_15() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.isOwner();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_positive_16() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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

    // @cover-intent Authorization & Access Control
    function test_relayer_positive_17() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.relayer();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_sendto_txorigin13_positive_18() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.sendto_txorigin13(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_sendto_txorigin33_positive_19() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.sendto_txorigin33(bob, 1, owner);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setRelayer_positive_20() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.setRelayer(alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_token_positive_21() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.token();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_positive_22() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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

    // @cover-intent Resource & Execution Integrity
    function test_transferTo_txorigin23_positive_23() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferTo_txorigin23(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_transferTo_txorigin27_positive_24() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferTo_txorigin27(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_transferTo_txorigin31_positive_25() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferTo_txorigin31(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_transferTo_txorigin35_positive_26() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferTo_txorigin35(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_transferTo_txorigin39_positive_27() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferTo_txorigin39(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_transferTo_txorigin7_positive_28() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.transferTo_txorigin7(bob, 1, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawAll_txorigin14_positive_29() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.withdrawAll_txorigin14(bob, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawAll_txorigin30_positive_30() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.withdrawAll_txorigin30(bob, owner);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawAll_txorigin38_positive_31() public {
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
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
        target.withdrawAll_txorigin38(bob, owner);
        }
    }

}
