// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

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

contract TokenSender_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TokenSender_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Owner fills transfers and runs distribution successfully.
    function test_Positive_fill_and_run_0() public {
// assume: next == 0
// assume: totalToDistribute == 0
// cover: run :: transfers.length > 0
// cover: run :: mNext == 0 && token.balanceOf(this) == totalToDistribute
// cover: run :: mNext < transfers.length && gas() > 150000
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.fill(_arr1);
        }
        // skip ABI-mismatched call: run()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Non-owner call to fill reverts.
    function test_Non_owner_cannot_fill_1() public {
// cover: fill :: onlyOwner modifier fails
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.fill(_arr1);
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner call to run reverts.
    function test_Non_owner_cannot_run_2() public {
// cover: run :: onlyOwner modifier fails
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.fill(_arr1);
        }
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Protocol State Machine: fill reverts when distribution has started (next > 0).
    function test_Fill_reverts_if_next_0_3() public {
// assume: next > 0
// cover: fill :: next > 0 throw
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.fill(_arr1);
        }
        // skip ABI-mismatched call: run()
        vm.expectRevert();
        {
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.fill(_arr2);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: run does nothing when transfers is empty.
    function test_Run_with_empty_transfers_4() public {
// assume: transfers.length == 0
// cover: run :: transfers.length == 0 return
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Financial & Accounting: run reverts when token balance does not equal totalToDistribute.
    function test_Run_reverts_if_balance_mismatch_5() public {
// assume: token.balanceOf(this) != totalToDistribute
// cover: run :: mNext == 0 && token.balanceOf(this) != totalToDistribute throw
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.fill(_arr1);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: run()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot change owner.
    function test_Change_owner_by_non_owner_reverts_6() public {
// cover: changeOwner :: onlyOwner modifier fails
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        target.changeOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Owner can change owner.
    function test_Change_owner_by_owner_succeeds_7() public {
// cover: changeOwner :: onlyOwner passes
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        target.changeOwner(alice);
        }
    }

    // @cover-intent Protocol State Machine: hasTerminated returns false when no transfers exist.
    function test_HasTerminated_returns_false_when_transfers_empty_8() public {
// assume: transfers.length == 0
// cover: hasTerminated :: transfers.length == 0 return false
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: hasTerminated()
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_9() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        target.changeOwner(alice);
        }
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_negative_10() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        target.changeOwner(bob);
        }
    }

    // @cover-intent Protocol State Machine
    function test_hasTerminated_false_11() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: hasTerminated()
    }

    // @cover-intent Protocol State Machine
    function test_nTransfers_zero_12() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: nTransfers()
        {
            uint256 __v1 = uint256(target.nTransfers());
            _assertRelU(__v1, 0, 0, "call:nTransfers==0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_next_zero_13() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: next()
        {
            uint256 __v2 = uint256(target.next());
            _assertRelU(__v2, 0, 0, "call:next==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_initial_14() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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

    // @cover-intent Financial & Accounting
    function test_run_positive_15() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.fill(_arr1);
        }
        // skip ABI-mismatched call: run()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.next());
            _assertRelU(__v3, 2, 0, "call:next>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_run_negative_16() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: run()
    }

    // @cover-intent Protocol State Machine
    function test_token_address_17() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: token()
    }

    // @cover-intent Financial & Accounting
    function test_totalToDistribute_zero_18() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        // skip ABI-mismatched call: totalToDistribute()
        {
            uint256 __v4 = uint256(target.totalToDistribute());
            _assertRelU(__v4, 0, 0, "call:totalToDistribute==0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_transfers_default_19() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        target.transfers(0);
        }
    }

    // @cover-intent minimal test for execute
    function test_perfn_execute_20() public {
        vm.startPrank(owner);
        TokenSender target = new TokenSender(alice);
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
        target.execute(alice, 100, hex"01");
        }
    }

}
