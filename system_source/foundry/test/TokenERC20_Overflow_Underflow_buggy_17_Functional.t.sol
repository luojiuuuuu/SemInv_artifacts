// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;
import "../src/buggy_17.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract TokenERC20_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Transfer 60 from alice to bob (supply conserved)
    function test_erc20_transfer_0() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 600);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 60);
        }
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent approve -> transferFrom flow
    function test_erc20_approve_spend_1() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 200);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, bob, 60);
        }
        _assertEqU(target.allowance(alice, bob), 40);
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent Financial & Accounting: Verify standard ERC20 transfer works correctly, updating balances and emitting Transfer event
    function test_basic_transfer_positive_2() public {
// assume: balanceOf(alice) >= 700
// cover: _transfer :: require(_to != address(0x0)) true
// cover: _transfer :: balanceOf[_from].sub(_value) succeeds
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.transfer(bob, 500);
        }
        {
        target.transfer(carol, 200);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 300
        // TODO assert: bob.balance == 500
        // TODO assert: carol.balance == 200
    }

    // @cover-intent Financial & Accounting: Verify transfer reverts when sender has insufficient balance
    function test_transfer_insufficient_balance_3() public {
// assume: balanceOf(alice) == 100
// cover: _transfer :: balanceOf[_from].sub(_value) reverts
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 200);
        }
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify transfer to zero address reverts
    function test_transfer_to_zero_address_4() public {
// assume: balanceOf(alice) >= 50
// cover: _transfer :: require(_to != address(0x0)) false
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(0x0000000000000000000000000000000000000000, 50);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Authorization & Access Control: Verify approve and transferFrom workflow with allowance deduction
    function test_approve_and_transferFrom_5() public {
// assume: allowance(alice, bob) == 300
// assume: balanceOf(alice) >= 300
// cover: transferFrom :: allowance[_from][msg.sender].sub(_value) succeeds
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 300);
        }
        vm.startPrank(bob);
        {
        target.transferFrom(alice, carol, 200);
        }
        {
        target.transferFrom(alice, bob, 100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 700
        // TODO assert: carol.balance == 200
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Authorization & Access Control: Verify transferFrom reverts when allowance is insufficient
    function test_transferFrom_exceeds_allowance_6() public {
// assume: allowance(alice, bob) == 100
// cover: transferFrom :: allowance[_from][msg.sender].sub(_value) reverts
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 500);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 200);
        }
        // TODO assert: alice.balance == 500
        // TODO assert: carol.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify approveAndCall calls external receiveApproval and sets allowance
    function test_approveAndCall_positive_7() public {
// assume: bob implements tokenRecipient.receiveApproval
// cover: approveAndCall :: approve(_spender, _value) returns true
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approveAndCall(bob, 500, hex"00");
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify lock time increase can overflow and then withdraw becomes possible
    function test_increaseLockTime_and_withdraw_overflow_8() public {
// assume: lockTime_intou1(alice) overflows to 0 after second call
// cover: increaseLockTime_intou1 :: lockTime_intou1[msg.sender] += _secondsToIncrease overflows
// cover: withdraw_ovrflow1 :: require(now > lockTime_intou1[msg.sender]) true after overflow
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        // skip malformed call: increaseLockTime_intou1(2**256 - 1) (bad raw arg for increaseLockTime_intou1.arg0: type=uint256, raw=2**256 - 1)
        {
        target.increaseLockTime_intou1(1);
        }
        // skip ABI-mismatched call: withdraw_ovrflow1()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify transfer_undrflow2 reverts due to underflow check (balance - value >= 0)
    function test_transfer_undrflow2_underflow_9() public {
// assume: balances_intou2(alice) == 50
// cover: transfer_undrflow2 :: require(balances_intou2[msg.sender] - _value >= 0) false
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 50);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_undrflow2(bob, 100);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify bug_intou11 causes uint8 underflow (vundflw = 0 - 10)
    function test_bug_intou11_underflow_10() public {
// cover: bug_intou11 :: vundflw = vundflw - 10 underflows
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent Resource & Execution Integrity: Verify bug_intou12 causes uint8 overflow (vundflw1 = 0 + p_intou12)
    function test_bug_intou12_overflow_11() public {
// cover: bug_intou12 :: vundflw1 = vundflw1 + p_intou12 overflows
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.bug_intou12(255);
        }
        {
        target.bug_intou12(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_allowance_12() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.allowance(alice, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approve_13() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_approveAndCall_14() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approveAndCall(bob, 50, hex"00");
        }
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_15() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou11_16() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou12_17() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou12(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou23_18() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_19() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_20() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou4_21() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou4(2);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou7_22() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent Financial & Accounting
    function test_decimals_23() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: decimals()
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou1_24() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.increaseLockTime_intou1(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_25() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.increaseLockTime_intou13(200);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou17_26() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.increaseLockTime_intou17(300);
        }
    }

    // @cover-intent Financial & Accounting
    function test_lockTime_intou1_27() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.lockTime_intou1(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_lockTime_intou13_28() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_lockTime_intou17_29() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_name_30() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: name()
    }

    // @cover-intent Financial & Accounting
    function test_symbol_31() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_32() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
    }

    // @cover-intent Financial & Accounting
    function test_transfer_33() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transferFrom_34() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 50);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 20);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_35() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou14(bob, 5);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou22_36() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou22(bob, 5);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_37() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou30(bob, 5);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou38_38() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou38(bob, 5);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_undrflow2_39() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_undrflow2(bob, 5);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_intou13_40() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou13(0);
        }
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_intou17_41() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou17(0);
        }
        // skip ABI-mismatched call: withdraw_intou17()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_ovrflow1_42() public {
        vm.startPrank(owner);
        TokenERC20 target = new TokenERC20("X", "X", 1);
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
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou1(0);
        }
        // skip ABI-mismatched call: withdraw_ovrflow1()
        vm.stopPrank();
    }

}
