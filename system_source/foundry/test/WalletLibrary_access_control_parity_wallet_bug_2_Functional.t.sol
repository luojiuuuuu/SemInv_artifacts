// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/parity_wallet_bug_2.sol";

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


    // @cover-intent Authorization & Access Control: Verify that initWallet correctly sets up multi-owner wallet with required confirmations and that isOwner returns correct results.
    function test_init_wallet_and_basic_ownership_0() public {
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
        vm.startPrank(owner);
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
        {
        target.m_numOwners();
        }
        {
        target.m_required();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that addOwner requires multiple confirmations and correctly adds a new owner.
    function test_add_owner_with_multisig_1() public {
// cover: addOwner :: isOwner(_owner) false
// cover: addOwner :: m_numOwners >= c_maxOwners false
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
        target.initWallet(_arr1, 2, 100);
        }
        {
        target.addOwner(bob);
        }
        {
        target.isOwner(bob);
        }
        {
        target.m_numOwners();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that removeOwner requires multiple confirmations and correctly removes an owner, adjusting the owner count.
    function test_remove_owner_with_multisig_2() public {
// cover: removeOwner :: ownerIndex == 0 false
// cover: removeOwner :: m_required > m_numOwners - 1 false
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
        target.initWallet(_arr1, 2, 100);
        }
        {
        target.removeOwner(bob);
        }
        {
        target.isOwner(bob);
        }
        {
        target.m_numOwners();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that changeOwner replaces an existing owner with a new one.
    function test_change_owner_with_multisig_3() public {
// cover: changeOwner :: isOwner(_to) false
// cover: changeOwner :: ownerIndex == 0 false
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
        target.initWallet(_arr1, 2, 100);
        }
        {
        target.changeOwner(bob, carol);
        }
        {
        target.isOwner(bob);
        }
        {
        target.isOwner(carol);
        }
        {
        target.m_numOwners();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that changeRequirement updates the required number of confirmations.
    function test_change_requirement_with_multisig_4() public {
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
        vm.prank(owner);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(alice);
        {
        target.changeRequirement(1);
        }
        vm.prank(owner);
        {
        target.m_required();
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that execute works immediately when value is below daily limit and data is empty.
    function test_execute_below_daily_limit_5() public {
// cover: execute :: _data.length == 0 && underLimit(_value) true
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
        {
        target.execute(bob, 50, hex"01");
        }
        vm.prank(owner);
        {
        target.m_spentToday();
        }
    }

    // @cover-intent Transactional Consistency: Verify that execute triggers multisig process when value exceeds daily limit.
    function test_execute_above_daily_limit_triggers_multisig_6() public {
// cover: execute :: _data.length == 0 && underLimit(_value) false
// cover: execute :: m_required == 1 false
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
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(alice);
        {
        target.execute(bob, 150, hex"01");
        }
        vm.prank(owner);
        {
        target.m_spentToday();
        }
    }

    // @cover-intent Transactional Consistency: Verify that a multisig transaction can be confirmed by multiple owners and executed.
    function test_confirm_multisig_transaction_7() public {
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
        vm.prank(owner);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(alice);
        {
        target.execute(bob, 150, hex"01");
        }
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(1)));
        }
        vm.prank(owner);
        {
        target.m_spentToday();
        }
    }

    // @cover-intent Transactional Consistency: Verify that an owner can revoke their confirmation on a pending operation.
    function test_revoke_confirmation_8() public {
// cover: revoke :: ownerIndex == 0 false
// cover: revoke :: pending.ownersDone & ownerIndexBit > 0 true
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
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(alice);
        {
        target.execute(bob, 150, hex"01");
        }
        vm.startPrank(owner);
        {
        target.revoke(bytes32(uint256(1)));
        }
        {
        target.hasConfirmed(bytes32(uint256(1)), alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that setDailyLimit and resetSpentToday work with multisig and affect daily spending.
    function test_set_and_reset_daily_limit_9() public {
// cover: setDailyLimit :: onlymanyowners modifier passes
// cover: resetSpentToday :: onlymanyowners modifier passes
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
        target.initWallet(_arr1, 2, 100);
        }
        vm.prank(alice);
        {
        target.setDailyLimit(200);
        }
        vm.prank(owner);
        {
        target.m_dailyLimit();
        }
        vm.prank(alice);
        {
        target.resetSpentToday();
        }
        vm.prank(owner);
        {
        target.m_spentToday();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_addOwner_positive_10() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.addOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_11() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.changeOwner(alice, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeRequirement_positive_12() public {
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
        target.initMultiowned(_arr1, 2);
        }
        {
        target.changeRequirement(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_confirm_positive_13() public {
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
        target.initMultiowned(_arr1, 2);
        }
        {
        target.execute(alice, 0, hex"");
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.confirm(bytes32(uint256(1)));
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_execute_positive_under_limit_14() public {
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
        target.initWallet(_arr1, 1, 100);
        }
        {
        target.execute(bob, 50, hex"");
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getOwner_positive_15() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.getOwner(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_hasConfirmed_positive_16() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.execute(alice, 0, hex"");
        }
        {
        target.hasConfirmed(bytes32(uint256(1)), owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_initDaylimit_positive_17() public {
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
    function test_isOwner_positive_18() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.isOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_kill_positive_19() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.kill(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_m_dailyLimit_positive_20() public {
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
        target.initDaylimit(100);
        }
        {
        target.m_dailyLimit();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_m_lastDay_positive_21() public {
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
        target.initDaylimit(100);
        }
        {
        target.m_lastDay();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_m_numOwners_positive_22() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.m_numOwners();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_m_required_positive_23() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.m_required();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_m_spentToday_positive_24() public {
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
        target.initWallet(_arr1, 1, 100);
        }
        {
        target.execute(alice, 50, hex"");
        }
        {
        target.m_spentToday();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_removeOwner_positive_25() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.removeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_resetSpentToday_positive_26() public {
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
        target.initWallet(_arr1, 1, 100);
        }
        {
        target.execute(alice, 50, hex"");
        }
        {
        target.resetSpentToday();
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency
    function test_revoke_positive_27() public {
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
        target.initMultiowned(_arr1, 2);
        }
        {
        target.execute(alice, 0, hex"");
        }
        {
        target.revoke(bytes32(uint256(1)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_setDailyLimit_positive_28() public {
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
        target.initMultiowned(_arr1, 1);
        }
        {
        target.initDaylimit(100);
        }
        {
        target.setDailyLimit(200);
        }
        vm.stopPrank();
    }

}
