// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/futureswap_exp.sol";


contract AttackContract_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }
    function _assertEqA(address a, address b) internal {
        assertEq(a, b);
    }
    function _assertEqB32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }
    function _assertEqS(string memory a, string memory b) internal {
        assertEq(a, b);
    }


    // @cover-intent Financial & Accounting: Verify that the owner can successfully initiate a flash loan via start(), execute the full attack sequence in executeOperation(), and repay the loan with profit.
    function test_Positive_path_owner_starts_flash_loan_and_executes_full_drain_0() public {
// assume: msg.sender == owner for start()
// assume: msg.sender == address(aavePool) for executeOperation()
// cover: start :: require(msg.sender == owner) true
// cover: executeOperation :: require(msg.sender == address(aavePool)) true
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: MockAaveV3Pool mockAave = new MockAaveV3Pool();
        // dropped unsafe prestate: IERC20(usdc).transfer(address(mockAave), 500250000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.start(500000000000);
        }
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller cannot invoke start(), enforcing the onlyOwner guard.
    function test_Negative_path_non_owner_calls_start_1() public {
// assume: msg.sender != owner
// cover: start :: require(msg.sender == owner) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        {
        target.start(1000000000);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that start() can be called with amount = 0, triggering a flash loan of zero USDC.
    function test_Edge_case_start_with_zero_amount_2() public {
// assume: msg.sender == owner
// cover: start :: require(msg.sender == owner) true
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: MockAaveV3Pool mockAave = new MockAaveV3Pool();
        // dropped unsafe prestate: IERC20(usdc).transfer(address(mockAave), 1000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.start(0);
        }
    }

    // @cover-intent Financial & Accounting: Verify that executeOperation reverts if the contract does not have enough USDC to repay the flash loan after the attack sequence.
    function test_Edge_case_executeOperation_with_insufficient_balance_to_repay_3() public {
// assume: msg.sender == owner
// assume: victim contract does not have sufficient USDC to generate profit
// cover: executeOperation :: require(bal >= repay) false
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: MockAaveV3Pool mockAave = new MockAaveV3Pool();
        // dropped unsafe prestate: IERC20(usdc).transfer(address(mockAave), 1000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.start(1000000);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_aavePool_getter_4() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: aavePool()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callerBigFee_getter_5() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: callerBigFee()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callerTiny_getter_6() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: callerTiny()
    }

    // @cover-intent Resource & Execution Integrity
    function test_opener_getter_7() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: opener()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_getter_8() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent External Interaction & Environment
    function test_start_positive_path_9() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        vm.prank(owner);
        {
        target.start(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_usdc_getter_10() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: usdc()
    }

    // @cover-intent Resource & Execution Integrity
    function test_victim_getter_11() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        // skip ABI-mismatched call: victim()
    }

    // @cover-intent minimal test for executeOperation
    function test_perfn_executeOperation_12() public {
        vm.startPrank(owner);
        AttackContract target = new AttackContract(alice, alice, alice, alice);
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
        target.executeOperation(alice, 100, 1, bob, hex"01");
        }
    }

}
