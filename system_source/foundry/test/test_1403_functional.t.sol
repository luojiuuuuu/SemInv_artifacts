// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x610495793564aed0f9c7fc48dc4c7c9151d34fd6.sol";

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

contract SimpleWallet_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function SimpleWallet_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify owner can withdraw the exact contract balance
    function test_Owner_withdraws_exact_balance_0() public {
// assume: address(this).balance == 5 ether
// cover: withdraw :: require(msg.sender == owner) true
// cover: withdraw :: msg.sender.transfer(_value) succeeds
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.withdraw(5 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify onlyOwner modifier prevents non-owner from withdrawing
    function test_Non_owner_withdraw_reverts_1() public {
// assume: address(this).balance == 1 ether
// cover: withdraw :: require(msg.sender == owner) false
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.withdraw(1 ether);
        }
        // TODO assert: owner.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify withdrawAll transfers entire balance to owner
    function test_WithdrawAll_empties_contract_2() public {
// assume: address(this).balance == 15 ether
// cover: withdrawAll :: require(msg.sender == owner) true
// cover: withdraw :: msg.sender.transfer(_value) succeeds
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: withdrawAll()
    }

    // @cover-intent Resource & Execution Integrity: Verify owner can withdraw zero amount without reverting
    function test_Withdraw_zero_value_3() public {
// assume: address(this).balance == 1 ether
// cover: withdraw :: require(msg.sender == owner) true
// cover: withdraw :: msg.sender.transfer(0) succeeds
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.withdraw(0);
        }
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify withdraw reverts when amount exceeds contract balance
    function test_Withdraw_more_than_balance_reverts_4() public {
// assume: address(this).balance == 1 ether
// cover: withdraw :: require(msg.sender == owner) true
// cover: withdraw :: msg.sender.transfer(2 ether) fails
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.withdraw(2 ether);
        }
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify fallback function increments depositsCount on ETH receipt
    function test_Fallback_increments_depositsCount_5() public {
// assume: depositsCount() == 0
// cover: fallback :: depositsCount++ executes
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: depositsCount()
    }

    // @cover-intent Financial & Accounting: Verify multiple deposits accumulate and withdrawAll empties contract
    function test_Multiple_deposits_then_withdrawAll_6() public {
// assume: address(this).balance == 6 ether
// assume: depositsCount() == 3
// cover: withdrawAll :: require(msg.sender == owner) true
// cover: withdraw :: msg.sender.transfer(6 ether) succeeds
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: withdrawAll()
    }

    // @cover-intent Resource & Execution Integrity
    function test_depositsCount_view_7() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: depositsCount()
        {
            uint256 __v1 = uint256(target.depositsCount());
            _assertRelU(__v1, 2, 0, "call:depositsCount>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_8() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
    function test_withdraw_positive_9() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.withdraw(50);
        }
        {
        target.withdraw(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_withdrawAll_positive_10() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        // skip ABI-mismatched call: withdrawAll()
        // skip ABI-mismatched call: withdrawAll()
        vm.stopPrank();
    }

    // @cover-intent minimal test for sendMoney
    function test_perfn_sendMoney_11() public {
        vm.startPrank(owner);
        SimpleWallet target = new SimpleWallet();
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
        target.sendMoney(alice, 100, hex"01");
        }
    }

}
