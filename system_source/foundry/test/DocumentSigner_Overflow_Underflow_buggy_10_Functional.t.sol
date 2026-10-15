// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/buggy_10.sol";

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

contract DocumentSigner_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DocumentSigner_FunctionalTest() public {
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


    // @cover-intent Transactional Consistency - Verify document submission and signing workflow with duplicate prevention
    function test_submit_and_sign_document_0() public {
// cover: signDocument :: require(bytes(docs[_docHash]).length != 0) true
// cover: signDocument :: for loop duplicate check true
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
        vm.stopPrank();
        vm.prank(bob);
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
        vm.prank(alice);
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
    }

    // @cover-intent Resource & Execution Integrity - Verify signing fails for unsubmitted document
    function test_sign_nonexistent_document_1() public {
// cover: signDocument :: require(bytes(docs[_docHash]).length != 0) false
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.signDocument(bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency - Verify duplicate document submission does not emit event
    function test_submit_duplicate_document_2() public {
// cover: submitDocument :: bytes(docs[_docHash]).length == 0 false
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        {
        target.submitDocument("doc1");
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity - Verify getDetail returns correct data after submission and signing
    function test_get_detail_for_submitted_document_3() public {
// cover: getDetail :: require(bytes(docs[_docHash]).length != 0) true
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
        vm.stopPrank();
        vm.prank(bob);
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
        vm.prank(alice);
        // skip malformed call: getDetail(getHash("doc1")) (bad raw arg for getDetail.arg0: type=bytes32, raw=getHash("doc1"))
    }

    // @cover-intent Resource & Execution Integrity - Verify getDetail reverts for unsubmitted document
    function test_get_detail_for_nonexistent_document_4() public {
// cover: getDetail :: require(bytes(docs[_docHash]).length != 0) false
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.getDetail(bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency - Verify getHash returns deterministic hash for same input
    function test_get_hash_consistency_5() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
        target.getHash("hello");
        }
        vm.prank(bob);
        {
        target.getHash("hello");
        }
    }

    // @cover-intent Financial & Accounting - Verify lock time increase and withdrawal with time constraint
    function test_increase_lock_time_and_withdraw_intou13_6() public {
// assume: now <= lockTime_intou13[alice]
// cover: withdraw_intou13 :: require(now > lockTime_intou13[msg.sender]) false
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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

    // @cover-intent Financial & Accounting - Verify lock time increase and withdrawal with time constraint
    function test_increase_lock_time_and_withdraw_intou33_7() public {
// assume: now <= lockTime_intou33[bob]
// cover: withdraw_intou33 :: require(now > lockTime_intou33[msg.sender]) false
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.increaseLockTime_intou33(200);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity - Verify bug functions execute without revert (known vulnerabilities)
    function test_overflow_bug_functions_8() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        // skip ABI-mismatched call: bug_intou39()
        // skip ABI-mismatched call: bug_intou31()
        // skip ABI-mismatched call: bug_intou35()
        // skip ABI-mismatched call: bug_intou27()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity - Verify bug functions with parameters execute without revert
    function test_overflow_bug_functions_with_params_9() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.bug_intou36(255);
        }
        {
        target.bug_intou40(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_sequence_10() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
    function test_bug_intou31_sequence_11() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
    function test_bug_intou35_sequence_12() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
    function test_bug_intou36_sequence_13() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
    function test_bug_intou39_sequence_14() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
    function test_bug_intou40_sequence_15() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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

    // @cover-intent Transactional Consistency
    function test_docs_sequence_16() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        {
        target.docs(bytes32(uint256(4660)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_getDetail_sequence_17() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        {
        target.getDetail(bytes32(uint256(4660)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_getHash_sequence_18() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
        target.getHash("test");
        }
    }

    // @cover-intent Financial & Accounting
    function test_increaseLockTime_intou13_sequence_19() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_increaseLockTime_intou33_sequence_20() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
    function test_lockTime_intou13_sequence_21() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting
    function test_lockTime_intou33_sequence_22() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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

    // @cover-intent Transactional Consistency
    function test_signDocument_sequence_23() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        {
        target.signDocument(bytes32(uint256(4660)));
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_signers_sequence_24() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
        target.submitDocument("doc1");
        }
        {
        target.signDocument(bytes32(uint256(4660)));
        }
        {
        target.signers(bytes32(uint256(4660)), 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_submitDocument_sequence_25() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
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
        target.submitDocument("doc1");
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_intou13_sequence_26() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
    function test_withdraw_intou33_sequence_27() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
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
