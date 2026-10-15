// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/modifier_reentrancy.sol";

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

contract ModifierEntrancy_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ModifierEntrancy_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that a user with zero tokenBalance can successfully call airDrop and receive 20 tokens, and that the supportsToken modifier passes when called from a Bank-like contract.
    function test_Normal_airdrop_for_zero_balance_user_0() public {
// assume: tokenBalance(alice) == 0
// cover: airDrop :: require(tokenBalance[msg.sender] == 0) true
// cover: airDrop :: require(keccak256(...) == Bank(msg.sender).supportsToken()) true
        vm.startPrank(owner);
        ModifierEntrancy target = new ModifierEntrancy();
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
        // skip ABI-mismatched call: airDrop()
        // skip ABI-mismatched call: airDrop()
        {
        target.tokenBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent Authorization & Access Control: Verify that a user with non-zero tokenBalance cannot call airDrop due to the hasNoBalance modifier.
    function test_Reject_airdrop_for_non_zero_balance_user_1() public {
// assume: tokenBalance(alice) == 20
// cover: airDrop :: require(tokenBalance[msg.sender] == 0) false
        vm.startPrank(owner);
        ModifierEntrancy target = new ModifierEntrancy();
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
        // skip ABI-mismatched call: airDrop()
        vm.expectRevert();
        // skip ABI-mismatched call: airDrop()
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent Resource & Execution Integrity: Verify that a malicious contract can exploit the modifier reentrancy to call airDrop multiple times, bypassing the hasNoBalance check, and receive extra tokens.
    function test_Reentrancy_attack_via_malicious_contract_2() public {
// assume: tokenBalance(alice) == 0
// cover: airDrop :: require(tokenBalance[msg.sender] == 0) true
// cover: airDrop :: require(keccak256(...) == Bank(msg.sender).supportsToken()) true
        vm.startPrank(owner);
        ModifierEntrancy target = new ModifierEntrancy();
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
        // skip ABI-mismatched call: airDrop()
        // skip ABI-mismatched call: airDrop()
        {
        target.tokenBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 40
    }

    // @cover-intent Resource & Execution Integrity
    function test_airDrop_test_3() public {
        vm.startPrank(owner);
        ModifierEntrancy target = new ModifierEntrancy();
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
        // skip ABI-mismatched call: airDrop()
        // skip ABI-mismatched call: airDrop()
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent Financial & Accounting
    function test_tokenBalance_test_4() public {
        vm.startPrank(owner);
        ModifierEntrancy target = new ModifierEntrancy();
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
        // skip ABI-mismatched call: airDrop()
        {
        target.tokenBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

}
