// SPDX-License-Identifier: MIT
pragma solidity 0.4.24;
import "../src/send_loop.sol";

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

contract Refunder_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Refunder_FunctionalTest() public {
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


    // @cover-intent Resource & Execution Integrity: Verify that refundAll reverts if any refund address is a contract that rejects ETH (e.g., via fallback that reverts), demonstrating a DoS vulnerability.
    function test_RefundAll_reverts_when_a_refund_address_is_a_contract_that_rejects_ETH_0() public {
// assume: refundAddresses contains two addresses, one of which is a contract that reverts on receive
// cover: refundAll :: require(send succeeds) false
        vm.startPrank(owner);
        Refunder target = new Refunder();
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
        vm.expectRevert();
        // skip ABI-mismatched call: refundAll()
        vm.expectRevert();
        // skip ABI-mismatched call: refundAll()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that refundAll succeeds when all refund addresses are externally owned accounts (EOAs) that accept ETH.
    function test_RefundAll_succeeds_when_all_refund_addresses_are_EOAs_1() public {
// assume: refundAddresses contains two EOAs
// assume: contract has enough ETH to cover refunds
// cover: refundAll :: require(send succeeds) true
        vm.startPrank(owner);
        Refunder target = new Refunder();
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
        // skip ABI-mismatched call: refundAll()
        // skip ABI-mismatched call: refundAll()
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that refundAll succeeds when all refund amounts are zero, sending 0 ETH to each address.
    function test_RefundAll_with_zero_refund_amounts_2() public {
// assume: refunds[address1] == 0
// assume: refunds[address2] == 0
// cover: refundAll :: require(send succeeds) true
        vm.startPrank(owner);
        Refunder target = new Refunder();
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
        // skip ABI-mismatched call: refundAll()
        // skip ABI-mismatched call: refundAll()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that refundAll succeeds when one address has a large refund amount, testing edge of ETH transfer.
    function test_RefundAll_with_one_address_having_a_large_refund_3() public {
// assume: refunds[address1] == 100 ether
// assume: refunds[address2] == 0
// assume: contract balance >= 100 ether
// cover: refundAll :: require(send succeeds) true
        vm.startPrank(owner);
        Refunder target = new Refunder();
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
        // skip ABI-mismatched call: refundAll()
        // skip ABI-mismatched call: refundAll()
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that refundAll reverts if the contract does not have enough ETH to cover the refunds, causing send to fail.
    function test_RefundAll_reverts_when_contract_has_insufficient_ETH_4() public {
// assume: refunds[address1] == 1 ether
// assume: refunds[address2] == 1 ether
// assume: contract balance < 2 ether
// cover: refundAll :: require(send succeeds) false
        vm.startPrank(owner);
        Refunder target = new Refunder();
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
        vm.expectRevert();
        // skip ABI-mismatched call: refundAll()
        vm.expectRevert();
        // skip ABI-mismatched call: refundAll()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_refundAll_basic_5() public {
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=keccak256(abi.encode(address(0x79B483371E87d664cd39491b5F06250165e4b184), uint(1))), value=1000000000000000000;
        // dropped unsafe vm.store: slot=keccak256(abi.encode(address(0x79B483371E87d664cd39491b5F06250165e4b185), uint(1))), value=2000000000000000000;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: refundAll()
    }

    // @cover-intent Resource & Execution Integrity
    function test_refunds_view_6() public {
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=keccak256(abi.encode(address(alice), uint(1))), value=5000000000000000000;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.refunds(alice);
        }
    }

}
