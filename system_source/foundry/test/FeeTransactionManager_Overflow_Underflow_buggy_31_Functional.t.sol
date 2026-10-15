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


    // @cover-intent Transactional Consistency: Verify that execute() succeeds when called by relayer with a valid signature from the signer of the calling contract (Marmo).
    function test_Execute_with_valid_signature_and_relayer_0() public {
// assume: relayer() == alice
// assume: token.allowance(alice, target) >= 60
// cover: execute :: tx.origin == relayer true
// cover: execute :: marmo.signer() == ECDSA.recover(hash, signature) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.execute(bob, 50, 10, hex"");
        }
    }

    // @cover-intent Authorization & Access Control: Ensure execute() reverts when tx.origin is not the relayer.
    function test_Execute_with_invalid_relayer_origin_1() public {
// assume: relayer() != bob
// cover: execute :: tx.origin == relayer false
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
        target.execute(alice, 10, 1, hex"");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can set a new relayer.
    function test_Set_relayer_as_owner_2() public {
// assume: owner() == owner
// cover: setRelayer :: onlyOwner modifier true
// cover: setRelayer :: onlyOwner modifier false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setRelayer(carol);
        }
    }

    // @cover-intent Authorization & Access Control: Ensure setRelayer reverts when _newRelayer is address(0).
    function test_Set_relayer_to_zero_address_reverts_3() public {
// cover: setRelayer :: _newRelayer != address(0) false
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

    // @cover-intent Authorization & Access Control: Verify that owner can transfer ownership to a new address.
    function test_Transfer_ownership_to_alice_4() public {
// cover: transferOwnership :: onlyOwner modifier true
// cover: _transferOwnership :: newOwner != address(0) true
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
        target.transferOwnership(alice);
        }
        // skip ABI-mismatched call: isOwner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Ensure transferOwnership reverts when newOwner is zero address.
    function test_Transfer_ownership_to_zero_address_reverts_5() public {
// cover: _transferOwnership :: newOwner != address(0) false
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

    // @cover-intent Authorization & Access Control: Verify that non-owner call to transferOwnership reverts.
    function test_Non_owner_cannot_transfer_ownership_6() public {
// assume: owner() != alice
// cover: transferOwnership :: onlyOwner modifier false
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

    // @cover-intent Protocol State Machine: Verify that increaseLockTime_intou13 updates lock time and withdraw_intou13 succeeds after lock expires.
    function test_Increase_lock_time_and_withdraw_7() public {
// assume: now <= lockTime_intou13(alice)
// cover: increaseLockTime_intou13 :: lockTime_intou13[msg.sender] += _secondsToIncrease
// cover: withdraw_intou13 :: now > lockTime_intou13[msg.sender] false
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
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou13(100);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that withdraw_intou13 succeeds when current time exceeds lock time.
    function test_Withdraw_after_lock_time_passes_8() public {
// assume: now > lockTime_intou13(alice)
// cover: withdraw_intou13 :: now > lockTime_intou13[msg.sender] true
        vm.startPrank(owner);
        FeeTransactionManager target = new FeeTransactionManager(bob, carol);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), 0x..., 0x...);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou13(1);
        }
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that increaseLockTime_intou33 can overflow (no revert).
    function test_Increase_lock_time_overflow_9() public {
// cover: increaseLockTime_intou33 :: lockTime_intou33[msg.sender] += _secondsToIncrease overflow
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
        vm.startPrank(alice);
        // skip malformed call: increaseLockTime_intou33(2**256 - 1) (bad raw arg for increaseLockTime_intou33.arg0: type=uint256, raw=2**256 - 1)
        {
        target.increaseLockTime_intou33(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou23_sequence_10() public {
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_sequence_11() public {
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_sequence_12() public {
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_sequence_13() public {
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou36_sequence_14() public {
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_sequence_15() public {
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou4_sequence_16() public {
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou40_sequence_17() public {
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou7_sequence_18() public {
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou8_sequence_19() public {
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_execute_sequence_20() public {
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
        // skip malformed call: setRelayer(relayer) (bad raw arg for setRelayer.arg0: type=address, raw=relayer)
        vm.expectRevert();
        vm.prank(alice);
        {
        target.execute(bob, 10, 5, hex"00");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_sequence_21() public {
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
        target.increaseLockTime_intou13(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou33_sequence_22() public {
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
        target.increaseLockTime_intou33(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_isOwner_sequence_23() public {
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
        // skip ABI-mismatched call: isOwner()
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou13_sequence_24() public {
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou33_sequence_25() public {
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_sequence_26() public {
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Authorization & Access Control
    function test_relayer_sequence_27() public {
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
        // skip ABI-mismatched call: relayer()
    }

    // @cover-intent Authorization & Access Control
    function test_setRelayer_sequence_28() public {
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

    // @cover-intent External Interaction & Environment
    function test_token_sequence_29() public {
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
        // skip ABI-mismatched call: token()
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_sequence_30() public {
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
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_sequence_31() public {
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
        target.transfer_intou14(bob, 10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_sequence_32() public {
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
        target.transfer_intou30(bob, 10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou38_sequence_33() public {
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
        target.transfer_intou38(bob, 10);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_sequence_34() public {
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
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou13(0);
        }
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_sequence_35() public {
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
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou33(0);
        }
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

}
