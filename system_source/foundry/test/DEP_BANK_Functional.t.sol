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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and then collect up to their balance, with the balance decreasing accordingly.
    function test_Deposit_and_Collect_positive_path_0() public {
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
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 5 ether + 2 ether
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts if the user's balance is less than MinSum.
    function test_Collect_reverts_when_balance_below_MinSum_1() public {
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
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(3 ether)();
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 3 ether
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts if the requested amount exceeds the user's balance.
    function test_Collect_reverts_when_amount_exceeds_balance_2() public {
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
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(2 ether)();
        }
        vm.expectRevert();
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 2 ether
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile revert after Initialized is called.
    function test_SetMinSum_and_SetLogFile_only_before_initialization_3() public {
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
        target.Initialized();
        }
        vm.expectRevert();
        {
        target.SetMinSum(100);
        }
        vm.expectRevert();
        {
        target.SetLogFile(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that Collect with zero amount succeeds and does not change balance.
    function test_Collect_with_zero_amount_when_balance_meets_MinSum_4() public {
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) true
// cover: Collect :: require(msg.sender.call.value(0)()) true
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
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 5 ether
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
        target.SetMinSum(100);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(200)();
        }
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
        {
        target.Initialized();
        }
        {
        target.Deposit.value(100)();
        }
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
        {
        target.Initialized();
        }
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
        target.SetMinSum(500);
        }
        {
        target.Initialized();
        }
        {
        target.MinSum();
        }
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
        target.SetMinSum(1000);
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
        {
        target.Initialized();
        }
        {
        target.Deposit.value(77)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 77
    }

}
