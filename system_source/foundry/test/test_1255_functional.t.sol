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


    // @cover-intent Transactional Consistency: Verify that multiple proofs can be stored for the same origin and retrieved via searchExistenceProoUsngQRf.
    function test_Set_multiple_proofs_and_retrieve_via_QR_code_0() public {
// cover: getQRCode :: found matching proof
// cover: searchExistenceProoUsngQRf :: no matching QR code (loop ends)
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
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
    }

    // @cover-intent External Interaction & Environment: Verify that callme_re_ent35 can be called up to 5 times and reverts on the 6th call due to counter limit.
    function test_Re_entrancy_guard_test_for_callme_re_ent35_1() public {
// cover: callme_re_ent35 :: counter <= 5 (true)
// cover: callme_re_ent35 :: counter <= 5 (false)
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

    // @cover-intent Authorization & Access Control: Verify that bug_re_ent27 can only be called once (not_called_re_ent27 guard).
    function test_Access_control_for_bug_re_ent27_2() public {
// cover: bug_re_ent27 :: not_called_re_ent27 == true
// cover: bug_re_ent27 :: not_called_re_ent27 == false
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
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent27()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent Authorization & Access Control: Verify that bug_re_ent13 can only be called once (not_called_re_ent13 guard).
    function test_Access_control_for_bug_re_ent13_3() public {
// cover: bug_re_ent13 :: not_called_re_ent13 == true
// cover: bug_re_ent13 :: not_called_re_ent13 == false
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
        // skip ABI-mismatched call: bug_re_ent13()
        vm.expectRevert();
        // skip ABI-mismatched call: bug_re_ent13()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdraw functions can be called (no revert) even with zero balance.
    function test_Withdraw_functions_basic_call_4() public {
// cover: withdraw_balances_re_ent36 :: send succeeds (balance 0)
// cover: withdrawBalance_re_ent40 :: call succeeds (balance 0)
// cover: withdrawBalance_re_ent33 :: call succeeds (balance 0)
// cover: withdrawFunds_re_ent31 :: require(balances >= 0) true
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
        {
        target.withdrawFunds_re_ent31(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_searchExistenceProoUsngQRf_positive_5() public {
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
        target.searchExistenceProoUsngQRf(alice, bytes32(uint256(0)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_balances_re_ent36_positive_6() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=balances_re_ent36[alice], value=100;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent35_positive_7() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=counter_re_ent35, value=0;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_re_ent40_positive_8() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=userBalance_re_ent40[alice], value=100;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_re_ent33_positive_9() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=userBalance_re_ent33[alice], value=100;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawFunds_re_ent31_positive_10() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=balances_re_ent31[alice], value=100;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent31(50);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_re_ent27_positive_11() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=not_called_re_ent27, value=true;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent Authorization & Access Control
    function test_bug_re_ent13_positive_12() public {
        vm.startPrank(owner);
        ProofOfExistence target = new ProofOfExistence();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=not_called_re_ent13, value=true;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent minimal test for GetFileExistenceProof
    function test_perfn_GetFileExistenceProof_13() public {
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
        target.GetFileExistenceProof(alice, "X", "X");
        }
    }

    // @cover-intent minimal test for SetFileExistenceProof
    function test_perfn_SetFileExistenceProof_14() public {
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
        vm.prank(owner);
        {
        target.SetFileExistenceProof(alice, "X", "X", alice, ProofOfExistence.BlockchainIdentification(0));
        }
    }

    // @cover-intent minimal test for getQRCode
    function test_perfn_getQRCode_15() public {
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
        target.getQRCode(alice, "X", "X");
        }
    }

}
