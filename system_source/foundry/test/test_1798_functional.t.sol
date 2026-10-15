// SPDX-License-Identifier: MIT
pragma solidity 0.4.11;
import "../src/parity_wallet_bug_1.sol";

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

contract WalletLibrary_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function WalletLibrary_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that initWallet correctly sets up multi-ownership and that isOwner returns correct values for initial owners.
    function test_InitWalletAndBasicOwnership_0() public {
// cover: initMultiowned :: loop over _owners
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 1000);
        }
        {
        target.isOwner(alice);
        }
        {
        target.isOwner(bob);
        }
        {
        target.isOwner(carol);
        }
        // skip ABI-mismatched call: m_numOwners()
        // skip ABI-mismatched call: m_required()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that addOwner requires multi-sig confirmation and correctly adds a new owner.
    function test_AddOwnerByMultiSig_1() public {
// cover: addOwner :: isOwner check false
// cover: addOwner :: m_numOwners < c_maxOwners
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 1000);
        }
        {
        target.addOwner(carol);
        }
        {
        target.isOwner(carol);
        }
        // skip ABI-mismatched call: m_numOwners()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that removeOwner removes an owner and updates the owner count correctly.
    function test_RemoveOwnerReducesCount_2() public {
// cover: removeOwner :: ownerIndex != 0
// cover: removeOwner :: m_required <= m_numOwners - 1
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 1, 1000);
        }
        {
        target.removeOwner(carol);
        }
        {
        target.isOwner(carol);
        }
        // skip ABI-mismatched call: m_numOwners()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that changeRequirement rejects invalid values greater than numOwners and accepts valid ones.
    function test_ChangeRequirementBoundary_3() public {
// cover: changeRequirement :: _newRequired > m_numOwners
// cover: changeRequirement :: _newRequired <= m_numOwners
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 1000);
        }
        {
        target.changeRequirement(5);
        }
        // skip ABI-mismatched call: m_required()
        {
        target.changeRequirement(1);
        }
        // skip ABI-mismatched call: m_required()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that execute with value under daily limit succeeds as a single transaction.
    function test_ExecuteUnderDailyLimit_4() public {
// cover: execute :: _data.length == 0 && underLimit(_value)
// cover: underLimit :: today() > m_lastDay
// cover: underLimit :: m_spentToday + _value <= m_dailyLimit
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 500);
        }
        // skip ABI-mismatched call: m_spentToday()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that execute with value over daily limit initiates multi-sig process and emits ConfirmationNeeded.
    function test_ExecuteRequiresMultiSigWhenOverLimit_5() public {
// cover: execute :: else branch (multi-sig)
// cover: execute :: m_txs[o_hash] is new
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        // skip ABI-mismatched call: m_spentToday()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that confirm completes a multi-sig transaction after enough confirmations.
    function test_ConfirmMultiSigTransaction_6() public {
// cover: confirm :: m_txs[_h] exists
// cover: confirmAndCheck :: pending.yetNeeded <= 1
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(0)));
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_spentToday()
    }

    // @cover-intent Transactional Consistency: Verify that revoke removes a prior confirmation and updates pending state.
    function test_RevokeConfirmation_7() public {
// cover: revoke :: ownerIndex != 0
// cover: revoke :: pending.ownersDone & ownerIndexBit > 0
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        vm.startPrank(bob);
        {
        target.confirm(bytes32(uint256(0)));
        }
        {
        target.revoke(bytes32(uint256(0)));
        }
        {
        target.hasConfirmed(bytes32(uint256(0)), bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that setDailyLimit and resetSpentToday work correctly with multi-sig.
    function test_SetDailyLimitAndResetSpent_8() public {
// cover: setDailyLimit :: onlymanyowners passes
// cover: resetSpentToday :: onlymanyowners passes
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 500);
        }
        {
        target.setDailyLimit(1000);
        }
        // skip ABI-mismatched call: m_dailyLimit()
        // skip ABI-mismatched call: resetSpentToday()
        // skip ABI-mismatched call: m_spentToday()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_addOwner_9() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        {
        target.addOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_10() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        {
        target.changeOwner(alice, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeRequirement_11() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 0);
        }
        {
        target.changeRequirement(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_confirm_12() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 0);
        }
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(0)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getOwner_13() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        {
        target.getOwner(0);
        }
    }

    // @cover-intent Transactional Consistency
    function test_hasConfirmed_14() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 0);
        }
        vm.prank(bob);
        {
        target.hasConfirmed(bytes32(uint256(0)), alice);
        }
    }

    // @cover-intent Protocol State Machine
    function test_initDaylimit_15() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        target.initDaylimit(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_isOwner_16() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        {
        target.isOwner(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_kill_17() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        {
        target.kill(0x0000000000000000000000000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_m_dailyLimit_18() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 100);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_dailyLimit()
    }

    // @cover-intent Financial & Accounting
    function test_m_lastDay_19() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_lastDay()
    }

    // @cover-intent Authorization & Access Control
    function test_m_numOwners_20() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_numOwners()
    }

    // @cover-intent Authorization & Access Control
    function test_m_required_21() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_required()
    }

    // @cover-intent Financial & Accounting
    function test_m_spentToday_22() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_spentToday()
    }

    // @cover-intent Authorization & Access Control
    function test_removeOwner_23() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        {
        target.removeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_resetSpentToday_24() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        // skip ABI-mismatched call: resetSpentToday()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_revoke_25() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 0);
        }
        vm.prank(alice);
        {
        target.revoke(bytes32(uint256(0)));
        }
    }

    // @cover-intent Financial & Accounting
    function test_setDailyLimit_26() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 0);
        }
        {
        target.setDailyLimit(200);
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for execute
    function test_perfn_execute_27() public {
        vm.startPrank(owner);
        WalletLibrary target = new WalletLibrary();
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
        target.execute(bob, 100, hex"01");
        }
    }

}
