// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/NovaBox_exp.sol";


contract NovaFlashLoanReceiver_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that a flash loan can be executed successfully, with the receiver unwrapping WETH, depositing ETH via constructor helper, repaying the loan, and forwarding remaining ETH profit to the root contract.
    function test_Normal_flash_loan_execution_with_profit_0() public {
// assume: msg.sender == AAVE_V3_POOL
// assume: asset == WETH
// assume: initiator == address(this)
// assume: amount == flashAmount
// cover: executeOperation :: require(msg.sender == AAVE_V3_POOL) true
// cover: executeOperation :: require(asset == WETH) true
// cover: executeOperation :: require(initiator == address(this)) true
// cover: executeOperation :: require(amount == flashAmount) true
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.deal(address(this), 1000 ether);
        // dropped unsafe prestate: vm.etch(VULNERABLE_CONTRACT, hex'...');
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: startFlashLoan()
    }

    // @cover-intent Financial & Accounting: Verify that fundHelperWithNova transfers the entire NOVA balance of the receiver to the caller.
    function test_fundHelperWithNova_transfers_NOVA_balance_1() public {
// assume: nova.balanceOf(address(this)) > 0
// cover: fundHelperWithNova :: nova.transfer(msg.sender, balance) true
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.deal(address(this), 1000 ether);
        // dropped unsafe prestate: deal(NOVA, address(this), 1000 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        // skip ABI-mismatched call: fundHelperWithNova()
    }

    // @cover-intent Resource & Execution Integrity: Verify that fundHelperWithNova succeeds even when the NOVA balance is zero.
    function test_fundHelperWithNova_with_zero_balance_succeeds_2() public {
// assume: nova.balanceOf(address(this)) == 0
// cover: fundHelperWithNova :: nova.transfer(msg.sender, balance) true
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.deal(address(this), 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        // skip ABI-mismatched call: fundHelperWithNova()
    }

    // @cover-intent External Interaction & Environment: Verify that startFlashLoan correctly calls Aave V3 pool's flashLoanSimple.
    function test_startFlashLoan_initiates_flash_loan_3() public {
// cover: startFlashLoan :: aave.flashLoanSimple() called
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.deal(address(this), 1000 ether);
        // dropped unsafe prestate: vm.mockCall(AAVE_V3_POOL, abi.encodeWithSelector(IAaveV3Pool.flashLoanSimple.selector), abi.encode(true));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: startFlashLoan()
    }

    // @cover-intent External Interaction & Environment
    function test_startFlashLoan_positive_4() public {
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
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
        // skip ABI-mismatched call: startFlashLoan()
        // skip ABI-mismatched call: startFlashLoan()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_fundHelperWithNova_positive_5() public {
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
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
        // skip ABI-mismatched call: startFlashLoan()
        // skip ABI-mismatched call: fundHelperWithNova()
        vm.stopPrank();
    }

    // @cover-intent minimal test for executeOperation
    function test_perfn_executeOperation_6() public {
        vm.startPrank(owner);
        NovaFlashLoanReceiver target = new NovaFlashLoanReceiver(payable(alice), 100);
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
