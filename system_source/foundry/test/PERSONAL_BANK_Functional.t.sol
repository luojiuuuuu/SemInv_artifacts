// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

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

contract PERSONAL_BANK_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PERSONAL_BANK_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that after initialization, SetMinSum and SetLogFile are locked, and Deposit works correctly.
    function test_Initialization_and_Deposit_0() public {
// assume: intitalized == true
// cover: SetMinSum :: if(intitalized)revert() true
// cover: SetLogFile :: if(intitalized)revert() true
// cover: Deposit :: normal execution
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(2 ether);
        }
        {
        target.SetLogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);
        }
        {
        target.Initialized();
        }
        vm.expectRevert();
        {
        target.SetMinSum(1 ether);
        }
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        {
        target.Deposit.value(5 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when balance is below MinSum.
    function test_Collect_Below_MinSum_1() public {
// assume: balances(alice) == 1 ether
// assume: MinSum() == 2 ether
// cover: Collect :: balances[msg.sender] >= MinSum false
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(2 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(1 ether)();
        }
        vm.expectRevert();
        // skip malformed call: Collect(0.5 ether) (bad raw arg for Collect.arg0: type=uint256, raw=0.5 ether)
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when requested amount exceeds balance.
    function test_Collect_Exceeds_Balance_2() public {
// assume: balances(alice) == 3 ether
// assume: MinSum() == 1 ether
// cover: Collect :: balances[msg.sender] >= _am false
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(3 ether)();
        }
        vm.expectRevert();
        {
        target.Collect(5 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent Financial & Accounting: Verify successful Collect reduces balance and sends ETH.
    function test_Successful_Collect_3() public {
// assume: balances(alice) == 5 ether
// assume: MinSum() == 1 ether
// cover: Collect :: balances[msg.sender] >= MinSum true
// cover: Collect :: balances[msg.sender] >= _am true
// cover: Collect :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 3 ether
    }

    // @cover-intent Financial & Accounting: Verify multiple deposits and a partial collect maintain correct balances.
    function test_Multiple_Deposits_And_Collect_4() public {
// assume: balances(alice) == 8 ether
// assume: MinSum() == 1 ether
// cover: Collect :: successful collect
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(5 ether)();
        }
        {
        target.Deposit.value(3 ether)();
        }
        {
        target.Collect(4 ether);
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify Collect with zero amount when balance meets MinSum.
    function test_Collect_Zero_Amount_5() public {
// assume: balances(alice) == 2 ether
// assume: MinSum() == 1 ether
// cover: Collect :: balances[msg.sender] >= _am true with _am=0
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.Collect(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Financial & Accounting: Verify Collect works when balance exactly equals MinSum.
    function test_Collect_Exact_MinSum_6() public {
// assume: balances(alice) == 2 ether
// assume: MinSum() == 2 ether
// cover: Collect :: balances[msg.sender] >= MinSum true (equal)
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(2 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Transactional Consistency: Verify that deposits and collects from different users are independent.
    function test_Multiple_Users_Independent_Balances_7() public {
// assume: balances(alice) == 4 ether
// assume: balances(bob) == 6 ether
// assume: MinSum() == 1 ether
// cover: Collect :: independent user balances
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.SetMinSum(1 ether);
        }
        {
        target.Initialized();
        }
        {
        target.Deposit.value(4 ether)();
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.Deposit.value(6 ether)();
        }
        vm.prank(alice);
        {
        target.Collect(2 ether);
        }
        vm.prank(bob);
        {
        target.Collect(3 ether);
        }
        // TODO assert: alice.balance == 2 ether
        // TODO assert: bob.balance == 3 ether
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_positive_path_8() public {
        vm.startPrank(alice);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        target.Deposit.value(1 ether)();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_positive_path_9() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
    function test_MinSum_read_10() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
        vm.prank(alice);
        {
        target.MinSum();
        }
        // TODO assert: call:MinSum() >= 2 ether
    }

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_11() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
    function test_perfn_SetLogFile_12() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
    function test_perfn_SetMinSum_13() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
    function test_perfn_balances_14() public {
        vm.startPrank(owner);
        PERSONAL_BANK target = new PERSONAL_BANK();
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
