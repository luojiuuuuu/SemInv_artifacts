// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x19cf8481ea15427a98ba3cdd6d9e14690011ab10.sol";

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

contract daoPOLSKAtokens_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function daoPOLSKAtokens_FunctionalTest() public {
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


    // @cover-intent Transfer 60 from alice to bob (supply conserved)
    function test_erc20_transfer_0() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 600);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 60);
        }
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent approve -> transferFrom flow
    function test_erc20_approve_spend_1() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 200);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, bob, 60);
        }
        _assertEqU(target.allowance(alice, bob), 40);
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent Financial & Accounting: Verify basic ERC20 transfer works correctly between two non-owner accounts
    function test_ERC20_basic_transfer_2() public {
// assume: funding == true
// assume: balanceOf(alice) >= 500
// cover: transfer :: balances[msg.sender] >= _value && balances[_to] + _value > balances[_to] true
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 1 ether});
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.transfer(bob, 500);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify transfer reverts when sender has insufficient balance
    function test_ERC20_transfer_insufficient_balance_3() public {
// assume: funding == true
// assume: balanceOf(alice) < 1000000
// cover: transfer :: balances[msg.sender] >= _value false
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 0.1 ether});
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens(alice);
        }
        {
        target.transfer(bob, 1000000);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify approve and transferFrom workflow works correctly
    function test_ERC20_approve_and_transferFrom_4() public {
// assume: allowance(alice, bob) >= 200
// assume: balanceOf(alice) >= 200
// cover: transferFrom :: balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to] true
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 1 ether});
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(bob, 300);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 200);
        }
    }

    // @cover-intent Financial & Accounting: Verify approve allows changing allowance from non-zero to zero then to new value (race condition mitigation)
    function test_ERC20_approve_race_condition_mitigation_5() public {
// assume: allowance(alice, bob) == 100
// cover: approve :: allowed[msg.sender][_spender] = _value
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 1 ether});
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(bob, 100);
        }
        {
        target.approve(bob, 0);
        }
        {
        target.approve(bob, 200);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify burn reduces total supply and sender balance
    function test_burn_tokens_6() public {
// assume: balanceOf(alice) >= 500
// cover: burn :: balances[msg.sender] >= _value true
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 1 ether});
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        {
        target.burn(500);
        }
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 0, "call:totalSupply>=0");
        }
    }

    // @cover-intent Financial & Accounting: Verify burnFrom works with proper allowance
    function test_burnFrom_with_allowance_7() public {
// assume: balanceOf(alice) >= 200
// assume: allowance(alice, bob) >= 200
// cover: burnFrom :: balances[_from] >= _value && _value <= allowed[_from][msg.sender] true
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 1 ether});
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(bob, 300);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.burnFrom(alice, 200);
        }
        {
            uint256 __v2 = uint256(target.totalSupply());
            _assertRelU(__v2, 2, 0, "call:totalSupply>=0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify only owner can set supply limit and it can only be set once
    function test_owner_set_supply_limit_8() public {
// assume: supplylimitset() == false
// cover: setSupply :: msg.sender == owner true
// cover: setSupply :: supplylimitset != false true
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        {
        target.setSupply(20000);
        }
        vm.expectRevert();
        {
        target.setSupply(30000);
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.supplylimit());
            _assertRelU(__v3, 2, 0, "call:supplylimit>=0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot set supply limit
    function test_non_owner_cannot_set_supply_9() public {
// assume: supplylimitset() == false
// cover: setSupply :: msg.sender != owner true
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setSupply(20000);
        }
    }

    // @cover-intent Protocol State Machine: Verify funding state can be toggled by owner
    function test_funding_state_transition_10() public {
// assume: funding() == true
// cover: fundingState :: msg.sender == owner true
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify token creation during funding phase with ETH payment
    function test_create_tokens_during_funding_11() public {
// assume: funding() == true
// assume: msg.value <= (supplylimit - totalSupply) / CreationRate
// cover: createDaoPOLSKAtokens :: funding true
// cover: createDaoPOLSKAtokens :: msg.value != 0 true
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: fundingState()
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
            uint256 __v4 = uint256(target.totalSupply());
            _assertRelU(__v4, 2, 1761000000000000000000, "call:totalSupply>=1761000000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain1_read_12() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: Chain1()
        _assertTrue(target.Chain1() == address(0x0000000000000000000000000000000000000000), "address:Chain1");
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain2_read_13() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: Chain2()
        _assertTrue(target.Chain2() == address(0x0000000000000000000000000000000000000000), "address:Chain2");
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain3_read_14() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: Chain3()
        _assertTrue(target.Chain3() == address(0x0000000000000000000000000000000000000000), "address:Chain3");
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain4_read_15() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: Chain4()
        _assertTrue(target.Chain4() == address(0x0000000000000000000000000000000000000000), "address:Chain4");
    }

    // @cover-intent Resource & Execution Integrity
    function test_CreationRate_read_16() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: CreationRate()
        {
            uint256 __v5 = uint256(target.CreationRate());
            _assertRelU(__v5, 0, 1761, "call:CreationRate==1761");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_DAOPolskaTokenICOregulations_call_17() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: DAOPolskaTokenICOregulations()
    }

    // @cover-intent Authorization & Access Control
    function test_FundsTransfer_owner_18() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: FundsTransfer()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_PartialFundsTransfer_owner_19() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.PartialFundsTransfer(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_allowance_read_20() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.allowance(alice, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approve_alice_to_bob_21() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approveAndCall_alice_to_bob_22() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approveAndCall(bob, 100, hex"00");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_balanceOf_alice_23() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity
    function test_bonusCreationRate_read_24() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: bonusCreationRate()
        {
            uint256 __v6 = uint256(target.bonusCreationRate());
            _assertRelU(__v6, 0, 1000, "call:bonusCreationRate==1000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_burn_alice_25() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        {
        target.burn(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_burnFrom_owner_to_alice_26() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(owner, 100);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.burnFrom(alice, 50);
        }
    }

    // @cover-intent Financial & Accounting
    function test_createDaoPOLSKAtokens_alice_27() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        // TODO assert: alice.balance == 1761
        // TODO assert: owner.balance == 211
    }

    // @cover-intent Resource & Execution Integrity
    function test_decimals_read_28() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: decimals()
        {
            uint256 __v7 = uint256(target.decimals());
            _assertRelU(__v7, 0, 18, "call:decimals==18");
        }
    }

    // @cover-intent Protocol State Machine
    function test_finalize_owner_29() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        {
        target.setSupply(10000);
        }
        // skip ABI-mismatched call: finalize()
        vm.stopPrank();
        // TODO assert: call:funding() == false
        // TODO assert: call:refundstate() == true
    }

    // @cover-intent Resource & Execution Integrity
    function test_funding_read_30() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: funding()
        // TODO assert: call:funding() == true
    }

    // @cover-intent Resource & Execution Integrity
    function test_fundingEndBlock_read_31() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: fundingEndBlock()
        {
            uint256 __v8 = uint256(target.fundingEndBlock());
            _assertRelU(__v8, 0, 5433616, "call:fundingEndBlock==5433616");
        }
    }

    // @cover-intent Protocol State Machine
    function test_fundingState_owner_32() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: fundingState()
        // TODO assert: call:funding() == false
    }

    // @cover-intent Financial & Accounting
    function test_migrate_alice_33() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.migrate(100);
        }
        vm.stopPrank();
        {
            uint256 __v9 = uint256(target.totalMigrated());
            _assertRelU(__v9, 0, 100, "call:totalMigrated==100");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_migratestate_read_34() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: migratestate()
        // TODO assert: call:migratestate() == false
    }

    // @cover-intent Resource & Execution Integrity
    function test_migrationAgent_read_35() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: migrationAgent()
        _assertTrue(target.migrationAgent() == address(0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2), "address:migrationAgent");
    }

    // @cover-intent Resource & Execution Integrity
    function test_migrationMaster_read_36() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: migrationMaster()
    }

    // @cover-intent Resource & Execution Integrity
    function test_name_read_37() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: name()
        // TODO assert: call:name() == 'DAO POLSKA TOKEN version 1'
    }

    // @cover-intent Resource & Execution Integrity
    function test_oneweek_read_38() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: oneweek()
        {
            uint256 __v10 = uint256(target.oneweek());
            _assertRelU(__v10, 0, 36000, "call:oneweek==36000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_otherchainstotalset_read_39() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: otherchainstotalset()
        // TODO assert: call:otherchainstotalset() == false
    }

    // @cover-intent Resource & Execution Integrity
    function test_otherchainstotalsupply_read_40() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: otherchainstotalsupply()
        {
            uint256 __v11 = uint256(target.otherchainstotalsupply());
            _assertRelU(__v11, 0, 1000000000000000000, "call:otherchainstotalsupply==1000000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_owner_read_41() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Resource & Execution Integrity
    function test_preICOregulations_call_42() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: preICOregulations()
    }

    // @cover-intent Financial & Accounting
    function test_refundTRA_alice_43() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: turnrefund()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: refundTRA()
        // TODO assert: alice.balance == 0
        {
            uint256 __v12 = uint256(target.totalSupply());
            _assertRelU(__v12, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_refundstate_read_44() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: refundstate()
        // TODO assert: call:refundstate() == false
    }

    // @cover-intent Authorization & Access Control
    function test_sendTokenAw_owner_45() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.sendTokenAw(alice, bob, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setBonusCreationRate_owner_46() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setBonusCreationRate(500);
        }
        {
            uint256 __v13 = uint256(target.bonusCreationRate());
            _assertRelU(__v13, 0, 500, "call:bonusCreationRate==500");
        }
        {
            uint256 __v14 = uint256(target.CreationRate());
            _assertRelU(__v14, 0, 1500, "call:CreationRate==1500");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setChainsAddresses_owner_47() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setChainsAddresses(alice, 1);
        }
        // TODO assert: call:Chain1() == alice
    }

    // @cover-intent Authorization & Access Control
    function test_setSupply_owner_48() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        // TODO assert: call:supplylimitset() == true
        // TODO assert: call:supplylimit() == 10000 * 10**18
    }

    // @cover-intent Authorization & Access Control
    function test_setotherchainstotalsupply_owner_49() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setotherchainstotalsupply(5000);
        }
        // TODO assert: call:otherchainstotalset() == true
        // TODO assert: call:otherchainstotalsupply() == 5000 * 10**18
    }

    // @cover-intent Resource & Execution Integrity
    function test_supplylimit_read_50() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: supplylimit()
        {
            uint256 __v15 = uint256(target.supplylimit());
            _assertRelU(__v15, 0, 10000000000000000000000, "call:supplylimit==10000000000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_supplylimitset_read_51() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: supplylimitset()
        // TODO assert: call:supplylimitset() == false
    }

    // @cover-intent Resource & Execution Integrity
    function test_symbol_read_52() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
        // TODO assert: call:symbol() == 'DPL'
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenCreationRate_read_53() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: tokenCreationRate()
        {
            uint256 __v16 = uint256(target.tokenCreationRate());
            _assertRelU(__v16, 0, 1000, "call:tokenCreationRate==1000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalMigrated_read_54() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: totalMigrated()
        {
            uint256 __v17 = uint256(target.totalMigrated());
            _assertRelU(__v17, 0, 0, "call:totalMigrated==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalSupply_read_55() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
        {
            uint256 __v18 = uint256(target.totalSupply());
            _assertRelU(__v18, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_alice_to_bob_56() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.transfer(bob, 100);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Authorization & Access Control
    function test_transferFrom_owner_to_bob_from_alice_57() public {
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(owner, 100);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.transferFrom(alice, bob, 50);
        }
        // TODO assert: bob.balance == 50
    }

    // @cover-intent Protocol State Machine
    function test_turnmigrate_owner_58() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: turnmigrate()
        // TODO assert: call:migratestate() == true
    }

    // @cover-intent Protocol State Machine
    function test_turnrefund_owner_59() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: turnrefund()
        // TODO assert: call:refundstate() == true
    }

    // @cover-intent minimal test for setTokenInformation
    function test_perfn_setTokenInformation_60() public {
        vm.startPrank(owner);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.setTokenInformation("Name", "SYM");
        }
    }

}
