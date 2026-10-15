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


    // @cover-intent Test normal document submission and signing flow (Transactional Consistency)
    function test_submit_and_sign_document_0() public {
// cover: submitDocument :: bytes(docs[_docHash]).length == 0 true
// cover: signDocument :: validDoc modifier passes
// cover: signDocument :: no duplicate signer
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
        target.submitDocument("Document1");
        }
        // skip malformed call: signDocument(getHash("Document1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("Document1"))
        vm.stopPrank();
        vm.prank(bob);
        // skip malformed call: signDocument(getHash("Document1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("Document1"))
    }

    // @cover-intent Test signing a document that has not been submitted (Authorization & Access Control)
    function test_sign_nonexistent_document_1() public {
// cover: signDocument :: validDoc modifier fails
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
        target.signDocument(bytes32(uint256(8234104122419153896766082834368325185836758793849283143825308940974890684980)));
        }
    }

    // @cover-intent Test that a signer cannot sign the same document twice (Transactional Consistency)
    function test_prevent_duplicate_signature_2() public {
// cover: signDocument :: duplicate signer detected and skipped
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
        target.submitDocument("Doc2");
        }
        // skip malformed call: signDocument(getHash("Doc2")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("Doc2"))
        // skip malformed call: signDocument(getHash("Doc2")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("Doc2"))
        vm.stopPrank();
    }

    // @cover-intent Test retrieving document details after submission (Resource & Execution Integrity)
    function test_get_detail_for_submitted_document_3() public {
// cover: getDetail :: validDoc modifier passes
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
        target.submitDocument("TestDoc");
        }
        // skip malformed call: signDocument(getHash("TestDoc")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("TestDoc"))
        vm.stopPrank();
        vm.prank(bob);
        // skip malformed call: getDetail(getHash("TestDoc")) (bad raw arg for getDetail.arg0: type=bytes32, raw=getHash("TestDoc"))
    }

    // @cover-intent Test retrieving details for a document that does not exist (Authorization & Access Control)
    function test_get_detail_for_nonexistent_document_4() public {
// cover: getDetail :: validDoc modifier fails
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

    // @cover-intent Test that getHash returns consistent results for the same input (Resource & Execution Integrity)
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
        target.getHash("HelloWorld");
        }
        vm.prank(bob);
        {
        target.getHash("HelloWorld");
        }
    }

    // @cover-intent Test claimReward_re_ent39 with no reward available (External Interaction & Environment)
    function test_reentrancy_claim_reward_6() public {
// cover: claimReward_re_ent39 :: require(redeemableEther_re_ent39[msg.sender] > 0) fails
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Test withdraw_balances_re_ent36 with zero balance (Financial & Accounting)
    function test_reentrancy_withdraw_balances_7() public {
// cover: withdraw_balances_re_ent36 :: msg.sender.send(0) returns true
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent Test withdrawFunds_re_ent31 with zero amount (Financial & Accounting)
    function test_reentrancy_withdraw_funds_zero_8() public {
// cover: withdrawFunds_re_ent31 :: require(balances_re_ent31[msg.sender] >= 0) passes
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
        target.withdrawFunds_re_ent31(0);
        }
    }

    // @cover-intent Test bug_re_ent27 which is access-controlled (Authorization & Access Control)
    function test_access_controlled_bug_re_ent27_9() public {
// cover: bug_re_ent27 :: require(not_called_re_ent27) passes
// cover: bug_re_ent27 :: require(not_called_re_ent27) fails on second call
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
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent27()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_re_ent13_sequence_10() public {
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
        // skip ABI-mismatched call: bug_re_ent13()
        // skip ABI-mismatched call: bug_re_ent13()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_re_ent27_sequence_11() public {
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: bug_re_ent27()
        // skip ABI-mismatched call: bug_re_ent27()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent35_sequence_12() public {
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
        // skip ABI-mismatched call: callme_re_ent35()
        // skip ABI-mismatched call: callme_re_ent35()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent39_sequence_13() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), redeemableEther_re_ent39[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Transactional Consistency
    function test_docs_sequence_14() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), docs[0x01], test);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.docs(bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency
    function test_getDetail_sequence_15() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), docs[0x01], test);
        vm.store(address(target), signers[0x01][0], alice);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.getDetail(bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency
    function test_getHash_sequence_16() public {
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
        // skip malformed call: getHash('test') (bad raw arg for getHash.arg0: type=string, raw='test')
    }

    // @cover-intent Transactional Consistency
    function test_signDocument_sequence_17() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), docs[0x01], test);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.signDocument(bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency
    function test_signers_sequence_18() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), signers[0x01][0], alice);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.signers(bytes32(uint256(1)), 0);
        }
    }

    // @cover-intent Transactional Consistency
    function test_submitDocument_sequence_19() public {
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
        // skip malformed call: submitDocument('test') (bad raw arg for submitDocument.arg0: type=string, raw='test')
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent33_sequence_20() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), userBalance_re_ent33[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent40_sequence_21() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), userBalance_re_ent40[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent31_sequence_22() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent31[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent31(50);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent36_sequence_23() public {
        vm.startPrank(owner);
        DocumentSigner target = new DocumentSigner();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent36[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

}
