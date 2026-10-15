// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;
import "../src/buggy_44.sol";

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


    // @cover-intent Authorization & Access Control: Verify the full lifecycle of operator management: set operator, activate, verify active status, transfer to new operator, renounce.
    function test_Operator_lifecycle_set_activate_check_transfer_renounce_0() public {
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.isActiveOperator(alice);
        }
        {
        target.hasActiveOperator();
        }
        {
        target.getOperator();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD10
    function test_Claim_reward_TOD10_positive_path_with_valid_submission_1() public {
// cover: claimReward_TOD10 :: require(!claimed_TOD10) true
// cover: claimReward_TOD10 :: require(submission < 10) true
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(100)));
        vm.store(address(target), bytes32(uint256(4)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD10.value(100)();
        }
        {
        target.claimReward_TOD10(5);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD10
    function test_Claim_reward_TOD10_revert_when_already_claimed_2() public {
// cover: claimReward_TOD10 :: require(!claimed_TOD10) false
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(1)));
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.claimReward_TOD10(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD10
    function test_Claim_reward_TOD10_revert_when_submission_10_3() public {
// cover: claimReward_TOD10 :: require(submission < 10) false
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.claimReward_TOD10(10);
        }
    }

    // @cover-intent Protocol State Machine: Verify play_TOD1 sets winner when guess matches 'hello'.
    function test_Play_TOD1_correct_guess_sets_winner_4() public {
// cover: play_TOD1 :: keccak256(guess) == keccak256('hello') true
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(5)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.play_TOD1(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent Protocol State Machine: Verify play_TOD1 does not set winner when guess does not match 'hello'.
    function test_Play_TOD1_wrong_guess_does_not_set_winner_5() public {
// cover: play_TOD1 :: keccak256(guess) == keccak256('hello') false
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(5)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.play_TOD1(bytes32(uint256(54022138726888104220405905141212465368814055558095984243072137216904367439872)));
        }
    }

    // @cover-intent Authorization & Access Control: Verify setReward_TOD2 requires msg.sender == owner_TOD2.
    function test_Set_reward_TOD2_only_owner_can_set_6() public {
// cover: setReward_TOD2 :: require(msg.sender == owner_TOD2) false
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(6)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(7)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(8)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setReward_TOD2.value(100)();
        }
    }

    // @cover-intent state transition test for claimReward_TOD22
    function test_Claim_reward_TOD22_positive_path_7() public {
// cover: claimReward_TOD22 :: require(!claimed_TOD22) true
// cover: claimReward_TOD22 :: require(submission < 10) true
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(9)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(10)), bytes32(uint256(100)));
        vm.store(address(target), bytes32(uint256(11)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD22.value(100)();
        }
        {
        target.claimReward_TOD22(3);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD26
    function test_Claim_reward_TOD26_revert_when_submission_10_8() public {
// cover: claimReward_TOD26 :: require(submission < 10) false
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(12)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(13)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.claimReward_TOD26(15);
        }
    }

    // @cover-intent Authorization & Access Control: Verify view functions return correct values for operator status.
    function test_View_functions_isOperator_and_isActiveOperator_9() public {
        vm.startPrank(owner);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.isOperator(alice);
        }
        {
        target.isActiveOperator(alice);
        }
        {
        target.hasActiveOperator();
        }
        {
        target.getOperator();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD10
    function test_claimReward_TOD10_positive_10() public {
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
        target.setReward_TOD10.value(1 ether)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD10(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD2
    function test_claimReward_TOD2_positive_11() public {
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
        target.setReward_TOD2.value(2 ether)();
        }
        vm.prank(bob);
        {
        target.claimReward_TOD2(3);
        }
    }

    // @cover-intent state transition test for claimReward_TOD22
    function test_claimReward_TOD22_positive_12() public {
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
        target.setReward_TOD22.value(3 ether)();
        }
        vm.prank(carol);
        {
        target.claimReward_TOD22(7);
        }
    }

    // @cover-intent state transition test for claimReward_TOD26
    function test_claimReward_TOD26_positive_13() public {
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
        target.setReward_TOD26.value(4 ether)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD26(1);
        }
    }

    // @cover-intent Protocol State Machine
    function test_getOperator_view_14() public {
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

    // @cover-intent Financial & Accounting
    function test_getReward_TOD1_positive_15() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD1(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD1.value(1 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD17_positive_16() public {
        vm.startPrank(bob);
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
        vm.startPrank(bob);
        {
        target.play_TOD17(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD17.value(2 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD19_positive_17() public {
        vm.startPrank(carol);
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
        vm.startPrank(carol);
        {
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD19.value(3 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD25_positive_18() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD25(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD25.value(4 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD3_positive_19() public {
        vm.startPrank(bob);
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
        vm.startPrank(bob);
        {
        target.play_TOD3(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD3.value(5 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD33_positive_20() public {
        vm.startPrank(carol);
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
        vm.startPrank(carol);
        {
        target.play_TOD33(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD33.value(6 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD37_positive_21() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD37(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD37.value(7 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD9_positive_22() public {
        vm.startPrank(bob);
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
        vm.startPrank(bob);
        {
        target.play_TOD9(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD9.value(8 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_hasActiveOperator_view_23() public {
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
    function test_isActiveOperator_view_24() public {
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
    function test_isOperator_view_25() public {
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

    // @cover-intent External Interaction & Environment
    function test_play_TOD1_positive_26() public {
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
        target.play_TOD1(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD17_positive_27() public {
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
        vm.prank(bob);
        {
        target.play_TOD17(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD19_positive_28() public {
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
        vm.prank(carol);
        {
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD25_positive_29() public {
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
        target.play_TOD25(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD3_positive_30() public {
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
        vm.prank(bob);
        {
        target.play_TOD3(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD33_positive_31() public {
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
        vm.prank(carol);
        {
        target.play_TOD33(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD37_positive_32() public {
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
        target.play_TOD37(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD9_positive_33() public {
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
        vm.prank(bob);
        {
        target.play_TOD9(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD10_positive_34() public {
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
        target.setReward_TOD10.value(1 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD2_positive_35() public {
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
        target.setReward_TOD2.value(2 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD22_positive_36() public {
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
        target.setReward_TOD22.value(3 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD26_positive_37() public {
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
        target.setReward_TOD26.value(4 ether)();
        }
    }

}
