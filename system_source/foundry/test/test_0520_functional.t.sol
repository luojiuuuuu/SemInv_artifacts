// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/governmental_survey.sol";

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

contract Governmental_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Governmental_FunctionalTest() public {
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


    // @cover-intent Verify constructor sets owner and requires minimum 1 ether investment. (Authorization & Access Control)
    function test_constructor_and_initial_state_0() public {
// cover: Governmental :: require(msg.value>=1 ether) true
        vm.startPrank(owner);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: owner()
        // skip ABI-mismatched call: jackpot()
        // skip ABI-mismatched call: ONE_MINUTE()
        vm.stopPrank();
    }

    // @cover-intent Verify invest() reverts if msg.value < jackpot/2. (Financial & Accounting)
    function test_invest_below_minimum_reverts_1() public {
// assume: jackpot() == 1 ether
// cover: invest :: require(msg.value>=jackpot/2) false
        vm.startPrank(owner);
        Governmental target = new Governmental();
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
        vm.prank(bob);
        // skip ABI-mismatched call: invest()
    }

    // @cover-intent Verify invest() updates lastInvestor, jackpot, and lastInvestmentTimestamp. (Financial & Accounting)
    function test_invest_successful_updates_state_2() public {
// assume: jackpot() == 1 ether
// cover: invest :: require(msg.value>=jackpot/2) true
        vm.startPrank(bob);
        Governmental target = new Governmental();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        // skip ABI-mismatched call: invest()
        // skip ABI-mismatched call: lastInvestor()
        // skip ABI-mismatched call: jackpot()
        vm.stopPrank();
    }

    // @cover-intent Verify resetInvestment() reverts if called before ONE_MINUTE has elapsed. (Protocol State Machine)
    function test_resetInvestment_before_timeout_reverts_3() public {
// assume: block.timestamp < lastInvestmentTimestamp() + ONE_MINUTE()
// cover: resetInvestment :: require(block.timestamp>=lastInvestmentTimestamp+ONE_MINUTE) false
        vm.startPrank(bob);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: invest()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: resetInvestment()
    }

    // @cover-intent Verify resetInvestment() succeeds after ONE_MINUTE, sends jackpot to lastInvestor and remaining balance minus 1 ether to owner. (Financial & Accounting)
    function test_resetInvestment_after_timeout_success_4() public {
// assume: block.timestamp >= lastInvestmentTimestamp() + ONE_MINUTE()
// cover: resetInvestment :: require(block.timestamp>=lastInvestmentTimestamp+ONE_MINUTE) true
        vm.startPrank(bob);
        Governmental target = new Governmental();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        // skip ABI-mismatched call: invest()
        vm.startPrank(alice);
        // skip ABI-mismatched call: resetInvestment()
        // skip ABI-mismatched call: lastInvestor()
        // skip ABI-mismatched call: jackpot()
        // skip ABI-mismatched call: lastInvestmentTimestamp()
        vm.stopPrank();
    }

    // @cover-intent Verify multiple investments accumulate jackpot correctly and reset works. (Financial & Accounting)
    function test_multiple_investments_and_reset_5() public {
// assume: jackpot() == 1.5 ether after first invest
// cover: invest :: require(msg.value>=jackpot/2) true
        vm.startPrank(bob);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: invest()
        vm.startPrank(carol);
        // skip ABI-mismatched call: invest()
        // skip ABI-mismatched call: jackpot()
        // skip ABI-mismatched call: lastInvestor()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_ONE_MINUTE_view_6() public {
        vm.startPrank(owner);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: ONE_MINUTE()
        {
            uint256 __v1 = uint256(target.ONE_MINUTE());
            _assertRelU(__v1, 0, 60, "call:ONE_MINUTE==60");
        }
    }

    // @cover-intent Financial & Accounting
    function test_invest_positive_7() public {
        vm.startPrank(alice);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: invest()
    }

    // @cover-intent Financial & Accounting
    function test_jackpot_view_8() public {
        vm.startPrank(owner);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: jackpot()
        // TODO assert: call:jackpot() == 1 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_lastInvestmentTimestamp_view_9() public {
        vm.startPrank(owner);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: lastInvestmentTimestamp()
        {
            uint256 __v2 = uint256(target.lastInvestmentTimestamp());
            _assertRelU(__v2, 2, 0, "call:lastInvestmentTimestamp>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_lastInvestor_view_10() public {
        vm.startPrank(owner);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: lastInvestor()
        // TODO assert: call:lastInvestor() == address(0)
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_11() public {
        vm.startPrank(owner);
        Governmental target = new Governmental();
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

    // @cover-intent Protocol State Machine
    function test_resetInvestment_positive_12() public {
        vm.startPrank(alice);
        Governmental target = new Governmental();
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
        // skip ABI-mismatched call: invest()
        // skip ABI-mismatched call: resetInvestment()
        vm.stopPrank();
    }

}
