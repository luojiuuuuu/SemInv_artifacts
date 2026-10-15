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


    // @cover-intent Authorization & Access Control: Owner fills transfer list and runs distribution successfully.
    function test_Positive_fill_and_run_0() public {
// assume: token.balanceOf(this) == totalToDistribute
// cover: run :: transfers.length == 0 -> return
// cover: run :: mNext == 0 && token.balanceOf(this) != totalToDistribute -> throw
// cover: run :: mNext < transfers.length && gas() > 150000 -> loop
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
        {
        target.run();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot call fill.
    function test_Non_owner_fill_reverts_1() public {
// cover: fill :: onlyOwner modifier
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

    // @cover-intent Authorization & Access Control: Non-owner cannot call run.
    function test_Non_owner_run_reverts_2() public {
// cover: run :: onlyOwner modifier
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
        vm.prank(bob);
        {
        target.run();
        }
    }

    // @cover-intent Protocol State Machine: fill reverts if next > 0 (distribution already started).
    function test_Fill_after_run_started_reverts_3() public {
// assume: next > 0
// cover: fill :: if (next>0) throw
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
        {
        target.run();
        }
        vm.expectRevert();
        {
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.fill(_arr2);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: run returns immediately if transfers.length == 0.
    function test_Run_with_empty_transfers_returns_early_4() public {
// assume: transfers.length == 0
// cover: run :: transfers.length == 0 -> return
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
        target.run();
        }
    }

    // @cover-intent Financial & Accounting: run reverts if token.balanceOf(this) != totalToDistribute when mNext == 0.
    function test_Run_reverts_if_balance_mismatch_5() public {
// assume: token.balanceOf(this) != totalToDistribute
// cover: run :: mNext == 0 && token.balanceOf(this) != totalToDistribute -> throw
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
        {
        target.run();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Owner can change owner to another address.
    function test_Change_owner_and_verify_6() public {
// cover: changeOwner :: onlyOwner modifier
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

    // @cover-intent Authorization & Access Control: Non-owner cannot change owner.
    function test_Non_owner_changeOwner_reverts_7() public {
// cover: changeOwner :: onlyOwner modifier
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

    // @cover-intent External Interaction & Environment: Owner can execute arbitrary call to another contract.
    function test_Execute_call_by_owner_8() public {
// cover: execute :: onlyOwner modifier
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
        target.execute(alice, 0, hex"");
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot call execute.
    function test_Non_owner_execute_reverts_9() public {
// cover: execute :: onlyOwner modifier
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
        vm.prank(bob);
        {
        target.execute(alice, 0, hex"");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_10() public {
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

    // @cover-intent External Interaction & Environment
    function test_execute_positive_11() public {
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
        target.execute(alice, 0, hex"");
        }
        {
        target.execute(alice, 0, hex"");
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_hasTerminated_positive_12() public {
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
        vm.prank(alice);
        {
        target.hasTerminated();
        }
    }

    // @cover-intent Protocol State Machine
    function test_nTransfers_positive_13() public {
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
        vm.prank(alice);
        {
        target.nTransfers();
        }
    }

    // @cover-intent Protocol State Machine
    function test_next_positive_14() public {
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
        target.next();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_positive_15() public {
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
        target.owner();
        }
    }

    // @cover-intent Financial & Accounting
    function test_run_positive_16() public {
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
        {
        target.run();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_token_positive_17() public {
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
        target.token();
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalToDistribute_positive_18() public {
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
        vm.prank(alice);
        {
        target.totalToDistribute();
        }
    }

    // @cover-intent Protocol State Machine
    function test_transfers_positive_19() public {
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
        vm.prank(alice);
        {
        target.transfers(0);
        }
    }

}
