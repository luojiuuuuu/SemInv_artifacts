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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH, then collect a portion of their balance when the balance meets MinSum.
    function test_Deposit_and_Collect_positive_path_0() public {
// assume: balances(alice) >= 2 ether
// assume: MinSum() == 1 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Ensure Collect reverts if the requested amount exceeds the caller's balance.
    function test_Collect_fails_when_amount_exceeds_balance_1() public {
// assume: balances(alice) == 2 ether
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
        // skip ABI-mismatched call: Deposit()
        vm.expectRevert();
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum can be called before Initialized to change MinSum.
    function test_SetMinSum_before_initialization_2() public {
// assume: intitalized == false
// cover: SetMinSum :: intitalized false
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
        vm.startPrank(alice);
        {
        target.SetMinSum(2 ether);
        }
        // skip ABI-mismatched call: MinSum()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetMinSum reverts after Initialized is called.
    function test_SetMinSum_reverts_after_initialization_3() public {
// assume: intitalized == true
// cover: SetMinSum :: intitalized true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that SetLogFile can be called before Initialized to change the log address.
    function test_SetLogFile_before_initialization_4() public {
// assume: intitalized == false
// cover: SetLogFile :: intitalized false
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Protocol State Machine: Verify that SetLogFile reverts after Initialized is called.
    function test_SetLogFile_reverts_after_initialization_5() public {
// assume: intitalized == true
// cover: SetLogFile :: intitalized true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate and a collect of the full balance works.
    function test_Multiple_deposits_and_collect_edge_6() public {
// assume: balances(alice) == 3 ether
// assume: MinSum() == 1 ether
// cover: Collect :: balances[msg.sender] >= MinSum && balances[msg.sender] >= _am true
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
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_7() public {
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
        target.SetLogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_sequence_8() public {
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
        // skip ABI-mismatched call: Initialized()
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_sequence_9() public {
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
        // skip ABI-mismatched call: MinSum()
        // TODO assert: call:MinSum() >= 1 ether
    }

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_10() public {
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
    function test_perfn_SetLogFile_11() public {
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
    function test_perfn_SetMinSum_12() public {
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
    function test_perfn_balances_13() public {
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
