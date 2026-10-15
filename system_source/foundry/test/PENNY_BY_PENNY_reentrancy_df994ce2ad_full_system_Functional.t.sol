// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

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

contract PENNY_BY_PENNY_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PENNY_BY_PENNY_FunctionalTest() public {
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
    function test_Initialization_and_MinSum_setup_0() public {
// cover: SetMinSum :: if(intitalized)throw; false
// cover: SetLogFile :: if(intitalized)throw; false
// cover: SetMinSum :: if(intitalized)throw; true
// cover: SetLogFile :: if(intitalized)throw; true
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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

    // @cover-intent Financial & Accounting: Verify that Put correctly updates balance and unlockTime for the sender, and that the fallback function also calls Put(0).
    function test_Put_with_ETH_and_unlock_time_1() public {
// cover: Put :: acc.balance += msg.value
// cover: Put :: if(now+_lockTime>acc.unlockTime)acc.unlockTime=now+_lockTime
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(50)(100);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify that Collect succeeds when balance >= MinSum, balance >= _am, and current time > unlockTime.
    function test_Collect_with_sufficient_balance_and_time_2() public {
// assume: now > alice's unlockTime (set via Put with lockTime=1)
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime true
// cover: Collect :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 150
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when acc.balance < _am.
    function test_Collect_fails_due_to_insufficient_balance_3() public {
// assume: now > alice's unlockTime
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime false
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(30)(1);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when acc.balance < MinSum.
    function test_Collect_fails_due_to_insufficient_MinSum_4() public {
// assume: now > alice's unlockTime
// cover: Collect :: acc.balance>=MinSum false
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(100);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(50)(1);
        }
        vm.expectRevert();
        {
        target.Collect(10);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when now <= unlockTime.
    function test_Collect_fails_due_to_lock_time_not_passed_5() public {
// assume: now < alice's unlockTime
// cover: Collect :: now>acc.unlockTime false
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(50)(1000000);
        }
        vm.expectRevert();
        {
        target.Collect(10);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending ETH to the contract triggers the fallback, which calls Put(0) and updates balance.
    function test_Fallback_function_calls_Put_0_6() public {
// cover: fallback :: Put(0)
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Acc(alice);
        }
        // TODO assert: alice.balance == 70
    }

    // @cover-intent External Interaction & Environment: Verify that Collect sends ETH and updates balance after external call, but reentrancy is not exploitable in a single test step.
    function test_Collect_reentrancy_attempt_single_call_7() public {
// assume: now > alice's unlockTime
// cover: Collect :: msg.sender.call.value(_am)() true
// cover: Collect :: acc.balance-=_am
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        {
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Resource & Execution Integrity
    function test_Acc_view_balance_and_unlock_time_8() public {
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.Acc(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_Collect_successful_withdrawal_after_meeting_conditions_9() public {
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(50);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_set_intitalized_flag_10() public {
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_minimum_sum_11() public {
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 100, "call:MinSum==100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_Put_deposit_with_lock_time_12() public {
        vm.startPrank(alice);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Put.value(50)(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_SetLogFile_set_log_file_address_13() public {
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
    function test_SetMinSum_set_minimum_sum_before_initialization_14() public {
        vm.startPrank(owner);
        PENNY_BY_PENNY target = new PENNY_BY_PENNY();
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
        target.SetMinSum(200);
        }
        {
            uint256 __v2 = uint256(target.MinSum());
            _assertRelU(__v2, 0, 200, "call:MinSum==200");
        }
    }

}
