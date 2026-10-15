// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;
import "../src/buggy_2.sol";

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

contract CareerOnToken_FunctionalTest {
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


    // @cover-intent Financial & Accounting: Verify basic transfer works correctly and balances update accordingly
    function test_basic_transfer_positive_0() public {
// assume: isTransPaused == false
// assume: balances[alice] >= 700
// cover: transfer :: assert condition true
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
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
    function test_transfer_insufficient_balance_1() public {
// assume: isTransPaused == false
// assume: balances[alice] == 100
// cover: transfer :: assert(balances[msg.sender] >= _value) false
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
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

    // @cover-intent Financial & Accounting: Verify approve and transferFrom workflow works correctly
    function test_approve_and_transferFrom_positive_2() public {
// assume: isTransPaused == false
// assume: allowed[alice][bob] == 500
// assume: balances[alice] >= 500
// cover: transferFrom :: assert condition true
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 500);
        }
        vm.startPrank(bob);
        {
        target.transferFrom(alice, carol, 300);
        }
        {
        target.transferFrom(alice, bob, 200);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 500
        // TODO assert: carol.balance == 300
        // TODO assert: bob.balance == 200
    }

    // @cover-intent Financial & Accounting: Verify transferFrom reverts when allowance is insufficient
    function test_transferFrom_exceeds_allowance_3() public {
// assume: isTransPaused == false
// assume: allowed[alice][bob] == 100
// assume: balances[alice] >= 200
// cover: transferFrom :: assert(allowed[_from][msg.sender] >= _value) false
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
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
        // TODO assert: alice.balance == 1000
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify approve to self reverts
    function test_approve_self_reverts_4() public {
// cover: approve :: assert(msg.sender != _spender) false
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(alice, 100);
        }
    }

    // @cover-intent Transactional Consistency: Verify approve with zero value reverts
    function test_approve_zero_value_reverts_5() public {
// cover: approve :: assert(_value > 0) false
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 0);
        }
    }

    // @cover-intent Authorization & Access Control: Verify owner can transfer ownership with balances
    function test_changeOwner_positive_6() public {
// assume: msg.sender == owner
// assume: msg.sender != alice
// cover: changeOwner :: assert condition true
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 500);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.changeOwner(alice);
        }
        // TODO assert: alice.balance == 500
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot change ownership
    function test_changeOwner_non_owner_reverts_7() public {
// assume: msg.sender != owner
// cover: changeOwner :: assert(msg.sender == owner) false
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Protocol State Machine: Verify pausing blocks transfers and unpausing allows them
    function test_setPauseStatus_blocks_transfers_8() public {
// assume: isTransPaused == true (after first require)
// assume: balances[alice] >= 100
// cover: transfer :: assert(!isTransPaused) false (first step)
// cover: transfer :: assert(!isTransPaused) true (third step)
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setPauseStatus(true);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 100);
        }
        vm.prank(owner);
        {
        target.setPauseStatus(false);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 100);
        }
        // TODO assert: alice.balance == 900
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Authorization & Access Control
    function test_allowance_9() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
    function test_allowed_10() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.allowed(alice, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approve_11() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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

    // @cover-intent Financial & Accounting
    function test_balances_12() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.balances(alice);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_13() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou20_14() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou20(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou23_15() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
    function test_bug_intou27_16() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
    function test_bug_intou31_17() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
    function test_bug_intou32_18() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou32(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_19() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou36_20() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou36(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_21() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou4_22() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou4(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou40_23() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou40(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou7_24() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou8_25() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.bug_intou8(1);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_26() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.changeOwner(alice);
        }
        // TODO assert: owner.balance == 0
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_decimals_27() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: decimals()
        {
            uint256 __v1 = uint256(target.decimals());
            _assertRelU(__v1, 0, 2, "call:decimals==2");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_28() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.increaseLockTime_intou13(100);
        }
        {
            uint256 __v2 = uint256(target.lockTime_intou13(alice));
            _assertRelU(__v2, 2, 100, "call:lockTime_intou13>=100");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou25_29() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.increaseLockTime_intou25(100);
        }
        {
            uint256 __v3 = uint256(target.lockTime_intou25(alice));
            _assertRelU(__v3, 2, 100, "call:lockTime_intou25>=100");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou33_30() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.increaseLockTime_intou33(100);
        }
        {
            uint256 __v4 = uint256(target.lockTime_intou33(alice));
            _assertRelU(__v4, 2, 100, "call:lockTime_intou33>=100");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou13_31() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        {
            uint256 __v5 = uint256(target.lockTime_intou13(alice));
            _assertRelU(__v5, 0, 0, "call:lockTime_intou13==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou25_32() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.lockTime_intou25(alice);
        }
        {
            uint256 __v6 = uint256(target.lockTime_intou25(alice));
            _assertRelU(__v6, 0, 0, "call:lockTime_intou25==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou33_33() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.lockTime_intou33(alice);
        }
        {
            uint256 __v7 = uint256(target.lockTime_intou33(alice));
            _assertRelU(__v7, 0, 0, "call:lockTime_intou33==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_name_34() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: name()
        // TODO assert: call:name() == "CareerOn Chain Token"
    }

    // @cover-intent Authorization & Access Control
    function test_owner_35() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_setPauseStatus_36() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setPauseStatus(true);
        }
    }

    // @cover-intent Financial & Accounting
    function test_symbol_37() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
        // TODO assert: call:symbol() == "COT"
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_38() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
        {
            uint256 __v8 = uint256(target.totalSupply());
            _assertRelU(__v8, 0, 100000000000000000, "call:totalSupply==100000000000000000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_39() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.transfer(alice, 10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transferFrom_40() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(bob, 50);
        }
        vm.prank(bob);
        {
        target.transferFrom(owner, alice, 10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_41() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou14(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou26_42() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou26(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_43() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou30(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou38_44() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer_intou38(bob, 0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_45() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou13(1);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou25_46() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou25(1);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou25()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_47() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.increaseLockTime_intou33(1);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

    // @cover-intent minimal test for changeContractName
    function test_perfn_changeContractName_48() public {
        vm.startPrank(owner);
        CareerOnToken target = new CareerOnToken(100, 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.changeContractName("Name", "SYM");
        }
    }

}
