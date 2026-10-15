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


    // @cover-intent Financial & Accounting: Verify ETH deposit and withdraw with fee deduction maintains balance consistency
    function test_ETH_Deposit_and_Withdraw_0() public {
// assume: dexStatus == true
// assume: withdrawfee[address(0)] == 1 ether
// cover: deposit :: require(msg.value > 0) true
// cover: withdraw :: type_ == 0 && tokenaddr == address(0) true
// cover: withdraw :: amount <= userDetails[msg.sender][address(0)] true
// cover: withdraw :: withdrawfee[address(0)] < amount true
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
        {
        target.withdraw(0, address(0), 5 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100 ether - 10 ether + (5 ether - 1 ether)
        // TODO assert: owner.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify token deposit and withdraw with fee deduction maintains balance consistency
    function test_Token_Deposit_and_Withdraw_1() public {
// assume: dexStatus == true
// assume: tokendetails[address(this)].status == true
// assume: withdrawfee[address(this)] == 10
// cover: tokenDeposit :: tokenAmount > 0 && tokendetails[tokenaddr].status == true true
// cover: withdraw :: type_ == 1 && tokenaddr != address(0) true
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
        // skip malformed call: tokenDeposit(address(this), 200) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        // skip malformed call: withdraw(1, address(this), 100) (bad raw arg for withdraw.arg1: type=address, raw=address(this))
        // skip malformed call: withdraw(1, address(this), 100) (bad raw arg for withdraw.arg1: type=address, raw=address(this))
        vm.stopPrank();
        // TODO assert: alice.balance == 1000 - 200 + (100 - 10)
    }

    // @cover-intent Authorization & Access Control: Verify only admin can withdraw accumulated fees
    function test_Admin_Profit_Withdraw_2() public {
// assume: dexStatus == true
// assume: msg.sender == admin for adminProfitWithdraw
// cover: adminProfitWithdraw :: msg.sender == admin true
// cover: adminProfitWithdraw :: msg.sender == admin false
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
        vm.prank(owner);
        {
        target.adminProfitWithdraw(0, address(0));
        }
        vm.prank(alice);
        {
        target.adminProfitWithdraw(0, address(0));
        }
        // TODO assert: owner.balance == 1 ether
    }

    // @cover-intent Protocol State Machine: Verify dexStatus can be toggled by admin and blocks operations when false
    function test_Dex_Status_Toggle_3() public {
// assume: dexStatus starts as true
// cover: setDexStatus :: msg.sender == admin true
// cover: deposit :: dexStatus == true true
// cover: deposit :: dexStatus == true false
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

    // @cover-intent Resource & Execution Integrity: Verify setwithdrawfee array length constraints
    function test_Set_Withdraw_Fee_Boundary_4() public {
// assume: msg.sender == admin for setwithdrawfee
// cover: setwithdrawfee :: addr.length < 10 && feeamount.length < 10 true
// cover: setwithdrawfee :: addr.length < 10 && feeamount.length < 10 false
// cover: setwithdrawfee :: msg.sender == admin false
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
        address[] memory _arr1 = new address[](9);
        _arr1[0] = alice;
        _arr1[1] = alice;
        _arr1[2] = alice;
        _arr1[3] = alice;
        _arr1[4] = alice;
        _arr1[5] = alice;
        _arr1[6] = alice;
        _arr1[7] = alice;
        _arr1[8] = alice;
        uint256[] memory _arr2 = new uint256[](9);
        _arr2[0] = 100;
        _arr2[1] = 100;
        _arr2[2] = 100;
        _arr2[3] = 100;
        _arr2[4] = 100;
        _arr2[5] = 100;
        _arr2[6] = 100;
        _arr2[7] = 100;
        _arr2[8] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        {
        address[] memory _arr3 = new address[](9);
        _arr3[0] = alice;
        _arr3[1] = alice;
        _arr3[2] = alice;
        _arr3[3] = alice;
        _arr3[4] = alice;
        _arr3[5] = alice;
        _arr3[6] = alice;
        _arr3[7] = alice;
        _arr3[8] = alice;
        uint256[] memory _arr4 = new uint256[](9);
        _arr4[0] = 100;
        _arr4[1] = 100;
        _arr4[2] = 100;
        _arr4[3] = 100;
        _arr4[4] = 100;
        _arr4[5] = 100;
        _arr4[6] = 100;
        _arr4[7] = 100;
        _arr4[8] = 100;
        target.setwithdrawfee(_arr3, _arr4);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        address[] memory _arr5 = new address[](9);
        _arr5[0] = alice;
        _arr5[1] = alice;
        _arr5[2] = alice;
        _arr5[3] = alice;
        _arr5[4] = alice;
        _arr5[5] = alice;
        _arr5[6] = alice;
        _arr5[7] = alice;
        _arr5[8] = alice;
        uint256[] memory _arr6 = new uint256[](9);
        _arr6[0] = 100;
        _arr6[1] = 100;
        _arr6[2] = 100;
        _arr6[3] = 100;
        _arr6[4] = 100;
        _arr6[5] = 100;
        _arr6[6] = 100;
        _arr6[7] = 100;
        _arr6[8] = 100;
        target.setwithdrawfee(_arr5, _arr6);
        }
    }

    // @cover-intent Transactional Consistency: Verify order creation and cancellation updates user balances correctly
    function test_Make_Order_and_Cancel_5() public {
// assume: dexStatus == true
// assume: msg.sender == feeAddress for makeOrder
// cover: makeOrder :: Order[orderiD].status == 0 true
// cover: makeOrder :: Order[orderiD].status == 1 && tradeDetails[8] == 0 true
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
        vm.startPrank(owner);
        // skip malformed call: makeOrder([1, 50, 2, 100, 0, 0, 0, 18, 0], [address(this), alice], "test", 27, bytes32(0), bytes32(0)) (bad raw arg for makeOrder.arg4: type=bytes32, raw=bytes32(0))
        // skip malformed call: makeOrder([1, 0, 0, 0, 0, 0, 0, 0, 0], [address(this), alice], "test", 27, bytes32(0), bytes32(0)) (bad raw arg for makeOrder.arg4: type=bytes32, raw=bytes32(0))
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify re-entrancy guard functions can be called
    function test_Re_entrancy_Guard_Functions_6() public {
// assume: counter_re_ent42 <= 5
// assume: not_called_re_ent13 == true
// cover: callme_re_ent42 :: counter_re_ent42 <= 5 true
// cover: bug_re_ent13 :: not_called_re_ent13 true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: callme_re_ent42()
        // skip ABI-mismatched call: callme_re_ent7()
        // skip ABI-mismatched call: bug_re_ent13()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify tokenDeposit requires sufficient allowance
    function test_Token_Allowance_Check_7() public {
// assume: dexStatus == true
// assume: tokendetails[address(this)].status == true
// cover: tokenDeposit :: tokenallowance(tokenaddr, msg.sender) > 0 false
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
        vm.startPrank(alice);
        // skip malformed call: tokenDeposit(address(this), 10) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        // skip malformed call: tokenDeposit(address(this), 10) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify withdraw fails when fee exceeds amount
    function test_Withdraw_Fee_Boundary_8() public {
// assume: dexStatus == true
// assume: withdrawfee[address(0)] == 5 ether
// cover: withdraw :: withdrawfee[address(0)] < amount false
// cover: withdraw :: withdrawfee[address(0)] < amount true
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
        target.withdraw(0, address(0), 4 ether);
        }
        {
        target.withdraw(0, address(0), 6 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100 ether - 10 ether + (6 ether - 5 ether)
    }

    // @cover-intent Resource & Execution Integrity: Verify view functions return expected values
    function test_View_Functions_9() public {
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
        vm.startPrank(alice);
        // skip malformed call: tokenDeposit(address(this), 50) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        // skip ABI-mismatched call: tokenId()
        // skip ABI-mismatched call: feeAddress()
        // skip malformed call: tokendetails(address(this)) (bad raw arg for tokendetails.arg0: type=address, raw=address(this))
        // skip malformed call: userDetails(alice, address(this)) (bad raw arg for userDetails.arg1: type=address, raw=address(this))
        {
        target.withdrawfee(address(0));
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
    function test_addToken_ok_11() public {
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
        // skip malformed call: addToken(address(1),"TKN",18) (bad raw arg for addToken.arg0: type=address, raw=address(1))
        // skip malformed call: addToken(address(1), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(1))
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_adminProfitWithdraw_ok_12() public {
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
        // skip ABI-mismatched call: deposit()
        {
        target.adminProfitWithdraw(0, address(0));
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for bug_re_ent13
    function test_bug_re_ent13_ok_13() public {
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent state transition test for bug_re_ent27
    function test_bug_re_ent27_ok_14() public {
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent state transition test for bug_re_ent41
    function test_bug_re_ent41_ok_15() public {
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
        // skip ABI-mismatched call: bug_re_ent41()
    }

    // @cover-intent Resource & Execution Integrity
    function test_buyTicket_re_ent2_ok_16() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent Resource & Execution Integrity
    function test_buyTicket_re_ent23_ok_17() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent23()
    }

    // @cover-intent Resource & Execution Integrity
    function test_buyTicket_re_ent30_ok_18() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent30()
    }

    // @cover-intent Resource & Execution Integrity
    function test_buyTicket_re_ent37_ok_19() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent37()
    }

    // @cover-intent Resource & Execution Integrity
    function test_buyTicket_re_ent9_ok_20() public {
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent14_ok_21() public {
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
        // skip ABI-mismatched call: callme_re_ent14()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent35_ok_22() public {
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
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent42_ok_23() public {
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
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent Resource & Execution Integrity
    function test_callme_re_ent7_ok_24() public {
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
        // skip ABI-mismatched call: callme_re_ent7()
    }

    // @cover-intent Resource & Execution Integrity
    function test_claimReward_re_ent25_ok_25() public {
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
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent Resource & Execution Integrity
    function test_claimReward_re_ent39_ok_26() public {
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Financial & Accounting
    function test_deposit_ok_27() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
    }

    // @cover-intent Resource & Execution Integrity
    function test_feeAddress_view_28() public {
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
    function test_feeAmount_view_29() public {
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
        target.feeAmount(address(0), address(0));
        }
    }

    // @cover-intent Transactional Consistency
    function test_makeOrder_ok_30() public {
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
        // skip malformed call: addToken(address(1),"TKN",18) (bad raw arg for addToken.arg0: type=address, raw=address(1))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(1),100) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(1))
        vm.prank(owner);
        // skip malformed call: makeOrder([1, 100, 10, 1000, 1, 1, 0, 18, 0], [address(1), alice], "msg", 27, bytes32(0), bytes32(0)) (bad raw arg for makeOrder.arg4: type=bytes32, raw=bytes32(0))
    }

    // @cover-intent Resource & Execution Integrity
    function test_orderPairStatus_view_31() public {
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
    function test_setDexStatus_ok_32() public {
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
    function test_tokenDeposit_ok_33() public {
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
        // skip malformed call: addToken(address(1),"TKN",18) (bad raw arg for addToken.arg0: type=address, raw=address(1))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(1), 100) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(1))
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenId_view_34() public {
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
    function test_tokenallowance_view_35() public {
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
        // skip malformed call: tokenallowance(address(1), alice) (bad raw arg for tokenallowance.arg0: type=address, raw=address(1))
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokendetails_view_36() public {
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
        target.tokendetails(address(0));
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_userDetails_view_37() public {
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
        target.userDetails(alice, address(0));
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_viewTokenBalance_view_38() public {
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
        // skip malformed call: viewTokenBalance(address(1), alice) (bad raw arg for viewTokenBalance.arg0: type=address, raw=address(1))
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_ok_39() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
        vm.prank(owner);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.prank(alice);
        {
        target.withdraw(0, address(0), 1 ether);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawBalance_re_ent19_ok_40() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawBalance_re_ent26_ok_41() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawBalance_re_ent33_ok_42() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawBalance_re_ent40_ok_43() public {
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
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawFunds_re_ent17_ok_44() public {
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
        target.withdrawFunds_re_ent17(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawFunds_re_ent3_ok_45() public {
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
        target.withdrawFunds_re_ent3(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawFunds_re_ent31_ok_46() public {
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
        target.withdrawFunds_re_ent31(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_balances_re_ent36_ok_47() public {
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_balances_re_ent8_ok_48() public {
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
        // skip ABI-mismatched call: withdraw_balances_re_ent8()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawfee_view_49() public {
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
        target.withdrawfee(address(0));
        }
    }

}
