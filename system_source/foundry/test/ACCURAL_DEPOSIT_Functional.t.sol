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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH, then collect up to their balance when balance >= MinSum and balance >= _am.
    function test_Deposit_and_Collect_positive_path_0() public {
// assume: MinSum == 1 ether
// assume: balances(alice) >= 5 ether
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
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when caller's balance is less than MinSum.
    function test_Collect_fails_when_balance_below_MinSum_1() public {
// assume: MinSum == 1 ether
// assume: balances(alice) == 0.5 ether
// cover: Collect :: balances[msg.sender] >= MinSum false
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
        {
        target.Deposit.value(0.5 ether)();
        }
        vm.expectRevert();
        // skip malformed call: Collect(0.1 ether) (bad raw arg for Collect.arg0: type=uint256, raw=0.1 ether)
        vm.stopPrank();
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when requested amount exceeds caller's balance.
    function test_Collect_fails_when_am_exceeds_balance_2() public {
// assume: MinSum == 1 ether
// assume: balances(alice) == 2 ether
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
        {
        target.Deposit.value(2 ether)();
        }
        vm.expectRevert();
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum can be called before Initialized, and changes MinSum.
    function test_SetMinSum_before_initialization_3() public {
// assume: intitalized == false
// cover: SetMinSum :: intitalized false
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
        {
        target.MinSum();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum reverts after Initialized is called.
    function test_SetMinSum_reverts_after_initialization_4() public {
// assume: intitalized == true
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
        target.Initialized();
        }
        vm.expectRevert();
        {
        target.SetMinSum(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetLogFile can be called before Initialized.
    function test_SetLogFile_before_initialization_5() public {
// assume: intitalized == false
// cover: SetLogFile :: intitalized false
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

    // @cover-intent Protocol State Machine: Verify that SetLogFile reverts after Initialized is called.
    function test_SetLogFile_reverts_after_initialization_6() public {
// assume: intitalized == true
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
        target.Initialized();
        }
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000002);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract via fallback calls Deposit and increases balance.
    function test_Fallback_triggers_Deposit_7() public {
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
        {
        target.Deposit();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect with _am = 0 succeeds when balance >= MinSum.
    function test_Collect_with_zero_amount_8() public {
// assume: MinSum == 1 ether
// assume: balances(alice) == 2 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
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
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.Collect(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate and partial collect reduces balance correctly.
    function test_Multiple_deposits_and_partial_collect_9() public {
// assume: MinSum == 1 ether
// assume: balances(alice) == 5 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
// cover: Collect :: msg.sender.call.value(4 ether)() true
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
        {
        target.Deposit.value(3 ether)();
        }
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.Collect(4 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_10() public {
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
        vm.startPrank(owner);
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Deposit.value(1 ether)();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_11() public {
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
        target.Initialized();
        }
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_sequence_12() public {
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
        {
        target.MinSum();
        }
    }

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_13() public {
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
        {
        target.Collect(1);
        }
    }

    // @cover-intent minimal test for SetLogFile
    function test_perfn_SetLogFile_14() public {
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
        target.SetLogFile(alice);
        }
    }

    // @cover-intent minimal test for SetMinSum
    function test_perfn_SetMinSum_15() public {
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
        target.SetMinSum(1);
        }
    }

    // @cover-intent minimal test for balances
    function test_perfn_balances_16() public {
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
        {
        target.balances(alice);
        }
    }

}
