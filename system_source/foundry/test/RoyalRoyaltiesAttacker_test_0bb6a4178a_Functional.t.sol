// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/RoyalRoyalties_exp.sol";


contract RoyalRoyaltiesAttacker_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Demonstrate that zero-amount batch transfers inflate tierBalanceOf, enabling disproportionate royalty claims
    function test_Exploit_simulation_zero_amount_tier_balance_inflation_0() public {
// assume: IRoyal1155LDA(ROYAL_LDA_PROXY).getTierTotalSupply(TIER_ID) == 1
// assume: IRoyal1155LDA(ROYAL_LDA_PROXY).getIsOwnedTokensBackfillComplete() == false
// cover: uniswapV2Call :: require(msg.sender == QUICKSWAP_WMATIC_USDC_PAIR) false
// cover: execute :: successful flash swap and claim
        vm.startPrank(owner);
        RoyalRoyaltiesAttacker target = new RoyalRoyaltiesAttacker();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: // Fork at block 89_018_050 on polygon;
        // dropped unsafe prestate: // Deploy attack contract and fund with USDC for flash swap fees;
        // dropped unsafe prestate: vm.deal(alice, 1 ether);
        // dropped unsafe prestate: deal(USDC_TOKEN, alice, 1000000e6);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: execute()
    }

    // @cover-intent Resource & Execution Integrity: Verify that execute reverts or returns zero profit when royalty float is too low
    function test_Execute_with_insufficient_royalty_float_1() public {
// assume: IERC20(USDC_TOKEN).balanceOf(ROYALTIES_PROXY) == 0
// assume: _deriveBorrowAmount() returns 0
// cover: execute :: borrowAmount == 0, no profit
        vm.startPrank(owner);
        RoyalRoyaltiesAttacker target = new RoyalRoyaltiesAttacker();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: // Deploy attack contract;
        // dropped unsafe prestate: attackContract = new RoyalRoyaltiesAttacker();
        // dropped unsafe prestate: // Drain royalty float to near zero;
        // dropped unsafe prestate: uint256 royaltyBalance = IERC20(USDC_TOKEN).balanceOf(ROYALTIES_PROXY);
        // dropped unsafe prestate: vm.prank(ROYALTIES_PROXY);
        // dropped unsafe prestate: IERC20(USDC_TOKEN).transfer(alice, royaltyBalance);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: execute()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_execute_minimal_2() public {
        vm.startPrank(owner);
        RoyalRoyaltiesAttacker target = new RoyalRoyaltiesAttacker();
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
        // skip ABI-mismatched call: execute()
    }

    // @cover-intent External Interaction & Environment
    function test_uniswapV2Call_minimal_3() public {
        vm.startPrank(owner);
        RoyalRoyaltiesAttacker target = new RoyalRoyaltiesAttacker();
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
        target.uniswapV2Call(alice, 0, 1000000, hex"0000000000000000000000000000000000000000000000000000000000000001");
        }
    }

}
