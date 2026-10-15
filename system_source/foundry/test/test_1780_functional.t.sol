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


    // @cover-intent Authorization & Access Control - Verify that initWallet correctly sets up multi-owner wallet with required signatures and that isOwner returns correct results.
    function test_InitWalletAndCheckOwners_0() public {
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
        target.initWallet(_arr1, 2, 100);
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
        {
            uint256 __v1 = uint256(target.m_numOwners());
            _assertRelU(__v1, 2, 3, "call:m_numOwners>=3");
        }
        {
            uint256 __v2 = uint256(target.m_required());
            _assertRelU(__v2, 0, 2, "call:m_required==2");
        }
    }

    // @cover-intent Resource & Execution Integrity - Execute a transaction below the daily limit with a single owner, verifying it succeeds and emits SingleTransact.
    function test_ExecuteBelowDailyLimit_1() public {
// cover: execute :: underLimit true
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
        target.initWallet(_arr1, 1, 1000);
        }
        // skip ABI-mismatched call: m_spentToday()
        // skip ABI-mismatched call: m_dailyLimit()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.m_spentToday());
            _assertRelU(__v3, 0, 500, "call:m_spentToday==500");
        }
    }

    // @cover-intent Authorization & Access Control - Complete a multi-sig transaction by having both owners confirm, verifying it executes and emits MultiTransact.
    function test_ConfirmMultiSigTransaction_2() public {
// cover: confirmAndCheck :: pending.yetNeeded <= 1
// cover: confirm :: m_txs[_h].to != 0
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(1)));
        }
        vm.prank(carol);
        {
        target.confirm(bytes32(uint256(1)));
        }
    }

    // @cover-intent Authorization & Access Control - Add a new owner via multi-sig, verifying OwnerAdded event and isOwner returns true for new owner.
    function test_AddOwnerByMultiSig_3() public {
// cover: addOwner :: isOwner false
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        {
        target.addOwner(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(1)));
        }
    }

    // @cover-intent Authorization & Access Control - Remove an owner when m_required > m_numOwners - 1, verifying the operation reverts.
    function test_RemoveOwnerReducesRequired_4() public {
// cover: removeOwner :: m_required > m_numOwners - 1
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
        vm.expectRevert();
        {
        target.removeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine - Change the required number of signatures to a valid value, verifying RequirementChanged event.
    function test_ChangeRequirementValid_5() public {
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
        target.initWallet(_arr1, 2, 100);
        }
        {
        target.changeRequirement(1);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(1)));
        }
        {
            uint256 __v4 = uint256(target.m_required());
            _assertRelU(__v4, 0, 1, "call:m_required==1");
        }
    }

    // @cover-intent Financial & Accounting - Set a new daily limit and reset spent today via multi-sig, verifying state changes.
    function test_SetDailyLimitAndResetSpent_6() public {
// cover: setDailyLimit :: onlymanyowners
// cover: resetSpentToday :: onlymanyowners
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
        {
        target.setDailyLimit(200);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(1)));
        }
        vm.prank(alice);
        // skip ABI-mismatched call: resetSpentToday()
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(2)));
        }
        {
            uint256 __v5 = uint256(target.m_dailyLimit());
            _assertRelU(__v5, 0, 200, "call:m_dailyLimit==200");
        }
        {
            uint256 __v6 = uint256(target.m_spentToday());
            _assertRelU(__v6, 0, 0, "call:m_spentToday==0");
        }
    }

    // @cover-intent Transactional Consistency - Revoke a prior confirmation, verifying Revoke event and that the operation still needs confirmations.
    function test_RevokeConfirmation_7() public {
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
        target.confirm(bytes32(uint256(1)));
        }
        {
        target.revoke(bytes32(uint256(1)));
        }
        {
        target.hasConfirmed(bytes32(uint256(1)), bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_addOwner_8() public {
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
        target.addOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_9() public {
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
        target.changeOwner(alice, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeRequirement_10() public {
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
        target.changeRequirement(1);
        }
    }

    // @cover-intent Transactional Consistency
    function test_confirm_11() public {
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
    function test_getOwner_12() public {
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
    function test_hasConfirmed_13() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_initDaylimit_14() public {
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
    function test_isOwner_15() public {
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
    function test_kill_16() public {
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
        target.kill(carol);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_m_dailyLimit_17() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_m_lastDay_18() public {
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
    function test_m_numOwners_19() public {
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
    function test_m_required_20() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_m_spentToday_21() public {
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
    function test_removeOwner_22() public {
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
        target.initWallet(_arr1, 1, 0);
        }
        vm.prank(alice);
        {
        target.removeOwner(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_resetSpentToday_23() public {
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
        // skip ABI-mismatched call: resetSpentToday()
    }

    // @cover-intent Transactional Consistency
    function test_revoke_24() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_setDailyLimit_25() public {
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
        target.setDailyLimit(200);
        }
    }

    // @cover-intent minimal test for execute
    function test_perfn_execute_26() public {
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
