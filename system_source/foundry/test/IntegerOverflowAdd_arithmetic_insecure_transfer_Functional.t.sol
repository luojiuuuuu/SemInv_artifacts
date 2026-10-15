// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/insecure_transfer.sol";

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

contract IntegerOverflowAdd_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowAdd_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify a normal transfer between two addresses with sufficient balance succeeds and balances update correctly
    function test_normal_transfer_0() public {
// assume: balanceOf(alice) >= 50
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 50);
        }
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify transfer reverts when sender has insufficient balance
    function test_transfer_insufficient_balance_1() public {
// assume: balanceOf(alice) == 10
// cover: transfer :: require(balanceOf[msg.sender] >= _value) false
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transfer(bob, 20);
        }
        // TODO assert: alice.balance == 10
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify transfer of zero value succeeds and does not change balances
    function test_transfer_zero_value_2() public {
// assume: balanceOf(alice) >= 0
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 0);
        }
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify transfer of maximum uint256 value causes integer overflow on addition to recipient
    function test_transfer_max_uint256_3() public {
// assume: balanceOf(alice) >= 100
// assume: balanceOf(bob) == 100
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
// cover: transfer :: require(balanceOf[msg.sender] >= _value) false
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 100);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transfer(alice, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify transfer to self succeeds and balance remains unchanged
    function test_transfer_self_4() public {
// assume: balanceOf(alice) >= 50
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(alice, 50);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify transfer to address(0) succeeds (no special protection in contract)
    function test_transfer_to_zero_address_5() public {
// assume: balanceOf(alice) >= 50
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(0x0000000000000000000000000000000000000000, 50);
        }
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify transfer of exact balance succeeds and sender balance becomes zero
    function test_transfer_exact_balance_6() public {
// assume: balanceOf(alice) == 100
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 100);
        }
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify multiple transfers from same sender work correctly
    function test_transfer_multiple_recipients_7() public {
// assume: balanceOf(alice) >= 60
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
// cover: transfer :: require(balanceOf[msg.sender] >= _value) true
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.transfer(bob, 30);
        }
        {
        target.transfer(carol, 30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 40
        // TODO assert: bob.balance == 30
        // TODO assert: carol.balance == 30
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_view_8() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_overflow_9() public {
        vm.startPrank(owner);
        IntegerOverflowAdd target = new IntegerOverflowAdd();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: balanceOf[alice] = 100;
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 1);
        }
    }

}
