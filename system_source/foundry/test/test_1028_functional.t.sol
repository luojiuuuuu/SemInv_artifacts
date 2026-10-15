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


    // @cover-intent Financial & Accounting: Verify that the constructor assigns 10000 tokens to tx.origin (owner) and that a successful transfer reduces sender balance and increases receiver balance, preserving total supply.
    function test_Initial_balance_and_basic_transfer_0() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
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
        vm.startPrank(owner);
        {
        target.getBalance(owner);
        }
        {
        target.sendCoin(alice, 1000);
        }
        {
        target.getBalance(owner);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 9000
        // TODO assert: alice.balance == 1000
    }

    // @cover-intent Financial & Accounting: Verify that sendCoin returns false when sender has insufficient balance, and balances remain unchanged.
    function test_Insufficient_balance_revert_1() public {
// cover: sendCoin :: balances[msg.sender] < amount (true)
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
        target.sendCoin(bob, 1);
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
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending the entire balance works correctly, leaving sender with 0 and receiver credited.
    function test_Transfer_entire_balance_2() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
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
        vm.prank(owner);
        {
        target.sendCoin(alice, 5000);
        }
        vm.startPrank(alice);
        {
        target.sendCoin(bob, 5000);
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
        // TODO assert: bob.balance == 5000
    }

    // @cover-intent Financial & Accounting: Verify that transferring 0 tokens is allowed and does not change balances.
    function test_Transfer_zero_amount_3() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
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
        vm.prank(owner);
        {
        target.sendCoin(alice, 100);
        }
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
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that multiple transfers from the same sender correctly decrement balance each time.
    function test_Multiple_transfers_from_same_sender_4() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
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
        vm.prank(owner);
        {
        target.sendCoin(alice, 300);
        }
        vm.startPrank(alice);
        {
        target.sendCoin(bob, 100);
        }
        {
        target.sendCoin(carol, 100);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        vm.prank(carol);
        {
        target.getBalance(carol);
        }
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 100
        // TODO assert: carol.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify that sending tokens to oneself is allowed and balance remains unchanged.
    function test_Transfer_to_self_5() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
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
        vm.prank(owner);
        {
        target.sendCoin(alice, 500);
        }
        vm.startPrank(alice);
        {
        target.sendCoin(alice, 200);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 500
    }

    // @cover-intent Financial & Accounting: Verify that after a partial spend, remaining balance is correct and further transfers work.
    function test_Transfer_after_partial_spend_6() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
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
        vm.prank(owner);
        {
        target.sendCoin(alice, 1000);
        }
        vm.startPrank(alice);
        {
        target.sendCoin(bob, 300);
        }
        {
        target.sendCoin(carol, 200);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
        vm.prank(carol);
        {
        target.getBalance(carol);
        }
        // TODO assert: alice.balance == 500
        // TODO assert: bob.balance == 300
        // TODO assert: carol.balance == 200
    }

    // @cover-intent Financial & Accounting: Verify that after exhausting balance, subsequent transfer returns false.
    function test_Exhaustive_transfer_then_insufficient_7() public {
// cover: sendCoin :: balances[msg.sender] >= amount (true)
// cover: sendCoin :: balances[msg.sender] < amount (true)
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
        vm.prank(owner);
        {
        target.sendCoin(alice, 100);
        }
        vm.startPrank(alice);
        {
        target.sendCoin(bob, 100);
        }
        {
        target.sendCoin(carol, 1);
        }
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 100
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
        vm.prank(alice);
        {
        target.sendCoin(bob, 100);
        }
        // TODO assert: alice.balance == 9900
        // TODO assert: bob.balance == 100
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
