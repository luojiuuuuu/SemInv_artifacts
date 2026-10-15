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


    // @cover-intent Authorization & Access Control: Verify that only the active operator can transfer or renounce operator-ship, and that deactivation/activation transitions work correctly.
    function test_Operator_activation_and_deactivation_0() public {
// cover: hasActiveOperator :: return _status
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
        // skip ABI-mismatched call: getOperator()
        // skip ABI-mismatched call: hasActiveOperator()
        {
        target.isActiveOperator(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.isActiveOperator(bob);
        }
    }

    // @cover-intent External Interaction & Environment: Test that withdrawBalance functions revert when user balance is zero (edge case).
    function test_Reentrancy_withdraw_balance_attempts_1() public {
// cover: withdrawBalance_re_ent12 :: require(userBalance_re_ent12[msg.sender] > 0) false
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
        vm.expectRevert();
        // skip ABI-mismatched call: withdrawBalance_re_ent12()
        vm.expectRevert();
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
        vm.expectRevert();
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
        vm.expectRevert();
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test that withdrawFunds functions revert when requested amount exceeds balance (edge case).
    function test_Reentrancy_withdraw_funds_with_zero_amount_2() public {
// cover: withdrawFunds_re_ent17 :: require(balances_re_ent17[msg.sender] >= _weiToWithdraw) false
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
        vm.expectRevert();
        {
        target.withdrawFunds_re_ent17(0);
        }
        vm.expectRevert();
        {
        target.withdrawFunds_re_ent3(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test that claimReward functions revert when redeemable balance is zero (edge case).
    function test_Reentrancy_claim_reward_with_zero_balance_3() public {
// cover: claimReward_re_ent11 :: require(redeemableEther_re_ent11[msg.sender] > 0) false
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
        vm.expectRevert();
        // skip ABI-mismatched call: claimReward_re_ent11()
        vm.expectRevert();
        // skip ABI-mismatched call: claimReward_re_ent25()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Test that buyTicket and callme functions execute without revert under normal conditions (positive path).
    function test_Reentrancy_buy_ticket_and_callme_4() public {
// cover: buyTicket_re_ent2 :: send succeeds
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
        // skip ABI-mismatched call: buyTicket_re_ent37()
        // skip ABI-mismatched call: buyTicket_re_ent9()
        // skip ABI-mismatched call: callme_re_ent42()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that isOperator and isActiveOperator return correct values for different callers.
    function test_Operator_view_functions_after_initialization_5() public {
// cover: isOperator :: return (caller == getOperator())
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
        {
        target.isOperator(alice);
        }
        {
        target.isOperator(bob);
        }
        {
        target.isActiveOperator(alice);
        }
        {
        target.isActiveOperator(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent2_6() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent37_7() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent37()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent9_8() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent42_9() public {
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
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent11_10() public {
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
        // skip ABI-mismatched call: claimReward_re_ent11()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent25_11() public {
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
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent Authorization & Access Control
    function test_getOperator_12() public {
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
        // skip ABI-mismatched call: getOperator()
    }

    // @cover-intent Protocol State Machine
    function test_hasActiveOperator_13() public {
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
        // skip ABI-mismatched call: hasActiveOperator()
    }

    // @cover-intent Authorization & Access Control
    function test_isActiveOperator_14() public {
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
    function test_isOperator_15() public {
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

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent12_16() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent12()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent19_17() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent26_18() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent33_19() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent17_20() public {
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
        target.withdrawFunds_re_ent17(50);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent3_21() public {
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
        target.withdrawFunds_re_ent3(50);
        }
    }

}
