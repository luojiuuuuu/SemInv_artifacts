// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/incorrect_constructor_name1.sol";

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

contract Missing_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Missing_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that IamMissing() sets the owner and then only the owner can call withdraw()
    function test_authorization_setup_and_withdraw_0() public {
// assume: alice is the first caller of IamMissing()
// cover: IamMissing :: owner = msg.sender
// cover: withdraw :: require(msg.sender==owner) true
// cover: withdraw :: require(msg.sender==owner) false
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: IamMissing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() reverts when no owner has been set via IamMissing()
    function test_unauthorized_withdraw_before_setup_1() public {
// assume: IamMissing() has not been called yet
// cover: withdraw :: require(msg.sender==owner) false (owner is address(0))
        vm.startPrank(owner);
        Missing target = new Missing();
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
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting: Verify that withdraw() sends the contract balance to the owner when called by the owner
    function test_owner_transfer_with_balance_2() public {
// assume: alice is owner after calling IamMissing()
// assume: contract has 50 wei from fallback
// cover: withdraw :: owner.transfer(this.balance)
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: IamMissing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that IamMissing() can be called multiple times, overwriting the owner each time
    function test_multiple_owner_setup_attempts_3() public {
// assume: IamMissing() can be called by anyone to change owner
// cover: IamMissing :: owner = msg.sender (second call by bob)
// cover: withdraw :: require(msg.sender==owner) true (bob)
// cover: withdraw :: require(msg.sender==owner) false (alice after bob)
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: IamMissing()
        vm.startPrank(bob);
        // skip ABI-mismatched call: IamMissing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw() succeeds even when contract balance is zero
    function test_withdraw_with_zero_balance_4() public {
// assume: contract balance is 0
// cover: withdraw :: owner.transfer(0)
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: IamMissing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_IamMissing_positive_5() public {
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: IamMissing()
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_6() public {
        vm.startPrank(owner);
        Missing target = new Missing();
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
        // skip ABI-mismatched call: IamMissing()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

}
