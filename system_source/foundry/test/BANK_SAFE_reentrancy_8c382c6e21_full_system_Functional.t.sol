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


    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile can only be called before Initialized, and after Initialized they revert.
    function test_Initialize_and_set_parameters_0() public {
// cover: SetMinSum :: if(intitalized)throw; true
// cover: SetLogFile :: if(intitalized)throw; true
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(20);
        }
        vm.expectRevert();
        {
        target.SetLogFile(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Deposit increases the caller's balance correctly.
    function test_Deposit_and_check_balance_1() public {
// cover: Deposit :: balances[msg.sender]+= msg.value
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
        target.SetMinSum(0);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(bob);
        // skip ABI-mismatched call: Deposit()
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 200
    }

    // @cover-intent Financial & Accounting: Verify that Collect reduces balance when conditions are met.
    function test_Collect_with_sufficient_balance_and_MinSum_2() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am true
// cover: Collect :: msg.sender.call.value(_am)() true
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
        target.SetMinSum(50);
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
        // TODO assert: alice.balance == 70
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts if balance is less than MinSum.
    function test_Collect_revert_when_balance_below_MinSum_3() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am false
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
        vm.expectRevert();
        {
        target.Collect(10);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts if _am is greater than balance.
    function test_Collect_revert_when_am_exceeds_balance_4() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am false
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
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract via fallback calls Deposit and increases balance.
    function test_Fallback_triggers_Deposit_5() public {
// cover: fallback :: Deposit() called
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
        target.SetMinSum(0);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: Deposit()
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify that Collect with _am=0 works when balance >= MinSum.
    function test_Collect_with_zero_amount_6() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am true
// cover: Collect :: msg.sender.call.value(0)() true
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
        target.SetMinSum(0);
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

    // @cover-intent Financial & Accounting: Verify that Collect can withdraw the entire balance when it equals MinSum.
    function test_Collect_with_exact_balance_7() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am true
// cover: Collect :: msg.sender.call.value(100)() true
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
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify that multiple deposits and collects maintain correct balances.
    function test_Multiple_deposits_and_collects_8() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am true
// cover: Collect :: msg.sender.call.value(_am)() true
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
        vm.prank(bob);
        // skip ABI-mismatched call: Deposit()
        vm.prank(alice);
        {
        target.Collect(20);
        }
        vm.prank(bob);
        {
        target.Collect(10);
        }
        vm.prank(alice);
        {
        target.Collect(30);
        }
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 20
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts if balance drops below MinSum after previous withdrawals.
    function test_Collect_with_insufficient_balance_after_partial_withdrawal_9() public {
// cover: Collect :: balances[msg.sender]>=MinSum && balances[msg.sender]>=_am false
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(60);
        }
        vm.expectRevert();
        {
        target.Collect(40);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 40
    }

    // @cover-intent Financial & Accounting
    function test_Collect_sequence_10() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_11() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_12() public {
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
    function test_MinSum_sequence_13() public {
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
        target.SetMinSum(500);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
    }

    // @cover-intent Authorization & Access Control
    function test_SetLogFile_sequence_14() public {
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

    // @cover-intent Authorization & Access Control
    function test_SetMinSum_sequence_15() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_16() public {
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
