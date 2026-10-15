// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

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

contract BANK_SAFE_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function BANK_SAFE_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that initialization prevents further configuration and that deposits work correctly after initialization.
    function test_Initialization_and_Deposit_0() public {
// assume: intitalized == true
// cover: SetMinSum :: require(!intitalized) false
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(50)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(owner);
        {
        target.SetMinSum(20);
        }
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify that Collect succeeds when balance meets MinSum and amount requirements.
    function test_Collect_Successful_1() public {
// assume: balances(alice) >= MinSum
// assume: balances(alice) >= 20
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(30);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(50)();
        }
        {
        target.Collect(20);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance is below MinSum.
    function test_Collect_Insufficient_Balance_2() public {
// assume: balances(alice) < MinSum
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) false
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(100);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(50)();
        }
        vm.expectRevert();
        {
        target.Collect(10);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when requested amount exceeds balance.
    function test_Collect_Exceeds_Balance_3() public {
// assume: balances(alice) >= MinSum
// assume: balances(alice) < 60
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) false
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(50)();
        }
        vm.expectRevert();
        {
        target.Collect(60);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent External Interaction & Environment: Verify that the fallback function triggers Deposit correctly.
    function test_Fallback_Deposit_4() public {
// cover: fallback :: Deposit() called
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(30)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 30
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate correctly.
    function test_Multiple_Deposits_5() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(25)();
        }
        {
        target.Deposit.value(35)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 60
    }

    // @cover-intent Financial & Accounting: Verify that Collect with zero amount succeeds when balance meets MinSum.
    function test_Collect_Zero_Amount_6() public {
// assume: balances(alice) >= MinSum
// assume: balances(alice) >= 0
// cover: Collect :: require(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) true
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(10);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(50)();
        }
        {
        target.Collect(0);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum works before initialization.
    function test_SetMinSum_Before_Init_7() public {
// assume: intitalized == false
// cover: SetMinSum :: require(!intitalized) true
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(50);
        }
        {
        target.MinSum();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetLogFile works before initialization.
    function test_SetLogFile_Before_Init_8() public {
// assume: intitalized == false
// cover: SetLogFile :: require(!intitalized) true
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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

    // @cover-intent Financial & Accounting
    function test_Collect_positive_9() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(50);
        }
        {
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(100)();
        }
        {
        target.Collect(30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 70
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_positive_10() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Deposit.value(50)();
        }
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_positive_11() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_12() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(100);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.MinSum();
        }
    }

    // @cover-intent Protocol State Machine
    function test_SetLogFile_positive_13() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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

    // @cover-intent Protocol State Machine
    function test_SetMinSum_positive_14() public {
        vm.startPrank(owner);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetMinSum(200);
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_view_15() public {
        vm.startPrank(alice);
        BANK_SAFE target = new BANK_SAFE();
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
        target.SetLogFile(alice);
        }
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Deposit.value(75)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 75
    }

}
