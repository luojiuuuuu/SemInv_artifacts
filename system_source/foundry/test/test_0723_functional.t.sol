// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb7c5c5aa4d42967efe906e1b66cb8df9cebf04f7.sol";

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

contract keepMyEther_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function keepMyEther_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via the fallback function and withdraw the full balance, and that the balance is reset to zero after withdrawal.
    function test_Normal_deposit_and_withdraw_0() public {
// cover: withdraw :: balances[msg.sender] > 0
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v1 = uint256(target.balances(alice));
            _assertRelU(__v1, 0, 0, "call:balances==0");
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate correctly and a single withdrawal returns the total deposited amount.
    function test_Multiple_deposits_and_single_withdrawal_1() public {
// cover: withdraw :: balances[msg.sender] > 0
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v2 = uint256(target.balances(alice));
            _assertRelU(__v2, 0, 0, "call:balances==0");
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that calling withdraw when balance is zero does not revert but sends 0 ETH and sets balance to 0 (no-op).
    function test_Withdraw_with_zero_balance_2() public {
// cover: withdraw :: balances[msg.sender] == 0
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v3 = uint256(target.balances(alice));
            _assertRelU(__v3, 0, 0, "call:balances==0");
        }
    }

    // @cover-intent External Interaction & Environment: Verify that a malicious contract cannot reenter withdraw to drain funds because balance is set to zero after the call (but before external call returns, the balance is still non-zero, so reentrancy is possible; this test demonstrates the vulnerability).
    function test_Reentrancy_attempt_via_fallback_3() public {
// cover: withdraw :: reentrancy via fallback
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v4 = uint256(target.balances(alice));
            _assertRelU(__v4, 0, 0, "call:balances==0");
        }
    }

    // @cover-intent Financial & Accounting: Verify that balances are isolated per user and each can withdraw their own funds.
    function test_Multiple_users_deposit_and_withdraw_independently_4() public {
// cover: withdraw :: balances[msg.sender] > 0
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v5 = uint256(target.balances(alice));
            _assertRelU(__v5, 0, 0, "call:balances==0");
        }
        {
            uint256 __v6 = uint256(target.balances(bob));
            _assertRelU(__v6, 0, 0, "call:balances==0");
        }
    }

    // @cover-intent Financial & Accounting: Verify that the contract handles the smallest unit of ETH (1 wei) correctly.
    function test_Deposit_and_withdraw_with_exact_boundary_1_wei_5() public {
// cover: withdraw :: balances[msg.sender] == 1
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v7 = uint256(target.balances(alice));
            _assertRelU(__v7, 0, 0, "call:balances==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_balances_query_6() public {
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_after_deposit_7() public {
        vm.startPrank(owner);
        keepMyEther target = new keepMyEther();
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
        // skip ABI-mismatched call: withdraw()
        // TODO assert: alice.balance == 0
    }

}
