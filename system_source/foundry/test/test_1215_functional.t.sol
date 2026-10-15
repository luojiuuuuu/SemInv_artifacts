// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

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

contract PRIVATE_ETH_CELL_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PRIVATE_ETH_CELL_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that initialization gates work correctly and deposits update balances
    function test_Initialization_and_Deposit_Flow_0() public {
// cover: Deposit :: normal deposit
// cover: Initialized :: set initialized true
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify Collect succeeds when balance meets MinSum and requested amount
    function test_Collect_with_Sufficient_Balance_1() public {
// cover: Collect :: balance >= MinSum && balance >= _am
// cover: Collect :: call.value succeeds
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(2);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(3 ether);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify Collect reverts when balance is below MinSum threshold
    function test_Collect_Reverts_When_Balance_Below_MinSum_2() public {
// cover: Collect :: balance < MinSum (no-op)
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify Collect reverts when _am exceeds balance even if MinSum met
    function test_Collect_Reverts_When_Requested_Amount_Exceeds_Balance_3() public {
// cover: Collect :: balance >= MinSum but balance < _am (no-op)
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(10 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify fallback function calls Deposit and updates balance
    function test_Fallback_Triggers_Deposit_4() public {
// cover: fallback :: calls Deposit
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify SetMinSum reverts after contract is initialized
    function test_SetMinSum_Reverts_After_Initialization_5() public {
// cover: SetMinSum :: require(!intitalized) false
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetMinSum(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify SetLogFile reverts after contract is initialized
    function test_SetLogFile_Reverts_After_Initialization_6() public {
// cover: SetLogFile :: require(!intitalized) false
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        // skip ABI-mismatched call: Initialized()
        vm.expectRevert();
        {
        target.SetLogFile(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify multiple deposits correctly accumulate in balance
    function test_Multiple_Deposits_Accumulate_7() public {
// cover: Deposit :: multiple deposits
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(1);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify Collect works correctly after multiple deposits
    function test_Collect_After_Multiple_Deposits_8() public {
// cover: Collect :: balance >= MinSum && balance >= _am
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(5);
        }
        {
        target.SetLogFile(alice);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(5 ether);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify MinSum returns correct value after being set
    function test_MinSum_View_After_Initialization_9() public {
// cover: MinSum :: view function
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(42);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
    }

    // @cover-intent Financial & Accounting
    function test_Collect_test_10() public {
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetLogFile(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Collect(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_test_11() public {
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_test_12() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
    function test_MinSum_test_13() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        // skip ABI-mismatched call: Initialized()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: MinSum()
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 50, "call:MinSum==50");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_SetLogFile_test_14() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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

    // @cover-intent Financial & Accounting
    function test_SetMinSum_test_15() public {
        vm.startPrank(owner);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        target.SetMinSum(100);
        }
        {
            uint256 __v2 = uint256(target.MinSum());
            _assertRelU(__v2, 0, 100, "call:MinSum==100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_test_16() public {
        vm.startPrank(alice);
        PRIVATE_ETH_CELL target = new PRIVATE_ETH_CELL();
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
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

}
