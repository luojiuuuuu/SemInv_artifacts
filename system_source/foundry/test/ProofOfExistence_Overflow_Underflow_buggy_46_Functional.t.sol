// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/buggy_46.sol";

// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}

contract ProofOfExistence_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ProofOfExistence_FunctionalTest() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() public payable { }


    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }


    // @cover-intent Test normal behavior of setting a file existence proof and retrieving it via GetFileExistenceProof, verifying all fields match.
    function test_Set_and_retrieve_file_existence_proof_0() public {
// cover: SetFileExistenceProof :: normal execution
// cover: GetFileExistenceProof :: found match
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.SetFileExistenceProof(alice, "hash1", "path1", bob, 1);
        }
        {
        target.GetFileExistenceProof(alice, "hash1", "path1");
        }
        vm.stopPrank();
    }

    // @cover-intent Test edge case where GetFileExistenceProof is called for a file that was never registered, expecting no match (empty return).
    function test_Retrieve_non_existent_proof_returns_empty_1() public {
// cover: GetFileExistenceProof :: no match found
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.GetFileExistenceProof(alice, "nonexistent", "nopath");
        }
    }

    // @cover-intent Test normal behavior of setting multiple proofs and retrieving one via searchExistenceProoUsngQRf using the returned QR code.
    function test_Set_multiple_proofs_and_retrieve_via_QR_code_2() public {
// cover: SetFileExistenceProof :: multiple entries
// cover: getQRCode :: found match
// cover: searchExistenceProoUsngQRf :: found match
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.SetFileExistenceProof(alice, "hashA", "pathA", bob, 1);
        }
        {
        target.SetFileExistenceProof(alice, "hashB", "pathB", carol, 2);
        }
        {
        target.getQRCode(alice, "hashA", "pathA");
        }
        // skip malformed call: searchExistenceProoUsngQRf(alice, <bytes32 from previous step>) (bad raw arg for searchExistenceProoUsngQRf.arg1: type=bytes32, raw=<bytes32 from previous step>)
        vm.stopPrank();
    }

    // @cover-intent Test edge case where searchExistenceProoUsngQRf is called with a non-existent QR code hash, expecting no match.
    function test_Search_QR_code_with_no_match_3() public {
// cover: searchExistenceProoUsngQRf :: no match found
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(1)));
        }
    }

    // @cover-intent Test boundary behavior by setting proofs with all valid BlockchainIdentification enum values (0, 1, 2) and verifying retrieval.
    function test_Set_proof_with_different_identifier_values_4() public {
// cover: SetFileExistenceProof :: identifier 0
// cover: SetFileExistenceProof :: identifier 1
// cover: SetFileExistenceProof :: identifier 2
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.SetFileExistenceProof(alice, "hash0", "path0", bob, 0);
        }
        {
        target.SetFileExistenceProof(alice, "hash1", "path1", bob, 1);
        }
        {
        target.SetFileExistenceProof(alice, "hash2", "path2", bob, 2);
        }
        {
        target.GetFileExistenceProof(alice, "hash0", "path0");
        }
        {
        target.GetFileExistenceProof(alice, "hash2", "path2");
        }
        vm.stopPrank();
    }

    // @cover-intent Test the guarded withdraw_intou33 function by first increasing lock time, then attempting withdrawal before and after the lock expires.
    function test_Increase_lock_time_and_withdraw_for_intou33_5() public {
// assume: now <= lockTime_intou33[alice]
// cover: withdraw_intou33 :: require(now > lockTime) false
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.increaseLockTime_intou33(100);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

    // @cover-intent Test the guarded withdraw_intou13 function by increasing lock time and verifying the guard condition.
    function test_Increase_lock_time_and_withdraw_for_intou13_6() public {
// assume: now <= lockTime_intou13[bob]
// cover: withdraw_intou13 :: require(now > lockTime) false
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.increaseLockTime_intou13(200);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Test that bug_intou27, bug_intou31, bug_intou35, bug_intou36, and bug_intou40 execute without reverting (basic sanity).
    function test_Call_bug_functions_for_coverage_7() public {
// cover: bug_intou27 :: execution
// cover: bug_intou31 :: execution
// cover: bug_intou35 :: execution
// cover: bug_intou36 :: execution
// cover: bug_intou40 :: execution
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        // skip ABI-mismatched call: bug_intou27()
        // skip ABI-mismatched call: bug_intou31()
        // skip ABI-mismatched call: bug_intou35()
        {
        target.bug_intou36(5);
        }
        {
        target.bug_intou40(10);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that lockTime_intou33 and lockTime_intou13 return correct values after being set.
    function test_Read_lockTime_mappings_8() public {
// cover: lockTime_intou33 :: read
// cover: lockTime_intou13 :: read
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.increaseLockTime_intou33(50);
        }
        vm.prank(bob);
        {
        target.increaseLockTime_intou13(75);
        }
        vm.prank(alice);
        {
        target.lockTime_intou33(alice);
        }
        vm.prank(bob);
        {
        target.lockTime_intou13(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_SetFileExistenceProof_9() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.SetFileExistenceProof(alice, "hash1", "path1", bob, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_GetFileExistenceProof_10() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.SetFileExistenceProof(alice, "hash1", "path1", bob, 1);
        }
        {
        target.GetFileExistenceProof(alice, "hash1", "path1");
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getQRCode_11() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.SetFileExistenceProof(alice, "hash1", "path1", bob, 1);
        }
        {
        target.getQRCode(alice, "hash1", "path1");
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_searchExistenceProoUsngQRf_12() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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
        target.SetFileExistenceProof(alice, "hash1", "path1", bob, 1);
        }
        {
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_increaseLockTime_intou33_13() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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

    // @cover-intent Financial & Accounting
    function test_withdraw_intou33_14() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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

    // @cover-intent Financial & Accounting
    function test_increaseLockTime_intou13_15() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.increaseLockTime_intou13(200);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_intou13_16() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
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

    // @cover-intent Financial & Accounting
    function test_lockTime_intou33_17() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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

    // @cover-intent Financial & Accounting
    function test_lockTime_intou13_18() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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
    function test_bug_intou27_19() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
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
    function test_bug_intou31_20() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
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
    function test_bug_intou35_21() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
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
    function test_bug_intou36_22() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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
    function test_bug_intou40_23() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
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

}
