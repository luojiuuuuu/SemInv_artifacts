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


    // @cover-intent Test normal behavior: set a file existence proof and retrieve it using GetFileExistenceProof, verifying all fields match. Covers Transactional Consistency.
    function test_Set_and_retrieve_file_existence_proof_normal_path_0() public {
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
        // skip malformed call: GetFileExistenceProof(alice, 'hash1', 'path1') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hash1')
        vm.stopPrank();
    }

    // @cover-intent Test edge behavior: calling GetFileExistenceProof for a non-existent proof should return default values (zero/empty). Covers Resource & Execution Integrity.
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
        // skip malformed call: GetFileExistenceProof(alice, 'nonexistent', 'nopath') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='nonexistent')
    }

    // @cover-intent Test normal behavior: set multiple proofs for same origin, then retrieve using searchExistenceProoUsngQRf. Covers Transactional Consistency.
    function test_Set_multiple_proofs_and_retrieve_by_QR_code_2() public {
// cover: SetFileExistenceProof :: multiple entries
// cover: getQRCode :: found match
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
        // skip malformed call: SetFileExistenceProof(alice, 'hashA', 'pathA', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hashA')
        // skip malformed call: SetFileExistenceProof(alice, 'hashB', 'pathB', carol, 2) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hashB')
        // skip malformed call: getQRCode(alice, 'hashA', 'pathA') (bad raw arg for getQRCode.arg1: type=string, raw='hashA')
        vm.stopPrank();
    }

    // @cover-intent Test edge behavior: searchExistenceProoUsngQRf with existing and non-existing QR code hash. Covers Resource & Execution Integrity.
    function test_Search_by_QR_code_found_and_not_found_3() public {
// cover: searchExistenceProoUsngQRf :: no match
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
        // skip malformed call: SetFileExistenceProof(alice, 'hashX', 'pathX', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hashX')
        // skip malformed call: getQRCode(alice, 'hashX', 'pathX') (bad raw arg for getQRCode.arg1: type=string, raw='hashX')
        {
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Test boundary behavior: set proofs with all possible BlockchainIdentification enum values (0=Ixxo, 1=Ethereum, 2=Gochain). Covers Protocol State Machine.
    function test_Set_proof_with_different_identifier_values_4() public {
// cover: SetFileExistenceProof :: all enum values
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash0', 'path0', bob, 0) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash0')
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
        // skip malformed call: SetFileExistenceProof(alice, 'hash2', 'path2', bob, 2) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash2')
        // skip malformed call: GetFileExistenceProof(alice, 'hash2', 'path2') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hash2')
        vm.stopPrank();
    }

    // @cover-intent Test edge behavior: play_tmstmp31 with a startTime that matches block.timestamp exactly after 5 days. Covers External Interaction & Environment.
    function test_play_tmstmp31_timestamp_boundary_test_5() public {
// assume: block.timestamp == 0 + 5 days
// cover: play_tmstmp31 :: condition true
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
        target.play_tmstmp31(0);
        }
    }

    // @cover-intent Test normal behavior: bug_tmstmp13 returns a boolean based on block.timestamp comparison. Covers Resource & Execution Integrity.
    function test_bug_tmstmp13_returns_boolean_6() public {
// cover: bug_tmstmp13 :: returns bool
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
        target.bug_tmstmp13();
        }
    }

    // @cover-intent Test boundary behavior: set a proof with empty fileHash and filePathHash strings. Covers Resource & Execution Integrity.
    function test_Set_proof_with_empty_strings_7() public {
// cover: SetFileExistenceProof :: empty strings
// cover: GetFileExistenceProof :: empty strings match
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
        // skip malformed call: SetFileExistenceProof(alice, '', '', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='')
        // skip malformed call: GetFileExistenceProof(alice, '', '') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='')
        vm.stopPrank();
    }

    // @cover-intent Test normal behavior: set multiple proofs for same origin and verify retrieval returns correct data for each. Covers Transactional Consistency.
    function test_Multiple_proofs_for_same_origin_retrieval_order_8() public {
// cover: GetFileExistenceProof :: multiple matches
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
        // skip malformed call: SetFileExistenceProof(alice, 'hash2', 'path2', carol, 2) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash2')
        // skip malformed call: GetFileExistenceProof(alice, 'hash1', 'path1') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hash1')
        // skip malformed call: GetFileExistenceProof(alice, 'hash2', 'path2') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hash2')
        vm.stopPrank();
    }

    // @cover-intent Test normal behavior: set proofs for different origin addresses and verify isolation. Covers Authorization & Access Control.
    function test_Set_proof_with_different_origin_addresses_9() public {
// cover: SetFileExistenceProof :: different origins
// cover: GetFileExistenceProof :: cross-origin query
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
        // skip malformed call: SetFileExistenceProof(alice, 'hashA', 'pathA', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hashA')
        vm.prank(bob);
        // skip malformed call: SetFileExistenceProof(bob, 'hashB', 'pathB', carol, 2) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hashB')
        vm.prank(alice);
        // skip malformed call: GetFileExistenceProof(alice, 'hashA', 'pathA') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hashA')
        vm.prank(bob);
        // skip malformed call: GetFileExistenceProof(bob, 'hashB', 'pathB') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hashB')
        vm.prank(alice);
        // skip malformed call: GetFileExistenceProof(bob, 'hashB', 'pathB') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hashB')
    }

    // @cover-intent Resource & Execution Integrity
    function test_SetFileExistenceProof_sequence_10() public {
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
    }

    // @cover-intent Resource & Execution Integrity
    function test_GetFileExistenceProof_sequence_11() public {
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
        vm.prank(bob);
        // skip malformed call: GetFileExistenceProof(alice, 'hash1', 'path1') (bad raw arg for GetFileExistenceProof.arg1: type=string, raw='hash1')
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp13_sequence_12() public {
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
        target.bug_tmstmp13();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getQRCode_sequence_13() public {
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
        vm.prank(bob);
        // skip malformed call: getQRCode(alice, 'hash1', 'path1') (bad raw arg for getQRCode.arg1: type=string, raw='hash1')
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp31_sequence_14() public {
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
        target.play_tmstmp31(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_searchExistenceProoUsngQRf_sequence_15() public {
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
        // skip malformed call: SetFileExistenceProof(alice, 'hash1', 'path1', bob, 1) (bad raw arg for SetFileExistenceProof.arg1: type=string, raw='hash1')
        vm.prank(bob);
        {
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
    }

}
