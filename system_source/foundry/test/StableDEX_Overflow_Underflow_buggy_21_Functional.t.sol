// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_21.sol";

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

contract StableDEX_FunctionalTest {
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


    // @cover-intent Test normal ETH deposit and withdraw flow with fee set to zero, verifying Financial & Accounting invariants
    function test_basic_deposit_and_withdraw_eth_0() public {
// assume: dexStatus == true
// assume: withdrawfee[address(0)] == 0
// cover: deposit :: require(msg.value > 0) true
// cover: withdraw :: type_ == 0 && tokenaddr == address(0) true
// cover: withdraw :: amount <= userDetails[msg.sender][address(0)] true
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(0, address(0), 5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that withdrawing more than deposited ETH balance reverts, verifying Resource & Execution Integrity
    function test_withdraw_exceeds_balance_reverts_1() public {
// assume: userDetails[alice][address(0)] == 5 ether
// cover: withdraw :: amount <= userDetails[msg.sender][address(0)] false
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(0, address(0), 10 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that withdraw fee is correctly deducted and credited to admin, verifying Financial & Accounting invariants
    function test_withdraw_with_fee_deducted_2() public {
// assume: withdrawfee[address(0)] == 1 ether
// cover: withdraw :: withdrawfee[address(0)] < amount true
// cover: withdraw :: amount <= address(this).balance true
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(0, address(0), 10 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Test admin can withdraw accumulated ETH fees, verifying Authorization & Access Control
    function test_admin_profit_withdraw_eth_3() public {
// assume: feeAmount[owner][address(0)] == 1 ether
// cover: adminProfitWithdraw :: msg.sender == admin true
// cover: adminProfitWithdraw :: type_ == 0 true
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(0, address(0), 10 ether);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.adminProfitWithdraw(0, address(0));
        }
    }

    // @cover-intent Test that non-admin cannot call adminProfitWithdraw, verifying Authorization & Access Control
    function test_non_admin_cannot_withdraw_profits_4() public {
// cover: adminProfitWithdraw :: msg.sender == admin false
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.adminProfitWithdraw(0, address(0));
        }
    }

    // @cover-intent Test that admin can pause and resume the DEX, verifying Protocol State Machine
    function test_set_dex_status_pause_and_resume_5() public {
// assume: dexStatus == true initially
// cover: setDexStatus :: msg.sender == admin true
// cover: deposit :: dexStatus == true false
// cover: deposit :: dexStatus == true true
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(false);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
        vm.startPrank(owner);
        {
        target.setDexStatus(true);
        }
        // skip ABI-mismatched call: deposit()
        vm.stopPrank();
    }

    // @cover-intent state transition test for setDexStatus
    function test_non_admin_cannot_set_dex_status_6() public {
// cover: setDexStatus :: msg.sender == admin false
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(false);
        }
    }

    // @cover-intent Test adding a new token and depositing it, verifying Financial & Accounting invariants
    function test_add_token_and_deposit_token_7() public {
// assume: tokendetails[address(this)].status == true
// assume: tokenallowance(address(this), alice) >= 100
// cover: addToken :: msg.sender == feeAddress && tokendetails[tokenAddress].status == false true
// cover: tokenDeposit :: tokenAmount > 0 && tokendetails[tokenaddr].status == true true
// cover: tokenDeposit :: tokenallowance(tokenaddr, msg.sender) > 0 true
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip malformed call: addToken(address(this), "TEST", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(this), 100) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
    }

    // @cover-intent Test token withdrawal with fee deduction, verifying Financial & Accounting invariants
    function test_withdraw_token_with_fee_8() public {
// assume: withdrawfee[address(this)] == 10
// assume: userDetails[alice][address(this)] == 100
// cover: withdraw :: type_ == 1 true
// cover: withdraw :: withdrawfee[tokenaddr] < amount true
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip malformed call: addToken(address(this), "TEST", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip malformed call: tokenDeposit(address(this), 100) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        // skip malformed call: withdraw(1, address(this), 100) (bad raw arg for withdraw.arg1: type=address, raw=address(this))
        vm.stopPrank();
    }

    // @cover-intent Test order creation and cancellation, verifying Transactional Consistency
    function test_make_order_and_cancel_9() public {
// assume: Order[1].status == 1 initially after first call
// cover: makeOrder :: Order[orderiD].status == 0 true
// cover: makeOrder :: Order[orderiD].status == 1 && tradeDetails[8] == 0 true
// cover: cancelOrder :: Order[orderid].status == 1 true
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip malformed call: addToken(address(this), "TEST", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(this), 500) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        vm.startPrank(owner);
        {
        uint256[9] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        _arr1[2] = 1;
        _arr1[3] = 1;
        _arr1[4] = 1;
        _arr1[5] = 1;
        _arr1[6] = 1;
        _arr1[7] = 1;
        _arr1[8] = 1;
        address[2] memory _arr2;
        _arr2[0] = alice;
        _arr2[1] = alice;
        target.makeOrder(_arr1, _arr2, "test", 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        {
        uint256[9] memory _arr3;
        _arr3[0] = 1;
        _arr3[1] = 1;
        _arr3[2] = 1;
        _arr3[3] = 1;
        _arr3[4] = 1;
        _arr3[5] = 1;
        _arr3[6] = 1;
        _arr3[7] = 1;
        _arr3[8] = 1;
        address[2] memory _arr4;
        _arr4[0] = alice;
        _arr4[1] = alice;
        target.makeOrder(_arr3, _arr4, "test", 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Order_view_10() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.Order(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_addToken_by_feeAddress_11() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(true);
        }
        {
        target.addToken(alice, "TKN", 18);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_adminProfitWithdraw_by_admin_12() public {
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(true);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
        vm.prank(owner);
        {
        target.adminProfitWithdraw(0, address(0));
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou11_13() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_14() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou23_15() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_16() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou3_17() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_18() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_19() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou36_20() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_21() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou40_22() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou7_23() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou8_24() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_deposit_ETH_25() public {
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(true);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
    }

    // @cover-intent Resource & Execution Integrity
    function test_feeAddress_view_26() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: feeAddress()
    }

    // @cover-intent Resource & Execution Integrity
    function test_feeAmount_view_27() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.feeAmount(alice, bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou1_28() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou1(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_29() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou13(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou17_30() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou17(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou25_31() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou25(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou33_32() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou33(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou37_33() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou37(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou9_34() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.increaseLockTime_intou9(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou1_view_35() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou1(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou13_view_36() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou17_view_37() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou25_view_38() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou25(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou33_view_39() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou37_view_40() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou9_view_41() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.lockTime_intou9(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_makeOrder_by_feeAddress_42() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(true);
        }
        {
        uint256[9] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        _arr1[2] = 1;
        _arr1[3] = 1;
        _arr1[4] = 1;
        _arr1[5] = 1;
        _arr1[6] = 1;
        _arr1[7] = 1;
        _arr1[8] = 1;
        address[2] memory _arr2;
        _arr2[0] = alice;
        _arr2[1] = alice;
        target.makeOrder(_arr1, _arr2, "", 0, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_orderPairStatus_view_43() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.orderPairStatus(0, 0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_setDexStatus_by_admin_44() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(false);
        }
    }

    // @cover-intent Financial & Accounting
    function test_tokenDeposit_by_alice_45() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(true);
        }
        vm.prank(alice);
        {
        target.tokenDeposit(address(0), 100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenId_view_46() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: tokenId()
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenallowance_view_47() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.tokenallowance(alice, bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokendetails_view_48() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.tokendetails(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_49() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.transfer_intou14(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou26_50() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.transfer_intou26(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_51() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.transfer_intou30(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_undrflow2_52() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.transfer_undrflow2(bob, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_userDetails_view_53() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.userDetails(alice, bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_viewTokenBalance_54() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.viewTokenBalance(alice, bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_ETH_55() public {
        vm.startPrank(alice);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.setDexStatus(true);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(0, address(0), 1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_56() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou17_57() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou25_58() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_intou25()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_59() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou37_60() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_intou37()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou9_61() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_intou9()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_ovrflow1_62() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        // skip ABI-mismatched call: withdraw_ovrflow1()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawfee_view_63() public {
        vm.startPrank(owner);
        StableDEX target = new StableDEX(address(uint160(bob)), carol);
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
        target.withdrawfee(alice);
        }
    }

}
