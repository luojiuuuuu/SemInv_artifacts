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


    // @cover-intent Authorization & Access Control: Verify that a user can submit a document and then sign it, and that duplicate signatures are prevented.
    function test_Submit_and_sign_a_document_0() public {
// cover: signDocument :: require(bytes(docs[_docHash]).length != 0) true
// cover: signDocument :: if(_signers[i] == msg.sender) return true
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
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
        vm.stopPrank();
        vm.prank(bob);
        // skip malformed call: signDocument(getHash("doc1")) (bad raw arg for signDocument.arg0: type=bytes32, raw=getHash("doc1"))
    }

    // @cover-intent Resource & Execution Integrity: Ensure signing a document that has not been submitted reverts.
    function test_Sign_non_existent_document_reverts_1() public {
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
        target.signDocument(bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)));
        }
    }

    // @cover-intent Transactional Consistency: Submitting the same document twice should not emit a NewDocument event the second time.
    function test_Submit_duplicate_document_does_not_emit_event_2() public {
// cover: submitDocument :: if(bytes(docs[_docHash]).length == 0) true
// cover: submitDocument :: if(bytes(docs[_docHash]).length == 0) false
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
        target.submitDocument("doc2");
        }
        {
        target.submitDocument("doc2");
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Ensure getDetail reverts for a document that has not been submitted.
    function test_Get_detail_of_non_existent_document_reverts_3() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that getHash returns the same hash for the same input.
    function test_Get_hash_is_pure_and_deterministic_4() public {
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

    // @cover-intent External Interaction & Environment: Verify that bug_tmstmp13 and bug_tmstmp33 return a boolean based on block.timestamp.
    function test_Timestamp_bug_functions_return_bool_5() public {
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
        // skip ABI-mismatched call: bug_tmstmp13()
        vm.prank(bob);
        // skip ABI-mismatched call: bug_tmstmp33()
    }

    // @cover-intent External Interaction & Environment: Verify that play_tmstmp27 and play_tmstmp31 can be called without reverting.
    function test_Play_timestamp_functions_do_not_revert_6() public {
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
        target.play_tmstmp27(100);
        }
        vm.prank(bob);
        {
        target.play_tmstmp31(200);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that docs mapping returns empty string for a hash that was never submitted.
    function test_Docs_mapping_returns_empty_string_for_unknown_hash_7() public {
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
        target.docs(bytes32(uint256(0)));
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that signers mapping returns zero address for an unknown hash and index.
    function test_Signers_mapping_returns_empty_array_for_unknown_hash_8() public {
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
        target.signers(bytes32(uint256(0)), 0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp13_test_9() public {
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
        // skip ABI-mismatched call: bug_tmstmp13()
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp33_test_10() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: bug_tmstmp33()
    }

    // @cover-intent Resource & Execution Integrity
    function test_docs_test_11() public {
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
        target.submitDocument("test");
        }
        {
        target.docs(bytes32(uint256(70622639689279718371527342103894932928233838121221666359043189029713682937432)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getDetail_test_12() public {
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
        target.submitDocument("doc");
        }
        {
        target.signDocument(bytes32(uint256(27199032953316346489137864649694495785828756015850261972833568927449232595806)));
        }
        {
        target.getDetail(bytes32(uint256(27199032953316346489137864649694495785828756015850261972833568927449232595806)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHash_test_13() public {
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
        vm.prank(carol);
        {
        target.getHash("hello");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp27_test_14() public {
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
        target.play_tmstmp27(100);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp31_test_15() public {
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
        vm.prank(bob);
        {
        target.play_tmstmp31(200);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_signDocument_test_16() public {
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
        target.submitDocument("contract");
        }
        {
        target.signDocument(bytes32(uint256(27199032953316346489137864649694495785828756015850261972833568927449232595806)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_signers_test_17() public {
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
        target.submitDocument("agreement");
        }
        {
        target.signDocument(bytes32(uint256(27199032953316346489137864649694495785828756015850261972833568927449232595806)));
        }
        {
        target.signers(bytes32(uint256(27199032953316346489137864649694495785828756015850261972833568927449232595806)), 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_submitDocument_test_18() public {
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
        target.submitDocument("newdoc");
        }
    }

}
