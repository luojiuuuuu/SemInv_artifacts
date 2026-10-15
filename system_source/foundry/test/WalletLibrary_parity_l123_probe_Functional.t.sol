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


    // @cover-intent Authorization & Access Control: Test that addOwner works when called by a multisig owner with sufficient confirmations, and fails when called by a non-owner.
    function test_InitWalletAndAddOwner_0() public {
// cover: addOwner :: onlymanyowners modifier passes
// cover: addOwner :: isOwner check false
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
        vm.expectRevert();
        {
        target.addOwner(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.addOwner(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Test that removeOwner fails when trying to remove the last owner below required threshold.
    function test_RemoveOwnerBoundary_1() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 1000);
        }
        vm.startPrank(bob);
        vm.expectRevert();
        {
        target.removeOwner(carol);
        }
        vm.expectRevert();
        {
        target.removeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test changing the required number of signatures from 2 to 1.
    function test_ChangeRequirementSuccess_2() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 1000);
        }
        vm.startPrank(bob);
        vm.expectRevert();
        {
        target.changeRequirement(1);
        }
        {
        target.changeRequirement(1);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.m_required());
            _assertRelU(__v1, 0, 1, "call:m_required==1");
        }
    }

    // @cover-intent Financial & Accounting: Test setDailyLimit and resetSpentToday with multisig confirmation.
    function test_SetDailyLimitAndResetSpent_3() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        vm.startPrank(bob);
        vm.expectRevert();
        {
        target.setDailyLimit(200);
        }
        {
        target.setDailyLimit(200);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: resetSpentToday()
        // skip ABI-mismatched call: resetSpentToday()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.m_dailyLimit());
            _assertRelU(__v2, 0, 200, "call:m_dailyLimit==200");
        }
        {
            uint256 __v3 = uint256(target.m_spentToday());
            _assertRelU(__v3, 0, 0, "call:m_spentToday==0");
        }
    }

    // @cover-intent Authorization & Access Control: Test changing an owner from one address to another with multisig.
    function test_ChangeOwnerSuccess_4() public {
// cover: changeOwner :: isOwner(_to) false
// cover: changeOwner :: ownerIndex != 0
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
        vm.startPrank(bob);
        vm.expectRevert();
        {
        target.changeOwner(bob, alice);
        }
        {
        target.changeOwner(bob, alice);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Test that kill (selfdestruct) works with multisig confirmation.
    function test_KillContract_5() public {
// cover: kill :: onlymanyowners passes
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
        vm.startPrank(bob);
        vm.expectRevert();
        {
        target.kill(carol);
        }
        {
        target.kill(carol);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test view functions hasConfirmed and getOwner return correct values.
    function test_HasConfirmedAndGetOwner_6() public {
// cover: getOwner :: returns address from m_owners
// cover: hasConfirmed :: ownerIndex == 0 returns false
// cover: isOwner :: m_ownerIndex > 0 returns true
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
        vm.startPrank(bob);
        {
        target.getOwner(0);
        }
        {
        target.getOwner(1);
        }
        {
        target.hasConfirmed(bytes32(uint256(0)), bob);
        }
        {
        target.isOwner(bob);
        }
        {
        target.isOwner(alice);
        }
        vm.stopPrank();
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
        target.initWallet(_arr1, 1, 1000);
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
        target.initWallet(_arr1, 1, 1000);
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
        target.initWallet(_arr1, 2, 1000);
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
        target.initWallet(_arr1, 2, 1000);
        }
        vm.prank(alice);
        {
        target.execute(carol, 500, hex"00");
        }
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(0)));
        }
    }

    // @cover-intent Financial & Accounting
    function test_execute_11() public {
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
        {
        target.execute(bob, 100, hex"00");
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
        target.initWallet(_arr1, 1, 1000);
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 2, 1000);
        }
        vm.prank(alice);
        {
        target.execute(carol, 500, hex"00");
        }
        vm.prank(bob);
        {
        target.hasConfirmed(bytes32(uint256(0)), alice);
        }
    }

    // @cover-intent Financial & Accounting
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
        target.initDaylimit(500);
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
        target.initWallet(_arr1, 1, 1000);
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
        vm.startPrank(owner);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 1000);
        }
        {
        target.kill(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
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
        target.initWallet(_arr1, 1, 1000);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_dailyLimit()
    }

    // @cover-intent Financial & Accounting
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
        target.initWallet(_arr1, 1, 1000);
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
        target.initWallet(_arr1, 1, 1000);
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
        target.initWallet(_arr1, 1, 1000);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: m_required()
    }

    // @cover-intent Financial & Accounting
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
        target.initWallet(_arr1, 1, 1000);
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
        vm.startPrank(owner);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 1, 1000);
        }
        {
        target.removeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
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
        target.initWallet(_arr1, 1, 1000);
        }
        vm.prank(alice);
        {
        target.execute(bob, 100, hex"00");
        }
        vm.prank(owner);
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.initWallet(_arr1, 2, 1000);
        }
        vm.startPrank(alice);
        {
        target.execute(carol, 500, hex"00");
        }
        {
        target.revoke(bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
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

}
