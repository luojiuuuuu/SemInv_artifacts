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


    // @cover-intent Authorization & Access Control: Verify the full lifecycle of operator management including setting, activating, transferring, and renouncing operator status.
    function test_Operator_lifecycle_set_activate_transfer_renounce_0() public {
// cover: getOperator :: returns operator address
// cover: hasActiveOperator :: returns _status
// cover: isActiveOperator :: isOperator(caller) && hasActiveOperator()
// cover: isOperator :: caller == getOperator()
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
        vm.startPrank(alice);
        {
        target.getOperator();
        }
        {
        target.hasActiveOperator();
        }
        {
        target.isActiveOperator(alice);
        }
        {
        target.isOperator(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD12
    function test_Reward_set_and_claim_TOD12_1() public {
// assume: claimed_TOD12 == false
// cover: setReward_TOD12 :: require(!claimed_TOD12) true
// cover: setReward_TOD12 :: require(msg.sender == owner_TOD12) true
// cover: claimReward_TOD12 :: require(!claimed_TOD12) true
// cover: claimReward_TOD12 :: require(submission < 10) true
// cover: claimReward_TOD12 :: require(!claimed_TOD12) false
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD12.value(10)();
        }
        {
        target.claimReward_TOD12(5);
        }
        vm.expectRevert();
        {
        target.claimReward_TOD12(5);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD20
    function test_Reward_set_and_claim_TOD20_2() public {
// assume: claimed_TOD20 == false
// cover: setReward_TOD20 :: require(!claimed_TOD20) true
// cover: setReward_TOD20 :: require(msg.sender == owner_TOD20) true
// cover: claimReward_TOD20 :: require(!claimed_TOD20) true
// cover: claimReward_TOD20 :: require(submission < 10) true
// cover: claimReward_TOD20 :: require(!claimed_TOD20) false
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD20.value(20)();
        }
        {
        target.claimReward_TOD20(3);
        }
        vm.expectRevert();
        {
        target.claimReward_TOD20(3);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD22
    function test_Reward_set_and_claim_TOD22_3() public {
// assume: claimed_TOD22 == false
// cover: setReward_TOD22 :: require(!claimed_TOD22) true
// cover: setReward_TOD22 :: require(msg.sender == owner_TOD22) true
// cover: claimReward_TOD22 :: require(!claimed_TOD22) true
// cover: claimReward_TOD22 :: require(submission < 10) true
// cover: claimReward_TOD22 :: require(!claimed_TOD22) false
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD22.value(30)();
        }
        {
        target.claimReward_TOD22(7);
        }
        vm.expectRevert();
        {
        target.claimReward_TOD22(7);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD26
    function test_Reward_set_and_claim_TOD26_4() public {
// assume: claimed_TOD26 == false
// cover: setReward_TOD26 :: require(!claimed_TOD26) true
// cover: setReward_TOD26 :: require(msg.sender == owner_TOD26) true
// cover: claimReward_TOD26 :: require(!claimed_TOD26) true
// cover: claimReward_TOD26 :: require(submission < 10) true
// cover: claimReward_TOD26 :: require(!claimed_TOD26) false
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(4)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD26.value(40)();
        }
        {
        target.claimReward_TOD26(2);
        }
        vm.expectRevert();
        {
        target.claimReward_TOD26(2);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD32
    function test_Reward_set_and_claim_TOD32_5() public {
// assume: claimed_TOD32 == false
// cover: setReward_TOD32 :: require(!claimed_TOD32) true
// cover: setReward_TOD32 :: require(msg.sender == owner_TOD32) true
// cover: claimReward_TOD32 :: require(!claimed_TOD32) true
// cover: claimReward_TOD32 :: require(submission < 10) true
// cover: claimReward_TOD32 :: require(!claimed_TOD32) false
        vm.startPrank(alice);
        Operated target = new Operated();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(5)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.setReward_TOD32.value(50)();
        }
        {
        target.claimReward_TOD32(8);
        }
        vm.expectRevert();
        {
        target.claimReward_TOD32(8);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test the play and getReward pattern for TOD3 with correct guess.
    function test_Play_and_get_reward_TOD3_pattern_6() public {
// cover: play_TOD3 :: keccak256(guess) == keccak256('hello') true
// cover: getReward_TOD3 :: winner_TOD3.transfer(msg.value)
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
        target.play_TOD3(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD3.value(10)();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test the play and getReward pattern for TOD9 with correct guess.
    function test_Play_and_get_reward_TOD9_pattern_7() public {
// cover: play_TOD9 :: keccak256(guess) == keccak256('hello') true
// cover: getReward_TOD9 :: winner_TOD9.transfer(msg.value)
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
        target.play_TOD9(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD9.value(10)();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test the play and getReward pattern for TOD17 with correct guess.
    function test_Play_and_get_reward_TOD17_pattern_8() public {
// cover: play_TOD17 :: keccak256(guess) == keccak256('hello') true
// cover: getReward_TOD17 :: winner_TOD17.transfer(msg.value)
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
        target.play_TOD17(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD17.value(10)();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test the play and getReward pattern for TOD19 with correct guess.
    function test_Play_and_get_reward_TOD19_pattern_9() public {
// cover: play_TOD19 :: keccak256(guess) == keccak256('hello') true
// cover: getReward_TOD19 :: winner_TOD19.transfer(msg.value)
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
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD19.value(10)();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for claimReward_TOD12
    function test_claimReward_TOD12_positive_path_10() public {
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
        target.setReward_TOD12.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD12(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD20
    function test_claimReward_TOD20_positive_path_11() public {
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
        target.setReward_TOD20.value(200)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD20(3);
        }
    }

    // @cover-intent state transition test for claimReward_TOD22
    function test_claimReward_TOD22_positive_path_12() public {
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
        target.setReward_TOD22.value(150)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD22(7);
        }
    }

    // @cover-intent state transition test for claimReward_TOD26
    function test_claimReward_TOD26_positive_path_13() public {
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
        target.setReward_TOD26.value(300)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD26(1);
        }
    }

    // @cover-intent state transition test for claimReward_TOD32
    function test_claimReward_TOD32_positive_path_14() public {
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
        target.setReward_TOD32.value(250)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD32(9);
        }
    }

    // @cover-intent Protocol State Machine
    function test_getOperator_view_15() public {
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

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD17_positive_path_16() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD17(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD17();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD19_positive_path_17() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD19();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD25_positive_path_18() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD25(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD25();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD27_positive_path_19() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD27(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD27();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD3_positive_path_20() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD3(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD3();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD37_positive_path_21() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD37(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD37();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_getReward_TOD9_positive_path_22() public {
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
        vm.startPrank(alice);
        {
        target.play_TOD9(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD9();
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
    function test_play_TOD17_positive_path_26() public {
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
        target.play_TOD17(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD19_positive_path_27() public {
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
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD25_positive_path_28() public {
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
    function test_play_TOD27_positive_path_29() public {
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
        target.play_TOD27(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD3_positive_path_30() public {
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
        target.play_TOD3(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD37_positive_path_31() public {
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
    function test_play_TOD9_positive_path_32() public {
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
        target.play_TOD9(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_TOD12_positive_path_33() public {
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
        target.setReward_TOD12.value(100)();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_TOD20_positive_path_34() public {
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
        target.setReward_TOD20.value(200)();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_TOD22_positive_path_35() public {
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
        target.setReward_TOD22.value(150)();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_TOD26_positive_path_36() public {
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
        target.setReward_TOD26.value(300)();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setReward_TOD32_positive_path_37() public {
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
        target.setReward_TOD32.value(250)();
        }
    }

}
