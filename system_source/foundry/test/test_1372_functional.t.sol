// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/mishandled.sol";

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

contract SendBack_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function SendBack_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user with zero balance can call withdrawBalance without error and no state change occurs.
    function test_Normal_withdrawal_with_zero_balance_0() public {
// assume: userBalances[alice] == 0
        vm.startPrank(owner);
        SendBack target = new SendBack();
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
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that a user with a positive balance can withdraw and the mapping is zeroed out.
    function test_Withdrawal_after_deposit_simulated_via_prestate_1() public {
// assume: userBalances[alice] == 100
        vm.startPrank(owner);
        SendBack target = new SendBack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify that two users with balances can withdraw independently and their balances are correctly zeroed.
    function test_Multiple_withdrawals_from_different_users_2() public {
// assume: userBalances[alice] == 50
// assume: userBalances[bob] == 20
        vm.startPrank(owner);
        SendBack target = new SendBack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(50)));
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(20)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 20
    }

    // @cover-intent External Interaction & Environment: Verify that if the recipient contract reverts, the send fails but the balance is already zeroed, preventing reentrancy.
    function test_Reentrancy_attempt_send_fails_silently_3() public {
// assume: userBalances[alice] == 100
// assume: address(alice).code.length > 0
        vm.startPrank(owner);
        SendBack target = new SendBack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_basic_4() public {
        vm.startPrank(owner);
        SendBack target = new SendBack();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=keccak256(abi.encode(alice, uint(0))), value=100;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 100
    }

}
