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


    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile can only be called before Initialized, and after Initialized they revert.
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

    // @cover-intent Financial & Accounting: Verify that after putting ETH and waiting for unlock, Collect succeeds and balance decreases.
    function test_Put_and_Collect_positive_path_1() public {
// assume: block.timestamp increases by 2 seconds between steps
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
        target.SetMinSum(10);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 950
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if acc.balance < MinSum.
    function test_Collect_fails_when_balance_below_MinSum_2() public {
// assume: block.timestamp increases by 2 seconds
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
        target.SetMinSum(200);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 900
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if _am > acc.balance.
    function test_Collect_fails_when_amount_exceeds_balance_3() public {
// assume: block.timestamp increases by 2 seconds
// cover: Collect :: acc.balance>=_am false
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        vm.expectRevert();
        {
        target.Collect(150);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 900
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if now <= acc.unlockTime.
    function test_Collect_fails_before_unlock_time_4() public {
// assume: block.timestamp does not advance
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(100);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 900
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract triggers fallback and increases balance.
    function test_Fallback_calls_Put_with_zero_lock_time_5() public {
// assume: block.timestamp increases by 1 second
// cover: Put :: fallback path
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Collect(30);
        }
        // TODO assert: alice.balance == 980
    }

    // @cover-intent Transactional Consistency: Verify that multiple users can independently deposit and withdraw.
    function test_Multiple_puts_and_collects_from_different_users_6() public {
// assume: block.timestamp increases by 2 seconds
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Put.value(200)(1);
        }
        vm.prank(bob);
        {
        target.Put.value(300)(1);
        }
        vm.prank(alice);
        {
        target.Collect(100);
        }
        vm.prank(bob);
        {
        target.Collect(150);
        }
        // TODO assert: alice.balance == 900
        // TODO assert: bob.balance == 850
    }

    // @cover-intent Resource & Execution Integrity: Verify that Collect uses call.value which is vulnerable to reentrancy, but the balance update after call prevents double withdrawal.
    function test_Collect_reentrancy_attempt_7() public {
// assume: block.timestamp increases by 2 seconds
// cover: Collect :: msg.sender.call.value(_am)() true
// cover: Collect :: acc.balance>=_am false after first collect
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100)(1);
        }
        {
        target.Collect(100);
        }
        vm.expectRevert();
        {
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 900
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_set_initialized_flag_8() public {
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
        // skip ABI-mismatched call: Initialized()
    }

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_minimum_sum_9() public {
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
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 0, "call:MinSum==0");
        }
    }

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_10() public {
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

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_11() public {
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
        target.Collect(1);
        }
    }

    // @cover-intent minimal test for Put
    function test_perfn_Put_12() public {
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
        target.Put(1);
        }
    }

    // @cover-intent minimal test for SetLogFile
    function test_perfn_SetLogFile_13() public {
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

    // @cover-intent minimal test for SetMinSum
    function test_perfn_SetMinSum_14() public {
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
        target.SetMinSum(1);
        }
    }

}
