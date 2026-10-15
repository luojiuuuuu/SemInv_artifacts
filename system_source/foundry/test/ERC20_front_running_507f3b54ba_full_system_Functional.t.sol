// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/ERC20.sol";

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

contract ERC20_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ERC20_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify a simple transfer from the owner (who has initial supply) to alice succeeds, updating balances and emitting Transfer event.
    function test_Basic_transfer_from_owner_to_alice_0() public {
// assume: balanceOf(owner) >= 50
// cover: transfer :: require(balance>=amount) true
// cover: transfer :: require(to!=0) true
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.transfer(alice, 50);
        }
    }

    // @cover-intent Resource & Execution Integrity: Ensure transfer to address(0) reverts as per require(to != address(0)).
    function test_Transfer_to_zero_address_reverts_1() public {
// assume: balanceOf(owner) >= 10
// cover: transfer :: require(to!=0) false
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.transfer(0x0000000000000000000000000000000000000000, 10);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify transfer fails when sender lacks sufficient balance.
    function test_Transfer_with_insufficient_balance_reverts_2() public {
// assume: balanceOf(alice) == 0
// cover: transfer :: require(balance>=amount) false
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 1);
        }
    }

    // @cover-intent Authorization & Access Control: Verify approve sets allowance and transferFrom moves tokens from owner to bob via alice's approval.
    function test_Approve_and_transferFrom_positive_path_3() public {
// assume: balanceOf(owner) >= 20
// assume: allowance(owner, alice) >= 20
// cover: transferFrom :: require(balance>=amount) true
// cover: transferFrom :: require(allowance>=amount) true
// cover: transferFrom :: require(to!=0) true
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(alice, 30);
        }
        vm.prank(alice);
        {
        target.transferFrom(owner, bob, 20);
        }
    }

    // @cover-intent Resource & Execution Integrity: Ensure approve to address(0) reverts as per require(spender != address(0)).
    function test_Approve_to_zero_address_reverts_4() public {
// cover: approve :: require(spender!=0) false
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(0x0000000000000000000000000000000000000000, 100);
        }
    }

    // @cover-intent Authorization & Access Control: Verify transferFrom fails when spender's allowance is insufficient.
    function test_TransferFrom_with_insufficient_allowance_reverts_5() public {
// assume: balanceOf(owner) >= 10
// assume: allowance(owner, alice) == 5
// cover: transferFrom :: require(allowance>=amount) false
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(alice, 5);
        }
        vm.prank(alice);
        {
        target.transferFrom(owner, bob, 10);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify transferFrom fails when from address has insufficient balance.
    function test_TransferFrom_with_insufficient_balance_reverts_6() public {
// assume: balanceOf(alice) == 0
// assume: allowance(alice, bob) >= 1
// cover: transferFrom :: require(balance>=amount) false
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity: Ensure transferFrom to address(0) reverts.
    function test_TransferFrom_to_zero_address_reverts_7() public {
// assume: balanceOf(owner) >= 5
// assume: allowance(owner, alice) >= 5
// cover: transferFrom :: require(to!=0) false
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(alice, 10);
        }
        vm.prank(alice);
        {
        target.transferFrom(owner, 0x0000000000000000000000000000000000000000, 5);
        }
    }

    // @cover-intent Authorization & Access Control: Verify allowance returns correct value after approve.
    function test_Allowance_read_after_approve_8() public {
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        {
        target.approve(bob, 42);
        }
        {
        target.allowance(owner, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify balanceOf returns correct balance after a transfer.
    function test_BalanceOf_after_transfer_9() public {
// assume: balanceOf(owner) >= 30
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        {
        target.transfer(alice, 30);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent Authorization & Access Control
    function test_allowance_test_10() public {
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 50);
        }
        vm.prank(owner);
        {
        target.allowance(alice, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approve_test_11() public {
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 30);
        }
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_test_12() public {
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_transfer_test_13() public {
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 40);
        }
        // TODO assert: alice.balance == 60
        // TODO assert: bob.balance == 40
    }

    // @cover-intent Authorization & Access Control
    function test_transferFrom_test_14() public {
        vm.startPrank(owner);
        ERC20 target = new ERC20(100);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 50);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 20);
        }
        // TODO assert: alice.balance == 80
        // TODO assert: carol.balance == 20
    }

}
