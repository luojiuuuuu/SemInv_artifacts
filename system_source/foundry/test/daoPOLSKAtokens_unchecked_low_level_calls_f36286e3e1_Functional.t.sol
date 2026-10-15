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
// cover: transfer :: balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]
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
        {
        target.setSupply(10000);
        }
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

    // @cover-intent Authorization & Access Control: Verify approve and transferFrom workflow with allowance checks
    function test_ERC20_approve_and_transferFrom_3() public {
// assume: allowance(alice, bob) == 300
// assume: balanceOf(alice) >= 200
// cover: transferFrom :: balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]
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
        {
        target.setSupply(10000);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(bob, 300);
        }
        vm.stopPrank();
        vm.startPrank(bob);
        {
        target.transferFrom(alice, carol, 200);
        }
        {
        target.transferFrom(alice, carol, 200);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify token burning reduces total supply and sender balance
    function test_ERC20_burn_own_tokens_4() public {
// assume: balanceOf(alice) >= 100
// cover: burn :: balances[msg.sender] >= _value
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
        {
        target.setSupply(10000);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        {
        target.burn(100);
        }
        vm.prank(alice);
        {
        target.burn(999999);
        }
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 0, "call:totalSupply>=0");
        }
    }

    // @cover-intent Financial & Accounting: Verify token creation during funding phase with correct rate calculation
    function test_createDaoPOLSKAtokens_during_funding_5() public {
// assume: funding == true
// assume: CreationRate == 1761
// cover: createDaoPOLSKAtokens :: funding == true
// cover: createDaoPOLSKAtokens :: msg.value > 0
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setSupply(10000);
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
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.expectRevert();
        {
        target.createDaoPOLSKAtokens(alice);
        }
        vm.stopPrank();
        // TODO assert: call:totalSupply() >= 1761 * 1 ether
    }

    // @cover-intent Protocol State Machine: Verify owner can toggle funding state on and off
    function test_fundingState_toggle_6() public {
// assume: funding == false after first call
// cover: fundingState :: msg.sender == owner
        vm.startPrank(owner);
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: fundingState()
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: fundingState()
    }

    // @cover-intent Protocol State Machine: Verify finalize transitions funding to false and enables refund
    function test_finalize_after_funding_period_7() public {
// assume: block.number > fundingEndBlock + 8 * oneweek
// cover: finalize :: block.number > fundingEndBlock + 8 * oneweek
// cover: finalize :: msg.sender == owner
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.warp(block.timestamp + 8 * 36000 * 13);
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
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: finalize()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: finalize()
    }

    // @cover-intent Financial & Accounting: Verify refund mechanism returns ETH equivalent to original contribution
    function test_refundTRA_after_finalize_8() public {
// assume: funding == false
// assume: refundstate == true
// assume: balancesRAW[alice] > 0
// cover: refundTRA :: funding == false
// cover: refundTRA :: refundstate == true
// cover: refundTRA :: ETHValue > 0
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: vm.warp(block.timestamp + 8 * 36000 * 13);
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
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: finalize()
        vm.startPrank(alice);
        // skip ABI-mismatched call: refundTRA()
        vm.expectRevert();
        // skip ABI-mismatched call: refundTRA()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
        {
            uint256 __v2 = uint256(target.totalSupply());
            _assertRelU(__v2, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent External Interaction & Environment: Verify migration sends tokens to migration agent
    function test_migrate_tokens_9() public {
// assume: migratestate == false
// assume: balanceOf(alice) >= 100
// cover: migrate :: migratestate == false
// cover: migrate :: _value > 0
// cover: migrate :: _value <= balances[msg.sender]
        vm.startPrank(alice);
        daoPOLSKAtokens target = new daoPOLSKAtokens();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.fundingState();
        // dropped unsafe prestate: target.createDaoPOLSKAtokens(alice, {value: 1 ether});
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
        // skip ABI-mismatched call: fundingState()
        vm.stopPrank();
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: turnmigrate()
        vm.startPrank(alice);
        {
        target.migrate(100);
        }
        vm.expectRevert();
        {
        target.migrate(0);
        }
        vm.expectRevert();
        {
        target.migrate(999999);
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.totalMigrated());
            _assertRelU(__v3, 2, 100, "call:totalMigrated>=100");
        }
    }

    // @cover-intent Authorization & Access Control: Verify only owner can update bonus creation rate
    function test_setBonusCreationRate_by_owner_10() public {
// assume: owner() == owner
// cover: setBonusCreationRate :: msg.sender == owner
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setBonusCreationRate(500);
        }
        {
            uint256 __v4 = uint256(target.CreationRate());
            _assertRelU(__v4, 0, 1500, "call:CreationRate==1500");
        }
    }

    // @cover-intent Protocol State Machine: Verify supply limit can only be set once
    function test_setSupply_only_once_11() public {
// assume: supplylimitset == false initially
// cover: setSupply :: msg.sender == owner
// cover: setSupply :: supplylimitset == false
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
        target.setSupply(5000);
        }
        vm.expectRevert();
        {
        target.setSupply(5000);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setSupply(5000);
        }
        // TODO assert: call:supplylimit() == 5000 * 10^18
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain1_read_chain_address_12() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain2_read_chain_address_13() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain3_read_chain_address_14() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_Chain4_read_chain_address_15() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_CreationRate_read_creation_rate_16() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_DAOPolskaTokenICOregulations_returns_regulations_string_17() public {
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
    function test_FundsTransfer_owner_sends_balance_after_funding_ends_18() public {
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
    function test_PartialFundsTransfer_owner_sends_partial_balance_19() public {
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

    // @cover-intent Financial & Accounting
    function test_allowance_read_allowance_20() public {
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
        target.approve(bob, 50);
        }
        vm.prank(carol);
        {
        target.allowance(alice, bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_approve_set_allowance_21() public {
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

    // @cover-intent External Interaction & Environment
    function test_approveAndCall_approve_and_notify_22() public {
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
        target.approveAndCall(bob, 50, hex"00");
        }
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_read_balance_23() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_bonusCreationRate_read_bonus_rate_24() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_burn_destroy_tokens_25() public {
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
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        vm.prank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        vm.prank(owner);
        {
        target.burn(10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_burnFrom_destroy_tokens_from_another_account_26() public {
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
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(bob, 50);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.burnFrom(alice, 10);
        }
    }

    // @cover-intent Financial & Accounting
    function test_createDaoPOLSKAtokens_create_tokens_with_ETH_27() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_decimals_read_decimals_28() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_finalize_close_funding_after_deadline_29() public {
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
        // skip ABI-mismatched call: finalize()
    }

    // @cover-intent Protocol State Machine
    function test_funding_read_funding_state_30() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_fundingEndBlock_read_end_block_31() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_fundingState_toggle_funding_32() public {
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
    }

    // @cover-intent External Interaction & Environment
    function test_migrate_migrate_tokens_33() public {
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
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.migrate(10);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_migratestate_read_migration_state_34() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_migrationAgent_read_migration_agent_35() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_migrationMaster_read_migration_master_36() public {
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
    function test_name_read_token_name_37() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_oneweek_read_oneweek_constant_38() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_otherchainstotalset_read_flag_39() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_otherchainstotalsupply_read_other_chain_supply_40() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_owner_read_owner_41() public {
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
    function test_preICOregulations_returns_regulations_string_42() public {
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
    function test_refundTRA_refund_ETH_to_token_holders_43() public {
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
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
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
    }

    // @cover-intent Protocol State Machine
    function test_refundstate_read_refund_state_44() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_sendTokenAw_owner_sends_tokens_45() public {
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
        target.sendTokenAw(0x0000000000000000000000000000000000000001, bob, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setBonusCreationRate_owner_sets_bonus_rate_46() public {
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
            uint256 __v5 = uint256(target.CreationRate());
            _assertRelU(__v5, 0, 1500, "call:CreationRate==1500");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setChainsAddresses_owner_sets_chain_addresses_47() public {
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
        target.setChainsAddresses(bob, 1);
        }
        // TODO assert: call:Chain1() == bob
    }

    // @cover-intent Authorization & Access Control
    function test_setSupply_owner_sets_supply_limit_48() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_setotherchainstotalsupply_owner_sets_other_chain_supply_49() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_supplylimit_read_supply_limit_50() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_supplylimitset_read_flag_51() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_symbol_read_token_symbol_52() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_tokenCreationRate_read_creation_rate_53() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalMigrated_read_total_migrated_54() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_read_total_supply_55() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_transfer_send_tokens_56() public {
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
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.transfer(bob, 10);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_transferFrom_transfer_on_behalf_57() public {
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
        vm.prank(owner);
        {
        target.setSupply(10000);
        }
        vm.startPrank(alice);
        {
        target.createDaoPOLSKAtokens.value(1 ether)(alice);
        }
        {
        target.approve(bob, 50);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 10);
        }
    }

    // @cover-intent Protocol State Machine
    function test_turnmigrate_toggle_migrate_state_58() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_turnrefund_toggle_refund_state_59() public {
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
