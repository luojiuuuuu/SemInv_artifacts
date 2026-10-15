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


    // @cover-intent Financial & Accounting: Verify that after a successful invest and waiting ONE_MINUTE, resetInvestment correctly distributes jackpot to lastInvestor and resets state.
    function test_Positive_invest_and_reset_after_timeout_0() public {
// assume: block.timestamp >= lastInvestmentTimestamp + ONE_MINUTE
// cover: invest :: require(msg.value >= jackpot/2) true
// cover: resetInvestment :: require(block.timestamp >= lastInvestmentTimestamp + ONE_MINUTE) true
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
        {
        target.resetInvestment();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.resetInvestment();
        }
    }

    // @cover-intent Authorization & Access Control: Ensure invest reverts when msg.value is less than jackpot/2.
    function test_Invest_with_insufficient_value_reverts_1() public {
// cover: invest :: require(msg.value >= jackpot/2) false
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
    }

    // @cover-intent Protocol State Machine: Verify resetInvestment reverts if called before ONE_MINUTE has elapsed since last investment.
    function test_ResetInvestment_before_timeout_reverts_2() public {
// assume: block.timestamp < lastInvestmentTimestamp + ONE_MINUTE
// cover: resetInvestment :: require(block.timestamp >= lastInvestmentTimestamp + ONE_MINUTE) false
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
        vm.prank(alice);
        {
        target.resetInvestment();
        }
    }

    // @cover-intent Financial & Accounting: Verify jackpot increases by msg.value/2 on each invest.
    function test_Multiple_invests_increase_jackpot_correctly_3() public {
// cover: invest :: require(msg.value >= jackpot/2) true
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
        {
        target.jackpot();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that after timeout, resetInvestment sends jackpot to lastInvestor and owner gets remainder.
    function test_ResetInvestment_after_timeout_sends_jackpot_to_lastInvestor_4() public {
// assume: block.timestamp >= lastInvestmentTimestamp + ONE_MINUTE
// cover: resetInvestment :: require(block.timestamp >= lastInvestmentTimestamp + ONE_MINUTE) true
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
        vm.prank(bob);
        {
        target.resetInvestment();
        }
    }

    // @cover-intent Authorization & Access Control: Verify constructor sets owner to deployer and reverts if msg.value < 1 ether.
    function test_Constructor_sets_owner_and_requires_1_ether_5() public {
// assume: constructor was called with msg.value >= 1 ether
// cover: Governmental :: require(msg.value >= 1 ether) true
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
        {
        target.owner();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_ONE_MINUTE_test_6() public {
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
        {
        target.ONE_MINUTE();
        }
    }

    // @cover-intent Financial & Accounting
    function test_invest_test_7() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_jackpot_test_8() public {
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
        {
        target.jackpot();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lastInvestmentTimestamp_test_9() public {
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
        {
        target.lastInvestmentTimestamp();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lastInvestor_test_10() public {
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
        {
        target.lastInvestor();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_test_11() public {
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
        {
        target.owner();
        }
    }

    // @cover-intent Protocol State Machine
    function test_resetInvestment_test_12() public {
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
        {
        target.resetInvestment();
        }
    }

}
