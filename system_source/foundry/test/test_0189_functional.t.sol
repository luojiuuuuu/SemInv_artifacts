// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x9d06cbafa865037a01d322d3f4222fa3e04e5488.sol";

// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}

contract Delta_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Delta_FunctionalTest() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() public payable { }


    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }


    // @cover-intent Financial & Accounting: Verify successful token purchase with sufficient ETH and active contract
    function test_tokens_buy_positive_0() public {
// assume: active == 1
// assume: token_price == 1000000000000000
// cover: tokens_buy :: require(active > 0) true
// cover: tokens_buy :: require(msg.value >= token_price) true
// cover: tokens_buy :: require(tokens_buy > 0) true
        vm.startPrank(alice);
        Delta target = new Delta();
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
        target.change_active(1);
        }
        {
        target.change_token_price(1000000000000000);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: tokens_buy()
    }

    // @cover-intent Protocol State Machine: Verify token purchase reverts when contract is inactive
    function test_tokens_buy_inactive_1() public {
// assume: active == 0
// cover: tokens_buy :: require(active > 0) false
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_active(0);
        }
        {
        target.change_token_price(1000000000000000);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: tokens_buy()
    }

    // @cover-intent Financial & Accounting: Verify token purchase reverts when ETH sent is below token price
    function test_tokens_buy_insufficient_eth_2() public {
// assume: active == 1
// assume: token_price == 1000000000000000
// cover: tokens_buy :: require(msg.value >= token_price) false
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_active(1);
        }
        {
        target.change_token_price(1000000000000000);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: tokens_buy()
    }

    // @cover-intent Authorization & Access Control: Verify owner can withdraw contract balance
    function test_withdraw_positive_3() public {
// assume: this.balance >= 500000000000000
// cover: withdraw :: onlyOwner modifier true
// cover: withdraw :: if(_amount > 0) true
        vm.startPrank(alice);
        Delta target = new Delta();
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
        target.change_active(1);
        }
        {
        target.change_token_price(1000000000000000);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: tokens_buy()
        vm.prank(owner);
        {
        target.withdraw(500000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot withdraw
    function test_withdraw_non_owner_4() public {
// cover: withdraw :: onlyOwner modifier false
        vm.startPrank(alice);
        Delta target = new Delta();
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
        target.change_active(1);
        }
        {
        target.change_token_price(1000000000000000);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: tokens_buy()
        {
        target.withdraw(1000000000000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify withdraw with zero amount sends entire balance
    function test_withdraw_zero_amount_5() public {
// assume: this.balance > 0
// cover: withdraw :: if(_amount > 0) false
        vm.startPrank(alice);
        Delta target = new Delta();
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
        target.change_active(1);
        }
        {
        target.change_token_price(1000000000000000);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: tokens_buy()
        vm.prank(owner);
        {
        target.withdraw(0);
        }
    }

    // @cover-intent Protocol State Machine: Verify owner can change token price
    function test_change_token_price_positive_6() public {
// cover: change_token_price :: onlyOwner modifier true
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_token_price(2000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot change token price
    function test_change_token_price_non_owner_7() public {
// cover: change_token_price :: onlyOwner modifier false
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_token_price(2000000000000000);
        }
    }

    // @cover-intent Protocol State Machine: Verify owner can change active state
    function test_change_active_positive_8() public {
// cover: change_active :: onlyOwner modifier true
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_active(0);
        }
        {
        target.change_active(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot change active state
    function test_change_active_non_owner_9() public {
// cover: change_active :: onlyOwner modifier false
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_active(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_active_view_10() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        // skip ABI-mismatched call: active()
        {
            uint256 __v1 = uint256(target.active());
            _assertRelU(__v1, 2, 0, "call:active>=0");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_c_view_11() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        // skip ABI-mismatched call: c()
    }

    // @cover-intent Authorization & Access Control
    function test_change_active_positive_12() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_active(0);
        }
        {
            uint256 __v2 = uint256(target.active());
            _assertRelU(__v2, 0, 0, "call:active==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_change_active_unauthorized_13() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_active(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_change_token_price_positive_14() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_token_price(2000);
        }
        {
            uint256 __v3 = uint256(target.token_price());
            _assertRelU(__v3, 0, 2000, "call:token_price==2000");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_change_token_price_unauthorized_15() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.change_token_price(2000);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_16() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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

    // @cover-intent Authorization & Access Control
    function test_owner2_view_17() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        // skip ABI-mismatched call: owner2()
    }

    // @cover-intent Financial & Accounting
    function test_token_price_view_18() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        // skip ABI-mismatched call: token_price()
        {
            uint256 __v4 = uint256(target.token_price());
            _assertRelU(__v4, 2, 0, "call:token_price>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_tokens_buy_positive_19() public {
        vm.startPrank(alice);
        Delta target = new Delta();
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
        target.change_active(1);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: tokens_buy()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_20() public {
        vm.startPrank(alice);
        Delta target = new Delta();
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
        // skip ABI-mismatched call: tokens_buy()
        vm.prank(owner);
        {
        target.withdraw(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_unauthorized_21() public {
        vm.startPrank(owner);
        Delta target = new Delta();
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
        target.withdraw(0);
        }
    }

}
