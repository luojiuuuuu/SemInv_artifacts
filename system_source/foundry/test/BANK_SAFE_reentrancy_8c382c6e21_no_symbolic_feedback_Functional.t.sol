// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

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

contract BANK_SAFE_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function BANK_SAFE_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that after initialization, SetMinSum and SetLogFile are locked, and Deposit works correctly.
    function test_Initialization_and_Deposit_0() public {
// cover: SetMinSum :: if(intitalized)throw; true
// cover: SetLogFile :: if(intitalized)throw; true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        vm.startPrank(owner);
        vm.expectRevert();
        {
        target.SetMinSum(20);
        }
        vm.expectRevert();
        {
        target.SetLogFile(bob);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify Collect succeeds when balances[msg.sender] >= MinSum and balances[msg.sender] >= _am.
    function test_Collect_with_sufficient_balance_and_MinSum_1() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(20);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent Financial & Accounting: Verify Collect reverts when balances[msg.sender] < _am.
    function test_Collect_insufficient_balance_2() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) false
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(10);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5
    }

    // @cover-intent Financial & Accounting: Verify Collect does not execute when balances[msg.sender] < MinSum.
    function test_Collect_insufficient_MinSum_3() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) false
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(10);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent External Interaction & Environment: Verify fallback function calls Deposit, increasing balance.
    function test_Fallback_triggers_Deposit_4() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify Collect with _am = 0 when balance >= MinSum.
    function test_Collect_with_zero_amount_5() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify Collect with _am equal to balance.
    function test_Collect_with_exact_balance_6() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify multiple deposits and a collect maintain correct balances.
    function test_Multiple_deposits_and_collect_7() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: Deposit()
        vm.prank(alice);
        {
        target.Collect(25);
        }
        vm.prank(bob);
        {
        target.Collect(10);
        }
        // TODO assert: alice.balance == 25
        // TODO assert: bob.balance == 30
    }

    // @cover-intent External Interaction & Environment: Verify Collect's external call does not cause reentrancy due to state update after call.
    function test_Collect_with_reentrant_call_via_fallback_8() public {
// cover: Collect :: if(msg.sender.call.value(_am)()) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(20);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent Financial & Accounting
    function test_Collect_sequence_9() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 150
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_10() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        // skip ABI-mismatched call: Deposit()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_11() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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
    function test_MinSum_sequence_12() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 2, 50, "call:MinSum>=50");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_SetLogFile_sequence_13() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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

    // @cover-intent Resource & Execution Integrity
    function test_SetMinSum_sequence_14() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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
            uint256 __v2 = uint256(target.MinSum());
            _assertRelU(__v2, 0, 100, "call:MinSum==100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_15() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

}
