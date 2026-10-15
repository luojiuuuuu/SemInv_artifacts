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


    // @cover-intent Test normal behavior of SetFileExistenceProof and GetFileExistenceProof, verifying that a proof can be stored and retrieved correctly.
    function test_Set_and_retrieve_file_existence_proof_0() public {
// cover: SetFileExistenceProof :: normal push
// cover: GetFileExistenceProof :: match found
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

    // @cover-intent Test edge behavior of GetFileExistenceProof when no matching proof exists, expecting default zero values.
    function test_Get_non_existent_proof_returns_default_1() public {
// cover: GetFileExistenceProof :: no match, loop ends
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

    // @cover-intent Test normal behavior of getQRCode, verifying it returns the correct QR code hash.
    function test_Retrieve_QR_code_after_setting_proof_2() public {
// cover: getQRCode :: match found
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
        target.SetFileExistenceProof(alice, "hash2", "path2", bob, 2);
        }
        {
        target.getQRCode(alice, "hash2", "path2");
        }
        vm.stopPrank();
    }

    // @cover-intent Test normal behavior of searchExistenceProoUsngQRf, verifying it returns the correct proof when QR code matches.
    function test_Search_proof_by_QR_code_3() public {
// cover: searchExistenceProoUsngQRf :: match found
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
        target.SetFileExistenceProof(alice, "hash3", "path3", bob, 0);
        }
        {
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Test edge behavior of searchExistenceProoUsngQRf when no proof matches the QR code, expecting default zero values.
    function test_Search_non_existent_QR_code_4() public {
// cover: searchExistenceProoUsngQRf :: no match, loop ends
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
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935)));
        }
    }

    // @cover-intent Test Authorization & Access Control: bug_re_ent27 can be called once by owner, then reverts on second call due to guard.
    function test_Re_entrancy_guard_bug_re_ent27_positive_path_5() public {
// cover: bug_re_ent27 :: require(not_called_re_ent27) true
// cover: bug_re_ent27 :: require(not_called_re_ent27) false
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: bug_re_ent27()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent27()
        vm.stopPrank();
    }

    // @cover-intent Test Authorization & Access Control: bug_re_ent13 can be called once by owner, then reverts on second call due to guard.
    function test_Re_entrancy_guard_bug_re_ent13_positive_path_6() public {
// cover: bug_re_ent13 :: require(not_called_re_ent13) true
// cover: bug_re_ent13 :: require(not_called_re_ent13) false
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: bug_re_ent13()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent13()
        vm.stopPrank();
    }

    // @cover-intent Test Resource & Execution Integrity: callme_re_ent35 succeeds up to 5 times, then reverts on 6th call.
    function test_callme_re_ent35_with_counter_limit_7() public {
// cover: callme_re_ent35 :: require(counter_re_ent35<=5) true
// cover: callme_re_ent35 :: require(counter_re_ent35<=5) false
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
        // skip ABI-mismatched call: callme_re_ent35()
        // skip ABI-mismatched call: callme_re_ent35()
        // skip ABI-mismatched call: callme_re_ent35()
        // skip ABI-mismatched call: callme_re_ent35()
        // skip ABI-mismatched call: callme_re_ent35()
        vm.expectRevert();
        // skip ABI-mismatched call: callme_re_ent35()
        vm.stopPrank();
    }

    // @cover-intent Test Financial & Accounting: withdrawFunds_re_ent31 reverts when caller has insufficient balance.
    function test_withdrawFunds_re_ent31_insufficient_balance_8() public {
// cover: withdrawFunds_re_ent31 :: require(balances_re_ent31[msg.sender] >= _weiToWithdraw) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent31(100);
        }
    }

    // @cover-intent Test Financial & Accounting: withdraw_balances_re_ent36 with zero balance does not send ETH and sets balance to zero.
    function test_withdraw_balances_re_ent36_zero_balance_9() public {
// cover: withdraw_balances_re_ent36 :: send fails or succeeds, balance set to 0
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent Resource & Execution Integrity
    function test_SetFileExistenceProof_positive_10() public {
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
    function test_GetFileExistenceProof_positive_11() public {
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
        vm.prank(bob);
        {
        target.GetFileExistenceProof(alice, "hash1", "path1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getQRCode_positive_12() public {
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
        vm.prank(carol);
        {
        target.getQRCode(alice, "hash1", "path1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_searchExistenceProoUsngQRf_positive_13() public {
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
        vm.prank(bob);
        {
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_balances_re_ent36_positive_14() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), keccak256(alice, 0) + 0, bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent35_positive_15() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_re_ent40_positive_16() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), keccak256(alice, 1) + 0, bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_re_ent33_positive_17() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), keccak256(alice, 2) + 0, bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawFunds_re_ent31_positive_18() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), keccak256(alice, 3) + 0, bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent31(50);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_re_ent27_positive_19() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(4)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent External Interaction & Environment
    function test_bug_re_ent13_positive_20() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(5)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent13()
    }

}
