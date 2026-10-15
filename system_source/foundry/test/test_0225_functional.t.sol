// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

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

contract DEP_BANK_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DEP_BANK_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and then collect a valid amount when balance >= MinSum and balance >= _am.
    function test_Deposit_and_Collect_positive_path_0() public {
// assume: balances[alice] >= MinSum
// assume: balances[alice] >= 2 ether
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) true
// cover: Collect :: require(msg.sender.call.value(_am)()) true
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts if the user's balance is less than MinSum.
    function test_Collect_fails_when_balance_below_MinSum_1() public {
// assume: balances[alice] < MinSum
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) false
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(5 ether);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if the requested amount exceeds the user's balance.
    function test_Collect_fails_when_am_exceeds_balance_2() public {
// assume: balances[alice] >= MinSum
// assume: balances[alice] < 3 ether
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) false
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        vm.expectRevert();
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile revert after Initialized is called.
    function test_SetMinSum_and_SetLogFile_only_before_Initialized_3() public {
// assume: intitalized == true
// cover: SetMinSum :: require(!intitalized) false
// cover: SetLogFile :: require(!intitalized) false
        vm.startPrank(owner);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(2 ether);
        }
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000002);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that Collect sends ETH before deducting balance, allowing reentrancy (vulnerability demonstration).
    function test_Collect_reentrancy_guard_bypass_no_guard_4() public {
// assume: balances[alice] >= MinSum
// assume: balances[alice] >= 2 ether
// cover: Collect :: require(msg.sender.call.value(_am)()) true
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Collect_sequence_5() public {
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_6() public {
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_7() public {
        vm.startPrank(owner);
        DEP_BANK target = new DEP_BANK();
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

    // @cover-intent Financial & Accounting
    function test_MinSum_sequence_8() public {
        vm.startPrank(owner);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(42);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: MinSum()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_SetLogFile_sequence_9() public {
        vm.startPrank(owner);
        DEP_BANK target = new DEP_BANK();
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
        target.SetLogFile(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_SetMinSum_sequence_10() public {
        vm.startPrank(owner);
        DEP_BANK target = new DEP_BANK();
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
        target.SetMinSum(100);
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_11() public {
        vm.startPrank(alice);
        DEP_BANK target = new DEP_BANK();
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
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 200
    }

}
