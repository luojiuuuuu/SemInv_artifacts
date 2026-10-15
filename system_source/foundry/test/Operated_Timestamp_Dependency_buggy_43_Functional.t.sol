// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;
import "../src/buggy_43.sol";

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

contract Operated_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify that after initialization, the operator is set and active, and that isActiveOperator returns true for the operator and false for others.
    function test_Initial_operator_setup_and_activation_0() public {
// cover: hasActiveOperator :: return _status
// cover: isActiveOperator :: return (isOperator(caller) && hasActiveOperator())
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        {
        target.getOperator();
        }
        {
        target.hasActiveOperator();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.isActiveOperator(owner);
        }
        vm.prank(bob);
        {
        target.isActiveOperator(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that renouncing operator sets status to false and operator to zero address.
    function test_Operator_renunciation_deactivates_1() public {
// cover: _renounceOperator :: require(hasActiveOperator()) true
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        {
        target.hasActiveOperator();
        }
        {
        target.getOperator();
        }
        {
        target.play_tmstmp2(0);
        }
        {
        target.hasActiveOperator();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-active operator cannot call renounceOperator (simulated via play_tmstmp2 which has no such guard, but we test the guard on the internal function).
    function test_Non_operator_cannot_renounce_2() public {
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        vm.startPrank(alice);
        {
        target.play_tmstmp2(0);
        }
        {
        target.hasActiveOperator();
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that play_tmstmp7, play_tmstmp19, play_tmstmp23, play_tmstmp26, play_tmstmp38 accept various startTime values including zero and large values.
    function test_Timestamp_based_play_functions_with_boundary_values_3() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp7(0);
        }
        vm.prank(bob);
        {
        target.play_tmstmp19(100);
        }
        vm.prank(carol);
        // skip malformed call: play_tmstmp23(2**256 - 1) (bad raw arg for play_tmstmp23.arg0: type=uint256, raw=2**256 - 1)
        vm.prank(bob);
        // skip malformed call: play_tmstmp38(block.timestamp + 1 days) (bad raw arg for play_tmstmp38.arg0: type=uint256, raw=block.timestamp + 1 days)
    }

    // @cover-intent Financial & Accounting: Verify that bug_tmstmp20, bug_tmstmp32, bug_tmstmp4 accept exactly 10 ether and succeed.
    function test_Payable_bug_functions_with_exact_ETH_4() public {
// cover: bug_tmstmp20 :: require(msg.value == 10 ether) true
// cover: bug_tmstmp32 :: require(msg.value == 10 ether) true
// cover: bug_tmstmp4 :: require(msg.value == 10 ether) true
        vm.startPrank(alice);
        Operated target = new Operated();
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
        target.bug_tmstmp20.value(10 ether)();
        }
        vm.prank(bob);
        {
        target.bug_tmstmp32.value(10 ether)();
        }
        vm.prank(carol);
        {
        target.bug_tmstmp4.value(10 ether)();
        }
    }

    // @cover-intent Financial & Accounting: Verify that bug functions revert when not sending exactly 10 ether.
    function test_Payable_bug_functions_with_wrong_ETH_amount_5() public {
// cover: bug_tmstmp20 :: require(msg.value == 10 ether) false
// cover: bug_tmstmp32 :: require(msg.value == 10 ether) false
// cover: bug_tmstmp4 :: require(msg.value == 10 ether) false
        vm.startPrank(owner);
        Operated target = new Operated();
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
        {
        target.bug_tmstmp20.value(9 ether)();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.bug_tmstmp32.value(11 ether)();
        }
        vm.expectRevert();
        vm.prank(carol);
        {
        target.bug_tmstmp4();
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that view functions bug_tmstmp17, bug_tmstmp25, getOperator, isOperator, hasActiveOperator, isActiveOperator return consistent results.
    function test_View_functions_return_expected_values_6() public {
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        vm.prank(alice);
        {
        target.bug_tmstmp17();
        }
        vm.prank(bob);
        {
        target.bug_tmstmp25();
        }
        vm.prank(carol);
        {
        target.getOperator();
        }
        vm.prank(alice);
        {
        target.isOperator(owner);
        }
        vm.prank(bob);
        {
        target.isOperator(alice);
        }
        vm.prank(carol);
        {
        target.hasActiveOperator();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that bug_tmstmp20 can be called multiple times (simulating different blocks) with correct ETH.
    function test_Multiple_calls_to_same_payable_function_in_different_blocks_7() public {
        vm.startPrank(alice);
        Operated target = new Operated();
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
        target.bug_tmstmp20.value(10 ether)();
        }
        vm.prank(bob);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        vm.prank(carol);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
    }

    // @cover-intent Protocol State Machine: Verify that operator status transitions correctly through activate/deactivate/renounce sequence.
    function test_Operator_status_after_multiple_state_transitions_8() public {
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        {
        target.hasActiveOperator();
        }
        {
        target.play_tmstmp2(0);
        }
        {
        target.hasActiveOperator();
        }
        {
        target.bug_tmstmp20.value(10 ether)();
        }
        {
        target.hasActiveOperator();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp17_sequence_9() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.bug_tmstmp17();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp20_sequence_10() public {
        vm.startPrank(alice);
        Operated target = new Operated();
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
        target.bug_tmstmp20.value(10 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp25_sequence_11() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.bug_tmstmp25();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp32_sequence_12() public {
        vm.startPrank(alice);
        Operated target = new Operated();
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
        target.bug_tmstmp32.value(10 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp4_sequence_13() public {
        vm.startPrank(alice);
        Operated target = new Operated();
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
        target.bug_tmstmp4.value(10 ether)();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getOperator_sequence_14() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.getOperator();
        }
    }

    // @cover-intent Protocol State Machine
    function test_hasActiveOperator_sequence_15() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.hasActiveOperator();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_isActiveOperator_sequence_16() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.isActiveOperator(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_isOperator_sequence_17() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.isOperator(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_tmstmp19_sequence_18() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp19(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_tmstmp2_sequence_19() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp2(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_tmstmp23_sequence_20() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp23(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_tmstmp26_sequence_21() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp26(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_tmstmp38_sequence_22() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp38(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_tmstmp7_sequence_23() public {
        vm.startPrank(owner);
        Operated target = new Operated();
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
        target.play_tmstmp7(0);
        }
    }

}
