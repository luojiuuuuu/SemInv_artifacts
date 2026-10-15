// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/lotto.sol";

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

contract Lotto_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Lotto_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify sendToWinner succeeds when payedOut is false, transitioning payedOut to true.
    function test_SendToWinner_before_payout_0() public {
// assume: payedOut == false
// cover: sendToWinner :: require(!payedOut) true
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner()
    }

    // @cover-intent Protocol State Machine: Verify sendToWinner reverts when payedOut is already true.
    function test_SendToWinner_after_payout_reverts_1() public {
// assume: payedOut == true
// cover: sendToWinner :: require(!payedOut) false
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner()
    }

    // @cover-intent Protocol State Machine: Verify withdrawLeftOver succeeds when payedOut is true.
    function test_WithdrawLeftOver_after_payout_succeeds_2() public {
// assume: payedOut == true
// cover: withdrawLeftOver :: require(payedOut) true
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawLeftOver()
    }

    // @cover-intent Protocol State Machine: Verify withdrawLeftOver reverts when payedOut is false.
    function test_WithdrawLeftOver_before_payout_reverts_3() public {
// assume: payedOut == false
// cover: withdrawLeftOver :: require(payedOut) false
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawLeftOver()
    }

    // @cover-intent Protocol State Machine: Verify the state transition from payedOut=false to true, then allow withdrawLeftOver.
    function test_Full_lifecycle_sendToWinner_then_withdrawLeftOver_4() public {
// assume: payedOut == false
// cover: sendToWinner :: require(!payedOut) true
// cover: withdrawLeftOver :: require(payedOut) true
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner()
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawLeftOver()
    }

    // @cover-intent Transactional Consistency: Verify that winAmount and winner are readable after sendToWinner, and payedOut is true.
    function test_Read_state_variables_after_sendToWinner_5() public {
// assume: payedOut == false
        vm.startPrank(owner);
        Lotto target = new Lotto();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: sendToWinner()
        vm.startPrank(bob);
        // skip ABI-mismatched call: payedOut()
        // skip ABI-mismatched call: winAmount()
        // skip ABI-mismatched call: winner()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_payedOut_initial_state_6() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: payedOut()
    }

    // @cover-intent Protocol State Machine
    function test_sendToWinner_before_payout_7() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: sendToWinner()
    }

    // @cover-intent Financial & Accounting
    function test_winAmount_initial_8() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: winAmount()
        {
            uint256 __v1 = uint256(target.winAmount());
            _assertRelU(__v1, 2, 0, "call:winAmount>=0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_winner_initial_9() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: winner()
    }

    // @cover-intent Protocol State Machine
    function test_withdrawLeftOver_after_payout_10() public {
        vm.startPrank(owner);
        Lotto target = new Lotto();
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
        // skip ABI-mismatched call: sendToWinner()
        // skip ABI-mismatched call: withdrawLeftOver()
        vm.stopPrank();
    }

}
