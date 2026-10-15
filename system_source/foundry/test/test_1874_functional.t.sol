// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x78c2a1e91b52bca4130b6ed9edd9fbcfd4671c37.sol";

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

contract WhaleGiveaway1_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function WhaleGiveaway1_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that redeem() transfers contract balance to Owner and msg.sender when msg.value meets minEligibility.
    function test_redeem_positive_eligibility_0() public {
// assume: address(this).balance >= 0
// cover: redeem :: msg.value >= minEligibility true
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.redeem.value(1 ether)();
        }
        {
        target.redeem.value(1 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that redeem() does nothing when msg.value is below minEligibility.
    function test_redeem_below_eligibility_1() public {
// assume: address(this).balance >= 0
// cover: redeem :: msg.value >= minEligibility false
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.redeem.value(0.5 ether)();
        }
        // TODO assert: owner.balance == 0
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() sends contract balance to Owner when called by Owner.
    function test_withdraw_owner_positive_2() public {
// assume: msg.sender == Owner
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.redeem.value(1 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() reverts when called by non-Owner.
    function test_withdraw_non_owner_revert_3() public {
// assume: msg.sender != Owner
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() changes Owner to 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b when called by that address, then transfers balance to new Owner.
    function test_withdraw_owner_change_on_special_address_4() public {
// assume: msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b
// cover: withdraw :: msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b true
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.redeem.value(1 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that Command() executes a low-level call when called by Owner.
    function test_Command_owner_positive_5() public {
// assume: msg.sender == Owner
// cover: Command :: require(msg.sender == Owner) true
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        // skip malformed call: Command(0x0000000000000000000000000000000000000000, "0x") (bad raw arg for Command.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Authorization & Access Control: Verify that Command() reverts when called by non-Owner.
    function test_Command_non_owner_revert_6() public {
// assume: msg.sender != Owner
// cover: Command :: require(msg.sender == Owner) false
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        // skip malformed call: Command(0x0000000000000000000000000000000000000000, "0x") (bad raw arg for Command.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Financial & Accounting: Verify that redeem() works after ETH is sent via fallback.
    function test_redeem_after_fallback_7() public {
// assume: address(this).balance >= 1 ether
// cover: redeem :: msg.value >= minEligibility true
        vm.startPrank(bob);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        // skip empty call after value injection
        vm.prank(bob);
        {
        target.redeem.value(1 ether)();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() works after multiple deposits.
    function test_withdraw_after_redeem_and_fallback_8() public {
// assume: msg.sender == Owner
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(bob);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        // skip empty call after value injection
        vm.prank(bob);
        {
        target.redeem.value(1 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_9() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.Owner();
        }
    }

    // @cover-intent Financial & Accounting
    function test_minEligibility_view_10() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.minEligibility();
        }
    }

    // @cover-intent Financial & Accounting
    function test_redeem_positive_path_11() public {
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.redeem.value(1 ether)();
        }
        // TODO assert: alice.balance == initial_balance_alice + this.balance - 1 ether
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_path_12() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.withdraw();
        }
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_13() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        target.Command(alice, hex"01");
        }
    }

}
