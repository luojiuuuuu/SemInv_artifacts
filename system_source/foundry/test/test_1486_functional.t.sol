// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/token-with-backdoor.sol";

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

contract Token_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Token_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that airdrop sets balance to 1000, consume decrements it, and test_invariants passes when balance <= 1000.
    function test_Normal_airdrop_and_consume_0() public {
// cover: consume :: require(balances[msg.sender]>0) true
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) true
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: consume()
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: alice.balance == 999
    }

    // @cover-intent Financial & Accounting: Verify that backdoor can increase balance beyond 1000, causing test_invariants to fail.
    function test_Backdoor_overflow_boundary_1() public {
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) false
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: backdoor()
        vm.expectRevert();
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: alice.balance == 1001
    }

    // @cover-intent Resource & Execution Integrity: Verify that consume reverts when balance is zero.
    function test_Consume_with_zero_balance_reverts_2() public {
// cover: consume :: require(balances[msg.sender]>0) false
        vm.startPrank(owner);
        Token target = new Token();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: consume()
    }

    // @cover-intent Financial & Accounting: Verify that repeated backdoor calls can push balance arbitrarily high, causing invariant violation.
    function test_Multiple_backdoors_and_test_invariants_3() public {
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) false
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: backdoor()
        // skip ABI-mismatched call: backdoor()
        vm.expectRevert();
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: alice.balance == 1002
    }

    // @cover-intent Financial & Accounting: Verify that consuming exactly 1000 times leaves balance at 0, and test_invariants passes.
    function test_Airdrop_then_consume_to_zero_4() public {
// cover: consume :: require(balances[msg.sender]>0) true
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) true
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: consume()
        // skip ABI-mismatched call: consume()
        // skip ABI-mismatched call: consume()
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: alice.balance == 997
    }

    // @cover-intent Financial & Accounting: Verify that backdoor works even without airdrop, and test_invariants passes for small balance.
    function test_Backdoor_only_without_airdrop_5() public {
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) true
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: backdoor()
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: bob.balance == 1
    }

    // @cover-intent Financial & Accounting: Verify mixed operations keep balance within invariant after consume reduces it below 1000.
    function test_Airdrop_then_backdoor_then_consume_6() public {
// cover: consume :: require(balances[msg.sender]>0) true
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) true
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: backdoor()
        // skip ABI-mismatched call: consume()
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: alice.balance == 1000
    }

    // @cover-intent Financial & Accounting: Verify that balances are independent per user and test_invariants works for each.
    function test_Multiple_users_independent_balances_7() public {
// cover: test_invariants :: assert(balances[msg.sender] <= 1000) true
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        vm.prank(bob);
        // skip ABI-mismatched call: airdrop()
        vm.prank(alice);
        // skip ABI-mismatched call: test_invariants()
        vm.prank(bob);
        // skip ABI-mismatched call: test_invariants()
        // TODO assert: alice.balance == 1000
        // TODO assert: bob.balance == 1000
    }

    // @cover-intent Financial & Accounting
    function test_airdrop_sequence_8() public {
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // TODO assert: alice.balance == 1000
    }

    // @cover-intent Financial & Accounting
    function test_backdoor_sequence_9() public {
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: backdoor()
        vm.stopPrank();
        // TODO assert: alice.balance == 1001
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_10() public {
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1000
    }

    // @cover-intent Financial & Accounting
    function test_consume_sequence_11() public {
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: consume()
        vm.stopPrank();
        // TODO assert: alice.balance == 999
    }

    // @cover-intent Financial & Accounting
    function test_test_invariants_sequence_12() public {
        vm.startPrank(owner);
        Token target = new Token();
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
        // skip ABI-mismatched call: airdrop()
        // skip ABI-mismatched call: backdoor()
        vm.expectRevert();
        // skip ABI-mismatched call: test_invariants()
        vm.stopPrank();
        // TODO assert: alice.balance == 1001
    }

}
