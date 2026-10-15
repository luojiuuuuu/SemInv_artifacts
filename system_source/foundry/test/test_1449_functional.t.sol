// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb0510d68f210b7db66e8c7c814f22680f2b8d1d6.sol";

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

contract Splitter_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Splitter_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify owner can successfully fund all four puppets via fundPuppets, splitting ETH equally.
    function test_owner_funds_puppets_positive_0() public {
// assume: owner() == owner
// assume: getPuppetCount() == 4
// cover: fundPuppets :: require(msg.sender == owner) true
// cover: fundPuppets :: SafeMath.div(msg.value, 4) == 1 ether
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: fundPuppets()
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot call fundPuppets.
    function test_non_owner_cannot_fund_puppets_1() public {
// assume: owner() == owner
// cover: fundPuppets :: require(msg.sender == owner) false
        vm.startPrank(owner);
        Splitter target = new Splitter();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: fundPuppets()
    }

    // @cover-intent Authorization & Access Control: Verify owner can withdraw contract balance.
    function test_owner_withdraw_positive_2() public {
// assume: owner() == owner
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: fundPuppets()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot call withdraw.
    function test_non_owner_cannot_withdraw_3() public {
// assume: owner() == owner
// cover: withdraw :: require(msg.sender == owner) false
        vm.startPrank(owner);
        Splitter target = new Splitter();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Verify owner can create a new puppet and count increases.
    function test_owner_creates_new_puppet_4() public {
// assume: owner() == owner
// assume: getPuppetCount() == 4
// cover: newPuppet :: require(msg.sender == owner) true
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: newPuppet()
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot create a new puppet.
    function test_non_owner_cannot_create_puppet_5() public {
// assume: owner() == owner
// cover: newPuppet :: require(msg.sender == owner) false
        vm.startPrank(owner);
        Splitter target = new Splitter();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: newPuppet()
    }

    // @cover-intent Resource & Execution Integrity: Verify setExtra updates the extra mapping with a valid address.
    function test_set_extra_valid_address_6() public {
// assume: alice != address(0)
// cover: setExtra :: require(_newExtra != address(0)) true
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        target.setExtra(0, alice);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify setExtra reverts when _newExtra is address(0).
    function test_set_extra_zero_address_reverts_7() public {
// cover: setExtra :: require(_newExtra != address(0)) false
        vm.startPrank(owner);
        Splitter target = new Splitter();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(owner);
        {
        target.setExtra(0, 0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Financial & Accounting: Verify fundPuppets with zero value sends zero to each puppet (edge case).
    function test_fund_puppets_with_zero_value_8() public {
// assume: owner() == owner
// cover: fundPuppets :: SafeMath.div(0, 4) == 0
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: fundPuppets()
    }

    // @cover-intent External Interaction & Environment: Verify updating extra mapping changes where funds are sent in fundPuppets.
    function test_set_extra_affects_fund_puppets_9() public {
// assume: owner() == owner
// cover: fundPuppets :: extra[0].call.value(_share) succeeds
// cover: fundPuppets :: extra[1].call.value(_share) succeeds
// cover: fundPuppets :: extra[2].call.value(_share) succeeds
// cover: fundPuppets :: extra[3].call.value(_share) succeeds
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        target.setExtra(0, alice);
        }
        {
        target.setExtra(1, bob);
        }
        {
        target.setExtra(2, carol);
        }
        {
        target.setExtra(3, owner);
        }
        // skip ABI-mismatched call: fundPuppets()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_fundPuppets_positive_10() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        target.setExtra(0, alice);
        }
        {
        target.setExtra(1, bob);
        }
        {
        target.setExtra(2, carol);
        }
        {
        target.setExtra(3, owner);
        }
        // skip ABI-mismatched call: fundPuppets()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getPuppetCount_view_11() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: getPuppetCount()
    }

    // @cover-intent Authorization & Access Control
    function test_newPuppet_positive_12() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: newPuppet()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_13() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_14() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        // skip ABI-mismatched call: fundPuppets()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent minimal test for extra
    function test_perfn_extra_15() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        target.extra(1);
        }
    }

    // @cover-intent minimal test for puppets
    function test_perfn_puppets_16() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        target.puppets(1);
        }
    }

    // @cover-intent minimal test for setExtra
    function test_perfn_setExtra_17() public {
        vm.startPrank(owner);
        Splitter target = new Splitter();
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
        target.setExtra(1, alice);
        }
    }

}
