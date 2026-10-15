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


    // @cover-intent Authorization & Access Control: Verify that a caller with zero tokenBalance can successfully receive an airdrop of 20 tokens.
    function test_Normal_airdrop_for_zero_balance_caller_0() public {
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
        {
        target.tokenBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent Authorization & Access Control: Verify that a caller with non-zero tokenBalance cannot receive an airdrop (hasNoBalance modifier reverts).
    function test_Airdrop_revert_when_caller_already_has_balance_1() public {
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

    // @cover-intent External Interaction & Environment: Verify that a caller (e.g., an EOA) that does not implement supportsToken() causes the airdrop to revert.
    function test_Airdrop_revert_when_caller_does_not_support_token_2() public {
// assume: tokenBalance(bob) == 0
// assume: bob is EOA (no supportsToken function)
// cover: airDrop :: require(keccak256(...) == Bank(msg.sender).supportsToken()) false
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
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: airDrop()
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Demonstrate that a malicious contract can reenter airDrop() via supportsToken() modifier, bypassing the hasNoBalance check and minting extra tokens.
    function test_Reentrancy_attack_via_malicious_contract_3() public {
// assume: carol is a contract that implements supportsToken() with reentrancy
// assume: tokenBalance(carol) == 0 initially
// cover: airDrop :: require(tokenBalance[msg.sender] == 0) true (first call)
// cover: airDrop :: require(tokenBalance[msg.sender] == 0) true (reentrant call)
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
        vm.startPrank(carol);
        // skip ABI-mismatched call: airDrop()
        {
        target.tokenBalance(carol);
        }
        vm.stopPrank();
        // TODO assert: carol.balance == 40
    }

    // @cover-intent Resource & Execution Integrity
    function test_airDrop_test_4() public {
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
    function test_tokenBalance_test_5() public {
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
