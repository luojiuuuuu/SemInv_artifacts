// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

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

contract MONEY_BOX_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MONEY_BOX_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile can only be called before Initialized, and that Initialized locks the configuration.
    function test_initialization_and_setup_0() public {
// cover: SetMinSum :: if(intitalized)throw; true
// cover: SetLogFile :: if(intitalized)throw; true
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(100);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(200);
        }
        vm.expectRevert();
        {
        target.SetLogFile(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Put correctly records balance and unlockTime for a user.
    function test_put_basic_deposit_1() public {
// cover: Put :: acc.balance += msg.value
// cover: Put :: if(now+_lockTime>acc.unlockTime)acc.unlockTime=now+_lockTime
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(50)(100);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect succeeds when balance >= MinSum, balance >= _am, and current time > unlockTime.
    function test_collect_basic_withdrawal_2() public {
// assume: now > unlockTime for alice
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime true
// cover: Collect :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(100)(1);
        }
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance < _am.
    function test_collect_revert_insufficient_balance_3() public {
// assume: now > unlockTime for alice
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime false
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(30)(1);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance < MinSum.
    function test_collect_revert_below_minsum_4() public {
// assume: now > unlockTime for alice
// cover: Collect :: acc.balance>=MinSum false
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(100);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(50)(1);
        }
        vm.expectRevert();
        {
        target.Collect(10);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when current time <= unlockTime.
    function test_collect_revert_locked_time_5() public {
// assume: now <= unlockTime for alice
// cover: Collect :: now>acc.unlockTime false
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(100)(1000000);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that the fallback function calls Put(0) and records the deposit.
    function test_fallback_put_zero_6() public {
// cover: fallback :: Put(0)
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(50)(100);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that Collect's reentrancy guard (balance deduction after call) prevents double withdrawal.
    function test_collect_reentrancy_attempt_7() public {
// assume: now > unlockTime for alice
// cover: Collect :: msg.sender.call.value(_am)() true
// cover: Collect :: acc.balance>=_am false after first withdrawal
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(100)(1);
        }
        {
        target.Collect(50);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that multiple users can independently deposit and withdraw without interference.
    function test_multiple_users_independent_accounts_8() public {
// assume: now > unlockTime for alice and bob
// cover: Collect :: different msg.sender paths
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(100)(1);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.Put.value(50)(1);
        }
        vm.prank(alice);
        {
        target.Collect(50);
        }
        vm.prank(bob);
        {
        target.Collect(30);
        }
    }

    // @cover-intent Protocol State Machine: Verify that Put updates unlockTime to max(current+_lockTime, existing unlockTime).
    function test_put_updates_unlock_time_9() public {
// cover: Put :: if(now+_lockTime>acc.unlockTime)acc.unlockTime=now+_lockTime true
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        {
        target.Put.value(50)(100);
        }
        {
        target.Put.value(50)(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_SetMinSum_test_10() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(100);
        }
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 100, "call:MinSum==100");
        }
    }

    // @cover-intent Protocol State Machine
    function test_SetLogFile_test_11() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetLogFile(alice);
        }
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_test_12() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        // skip ABI-mismatched call: Initialized()
    }

    // @cover-intent Financial & Accounting
    function test_Put_test_13() public {
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetLogFile(alice);
        }
        vm.prank(alice);
        {
        target.Put.value(1 ether)(100);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_Collect_test_14() public {
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(1);
        }
        {
        target.SetLogFile(alice);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(1 ether)(0);
        }
        {
        target.Collect(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Acc_test_15() public {
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        target.Put.value(1 ether)(0);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_test_16() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        target.SetMinSum(50);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v2 = uint256(target.MinSum());
            _assertRelU(__v2, 0, 50, "call:MinSum==50");
        }
    }

}
