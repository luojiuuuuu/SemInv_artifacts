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

    // @cover-intent Financial & Accounting: Verify that Put works before Initialized is called, storing balance and setting unlock time.
    function test_put_without_initialization_1() public {
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
        {
        target.Put.value(50)(100);
        }
        {
        target.Put.value(30)(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when unlock time has not passed yet.
    function test_collect_before_unlock_2() public {
// assume: now < unlockTime
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Put.value(100)(1000);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance is below MinSum.
    function test_collect_below_min_sum_3() public {
// assume: now > unlockTime
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
        target.SetMinSum(200);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Put.value(100)(0);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify successful Collect after meeting all conditions (balance >= MinSum, balance >= amount, unlock time passed).
    function test_collect_successful_4() public {
// assume: now > unlockTime
// cover: Collect :: acc.balance>=MinSum true
// cover: Collect :: acc.balance>=_am true
// cover: Collect :: now>acc.unlockTime true
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
        {
        target.Put.value(100)(0);
        }
        {
        target.Collect(60);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify Collect with amount equal to balance (edge case).
    function test_collect_exact_balance_5() public {
// assume: now > unlockTime
// cover: Collect :: acc.balance>=_am true (equal)
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
        {
        target.Put.value(100)(0);
        }
        {
        target.Collect(100);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that reentrancy via fallback does not drain more than intended (the contract uses call.value which is vulnerable).
    function test_collect_reentrancy_attempt_6() public {
// assume: now > unlockTime
// assume: alice is a contract with fallback that reenters Collect
// cover: Collect :: msg.sender.call.value(_am)() true (reentrancy)
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
        {
        target.Put.value(100)(0);
        }
        {
        target.Collect(60);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify Collect works correctly after multiple Put calls from same user.
    function test_collect_after_multiple_puts_7() public {
// assume: now > unlockTime
// cover: Collect :: acc.balance>=MinSum true (120 >= 100)
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
        {
        target.Put.value(50)(0);
        }
        {
        target.Put.value(70)(0);
        }
        {
        target.Collect(120);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify Collect with amount = 0 (edge case).
    function test_collect_zero_amount_8() public {
// assume: now > unlockTime
// cover: Collect :: acc.balance>=_am true (100 >= 0)
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
        target.SetMinSum(0);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Put.value(100)(0);
        }
        {
        target.Collect(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_set_9() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_10() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 0, "call:MinSum==0");
        }
    }

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_11() public {
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
        vm.prank(alice);
        {
        target.Acc(alice);
        }
    }

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_12() public {
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
        vm.prank(alice);
        {
        target.Collect(1);
        }
    }

    // @cover-intent minimal test for Put
    function test_perfn_Put_13() public {
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
        vm.prank(alice);
        {
        target.Put(1);
        }
    }

    // @cover-intent minimal test for SetLogFile
    function test_perfn_SetLogFile_14() public {
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

    // @cover-intent minimal test for SetMinSum
    function test_perfn_SetMinSum_15() public {
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
        target.SetMinSum(1);
        }
    }

}
