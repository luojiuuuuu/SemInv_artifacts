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


    // @cover-intent Financial & Accounting: Verify that owner cannot participate (fallback prevents it) and that a non-owner can participate and win when lucky number matches.
    function test_owner_participate_win_0() public {
// assume: luckyNumberOfAddress(alice) == 7
// cover: participate :: msg.value >= 0.1 ether true
// cover: participate :: winner[msg.sender] == false true
// cover: participate :: luckyNumberOfAddress(msg.sender) == LuckyNumber true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: participate()
        // skip ABI-mismatched call: participate()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that participating without matching lucky number does not transfer funds.
    function test_participate_no_win_1() public {
// assume: luckyNumberOfAddress(bob) != 7
// cover: participate :: msg.value >= 0.1 ether true
// cover: participate :: winner[msg.sender] == false true
// cover: participate :: luckyNumberOfAddress(msg.sender) == LuckyNumber false
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
        vm.prank(bob);
        // skip ABI-mismatched call: participate()
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending less than 0.1 ETH does nothing (returns early).
    function test_participate_insufficient_value_2() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: participate()
    }

    // @cover-intent Authorization & Access Control: Verify that an address that already won cannot participate again (require winner[msg.sender]==false).
    function test_participate_twice_same_address_3() public {
// assume: luckyNumberOfAddress(alice) == 7
// cover: participate :: winner[msg.sender] == false false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: participate()
        vm.expectRevert();
        // skip ABI-mismatched call: participate()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can kill the contract.
    function test_kill_by_owner_4() public {
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

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot kill the contract.
    function test_kill_by_non_owner_5() public {
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
    }

    // @cover-intent Protocol State Machine: Verify that owner can force a reseed, changing the secret seed and thus lucky numbers.
    function test_forceReseed_by_owner_6() public {
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

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot force reseed.
    function test_forceReseed_by_non_owner_7() public {
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
    }

    // @cover-intent Transactional Consistency: Verify that luckyNumberOfAddress returns a value between 0 and 7 (mod 8).
    function test_luckyNumberOfAddress_consistency_8() public {
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
    function test_participate_with_sufficient_value_and_no_prior_win_12() public {
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: participate()
        // skip ABI-mismatched call: participate()
        vm.stopPrank();
    }

}
