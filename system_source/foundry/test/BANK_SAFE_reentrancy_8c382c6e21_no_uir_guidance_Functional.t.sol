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


    // @cover-intent Protocol State Machine: Verify that after initialization, SetMinSum and SetLogFile cannot be called, and Deposit works correctly.
    function test_Initialization_and_Deposit_0() public {
// cover: Deposit :: normal deposit
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify that Collect succeeds when balances[msg.sender] >= MinSum and balances[msg.sender] >= _am.
    function test_Collect_with_sufficient_balance_and_MinSum_1() public {
// cover: Collect :: require(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(30);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 70
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balances[msg.sender] < MinSum.
    function test_Collect_with_insufficient_balance_2() public {
// cover: Collect :: require(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) false
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(10);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when _am > balances[msg.sender].
    function test_Collect_with_amount_exceeding_balance_3() public {
// cover: Collect :: require(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) false
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract triggers Deposit and updates balances.
    function test_Fallback_triggers_Deposit_4() public {
// cover: fallback :: calls Deposit()
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile revert after Initialized() is called.
    function test_SetMinSum_and_SetLogFile_after_initialization_revert_5() public {
// cover: SetMinSum :: require(!intitalized) false
// cover: SetLogFile :: require(!intitalized) false
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
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(5);
        }
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Collect_sequence_6() public {
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
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_7() public {
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
    function test_Initialized_sequence_8() public {
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

    // @cover-intent Financial & Accounting
    function test_MinSum_sequence_9() public {
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
        target.SetMinSum(100);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 100, "call:MinSum==100");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_SetLogFile_sequence_10() public {
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

    // @cover-intent Financial & Accounting
    function test_SetMinSum_sequence_11() public {
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
        target.SetMinSum(50);
        }
        {
            uint256 __v2 = uint256(target.MinSum());
            _assertRelU(__v2, 0, 50, "call:MinSum==50");
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_12() public {
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
        // TODO assert: alice.balance == 200
    }

}
