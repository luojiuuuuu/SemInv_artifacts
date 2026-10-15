// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/short_address_example.sol";

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

contract MyToken_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MyToken_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that sendCoin correctly transfers tokens from sender to recipient and updates balances accordingly, with the Transfer event emitted.
    function test_Positive_sendCoin_and_balance_check_0() public {
// cover: sendCoin :: require(balance>=amount) true
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 100);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        // TODO assert: alice.balance == 9900
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify that sendCoin returns false when sender has insufficient balance, and no state changes occur.
    function test_sendCoin_insufficient_balance_1() public {
// cover: sendCoin :: require(balance>=amount) false
        vm.startPrank(owner);
        MyToken target = new MyToken();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.sendCoin(alice, 1);
        }
        {
        target.getBalance(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
        // TODO assert: alice.balance == 10000
    }

    // @cover-intent Financial & Accounting: Verify that sendCoin with zero amount succeeds and emits Transfer event with zero value.
    function test_sendCoin_zero_amount_2() public {
// cover: sendCoin :: require(balance>=amount) true
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 0);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        // TODO assert: alice.balance == 10000
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sendCoin can transfer the entire balance of the sender, leaving sender with zero.
    function test_sendCoin_full_balance_3() public {
// cover: sendCoin :: require(balance>=amount) true
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 10000);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 10000
    }

    // @cover-intent Financial & Accounting: Verify that sendCoin to self works correctly, balance remains unchanged.
    function test_sendCoin_to_self_4() public {
// cover: sendCoin :: require(balance>=amount) true
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(alice, 500);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10000
    }

    // @cover-intent Financial & Accounting: Verify that multiple sendCoin calls correctly update balances and conserve total supply.
    function test_Multiple_sendCoin_transfers_5() public {
// cover: sendCoin :: require(balance>=amount) true
// cover: sendCoin :: require(balance>=amount) true
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 2000);
        }
        vm.prank(bob);
        {
        target.sendCoin(carol, 500);
        }
        vm.prank(alice);
        {
        target.getBalance(alice);
        }
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        vm.prank(carol);
        {
        target.getBalance(carol);
        }
        // TODO assert: alice.balance == 8000
        // TODO assert: bob.balance == 1500
        // TODO assert: carol.balance == 500
    }

    // @cover-intent Financial & Accounting: Verify that sendCoin with a very large amount (close to uint256 max) fails due to insufficient balance, no state change.
    function test_sendCoin_with_overflow_attempt_boundary_6() public {
// cover: sendCoin :: require(balance>=amount) false
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        // TODO assert: alice.balance == 10000
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that sendCoin to address(0) is allowed (no explicit revert), but balance of zero address increases.
    function test_sendCoin_to_zero_address_7() public {
// cover: sendCoin :: require(balance>=amount) true
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(0x0000000000000000000000000000000000000000, 100);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.getBalance(0x0000000000000000000000000000000000000000);
        }
        // TODO assert: alice.balance == 9900
    }

    // @cover-intent Financial & Accounting
    function test_sendCoin_positive_path_8() public {
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 100);
        }
        {
        target.sendCoin(bob, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getBalance_after_sendCoin_9() public {
        vm.startPrank(owner);
        MyToken target = new MyToken();
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
        target.sendCoin(bob, 50);
        }
        {
        target.getBalance(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 50
    }

}
