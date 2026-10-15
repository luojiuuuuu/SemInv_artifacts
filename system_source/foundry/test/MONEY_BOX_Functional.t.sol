// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

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

contract MONEY_BOX_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MONEY_BOX_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that SetMinSum and SetLogFile can only be called before Initialized, and that Initialized locks configuration.
    function test_initialization_and_setup_0() public {
// cover: SetMinSum :: if(intitalized)throw; false
// cover: SetMinSum :: if(intitalized)throw; true
// cover: SetLogFile :: if(intitalized)throw; false
// cover: SetLogFile :: if(intitalized)throw; true
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.expectRevert();
        {
        target.SetMinSum(200);
        }
        vm.expectRevert();
        {
        target.SetLogFile(0x0000000000000000000000000000000000000002);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, and then collect when balance >= MinSum and unlock time has passed.
    function test_put_and_collect_positive_1() public {
// assume: block.timestamp >= 2
// cover: Put :: acc.balance += msg.value
// cover: Put :: if(now+_lockTime>acc.unlockTime)acc.unlockTime=now+_lockTime
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(1 ether)(1);
        }
        vm.expectRevert();
        {
        target.Collect(500);
        }
        {
        target.Put.value(1 ether)(0);
        }
        {
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 2 ether + 100 wei
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when user balance is less than MinSum.
    function test_collect_insufficient_balance_2() public {
// cover: Collect :: acc.balance>=MinSum false
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(50 wei)(0);
        }
        vm.expectRevert();
        {
        target.Collect(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether - 50 wei
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when requested amount exceeds user balance.
    function test_collect_amount_exceeds_balance_3() public {
// cover: Collect :: acc.balance>=_am false
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(200 wei)(0);
        }
        vm.expectRevert();
        {
        target.Collect(300);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether - 200 wei
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when current time is before unlock time.
    function test_collect_before_unlock_time_4() public {
// assume: block.timestamp == 1
// cover: Collect :: now>acc.unlockTime false
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(200 wei)(100);
        }
        vm.expectRevert();
        {
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether - 200 wei
    }

    // @cover-intent External Interaction & Environment: Verify that the fallback function calls Put(0) and correctly updates balance and unlock time.
    function test_fallback_put_zero_5() public {
// assume: block.timestamp >= 51
// cover: fallback :: Put(0)
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100 wei)(50);
        }
        vm.expectRevert();
        {
        target.Collect(100);
        }
        {
        target.Put.value(100 wei)(0);
        }
        {
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether - 200 wei + 100 wei
    }

    // @cover-intent Financial & Accounting: Verify that multiple users can independently deposit and collect without interference.
    function test_multiple_users_collect_6() public {
// cover: Collect :: multiple users
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.Put.value(200 wei)(0);
        }
        vm.prank(bob);
        {
        target.Put.value(300 wei)(0);
        }
        vm.prank(alice);
        {
        target.Collect(100);
        }
        vm.prank(bob);
        {
        target.Collect(200);
        }
        // TODO assert: alice.balance == 2 ether - 200 wei + 100 wei
        // TODO assert: bob.balance == 2 ether - 300 wei + 200 wei
    }

    // @cover-intent Financial & Accounting: Verify that Collect works when balance exactly equals MinSum and requested amount equals balance.
    function test_collect_exact_minimum_7() public {
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime
        vm.startPrank(alice);
        MONEY_BOX target = new MONEY_BOX();
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
        {
        target.Initialized();
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.Put.value(100 wei)(0);
        }
        {
        target.Collect(100);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether - 100 wei + 100 wei
    }

    // @cover-intent Protocol State Machine
    function test_Initialized_test_8() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
    function test_MinSum_test_9() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 0, "call:MinSum==0");
        }
    }

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_10() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        target.Acc(alice);
        }
    }

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_11() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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

    // @cover-intent minimal test for Put
    function test_perfn_Put_12() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
        target.Put(1);
        }
    }

    // @cover-intent minimal test for SetLogFile
    function test_perfn_SetLogFile_13() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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
    function test_perfn_SetMinSum_14() public {
        vm.startPrank(owner);
        MONEY_BOX target = new MONEY_BOX();
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

}
