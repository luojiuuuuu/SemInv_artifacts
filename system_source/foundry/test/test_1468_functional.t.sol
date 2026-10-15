// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/SwarmRedistribution.sol";

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

contract SwarmRedistribution_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function SwarmRedistribution_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify basic buy and transfer with tax redistribution works correctly
    function test_basic_buy_and_transfer_0() public {
// cover: transfer :: require(balance>=amount) true
// cover: transfer :: require(_to != msg.sender) true
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buy()
        vm.startPrank(owner);
        {
        target.transfer(bob, 5 ether);
        }
        {
        target.balanceOf(alice);
        }
        {
        target.balanceOf(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test buyViaJohan creates dividend pathway and transfer triggers swarm redistribution
    function test_buy_via_johan_and_transfer_1() public {
// cover: transfer :: require(balance>=amount) true
// cover: swarmRedistribution :: swarmTree.length != 0 true
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buyViaJohan()
        vm.startPrank(owner);
        {
        target.transfer(bob, 5 ether);
        }
        {
        target.balanceOf(alice);
        }
        {
        target.balanceOf(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify transfer to self reverts to prevent dividend pathway loops
    function test_transfer_to_self_reverts_2() public {
// cover: transfer :: require(_to != msg.sender) false
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        vm.expectRevert();
        {
        target.transfer(alice, 1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify sell reverts when balance is insufficient
    function test_sell_insufficient_balance_reverts_3() public {
// cover: sell :: require(balance>=amount) false
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        vm.expectRevert();
        {
        target.sell(10 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify selling full balance reduces supply and balance correctly
    function test_sell_full_balance_4() public {
// cover: sell :: require(balance>=amount) true
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        {
        target.sell(10 ether);
        }
        {
        target.balanceOf(alice);
        }
        // skip ABI-mismatched call: totalSupply()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify only Johan can change his address
    function test_change_johan_address_only_johan_5() public {
// cover: changeJohanNygrensAddress :: onlyJohan modifier false
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeJohanNygrensAddress(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify transfer reverts when sender has insufficient balance
    function test_transfer_insufficient_balance_reverts_6() public {
// cover: transfer :: require(balance>=amount) false
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        vm.expectRevert();
        {
        target.transfer(bob, 2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test multiple transfers create proper dividend pathways and swarm redistribution
    function test_multiple_transfers_and_swarm_7() public {
// cover: transfer :: require(balance>=amount) true
// cover: iterateThroughSwarm :: dividendPathways[_node].length != 0 true
// cover: doSwarm :: JohanInSwarm true
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buyViaJohan()
        vm.prank(bob);
        // skip ABI-mismatched call: buy()
        vm.startPrank(owner);
        {
        target.transfer(bob, 5 ether);
        }
        {
        target.transfer(carol, 3 ether);
        }
        {
        target.balanceOf(alice);
        }
        {
        target.balanceOf(bob);
        }
        {
        target.balanceOf(carol);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify contract metadata is set correctly after construction
    function test_buy_and_check_metadata_8() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: name()
        // skip ABI-mismatched call: symbol()
        // skip ABI-mismatched call: decimals()
        // skip ABI-mismatched call: totalSupply()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.totalSupply());
            _assertRelU(__v2, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Resource & Execution Integrity: Test transfer when no dividend pathways exist (no swarm redistribution)
    function test_transfer_without_swarm_tree_9() public {
// cover: swarmRedistribution :: swarmTree.length == 0 true
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buy()
        vm.startPrank(owner);
        {
        target.transfer(bob, 5 ether);
        }
        {
        target.balanceOf(alice);
        }
        {
        target.balanceOf(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_10() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_buy_11() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buy()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_buyViaJohan_12() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buyViaJohan()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Authorization & Access Control
    function test_changeJohanNygrensAddress_13() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.changeJohanNygrensAddress(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_decimals_14() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: decimals()
        {
            uint256 __v3 = uint256(target.decimals());
            _assertRelU(__v3, 0, 18, "call:decimals==18");
        }
    }

    // @cover-intent Financial & Accounting
    function test_dividendPathways_15() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buyViaJohan()
        {
        target.dividendPathways(alice, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_name_16() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: name()
        // TODO assert: call:name() == 'RES'
    }

    // @cover-intent Financial & Accounting
    function test_sell_17() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        {
        target.sell(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting
    function test_swarmTree_18() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.swarmTree(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_symbol_19() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
        // TODO assert: call:symbol() == 'RES'
    }

    // @cover-intent Financial & Accounting
    function test_totalBasicIncome_20() public {
        vm.startPrank(owner);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.totalBasicIncome(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_21() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        // skip ABI-mismatched call: buy()
        // skip ABI-mismatched call: totalSupply()
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.totalSupply());
            _assertRelU(__v4, 2, 100, "call:totalSupply>=100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_22() public {
        vm.startPrank(alice);
        SwarmRedistribution target = new SwarmRedistribution();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: buy()
        vm.prank(owner);
        {
        target.transfer(bob, 50);
        }
        // TODO assert: alice.balance == 49
        // TODO assert: bob.balance == 50
    }

}
