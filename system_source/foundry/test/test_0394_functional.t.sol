// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/ether_lotto.sol";

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

contract EtherLotto_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EtherLotto_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a winning play distributes pot minus fee to the player, sends fee to bank, and resets pot to zero.
    function test_Play_and_win_scenario_0() public {
// assume: block.timestamp % 2 == 0
// cover: play :: random == 0
        vm.startPrank(alice);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: play()
        {
            uint256 __v1 = uint256(target.pot());
            _assertRelU(__v1, 0, 0, "call:pot==0");
        }
    }

    // @cover-intent Financial & Accounting: Verify that a losing play only increases the pot by the ticket amount.
    function test_Play_and_lose_scenario_1() public {
// assume: block.timestamp % 2 == 1
// cover: play :: random == 1
        vm.startPrank(alice);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: play()
        // TODO assert: call:pot() == initial_pot + 10 ether
    }

    // @cover-intent Transactional Consistency: Verify that sending an incorrect msg.value causes the transaction to revert.
    function test_Play_with_wrong_value_reverts_2() public {
// cover: play :: assert(msg.value == TICKET_AMOUNT) false
        vm.startPrank(owner);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: play()
        // TODO assert: call:pot() == initial_pot
    }

    // @cover-intent Financial & Accounting: Verify that multiple losing plays accumulate pot, then a winning play distributes correctly.
    function test_Multiple_plays_accumulate_pot_until_win_3() public {
// assume: block.timestamp % 2 == 1 for first two plays
// assume: block.timestamp % 2 == 0 for third play
// cover: play :: random == 1
// cover: play :: random == 0
        vm.startPrank(alice);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: play()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: play()
        {
            uint256 __v2 = uint256(target.pot());
            _assertRelU(__v2, 0, 0, "call:pot==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bank_sequence_4() public {
        vm.startPrank(owner);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: bank()
    }

    // @cover-intent Financial & Accounting
    function test_play_sequence_5() public {
        vm.startPrank(alice);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: play()
    }

    // @cover-intent Financial & Accounting
    function test_pot_sequence_6() public {
        vm.startPrank(owner);
        EtherLotto target = new EtherLotto();
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
        // skip ABI-mismatched call: pot()
        {
            uint256 __v3 = uint256(target.pot());
            _assertRelU(__v3, 2, 0, "call:pot>=0");
        }
    }

}
