// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

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

contract PRIVATE_ETH_CELL_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PRIVATE_ETH_CELL_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that initialization prevents further configuration and that deposits work correctly after initialization.
    function test_Initialization_and_deposit_flow_0() public {
// cover: SetMinSum :: require(!intitalized) false
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Deposit.value(5 ether)();
        }
        vm.expectRevert();
        vm.prank(owner);
        {
        target.SetMinSum(2 ether);
        }
        // TODO assert: alice.balance == 5 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect succeeds when balance >= MinSum and balance >= _am.
    function test_Collect_with_sufficient_balance_and_MinSum_1() public {
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
// cover: Collect :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when balance < MinSum.
    function test_Collect_fails_when_balance_below_MinSum_2() public {
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am false
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(5 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(3 ether)();
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when _am > balance even if MinSum is met.
    function test_Collect_fails_when_am_exceeds_balance_3() public {
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am false
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(3 ether)();
        }
        {
        target.Collect(5 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent External Interaction & Environment: Verify that Collect sends ETH and updates balance after external call (reentrancy pattern).
    function test_Collect_with_reentrancy_attempt_4() public {
// cover: Collect :: msg.sender.call.value(_am)() true
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(2 ether);
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that multiple users can deposit and balances are tracked independently.
    function test_Multiple_deposits_from_different_users_5() public {
// cover: Deposit :: balances[msg.sender] += msg.value
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Deposit.value(3 ether)();
        }
        vm.prank(bob);
        {
        target.Deposit.value(4 ether)();
        }
        // TODO assert: alice.balance == 3 ether
        // TODO assert: bob.balance == 4 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify that Collect with _am=0 succeeds when balance >= MinSum.
    function test_Collect_zero_amount_6() public {
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
// cover: Collect :: msg.sender.call.value(0)() true
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect works correctly after a previous withdrawal reduces balance.
    function test_Collect_after_partial_withdrawal_7() public {
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1 ether);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(2 ether);
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Protocol State Machine: Verify that SetLogFile reverts after initialization.
    function test_Initialization_prevents_SetLogFile_8() public {
// cover: SetLogFile :: require(!intitalized) false
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.Initialized();
        }
        vm.expectRevert();
        {
        target.SetLogFile(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Collect_sequence_9() public {
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(200)();
        }
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_10() public {
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Deposit.value(100)();
        }
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_11() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.Initialized();
        }
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_sequence_12() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.MinSum();
        }
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 50, "call:MinSum==50");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_SetLogFile_sequence_13() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
    function test_SetMinSum_sequence_14() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(100)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

}
