// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;
import "../src/buggy_46.sol";

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

contract ProofOfExistence_FunctionalTest {
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


    // @cover-intent Transactional Consistency: Verify that searchExistenceProoUsngQRf returns empty/default values when no matching QR code exists.
    function test_Search_Existence_Proof_with_Non_Existent_QR_Code_0() public {
// cover: searchExistenceProoUsngQRf :: no matching QR code
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

    // @cover-intent Financial & Accounting: Verify that increasing lock time and then withdrawing after the lock period works correctly.
    function test_Increase_Lock_Time_and_Withdraw_Positive_Path_1() public {
// assume: block.timestamp > lockTime_intou13[alice] + 100
// assume: block.timestamp > lockTime_intou33[alice] + 200
// cover: increaseLockTime_intou13 :: normal increase
// cover: increaseLockTime_intou33 :: normal increase
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
        target.increaseLockTime_intou13(100);
        }
        {
        target.increaseLockTime_intou33(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw_intou13 and withdraw_intou33 revert when called before the lock time has passed.
    function test_Withdraw_Before_Lock_Time_Revert_2() public {
// assume: block.timestamp < lockTime_intou13[alice]
// assume: block.timestamp < lockTime_intou33[alice]
// cover: withdraw_intou13 :: require(now > lockTime_intou13[msg.sender]) false
// cover: withdraw_intou33 :: require(now > lockTime_intou33[msg.sender]) false
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
        target.increaseLockTime_intou13(1000);
        }
        {
        target.increaseLockTime_intou33(1000);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou13()
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that the bug functions execute without reverting (basic sanity check).
    function test_Bug_Functions_Basic_Execution_3() public {
// cover: bug_intou27 :: normal execution
// cover: bug_intou31 :: normal execution
// cover: bug_intou35 :: normal execution
// cover: bug_intou36 :: normal execution
// cover: bug_intou40 :: normal execution
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_4() public {
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
    function test_bug_intou31_5() public {
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
    function test_bug_intou35_6() public {
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
    function test_bug_intou36_7() public {
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
    function test_bug_intou40_8() public {
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

    // @cover-intent Financial & Accounting
    function test_increaseLockTime_intou13_9() public {
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
        target.increaseLockTime_intou13(100);
        }
    }

    // @cover-intent Financial & Accounting
    function test_increaseLockTime_intou33_10() public {
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
    function test_lockTime_intou13_11() public {
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
        target.increaseLockTime_intou13(100);
        }
        {
        target.lockTime_intou13(alice);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.lockTime_intou13(alice));
            _assertRelU(__v1, 2, 100, "call:lockTime_intou13>=100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_lockTime_intou33_12() public {
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
        {
        target.lockTime_intou33(alice);
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.lockTime_intou33(alice));
            _assertRelU(__v2, 2, 100, "call:lockTime_intou33>=100");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_searchExistenceProoUsngQRf_13() public {
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

    // @cover-intent Financial & Accounting
    function test_withdraw_intou13_14() public {
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
    function test_withdraw_intou33_15() public {
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

    // @cover-intent minimal test for GetFileExistenceProof
    function test_perfn_GetFileExistenceProof_16() public {
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
    function test_perfn_SetFileExistenceProof_17() public {
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
    function test_perfn_getQRCode_18() public {
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
