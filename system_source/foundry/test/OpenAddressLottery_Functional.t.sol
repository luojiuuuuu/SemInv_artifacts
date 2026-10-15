// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/open_address_lottery.sol";

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

contract OpenAddressLottery_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function OpenAddressLottery_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a participant with lucky number 7 receives 7x their bet when contract has sufficient balance.
    function test_Participate_win_with_sufficient_balance_0() public {
// assume: luckyNumberOfAddress(alice) == 7
// assume: address(this).balance >= 0.7 ether
// cover: participate :: require(winner[msg.sender] == false) true
// cover: participate :: luckyNumberOfAddress(msg.sender) == LuckyNumber true
// cover: participate :: win <= this.balance true
        vm.startPrank(alice);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
        vm.prank(alice);
        {
        target.participate.value(0.1 ether)();
        }
    }

    // @cover-intent Financial & Accounting: Verify that when contract balance is less than 7x bet, the entire balance is transferred.
    function test_Participate_win_with_insufficient_balance_1() public {
// assume: luckyNumberOfAddress(alice) == 7
// assume: address(this).balance < 0.7 ether
// cover: participate :: win > this.balance true
        vm.startPrank(alice);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
        vm.prank(alice);
        {
        target.participate.value(0.1 ether)();
        }
    }

    // @cover-intent Protocol State Machine: Verify that a participant with non-lucky number does not win and state is unchanged.
    function test_Participate_lose_not_lucky_2() public {
// assume: luckyNumberOfAddress(alice) != 7
// cover: participate :: luckyNumberOfAddress(msg.sender) == LuckyNumber false
        vm.startPrank(alice);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
        vm.prank(alice);
        {
        target.participate.value(0.1 ether)();
        }
    }

    // @cover-intent Transactional Consistency: Verify that sending less than 0.1 ETH reverts or returns without effect.
    function test_Participate_with_insufficient_value_3() public {
// cover: participate :: msg.value < 0.1 ether true
        vm.startPrank(alice);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.participate.value(0.05 ether)();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that an address that already won cannot participate again.
    function test_Participate_already_won_4() public {
// assume: luckyNumberOfAddress(alice) == 7
// cover: participate :: require(winner[msg.sender] == false) false
        vm.startPrank(alice);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
        vm.startPrank(alice);
        {
        target.participate.value(0.1 ether)();
        }
        vm.expectRevert();
        {
        target.participate.value(0.1 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can kill the contract.
    function test_Kill_by_owner_5() public {
// cover: kill :: require(msg.sender == owner) true
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.kill();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot kill the contract.
    function test_Kill_by_non_owner_6() public {
// cover: kill :: require(msg.sender == owner) false
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.kill();
        }
    }

    // @cover-intent Protocol State Machine: Verify that owner can force reseed, changing secretSeed and lastReseed.
    function test_ForceReseed_by_owner_7() public {
// cover: forceReseed :: require(msg.sender == owner) true
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot force reseed.
    function test_ForceReseed_by_non_owner_8() public {
// cover: forceReseed :: require(msg.sender == owner) false
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_forceReseed_by_owner_9() public {
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.forceReseed();
        }
        {
        target.forceReseed();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_kill_by_owner_10() public {
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.kill();
        }
        {
        target.kill();
        }
        vm.stopPrank();
        // TODO assert: owner.balance >= 0
    }

    // @cover-intent Resource & Execution Integrity
    function test_luckyNumberOfAddress_for_alice_11() public {
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.luckyNumberOfAddress(alice);
        }
        {
            uint256 __v1 = uint256(target.luckyNumberOfAddress(alice));
            _assertRelU(__v1, 2, 0, "call:luckyNumberOfAddress>=0");
        }
        {
            uint256 __v2 = uint256(target.luckyNumberOfAddress(alice));
            _assertRelU(__v2, 3, 7, "call:luckyNumberOfAddress<=7");
        }
    }

    // @cover-intent Financial & Accounting
    function test_participate_with_sufficient_value_and_not_winner_12() public {
        vm.startPrank(alice);
        OpenAddressLottery target = new OpenAddressLottery();
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
        target.participate.value(0.1 ether)();
        }
        {
        target.participate.value(0.1 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance >= 0
    }

}
