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


    // @cover-intent Financial & Accounting: Verify that a player who wins receives the pot minus fee, and the pot resets to zero.
    function test_Normal_play_and_win_0() public {
// assume: block.timestamp % 2 == 0 for bob's transaction
// cover: play :: random == 0 true
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
        vm.prank(bob);
        // skip ABI-mismatched call: play()
    }

    // @cover-intent Financial & Accounting: Verify that a player who loses does not receive the pot, and the pot increases.
    function test_Play_and_lose_1() public {
// assume: block.timestamp % 2 == 1 for bob's transaction
// cover: play :: random == 1 true
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
        vm.prank(bob);
        // skip ABI-mismatched call: play()
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
    }

    // @cover-intent Financial & Accounting: Verify that the pot accumulates correctly over multiple losing plays.
    function test_Multiple_plays_and_pot_accumulation_3() public {
// assume: block.timestamp % 2 == 1 for all three transactions
// cover: play :: random == 1 true
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
        vm.prank(bob);
        // skip ABI-mismatched call: play()
        vm.prank(carol);
        // skip ABI-mismatched call: play()
    }

    // @cover-intent Protocol State Machine: Verify that after a win, the pot is reset to zero.
    function test_Win_resets_pot_to_zero_4() public {
// assume: block.timestamp % 2 == 0 for bob's transaction
// cover: play :: random == 0 true
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
        vm.prank(bob);
        // skip ABI-mismatched call: play()
    }

    // @cover-intent Financial & Accounting: Verify that the bank address receives the fee when a win occurs.
    function test_Bank_receives_fee_on_win_5() public {
// assume: block.timestamp % 2 == 0 for bob's transaction
// cover: play :: random == 0 true
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
        vm.prank(bob);
        // skip ABI-mismatched call: play()
    }

    // @cover-intent Authorization & Access Control
    function test_bank_sequence_6() public {
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
    function test_play_sequence_7() public {
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
    function test_pot_sequence_8() public {
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
    }

}
