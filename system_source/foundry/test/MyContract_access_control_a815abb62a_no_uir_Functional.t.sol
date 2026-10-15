// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/mycontract.sol";

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

contract MyContract_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MyContract_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that the owner (tx.origin == owner) can successfully send ETH to a receiver.
    function test_Positive_path_owner_sends_ETH_to_receiver_0() public {
// assume: tx.origin == owner
// cover: sendTo :: require(tx.origin == owner) true
        vm.startPrank(owner);
        MyContract target = new MyContract();
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
        target.sendTo(alice, 50);
        }
        {
        target.sendTo(alice, 50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller (tx.origin != owner) triggers a revert.
    function test_Negative_path_non_owner_alice_calls_sendTo_1() public {
// assume: tx.origin != owner
// cover: sendTo :: require(tx.origin == owner) false
        vm.startPrank(owner);
        MyContract target = new MyContract();
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
        target.sendTo(bob, 10);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending 0 ETH from owner to receiver succeeds (edge behavior).
    function test_Edge_case_sendTo_with_amount_0_2() public {
// assume: tx.origin == owner
// cover: sendTo :: require(tx.origin == owner) true
        vm.startPrank(owner);
        MyContract target = new MyContract();
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
        target.sendTo(bob, 0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that sending more ETH than owner has causes a revert (due to transfer failure).
    function test_Edge_case_sendTo_with_amount_exceeding_owner_balance_3() public {
// assume: tx.origin == owner
// assume: balance(owner) < 1000
// cover: sendTo :: require(tx.origin == owner) true
// cover: sendTo :: receiver.transfer(amount) fails
        vm.startPrank(owner);
        MyContract target = new MyContract();
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
        target.sendTo(alice, 1000);
        }
    }

    // @cover-intent Transactional Consistency: Verify that owner sending ETH to themselves succeeds and net balance unchanged.
    function test_Edge_case_sendTo_to_self_owner_sends_to_owner_4() public {
// assume: tx.origin == owner
// cover: sendTo :: require(tx.origin == owner) true
        vm.startPrank(owner);
        MyContract target = new MyContract();
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
        target.sendTo(owner, 30);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendTo_positive_path_5() public {
        vm.startPrank(owner);
        MyContract target = new MyContract();
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
        target.sendTo(alice, 1);
        }
        {
        target.sendTo(alice, 1);
        }
        vm.stopPrank();
    }

}
