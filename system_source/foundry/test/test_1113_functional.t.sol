// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;
import "../src/buggy_4.sol";

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

contract PHO_FunctionalTest {
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


    // @cover-intent Verify initial token distribution and state after construction (Financial & Accounting)
    function test_PHO_initial_state_verification_0() public {
// cover: constructor :: initial distribution
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: totalSupply()
        // skip ABI-mismatched call: name()
        // skip ABI-mismatched call: symbol()
        // skip ABI-mismatched call: decimals()
        // skip ABI-mismatched call: owner()
        {
        target.balanceOf(owner);
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 0
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 2000000000000000000000000000, "call:totalSupply>=2000000000000000000000000000");
        }
    }

    // @cover-intent Test normal transfer between non-team addresses (Financial & Accounting)
    function test_PHO_transfer_normal_1() public {
// assume: balance(alice) >= 500000000000000000
// assume: balance(bob) >= 250000000000000000
// cover: transfer :: require(msg.sender != to) true
// cover: transfer :: require(value > 0) true
// cover: transfer :: require(balances[msg.sender] >= value) true
// cover: transfer :: require(balances[to] + value >= balances[to]) true
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000000000000000000);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transfer(alice, 1000000000000000000);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 500000000000000000);
        }
        vm.prank(bob);
        {
        target.transfer(alice, 250000000000000000);
        }
        // TODO assert: alice.balance == 750000000000000000
        // TODO assert: bob.balance == 250000000000000000
    }

    // @cover-intent Test transfer to self reverts (Transactional Consistency)
    function test_PHO_transfer_self_revert_2() public {
// assume: balance(alice) >= 50
// cover: transfer :: require(msg.sender != to) false
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transfer(alice, 100);
        }
        vm.prank(alice);
        {
        target.transfer(alice, 50);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Test transfer with zero value reverts (Transactional Consistency)
    function test_PHO_transfer_zero_value_revert_3() public {
// cover: transfer :: require(value > 0) false
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transfer(alice, 100);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 0);
        }
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Test transfer with insufficient balance reverts (Financial & Accounting)
    function test_PHO_transfer_insufficient_balance_revert_4() public {
// cover: transfer :: require(balances[msg.sender] >= value) false
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transfer(alice, 10);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 20);
        }
        // TODO assert: alice.balance == 10
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Test normal burn by owner (Financial & Accounting)
    function test_PHO_burnCoins_normal_5() public {
// assume: balance(alice) >= 500
// assume: totalSupply() >= 500
// cover: burnCoins :: require(balances[msg.sender] >= value) true
// cover: burnCoins :: require(_totalSupply >= value) true
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.transfer(alice, 1000);
        }
        {
        target.burnCoins(500);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 500
        {
            uint256 __v2 = uint256(target.totalSupply());
            _assertRelU(__v2, 2, 1999999999999999999999999500, "call:totalSupply>=1999999999999999999999999500");
        }
    }

    // @cover-intent Test burn with insufficient balance reverts (Financial & Accounting)
    function test_PHO_burnCoins_insufficient_balance_revert_6() public {
// cover: burnCoins :: require(balances[msg.sender] >= value) false
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transfer(alice, 100);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.burnCoins(200);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Test burn exceeding total supply reverts (Financial & Accounting)
    function test_PHO_burnCoins_exceeds_supply_revert_7() public {
// cover: burnCoins :: require(_totalSupply >= value) false
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(owner);
        {
        target.burnCoins(3000000000000000000000000000);
        }
    }

    // @cover-intent Test team transfer before first unlock time reverts (Authorization & Access Control)
    function test_PHO_team_transfer_timelock_before_first_unlock_8() public {
// assume: block.timestamp < 1589036400
// cover: transfer :: require(now >= 1589036400) false
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1579830272)));
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.transfer(alice, 1);
        }
    }

    // @cover-intent Test team transfer after first unlock time succeeds (Authorization & Access Control)
    function test_PHO_team_transfer_after_first_unlock_9() public {
// assume: block.timestamp >= 1589036400
// assume: balance(team) >= 100000000000000000
// cover: transfer :: require(now >= 1589036400) true
// cover: transfer :: require(msg.sender == team) true
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1589611376)));
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.transfer(alice, 100000000000000000);
        }
        // TODO assert: alice.balance == 100000000000000000
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_10() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp13_11() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_tmstmp13()
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp33_12() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_tmstmp33()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp36_13() public {
        vm.startPrank(alice);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_tmstmp36()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp4_14() public {
        vm.startPrank(alice);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_tmstmp4()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp40_15() public {
        vm.startPrank(alice);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_tmstmp40()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp8_16() public {
        vm.startPrank(alice);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: bug_tmstmp8()
    }

    // @cover-intent Authorization & Access Control
    function test_burnCoins_owner_17() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.burnCoins(100);
        }
        // TODO assert: owner.balance == 1999999900
    }

    // @cover-intent Authorization & Access Control
    function test_burnCoins_nonowner_18() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.burnCoins(1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_decimals_19() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: decimals()
    }

    // @cover-intent Financial & Accounting
    function test_evt_20() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: evt()
    }

    // @cover-intent Financial & Accounting
    function test_name_21() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: name()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_22() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp14_23() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp14(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp23_24() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp23(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp27_25() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp27(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp30_26() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp30(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp31_27() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp31(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp35_28() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp35(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp39_29() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp39(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp7_30() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.play_tmstmp7(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_sale_31() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: sale()
    }

    // @cover-intent Financial & Accounting
    function test_symbol_32() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
    }

    // @cover-intent Financial & Accounting
    function test_team_33() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: team()
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_34() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
        {
            uint256 __v3 = uint256(target.totalSupply());
            _assertRelU(__v3, 0, 2000000000, "call:totalSupply==2000000000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_35() public {
        vm.startPrank(owner);
        PHO target = new PHO();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transfer(alice, 100);
        }
        // TODO assert: owner.balance == 1999999900
        // TODO assert: alice.balance == 100
    }

}
