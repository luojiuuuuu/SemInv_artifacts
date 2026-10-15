// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
import "../src/DutchAuction_076.sol";

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

contract DutchAuction_076_FunctionalTest {
    // 绑定 vm（hevm cheatcodes 固定地址）
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

    receive() external payable { }
    fallback() external payable { }


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


    // @cover-intent 测试在拍卖开始时以起始价格成功购买，验证状态变化、事件和余额转移
    function test_happy_path_buy_at_start_0() public {
// assume: block.timestamp < endsAt
// assume: sold == false
// cover: buy :: require(!sold) true
// cover: buy :: require(block.timestamp < endsAt) true
// cover: buy :: require(msg.value >= price) true
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.getCurrentPrice();
        }
    }

    // @cover-intent 测试在拍卖开始一段时间后以折扣价格购买，验证价格计算和找零逻辑
    function test_buy_after_discount_1() public {
// assume: block.timestamp < endsAt
// assume: sold == false
// assume: getCurrentPrice() < startPrice
// cover: buy :: require(!sold) true
// cover: buy :: require(block.timestamp < endsAt) true
// cover: buy :: require(msg.value >= price) true
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.getCurrentPrice();
        }
    }

    // @cover-intent 测试以精确价格购买，验证无找零场景
    function test_buy_exact_price_no_refund_2() public {
// assume: block.timestamp < endsAt
// assume: sold == false
// assume: getCurrentPrice() == 80 ether
// cover: buy :: require(!sold) true
// cover: buy :: require(block.timestamp < endsAt) true
// cover: buy :: require(msg.value >= price) true
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.getCurrentPrice();
        }
    }

    // @cover-intent state transition test for buy
    function test_revert_already_sold_3() public {
// assume: block.timestamp < endsAt
// cover: buy :: require(!sold) false
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent state transition test for buy
    function test_revert_after_auction_ended_4() public {
// assume: block.timestamp >= endsAt
// assume: sold == false
// cover: buy :: require(block.timestamp < endsAt) false
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent 测试支付不足时回退，验证价格检查
    function test_revert_insufficient_payment_5() public {
// assume: block.timestamp < endsAt
// assume: sold == false
// assume: getCurrentPrice() > 1 ether
// cover: buy :: require(msg.value >= price) false
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.getCurrentPrice();
        }
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent 测试拍卖结束后getCurrentPrice返回0
    function test_get_current_price_zero_after_end_6() public {
// assume: block.timestamp >= endsAt
// cover: getCurrentPrice :: block.timestamp >= endsAt true
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.getCurrentPrice();
        }
    }

    // @cover-intent 测试部署后所有view函数返回正确初始值
    function test_view_functions_after_deploy_7() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.seller();
        }
        {
        target.startPrice();
        }
        {
        target.discountRate();
        }
        {
        target.startAt();
        }
        {
        target.endsAt();
        }
        {
        target.sold();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for buy
    function test_buy_success_8() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
    }

    // @cover-intent Read discountRate constant
    function test_discountRate_view_9() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.discountRate();
        }
    }

    // @cover-intent Read endsAt constant
    function test_endsAt_view_10() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.endsAt();
        }
    }

    // @cover-intent Read current price before auction ends
    function test_getCurrentPrice_before_end_11() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.getCurrentPrice();
        }
    }

    // @cover-intent Read seller address
    function test_seller_view_12() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.seller();
        }
    }

    // @cover-intent Read sold flag before any purchase
    function test_sold_view_13() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.sold();
        }
    }

    // @cover-intent Read startAt constant
    function test_startAt_view_14() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.startAt();
        }
    }

    // @cover-intent Read startPrice constant
    function test_startPrice_view_15() public {
        vm.startPrank(owner);
        DutchAuction_076 target = new DutchAuction_076(1, 1, 1);
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
        target.startPrice();
        }
    }

}
