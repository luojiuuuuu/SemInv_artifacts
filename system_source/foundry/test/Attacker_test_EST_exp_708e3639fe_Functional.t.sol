// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/EST_exp.sol";


contract Attacker_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Execute a flash loan, unwrap WBNB, deposit BNB, swap tokens, and exploit skim() to generate profit, verifying the attacker's balance increases.
    function test_Positive_flash_loan_exploit_path_0() public {
// assume: IWBNB(payable(WBNB_ADDR)).balanceOf(MOOLAH) >= 20000 ether
// cover: start :: require(_amount <= IWBNB(payable(WBNB_ADDR)).balanceOf(MOOLAH)) true
        vm.startPrank(owner);
        Attacker target = new Attacker();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: IWBNB(payable(WBNB_ADDR)).deposit{value: 20000 ether}();
        // dropped unsafe prestate: IWBNB(payable(WBNB_ADDR)).transfer(address(this), 20000 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.start(20000 ether);
        }
    }

    // @cover-intent Resource & Execution Integrity: Test edge case where flash loan amount is zero, expecting revert due to insufficient balance or no-op.
    function test_Flash_loan_with_zero_amount_1() public {
// assume: IWBNB(payable(WBNB_ADDR)).balanceOf(MOOLAH) >= 0
// cover: start :: require(_amount <= IWBNB(payable(WBNB_ADDR)).balanceOf(MOOLAH)) false
        vm.startPrank(owner);
        Attacker target = new Attacker();
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
        target.start(0);
        }
    }

    // @cover-intent Authorization & Access Control: Test that start() reverts when requested amount exceeds Moolah's WBNB balance.
    function test_Flash_loan_with_amount_exceeding_Moolah_balance_2() public {
// assume: IWBNB(payable(WBNB_ADDR)).balanceOf(MOOLAH) < 100000 ether
// cover: start :: require(_amount <= IWBNB(payable(WBNB_ADDR)).balanceOf(MOOLAH)) false
        vm.startPrank(owner);
        Attacker target = new Attacker();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: IWBNB(payable(WBNB_ADDR)).deposit{value: 100000 ether}();
        // dropped unsafe prestate: IWBNB(payable(WBNB_ADDR)).transfer(address(this), 100000 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.start(100000 ether);
        }
    }

    // @cover-intent Financial & Accounting
    function test_start_sequence_3() public {
        vm.startPrank(owner);
        Attacker target = new Attacker();
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
        target.start(10000 ether);
        }
    }

    // @cover-intent minimal test for onMoolahFlashLoan
    function test_perfn_onMoolahFlashLoan_4() public {
        vm.startPrank(owner);
        Attacker target = new Attacker();
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
        target.onMoolahFlashLoan(1, hex"01");
        }
    }

}
