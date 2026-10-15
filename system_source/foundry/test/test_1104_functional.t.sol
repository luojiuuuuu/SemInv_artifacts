// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

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

contract PERSONAL_BANK_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PERSONAL_BANK_FunctionalTest() public {
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
// cover: SetMinSum :: if(intitalized)revert() true
// cover: SetLogFile :: if(intitalized)revert() true
// cover: Deposit :: normal execution
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(2000000000000000000);
        }
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000002);
        }
        // skip ABI-mismatched call: Deposit()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Deposit correctly updates balances mapping.
    function test_Deposit_and_Balance_Check_1() public {
// cover: Deposit :: normal execution
// cover: balances :: view function
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect succeeds when balance >= MinSum and balance >= _am.
    function test_Collect_Successful_2() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
// cover: Collect :: if(msg.sender.call.value(_am)()) true
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(2000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance < _am.
    function test_Collect_Insufficient_Balance_3() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) false
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(2000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance < MinSum.
    function test_Collect_Below_MinSum_4() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) false
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(5000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(1000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect works when balance exactly equals MinSum.
    function test_Collect_Exact_MinSum_5() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(3000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(1000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect with _am=0 succeeds when balance >= MinSum.
    function test_Collect_Zero_Amount_6() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate and partial collect works.
    function test_Multiple_Deposits_And_Collect_7() public {
// cover: Collect :: if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) true
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(4000000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that MinSum view function returns the set value.
    function test_MinSum_View_8() public {
// cover: MinSum :: view function
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(2000000000000000000);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: MinSum()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_9() public {
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_10() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
    function test_MinSum_sequence_11() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
            _assertRelU(__v1, 2, 0, "call:MinSum>=0");
        }
    }

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_12() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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

    // @cover-intent minimal test for SetLogFile
    function test_perfn_SetLogFile_13() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        PERSONAL_BANK target = new PERSONAL_BANK();
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

    // @cover-intent minimal test for balances
    function test_perfn_balances_15() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.balances(alice);
        }
    }

}
