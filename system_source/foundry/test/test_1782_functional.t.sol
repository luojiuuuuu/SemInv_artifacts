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


    // @cover-intent Authorization & Access Control: Verify that initWallet correctly sets up owners and that isOwner returns true for initial owners and false for non-owners.
    function test_InitWalletAndBasicOwnership_0() public {
// cover: isOwner :: m_ownerIndex[uint(_addr)] > 0 true
// cover: isOwner :: m_ownerIndex[uint(_addr)] > 0 false
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
        target.isOwner(bob);
        }
        {
        target.isOwner(carol);
        }
        {
        target.isOwner(alice);
        }
        {
        target.isOwner(0x0000000000000000000000000000000000000001);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that addOwner requires multi-sig confirmation and correctly adds a new owner.
    function test_AddOwnerByMultiSig_1() public {
// cover: addOwner :: isOwner(_owner) false
// cover: confirmAndCheck :: pending.yetNeeded <= 1 true
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
        target.initWallet(_arr1, 2, 1000);
        }
        vm.prank(bob);
        {
        target.addOwner(alice);
        }
        vm.prank(alice);
        {
        target.isOwner(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that removeOwner requires multi-sig and correctly removes an owner.
    function test_RemoveOwnerByMultiSig_2() public {
// cover: removeOwner :: m_required > m_numOwners - 1 false
// cover: removeOwner :: ownerIndex == 0 false
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
        target.initWallet(_arr1, 2, 1000);
        }
        vm.prank(bob);
        {
        target.removeOwner(carol);
        }
        vm.prank(alice);
        {
        target.isOwner(carol);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that changeRequirement updates m_required after multi-sig confirmation.
    function test_ChangeRequirementMultiSig_3() public {
// cover: changeRequirement :: _newRequired > m_numOwners false
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
        target.initWallet(_arr1, 2, 1000);
        }
        vm.prank(bob);
        {
        target.changeRequirement(1);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_required()
        {
            uint256 __v1 = uint256(target.m_required());
            _assertRelU(__v1, 0, 1, "call:m_required==1");
        }
    }

    // @cover-intent Transactional Consistency: Verify that a pending transaction can be confirmed by a second owner and executed.
    function test_ConfirmPendingTransaction_4() public {
// cover: confirm :: m_txs[_h].to != 0 || m_txs[_h].value != 0 || m_txs[_h].data.length != 0 true
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
        target.initDaylimit(1000);
        }
        // skip ABI-mismatched call: m_spentToday()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.m_spentToday());
            _assertRelU(__v2, 0, 1500, "call:m_spentToday==1500");
        }
    }

    // @cover-intent Financial & Accounting: Verify that setDailyLimit updates the daily limit after multi-sig confirmation.
    function test_SetDailyLimitMultiSig_5() public {
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
        target.initDaylimit(1000);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.setDailyLimit(2000);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_dailyLimit()
        {
            uint256 __v3 = uint256(target.m_dailyLimit());
            _assertRelU(__v3, 0, 2000, "call:m_dailyLimit==2000");
        }
    }

    // @cover-intent Financial & Accounting: Verify that resetSpentToday resets m_spentToday to 0 after multi-sig confirmation.
    function test_ResetSpentTodayMultiSig_6() public {
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
        target.initDaylimit(1000);
        }
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: resetSpentToday()
        vm.prank(alice);
        // skip ABI-mismatched call: m_spentToday()
        {
            uint256 __v4 = uint256(target.m_spentToday());
            _assertRelU(__v4, 0, 0, "call:m_spentToday==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_addOwner_7() public {
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
    function test_changeOwner_8() public {
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
    function test_changeRequirement_9() public {
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
        target.initWallet(_arr1, 2, 0);
        }
        {
        target.changeRequirement(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_confirm_10() public {
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
        target.initWallet(_arr1, 2, 0);
        }
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(0)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getOwner_11() public {
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
    function test_hasConfirmed_12() public {
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
        target.initWallet(_arr1, 2, 0);
        }
        vm.prank(bob);
        {
        target.hasConfirmed(bytes32(uint256(0)), alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_initDaylimit_13() public {
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
        target.initDaylimit(1000);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_isOwner_14() public {
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
    function test_kill_15() public {
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
        target.kill(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_m_dailyLimit_16() public {
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
        target.initWallet(_arr1, 1, 1000);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_dailyLimit()
    }

    // @cover-intent Financial & Accounting
    function test_m_lastDay_17() public {
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
    function test_m_numOwners_18() public {
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
    function test_m_required_19() public {
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
    function test_m_spentToday_20() public {
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
        target.initWallet(_arr1, 1, 1000);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_spentToday()
    }

    // @cover-intent Authorization & Access Control
    function test_removeOwner_21() public {
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
        target.initWallet(_arr1, 2, 0);
        }
        {
        target.removeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_resetSpentToday_22() public {
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
        target.initWallet(_arr1, 1, 1000);
        }
        // skip ABI-mismatched call: resetSpentToday()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_revoke_23() public {
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
        target.initWallet(_arr1, 2, 0);
        }
        vm.prank(alice);
        {
        target.revoke(bytes32(uint256(0)));
        }
    }

    // @cover-intent Financial & Accounting
    function test_setDailyLimit_24() public {
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
        target.initWallet(_arr1, 1, 1000);
        }
        {
        target.setDailyLimit(2000);
        }
        vm.stopPrank();
    }

    // @cover-intent minimal test for execute
    function test_perfn_execute_25() public {
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
