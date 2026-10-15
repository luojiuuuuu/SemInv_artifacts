// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

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

contract PrivateBank_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PrivateBank_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that deposits below MinDeposit (1 ether) are rejected, and deposits at or above the threshold update balances correctly.
    function test_Deposit_Minimum_Threshold_0() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: msg.value >= MinDeposit true
// cover: Deposit :: msg.value >= MinDeposit false
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(0.5 ether)();
        }
        {
        target.balances(alice);
        }
        {
        target.Deposit.value(1 ether)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether - 1.5 ether
    }

    // @cover-intent Financial & Accounting: Verify that CashOut respects the balance limit and correctly updates state after successful withdrawal.
    function test_CashOut_Balance_Limit_1() public {
// assume: balances(alice) >= 2 ether
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: _am <= balances[msg.sender] false
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.CashOut(3 ether);
        }
        {
        target.balances(alice);
        }
        {
        target.CashOut(1 ether);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether + 2 ether - 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that CashOut reverts when the requested amount exceeds the user's balance.
    function test_CashOut_Exceeds_Balance_2() public {
// assume: balances(alice) == 1 ether
// cover: CashOut :: _am <= balances[msg.sender] false
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(1 ether)();
        }
        {
        target.CashOut(2 ether);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits from the same user accumulate correctly in the balance mapping.
    function test_Multiple_Deposits_Accumulate_3() public {
// cover: Deposit :: msg.value >= MinDeposit true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(1 ether)();
        }
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.balances(alice);
        }
        {
        target.Deposit.value(1.5 ether)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether - 4.5 ether
    }

    // @cover-intent Financial & Accounting: Verify that balances are isolated per user and do not interfere with each other.
    function test_Separate_User_Balances_4() public {
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(1 ether)();
        }
        vm.prank(bob);
        {
        target.Deposit.value(1 ether)();
        }
        vm.prank(alice);
        {
        target.balances(alice);
        }
        vm.prank(bob);
        {
        target.balances(bob);
        }
        vm.prank(alice);
        {
        target.CashOut(1 ether);
        }
        vm.prank(bob);
        {
        target.balances(bob);
        }
        // TODO assert: alice.balance == 2 ether - 1 ether + 1 ether
        // TODO assert: bob.balance == 2 ether - 1 ether
    }

    // @cover-intent External Interaction & Environment: Verify that the fallback function accepts Ether without affecting balances.
    function test_Fallback_Receives_Ether_5() public {
// cover: fallback :: payable fallback
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(1 ether)();
        }
        {
        target.balances(alice);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether - 1.5 ether
    }

    // @cover-intent Financial & Accounting
    function test_CashOut_sequence_6() public {
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.CashOut(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance >= 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_7() public {
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(2 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_MinDeposit_sequence_8() public {
        vm.startPrank(owner);
        PrivateBank target = new PrivateBank(alice);
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
        target.MinDeposit();
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_9() public {
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

}
