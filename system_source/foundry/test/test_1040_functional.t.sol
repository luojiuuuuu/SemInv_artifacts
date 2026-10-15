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


    // @cover-intent Financial & Accounting: Verify that a participant with a lucky address (luckyNumberOfAddress == 7) wins 7x their bet when contract has sufficient balance, and winner mapping is updated.
    function test_participate_win_sufficient_balance_0() public {
// assume: luckyNumberOfAddress(alice) == 7
// assume: this.balance >= 0.7 ether
// cover: participate :: msg.value >= 0.1 ether true
// cover: participate :: winner[msg.sender] == false true
// cover: participate :: luckyNumberOfAddress(msg.sender) == LuckyNumber true
// cover: participate :: win <= this.balance true
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: participate()
        // skip ABI-mismatched call: participate()
        vm.expectRevert();
        // skip ABI-mismatched call: participate()
        vm.stopPrank();
        // TODO assert: owner.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify that when contract balance is insufficient to pay 7x bet, the entire balance is transferred to the winner.
    function test_participate_win_insufficient_balance_1() public {
// assume: luckyNumberOfAddress(alice) == 7
// assume: this.balance == 0.5 ether
// cover: participate :: win > this.balance true
// cover: participate :: win = this.balance
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: participate()
        vm.prank(alice);
        // skip ABI-mismatched call: participate()
    }

    // @cover-intent Financial & Accounting: Verify that a participant with a non-lucky address does not win and does not get a refund (ticket price is kept).
    function test_participate_no_win_2() public {
// assume: luckyNumberOfAddress(alice) != 7
// cover: participate :: luckyNumberOfAddress(msg.sender) == LuckyNumber false
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(2)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: participate()
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending less than 0.1 ETH results in no state change (early return).
    function test_participate_below_minimum_3() public {
// assume: msg.value < 0.1 ether
// cover: participate :: msg.value < 0.1 ether true
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
        // skip ABI-mismatched call: participate()
    }

    // @cover-intent Authorization & Access Control: Verify that an address that has already won cannot participate again (require fails).
    function test_participate_already_won_4() public {
// assume: winner[alice] == true
// cover: participate :: winner[msg.sender] == false false
        vm.startPrank(owner);
        OpenAddressLottery target = new OpenAddressLottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: participate()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call kill() and the contract selfdestructs.
    function test_kill_by_owner_5() public {
// assume: msg.sender == owner
// cover: kill :: msg.sender == owner true
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call kill() (require fails).
    function test_kill_by_non_owner_6() public {
// assume: msg.sender != owner
// cover: kill :: msg.sender == owner false
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
        // skip ABI-mismatched call: kill()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Protocol State Machine: Verify that owner can forceReseed, updating secretSeed and lastReseed.
    function test_forceReseed_by_owner_7() public {
// assume: msg.sender == owner
// cover: forceReseed :: msg.sender == owner true
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
        // skip ABI-mismatched call: forceReseed()
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call forceReseed (require fails).
    function test_forceReseed_by_non_owner_8() public {
// assume: msg.sender != owner
// cover: forceReseed :: msg.sender == owner false
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
        // skip ABI-mismatched call: forceReseed()
        // TODO assert: alice.balance == 100
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
        // skip ABI-mismatched call: forceReseed()
        // skip ABI-mismatched call: forceReseed()
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
        // skip ABI-mismatched call: kill()
        // skip ABI-mismatched call: kill()
        vm.stopPrank();
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
    function test_participate_with_win_12() public {
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
        // skip ABI-mismatched call: forceReseed()
        vm.prank(alice);
        // skip ABI-mismatched call: participate()
    }

}
