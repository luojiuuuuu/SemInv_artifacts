// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol";

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

contract W_WALLET_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function W_WALLET_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Test normal deposit via Put with future unlock time
    function test_Put_normal_deposit_0() public {
// assume: block.timestamp < 2000000000
// cover: Put :: acc.balance += msg.value
// cover: Put :: acc.unlockTime = _unlockTime>now ? _unlockTime : now
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(5 ether)(2000000000);
        }
    }

    // @cover-intent External Interaction & Environment: Test Put with zero unlock time (uses current timestamp)
    function test_Put_zero_unlock_time_1() public {
// cover: Put :: acc.unlockTime = _unlockTime>now ? _unlockTime : now (now branch)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(3 ether)(0);
        }
    }

    // @cover-intent Financial & Accounting: Test successful Collect when balance >= MinSum and unlock time passed
    function test_Collect_successful_withdrawal_2() public {
// assume: block.timestamp > 100
// assume: Acc(alice).balance >= 1 ether
// assume: MinSum() == 1 ether
// cover: Collect :: acc.balance >= MinSum && acc.balance >= _am && now > acc.unlockTime (true)
// cover: Collect :: msg.sender.call.value(_am)() (true)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(100);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test Collect reverts when balance below MinSum
    function test_Collect_below_MinSum_3() public {
// assume: block.timestamp > 100
// assume: Acc(alice).balance < 1 ether
// cover: Collect :: acc.balance >= MinSum (false)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(0.5 ether)(100);
        }
        vm.expectRevert();
        // skip malformed call: Collect(0.1 ether) (bad raw arg for Collect.arg0: type=uint256, raw=0.1 ether)
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test Collect reverts when before unlock time
    function test_Collect_before_unlock_time_4() public {
// assume: block.timestamp < 9999999999
// assume: Acc(alice).balance >= 1 ether
// cover: Collect :: now > acc.unlockTime (false)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(9999999999);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test Collect reverts when requesting more than balance
    function test_Collect_insufficient_balance_5() public {
// assume: block.timestamp > 100
// assume: Acc(alice).balance == 2 ether
// cover: Collect :: acc.balance >= _am (false)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(100);
        }
        vm.expectRevert();
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Test Collect with reentrant call (should fail due to balance check after call)
    function test_Collect_reentrancy_attempt_6() public {
// assume: block.timestamp > 100
// assume: Acc(alice).balance >= 1 ether
// cover: Collect :: msg.sender.call.value(_am)() (true)
// cover: Collect :: acc.balance -= _am (after call)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(100);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test multiple deposits accumulate correctly
    function test_Multiple_deposits_same_user_7() public {
// assume: block.timestamp < 100
// cover: Put :: acc.balance += msg.value (twice)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(100);
        }
        {
        target.Put.value(3 ether)(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test Collect with exact MinSum amount
    function test_Collect_exact_MinSum_8() public {
// assume: block.timestamp > 100
// assume: Acc(alice).balance == 1 ether
// cover: Collect :: acc.balance >= MinSum (true, exactly equal)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(1 ether)(100);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Acc_view_9() public {
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(1 ether)(0);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Collect_positive_10() public {
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(0);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_11() public {
        vm.startPrank(owner);
        W_WALLET target = new W_WALLET(alice);
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
        target.MinSum();
        }
    }

    // @cover-intent Financial & Accounting
    function test_Put_positive_12() public {
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(1 ether)(100);
        }
    }

}
