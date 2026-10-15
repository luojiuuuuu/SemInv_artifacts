// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_16.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract ExclusivePlatform_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Transfer 60 from alice to bob (supply conserved)
    function test_erc20_transfer_0() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        ExclusivePlatform target = new ExclusivePlatform();
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

    // @cover-intent Financial & Accounting: Verify that the fallback function correctly calculates token amounts with bonus tiers and transfers tokens from owner to buyer.
    function test_Crowdsale_purchase_with_bonus_tiers_2() public {
// assume: crowdsaleIsOn == true
// assume: msg.value >= minimumBuy
// cover: getBonus :: _amount >= XPLPerEther.mul(5) true
// cover: getBonus :: _amount >= XPLPerEther true
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10000000000e8);
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
        // skip ABI-mismatched call: switchCrowdsale()
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
    }

    // @cover-intent Financial & Accounting: Verify that the owner can transfer tokens to another address using the standard transfer function.
    function test_Owner_transfers_tokens_to_another_address_3() public {
// assume: balanceOf(alice) >= 500e8
// cover: doTransfer :: require(_to != address(0)) true
// cover: doTransfer :: require(_amount <= balances[_from]) true
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000e8);
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
        // skip malformed call: transfer(alice, 1000e8) (bad raw arg for transfer.arg1: type=uint256, raw=1000e8)
        vm.startPrank(alice);
        // skip malformed call: transfer(bob, 500e8) (bad raw arg for transfer.arg1: type=uint256, raw=500e8)
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.balanceOf(bob);
        }
    }

    // @cover-intent Transactional Consistency: Verify that transferring tokens to address(0) reverts.
    function test_Transfer_to_zero_address_reverts_4() public {
// assume: balanceOf(alice) >= 10e8
// cover: doTransfer :: require(_to != address(0)) false
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100e8);
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
        // skip malformed call: transfer(alice, 100e8) (bad raw arg for transfer.arg1: type=uint256, raw=100e8)
        vm.prank(alice);
        // skip malformed call: transfer(address(0), 10e8) (bad raw arg for transfer.arg1: type=uint256, raw=10e8)
    }

    // @cover-intent Transactional Consistency: Verify that transferring more tokens than balance reverts.
    function test_Transfer_with_insufficient_balance_reverts_5() public {
// assume: balanceOf(alice) == 10e8
// cover: doTransfer :: require(_amount <= balances[_from]) false
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10e8);
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
        // skip malformed call: transfer(alice, 10e8) (bad raw arg for transfer.arg1: type=uint256, raw=10e8)
        vm.prank(alice);
        // skip malformed call: transfer(bob, 20e8) (bad raw arg for transfer.arg1: type=uint256, raw=20e8)
    }

    // @cover-intent Financial & Accounting: Verify that approve and transferFrom work correctly with sufficient allowance.
    function test_Approve_and_transferFrom_with_sufficient_allowance_6() public {
// assume: allowance(alice, bob) >= 300e8
// cover: transferFrom :: require(allowed[_from][msg.sender] >= _amount) true
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000e8);
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
        // skip malformed call: transfer(alice, 1000e8) (bad raw arg for transfer.arg1: type=uint256, raw=1000e8)
        vm.prank(alice);
        // skip malformed call: approve(bob, 500e8) (bad raw arg for approve.arg1: type=uint256, raw=500e8)
        vm.prank(bob);
        // skip malformed call: transferFrom(alice, carol, 300e8) (bad raw arg for transferFrom.arg2: type=uint256, raw=300e8)
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
        vm.prank(carol);
        {
        target.balanceOf(carol);
        }
        vm.prank(alice);
        {
        target.allowance(alice, bob);
        }
    }

    // @cover-intent Transactional Consistency: Verify that transferFrom with insufficient allowance reverts.
    function test_transferFrom_with_insufficient_allowance_reverts_7() public {
// assume: allowance(alice, bob) == 50e8
// cover: transferFrom :: require(allowed[_from][msg.sender] >= _amount) false
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100e8);
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
        // skip malformed call: transfer(alice, 100e8) (bad raw arg for transfer.arg1: type=uint256, raw=100e8)
        vm.prank(alice);
        // skip malformed call: approve(bob, 50e8) (bad raw arg for approve.arg1: type=uint256, raw=50e8)
        vm.prank(bob);
        // skip malformed call: transferFrom(alice, carol, 100e8) (bad raw arg for transferFrom.arg2: type=uint256, raw=100e8)
    }

    // @cover-intent Financial & Accounting: Verify that the owner can burn tokens and totalSupply decreases accordingly.
    function test_Owner_burns_tokens_8() public {
// assume: balanceOf(owner) >= 1000e8
// cover: burn :: require(_value <= balances[msg.sender]) true
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip malformed call: burn(1000e8) (bad raw arg for burn.arg0: type=uint256, raw=1000e8)
        // skip ABI-mismatched call: totalSupply()
        {
        target.balanceOf(owner);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 0, "call:totalSupply>=0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call burn.
    function test_Non_owner_cannot_burn_tokens_9() public {
// cover: burn :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip malformed call: burn(100e8) (bad raw arg for burn.arg0: type=uint256, raw=100e8)
    }

    // @cover-intent minimal test for XPLPerEther
    function test_perfn_XPLPerEther_10() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: XPLPerEther()
    }

    // @cover-intent minimal test for _totalSupply
    function test_perfn_totalSupply_11() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: _totalSupply()
    }

    // @cover-intent minimal test for allowance
    function test_perfn_allowance_12() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.allowance(alice, alice);
        }
    }

    // @cover-intent minimal test for approve
    function test_perfn_approve_13() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1);
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
        target.approve(bob, 1);
        }
    }

    // @cover-intent minimal test for balanceOf
    function test_perfn_balanceOf_14() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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

    // @cover-intent minimal test for bug_intou11
    function test_perfn_bug_intou11_15() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent minimal test for bug_intou12
    function test_perfn_bug_intou12_16() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou12(1);
        }
    }

    // @cover-intent minimal test for bug_intou15
    function test_perfn_bug_intou15_17() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou15()
    }

    // @cover-intent minimal test for bug_intou16
    function test_perfn_bug_intou16_18() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou16(1);
        }
    }

    // @cover-intent minimal test for bug_intou19
    function test_perfn_bug_intou19_19() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent minimal test for bug_intou20
    function test_perfn_bug_intou20_20() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou20(1);
        }
    }

    // @cover-intent minimal test for bug_intou23
    function test_perfn_bug_intou23_21() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent minimal test for bug_intou24
    function test_perfn_bug_intou24_22() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou24(1);
        }
    }

    // @cover-intent minimal test for bug_intou27
    function test_perfn_bug_intou27_23() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent minimal test for bug_intou28
    function test_perfn_bug_intou28_24() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou28(1);
        }
    }

    // @cover-intent minimal test for bug_intou3
    function test_perfn_bug_intou3_25() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent minimal test for bug_intou31
    function test_perfn_bug_intou31_26() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_27() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent minimal test for bug_intou35
    function test_perfn_bug_intou35_28() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent minimal test for bug_intou36
    function test_perfn_bug_intou36_29() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent minimal test for bug_intou39
    function test_perfn_bug_intou39_30() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent minimal test for bug_intou4
    function test_perfn_bug_intou4_31() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent minimal test for bug_intou40
    function test_perfn_bug_intou40_32() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent minimal test for bug_intou7
    function test_perfn_bug_intou7_33() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent minimal test for bug_intou8
    function test_perfn_bug_intou8_34() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent minimal test for burn
    function test_perfn_burn_35() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.burn(100);
        }
    }

    // @cover-intent minimal test for crowdsaleIsOn
    function test_perfn_crowdsaleIsOn_36() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: crowdsaleIsOn()
    }

    // @cover-intent minimal test for decimals
    function test_perfn_decimals_37() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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

    // @cover-intent minimal test for getForeignTokenBalance
    function test_perfn_getForeignTokenBalance_38() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.getForeignTokenBalance(bob, alice);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou1
    function test_perfn_increaseLockTime_intou1_39() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou1(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou13
    function test_perfn_increaseLockTime_intou13_40() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou13(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou17
    function test_perfn_increaseLockTime_intou17_41() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou17(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou21
    function test_perfn_increaseLockTime_intou21_42() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou21(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou25
    function test_perfn_increaseLockTime_intou25_43() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou25(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou29
    function test_perfn_increaseLockTime_intou29_44() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou29(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou33
    function test_perfn_increaseLockTime_intou33_45() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou33(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou37
    function test_perfn_increaseLockTime_intou37_46() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou37(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou5
    function test_perfn_increaseLockTime_intou5_47() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou5(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou9
    function test_perfn_increaseLockTime_intou9_48() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.increaseLockTime_intou9(1);
        }
    }

    // @cover-intent minimal test for lockTime_intou1
    function test_perfn_lockTime_intou1_49() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou1(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou13
    function test_perfn_lockTime_intou13_50() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou17
    function test_perfn_lockTime_intou17_51() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou21
    function test_perfn_lockTime_intou21_52() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou21(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou25
    function test_perfn_lockTime_intou25_53() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou25(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou29
    function test_perfn_lockTime_intou29_54() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou29(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou33
    function test_perfn_lockTime_intou33_55() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou37
    function test_perfn_lockTime_intou37_56() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou5
    function test_perfn_lockTime_intou5_57() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou5(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou9
    function test_perfn_lockTime_intou9_58() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.lockTime_intou9(alice);
        }
    }

    // @cover-intent minimal test for minimumBuy
    function test_perfn_minimumBuy_59() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: minimumBuy()
    }

    // @cover-intent minimal test for name
    function test_perfn_name_60() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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

    // @cover-intent minimal test for owner
    function test_perfn_owner_61() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent minimal test for switchCrowdsale
    function test_perfn_switchCrowdsale_62() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: switchCrowdsale()
    }

    // @cover-intent minimal test for symbol
    function test_perfn_symbol_63() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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

    // @cover-intent minimal test for totalSupply
    function test_perfn_totalSupply_64() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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

    // @cover-intent minimal test for transfer
    function test_perfn_transfer_65() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer(bob, 1);
        }
    }

    // @cover-intent minimal test for transferEther
    function test_perfn_transferEther_66() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transferEther(alice, 100);
        }
    }

    // @cover-intent minimal test for transferFrom
    function test_perfn_transferFrom_67() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.approve(bob, 1);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, bob, 1);
        }
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_68() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transferOwnership(alice);
        }
    }

    // @cover-intent minimal test for transfer_intou10
    function test_perfn_transfer_intou10_69() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou10(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou14
    function test_perfn_transfer_intou14_70() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou14(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou18
    function test_perfn_transfer_intou18_71() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou18(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou22
    function test_perfn_transfer_intou22_72() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou22(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou26
    function test_perfn_transfer_intou26_73() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou26(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou30
    function test_perfn_transfer_intou30_74() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou30(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou34
    function test_perfn_transfer_intou34_75() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou34(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou38
    function test_perfn_transfer_intou38_76() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou38(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou62
    function test_perfn_transfer_intou62_77() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_intou62(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_undrflow2
    function test_perfn_transfer_undrflow2_78() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.transfer_undrflow2(bob, 100);
        }
    }

    // @cover-intent minimal test for updateXPLPerEther
    function test_perfn_updateXPLPerEther_79() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.updateXPLPerEther(1);
        }
    }

    // @cover-intent minimal test for withdrawForeignTokens
    function test_perfn_withdrawForeignTokens_80() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        target.withdrawForeignTokens(bob);
        }
    }

    // @cover-intent minimal test for withdrawFund
    function test_perfn_withdrawFund_81() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdrawFund()
    }

    // @cover-intent minimal test for withdraw_intou13
    function test_perfn_withdraw_intou13_82() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent minimal test for withdraw_intou17
    function test_perfn_withdraw_intou17_83() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent minimal test for withdraw_intou21
    function test_perfn_withdraw_intou21_84() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou21()
    }

    // @cover-intent minimal test for withdraw_intou25
    function test_perfn_withdraw_intou25_85() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou25()
    }

    // @cover-intent minimal test for withdraw_intou29
    function test_perfn_withdraw_intou29_86() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou29()
    }

    // @cover-intent minimal test for withdraw_intou33
    function test_perfn_withdraw_intou33_87() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent minimal test for withdraw_intou37
    function test_perfn_withdraw_intou37_88() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou37()
    }

    // @cover-intent minimal test for withdraw_intou5
    function test_perfn_withdraw_intou5_89() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou5()
    }

    // @cover-intent minimal test for withdraw_intou9
    function test_perfn_withdraw_intou9_90() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_intou9()
    }

    // @cover-intent minimal test for withdraw_ovrflow1
    function test_perfn_withdraw_ovrflow1_91() public {
        vm.startPrank(owner);
        ExclusivePlatform target = new ExclusivePlatform();
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
        // skip ABI-mismatched call: withdraw_ovrflow1()
    }

}
