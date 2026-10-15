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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and withdraw it minus the withdraw fee, and that the fee is credited to the admin.
    function test_Basic_ETH_deposit_and_withdraw_0() public {
// assume: withdrawfee[address(0)] == 0
// cover: withdraw :: type_==0 && tokenaddr==address(0) && amount>0 && amount<=userDetails[msg.sender][address(0)] && withdrawfee[address(0)]<amount && amount<=address(this).balance
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
        vm.startPrank(alice);
        {
        target.deposit.value(5 ether)();
        }
        {
        target.withdraw(0, address(0), 1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether - 1 ether
    }

    // @cover-intent Financial & Accounting: Verify token deposit and withdraw flow with a non-zero withdraw fee, ensuring fee is collected.
    function test_Token_deposit_and_withdraw_with_fee_1() public {
// assume: withdrawfee[address(this)] == 10
// assume: tokendetails[address(this)].status == true
// cover: withdraw :: type_==1 && tokenaddr!=address(0) && tokendetails[tokenaddr].status==true && amount>0 && amount<=userDetails[msg.sender][tokenaddr] && withdrawfee[tokenaddr]<amount
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
        // skip malformed call: addToken(address(this), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip malformed call: tokenDeposit(address(this), 500) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        // skip malformed call: withdraw(1, address(this), 100) (bad raw arg for withdraw.arg1: type=address, raw=address(this))
        vm.stopPrank();
        // TODO assert: alice.balance == 500 - 100
    }

    // @cover-intent Authorization & Access Control: Verify admin can withdraw accumulated fees, and non-admin cannot.
    function test_Admin_profit_withdrawal_2() public {
// assume: feeAmount[owner][address(0)] == 1 ether
// cover: adminProfitWithdraw :: type_==0 && msg.sender==admin
// cover: adminProfitWithdraw :: msg.sender!=admin
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
        {
        target.deposit.value(5 ether)();
        }
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
        target.withdraw(0, address(0), 2 ether);
        }
        vm.prank(owner);
        {
        target.adminProfitWithdraw(0, address(0));
        }
        vm.prank(alice);
        {
        target.adminProfitWithdraw(0, address(0));
        }
    }

    // @cover-intent Protocol State Machine: Verify that only admin can toggle dexStatus, and that deposits are blocked when paused.
    function test_DEX_status_toggle_3() public {
// assume: dexStatus == false
// cover: setDexStatus :: msg.sender==admin
// cover: deposit :: dexStatus==false (revert)
// cover: deposit :: dexStatus==true && msg.value>0
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
        target.setDexStatus(false);
        }
        vm.prank(alice);
        bool __ok = target.deposit.value(1 ether)();
        _assertTrue(!__ok, "expected false");
        vm.prank(owner);
        {
        target.setDexStatus(true);
        }
        vm.prank(alice);
        {
        target.deposit.value(1 ether)();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Authorization & Access Control: Verify only admin can set withdraw fees, and that the fee is applied correctly.
    function test_Set_withdraw_fee_and_verify_effect_4() public {
// assume: withdrawfee[address(0)] == 0
// cover: setwithdrawfee :: msg.sender!=admin (revert)
// cover: setwithdrawfee :: msg.sender==admin && addr.length<10 && feeamount.length<10 && addr.length==feeamount.length
// cover: withdraw :: withdrawfee[address(0)] < amount
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
        vm.startPrank(alice);
        {
        target.deposit.value(5 ether)();
        }
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 100;
        target.setwithdrawfee(_arr1, _arr2);
        }
        vm.stopPrank();
        vm.startPrank(owner);
        {
        address[] memory _arr3 = new address[](1);
        _arr3[0] = alice;
        uint256[] memory _arr4 = new uint256[](1);
        _arr4[0] = 100;
        target.setwithdrawfee(_arr3, _arr4);
        }
        {
        target.withdraw(0, address(0), 2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether - (2 ether - 1 ether)
    }

    // @cover-intent Authorization & Access Control: Verify only feeAddress can add tokens, and that token deposit works after adding.
    function test_Add_token_and_deposit_5() public {
// assume: tokendetails[address(this)].status == false
// cover: addToken :: msg.sender!=feeAddress (revert)
// cover: addToken :: msg.sender==feeAddress && tokendetails[tokenAddress].status==false
// cover: tokenDeposit :: tokenAmount>0 && tokendetails[tokenaddr].status==true && tokenallowance(tokenaddr,msg.sender)>0
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
        // skip malformed call: addToken(address(this), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        vm.prank(owner);
        // skip malformed call: addToken(address(this), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(this), 500) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
    }

    // @cover-intent Financial & Accounting: Verify that makeOrder reverts when user does not have enough balance.
    function test_Make_order_with_insufficient_balance_6() public {
// assume: userDetails[alice][address(this)] == 50
// cover: makeOrder :: amount__ > userDetails[traderAddresses[1]][traderAddresses[0]] (revert)
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
        // skip malformed call: addToken(address(this), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(this), 50) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        vm.prank(owner);
        // skip malformed call: makeOrder([1, 100, 1, 100, 0, 0, 0, 18, 0], [address(this), alice], "test", 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for makeOrder.arg0: type=uint256[9], raw=[1, 100, 1, 100, 0, 0, 0, 18, 0])
    }

    // @cover-intent Transactional Consistency: Verify that an active order can be cancelled and funds are returned.
    function test_Cancel_an_active_order_7() public {
// assume: Order[1].status == 1
// cover: makeOrder :: Order[orderiD].status==1 && tradeDetails[8]==0 (cancel)
// cover: cancelOrder :: Order[orderid].status==1 && Order[orderid].type_==0
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
        // skip malformed call: addToken(address(this), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address(this), 50) (bad raw arg for tokenDeposit.arg0: type=address, raw=address(this))
        vm.startPrank(owner);
        // skip malformed call: makeOrder([1, 10, 1, 10, 0, 0, 0, 18, 0], [address(this), alice], "test", 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for makeOrder.arg0: type=uint256[9], raw=[1, 10, 1, 10, 0, 0, 0, 18, 0])
        // skip malformed call: makeOrder([1, 0, 0, 0, 0, 0, 0, 0, 0], [address(this), alice], "test", 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for makeOrder.arg0: type=uint256[9], raw=[1, 0, 0, 0, 0, 0, 0, 0, 0])
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdraw reverts when amount exceeds user balance.
    function test_ETH_withdraw_with_insufficient_balance_8() public {
// assume: userDetails[alice][address(0)] == 5 ether
// cover: withdraw :: amount > userDetails[msg.sender][address(0)] (revert)
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
        vm.startPrank(alice);
        {
        target.deposit.value(5 ether)();
        }
        {
        target.withdraw(0, address(0), 10 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdraw reverts when withdraw fee is greater than or equal to amount.
    function test_Token_withdraw_with_fee_exceeding_amount_9() public {
// assume: withdrawfee[address(this)] == 50
// cover: withdraw :: withdrawfee[tokenaddr] >= amount (revert)
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
        // skip malformed call: addToken(address(this), "TKN", 18) (bad raw arg for addToken.arg0: type=address, raw=address(this))
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
        // skip malformed call: withdraw(1, address(this), 30) (bad raw arg for withdraw.arg1: type=address, raw=address(this))
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Order_lookup_10() public {
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
        // skip malformed call: Order(uint256:0) (bad raw arg for Order.arg0: type=uint256, raw=uint256:0)
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
        // skip malformed call: addToken(address:0x0000000000000000000000000000000000000001,string:TEST,uint256:18) (bad raw arg for addToken.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
        // skip malformed call: addToken(address:0x0000000000000000000000000000000000000001, string:TEST, uint256:18) (bad raw arg for addToken.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_adminProfitWithdraw_ETH_12() public {
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
        target.deposit.value(1 ether)();
        }
        // skip malformed call: adminProfitWithdraw(uint8:0, address:0x0000000000000000000000000000000000000000) (bad raw arg for adminProfitWithdraw.arg0: type=uint8, raw=uint8:0)
        vm.stopPrank();
        // TODO assert: owner.balance >= 0
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin36_13() public {
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
        // skip malformed call: bug_txorigin36(address:alice) (bad raw arg for bug_txorigin36.arg0: type=address, raw=address:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin40_14() public {
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
        vm.prank(bob);
        // skip malformed call: bug_txorigin40(address:bob) (bad raw arg for bug_txorigin40.arg0: type=address, raw=address:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin8_15() public {
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
        vm.prank(carol);
        // skip malformed call: bug_txorigin8(address:carol) (bad raw arg for bug_txorigin8.arg0: type=address, raw=address:carol)
    }

    // @cover-intent Financial & Accounting
    function test_deposit_ETH_16() public {
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
        {
        target.deposit.value(1 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_feeAddress_view_17() public {
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
        target.feeAddress();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_feeAmount_view_18() public {
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
        // skip malformed call: feeAmount(address:alice, address:0x0000000000000000000000000000000000000000) (bad raw arg for feeAmount.arg0: type=address, raw=address:alice)
    }

    // @cover-intent Protocol State Machine
    function test_makeOrder_minimal_19() public {
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
        target.deposit.value(1 ether)();
        }
        // skip malformed call: makeOrder(uint256[9]:[1, 0, 0, 0, 0, 0, 0, 0, 0], address[2]:[0x0000000000000000000000000000000000000000, alice], string:, uint8:27, bytes32:0x0000000000000000000000000000000000000000000000000000000000000000, bytes32:0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for makeOrder.arg0: type=uint256[9], raw=uint256[9]:[1, 0, 0, 0, 0, 0, 0, 0, 0])
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_orderPairStatus_view_20() public {
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
        // skip malformed call: orderPairStatus(uint256:0, uint256:0) (bad raw arg for orderPairStatus.arg0: type=uint256, raw=uint256:0)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin1_21() public {
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
        // skip malformed call: sendto_txorigin1(address payable:alice, uint256:0, address:alice) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=address payable:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin13_22() public {
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
        vm.prank(bob);
        // skip malformed call: sendto_txorigin13(address payable:bob, uint256:0, address:bob) (bad raw arg for sendto_txorigin13.arg0: type=address, raw=address payable:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin17_23() public {
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
        vm.prank(carol);
        // skip malformed call: sendto_txorigin17(address payable:carol, uint256:0, address:carol) (bad raw arg for sendto_txorigin17.arg0: type=address, raw=address payable:carol)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin25_24() public {
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
        // skip malformed call: sendto_txorigin25(address payable:alice, uint256:0, address:alice) (bad raw arg for sendto_txorigin25.arg0: type=address, raw=address payable:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin33_25() public {
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
        vm.prank(bob);
        // skip malformed call: sendto_txorigin33(address payable:bob, uint256:0, address:bob) (bad raw arg for sendto_txorigin33.arg0: type=address, raw=address payable:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin37_26() public {
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
        vm.prank(carol);
        // skip malformed call: sendto_txorigin37(address payable:carol, uint256:0, address:carol) (bad raw arg for sendto_txorigin37.arg0: type=address, raw=address payable:carol)
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin9_27() public {
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
        // skip malformed call: sendto_txorigin9(address payable:alice, uint256:0, address:alice) (bad raw arg for sendto_txorigin9.arg0: type=address, raw=address payable:alice)
    }

    // @cover-intent Protocol State Machine
    function test_setDexStatus_by_owner_28() public {
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
        // skip malformed call: setDexStatus(bool:false) (bad raw arg for setDexStatus.arg0: type=bool, raw=bool:false)
    }

    // @cover-intent Financial & Accounting
    function test_tokenDeposit_minimal_29() public {
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
        // skip malformed call: addToken(address:0x0000000000000000000000000000000000000001,string:TST,uint256:18) (bad raw arg for addToken.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
        vm.prank(alice);
        // skip malformed call: tokenDeposit(address:0x0000000000000000000000000000000000000001, uint256:100) (bad raw arg for tokenDeposit.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenId_view_30() public {
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
        target.tokenId();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenallowance_view_31() public {
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
        // skip malformed call: tokenallowance(address:0x0000000000000000000000000000000000000001, address:alice) (bad raw arg for tokenallowance.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokendetails_view_32() public {
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
        // skip malformed call: tokendetails(address:0x0000000000000000000000000000000000000001) (bad raw arg for tokendetails.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin11_33() public {
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
        // skip malformed call: transferTo_txorigin11(address:alice, uint256:0, address:alice) (bad raw arg for transferTo_txorigin11.arg0: type=address, raw=address:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin19_34() public {
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
        vm.prank(bob);
        // skip malformed call: transferTo_txorigin19(address:bob, uint256:0, address:bob) (bad raw arg for transferTo_txorigin19.arg0: type=address, raw=address:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin23_35() public {
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
        vm.prank(carol);
        // skip malformed call: transferTo_txorigin23(address:carol, uint256:0, address:carol) (bad raw arg for transferTo_txorigin23.arg0: type=address, raw=address:carol)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin27_36() public {
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
        // skip malformed call: transferTo_txorigin27(address:alice, uint256:0, address:alice) (bad raw arg for transferTo_txorigin27.arg0: type=address, raw=address:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin3_37() public {
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
        vm.prank(bob);
        // skip malformed call: transferTo_txorigin3(address:bob, uint256:0, address:bob) (bad raw arg for transferTo_txorigin3.arg0: type=address, raw=address:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin31_38() public {
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
        vm.prank(carol);
        // skip malformed call: transferTo_txorigin31(address:carol, uint256:0, address:carol) (bad raw arg for transferTo_txorigin31.arg0: type=address, raw=address:carol)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin35_39() public {
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
        // skip malformed call: transferTo_txorigin35(address:alice, uint256:0, address:alice) (bad raw arg for transferTo_txorigin35.arg0: type=address, raw=address:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin39_40() public {
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
        vm.prank(bob);
        // skip malformed call: transferTo_txorigin39(address:bob, uint256:0, address:bob) (bad raw arg for transferTo_txorigin39.arg0: type=address, raw=address:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin7_41() public {
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
        vm.prank(carol);
        // skip malformed call: transferTo_txorigin7(address:carol, uint256:0, address:carol) (bad raw arg for transferTo_txorigin7.arg0: type=address, raw=address:carol)
    }

    // @cover-intent Resource & Execution Integrity
    function test_userDetails_view_42() public {
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
        // skip malformed call: userDetails(address:alice, address:0x0000000000000000000000000000000000000000) (bad raw arg for userDetails.arg0: type=address, raw=address:alice)
    }

    // @cover-intent Resource & Execution Integrity
    function test_viewTokenBalance_43() public {
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
        // skip malformed call: viewTokenBalance(address:0x0000000000000000000000000000000000000001, address:alice) (bad raw arg for viewTokenBalance.arg0: type=address, raw=address:0x0000000000000000000000000000000000000001)
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_ETH_44() public {
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
        {
        target.deposit.value(1 ether)();
        }
        vm.prank(owner);
        // skip malformed call: setwithdrawfee(address[]:[0x0000000000000000000000000000000000000000],uint256[]:[0]) (bad raw arg for setwithdrawfee.arg0: type=address[], raw=address[]:[0x0000000000000000000000000000000000000000])
        vm.prank(alice);
        // skip malformed call: withdraw(uint8:0, address:0x0000000000000000000000000000000000000000, uint256:1000000000000000000) (bad raw arg for withdraw.arg0: type=uint8, raw=uint8:0)
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin14_45() public {
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
        // skip malformed call: withdrawAll_txorigin14(address payable:alice, address:alice) (bad raw arg for withdrawAll_txorigin14.arg0: type=address, raw=address payable:alice)
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin2_46() public {
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
        vm.prank(bob);
        // skip malformed call: withdrawAll_txorigin2(address payable:bob, address:bob) (bad raw arg for withdrawAll_txorigin2.arg0: type=address, raw=address payable:bob)
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin26_47() public {
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
        vm.prank(carol);
        // skip malformed call: withdrawAll_txorigin26(address payable:carol, address:carol) (bad raw arg for withdrawAll_txorigin26.arg0: type=address, raw=address payable:carol)
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin30_48() public {
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
        // skip malformed call: withdrawAll_txorigin30(address payable:alice, address:alice) (bad raw arg for withdrawAll_txorigin30.arg0: type=address, raw=address payable:alice)
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
        // skip malformed call: withdrawfee(address:0x0000000000000000000000000000000000000000) (bad raw arg for withdrawfee.arg0: type=address, raw=address:0x0000000000000000000000000000000000000000)
    }

}
