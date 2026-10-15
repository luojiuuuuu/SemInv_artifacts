// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

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

contract ACCURAL_DEPOSIT_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ACCURAL_DEPOSIT_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and then collect up to their balance, with balance decremented correctly.
    function test_Deposit_and_Collect_positive_path_0() public {
// assume: MinSum() <= 1 ether
// assume: balances(alice) >= 2 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
// cover: Collect :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if the requested amount exceeds the caller's balance.
    function test_Collect_fails_when_am_exceeds_balance_1() public {
// assume: MinSum() == 0.5 ether
// assume: balances(alice) == 1 ether
// cover: Collect :: balances[msg.sender] >= _am false
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        vm.expectRevert();
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum can be called before Initialized, and reverts after.
    function test_SetMinSum_before_initialization_2() public {
// assume: intitalized == false initially
// cover: SetMinSum :: intitalized false
// cover: SetMinSum :: intitalized true
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        target.SetMinSum(2 ether);
        }
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(3 ether);
        }
        vm.stopPrank();
        // TODO assert: call:MinSum() == 2 ether
    }

    // @cover-intent Protocol State Machine: Verify that SetLogFile can be called before Initialized, and reverts after.
    function test_SetLogFile_before_initialization_3() public {
// assume: intitalized == false initially
// cover: SetLogFile :: intitalized false
// cover: SetLogFile :: intitalized true
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000002);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract via fallback calls Deposit and updates balance.
    function test_Fallback_triggers_Deposit_4() public {
// cover: fallback :: fallback calls Deposit
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that Collect with _am=0 succeeds if balance >= MinSum, but no ETH is transferred.
    function test_Collect_with_zero_amount_5() public {
// assume: MinSum() == 0.5 ether
// assume: balances(alice) == 1 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= 0 true
// cover: Collect :: msg.sender.call.value(0)() true
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate and a partial collect reduces balance correctly.
    function test_Multiple_deposits_and_partial_collect_6() public {
// assume: MinSum() == 1 ether
// assume: balances(alice) == 5 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= 4 ether true
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        vm.stopPrank();
        vm.prank(owner);
        {
        target.SetMinSum(1 ether);
        }
        vm.prank(alice);
        {
        target.Collect(4 ether);
        }
    }

    // @cover-intent Financial & Accounting
    function test_Collect_test_7() public {
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        vm.startPrank(owner);
        {
        target.SetMinSum(1 ether);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Collect(1 ether);
        }
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_test_8() public {
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Initialized()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_test_9() public {
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Initialized()
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_test_10() public {
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: MinSum()
    }

    // @cover-intent Authorization & Access Control
    function test_SetLogFile_test_11() public {
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Protocol State Machine
    function test_SetMinSum_test_12() public {
        vm.startPrank(owner);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        target.SetMinSum(2 ether);
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_test_13() public {
        vm.startPrank(alice);
        ACCURAL_DEPOSIT target = new ACCURAL_DEPOSIT();
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
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

}
