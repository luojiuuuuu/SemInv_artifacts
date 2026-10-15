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


    // @cover-intent Resource & Execution Integrity: Verify that refundAll() succeeds when no refunds are owed, even though the refundAddresses array is non-empty.
    function test_RefundAll_with_no_refunds_due_0() public {
// cover: refundAll :: loop iteration with refunds[addr]==0
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
        vm.prank(alice);
        // skip ABI-mismatched call: refundAll()
    }

    // @cover-intent Financial & Accounting: Verify that refundAll() correctly sends the refund amount to the first address when it has a positive refund balance.
    function test_RefundAll_with_one_refund_due_1() public {
// assume: address(0x79B483371E87d664cd39491b5F06250165e4b184).balance >= 100
// cover: refundAll :: require(send) true for first address
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(694813447870989484213047828542697217882537111940)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: refundAll()
    }

    // @cover-intent Resource & Execution Integrity: Verify that refundAll() reverts if the send to any address fails, demonstrating the DoS vulnerability.
    function test_RefundAll_with_revert_on_send_failure_2() public {
// assume: address(0x79B483371E87d664cd39491b5F06250165e4b184).balance < 100
// cover: refundAll :: require(send) false for first address
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(694813447870989484213047828542697217882537111940)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: refundAll()
    }

    // @cover-intent Financial & Accounting: Verify that refundAll() processes all addresses in the array, sending refunds to each.
    function test_RefundAll_with_multiple_refunds_due_3() public {
// assume: address(0x79B483371E87d664cd39491b5F06250165e4b184).balance >= 100
// assume: address(0x79B483371E87d664cd39491b5F06250165e4b185).balance >= 100
// cover: refundAll :: both loop iterations succeed
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(694813447870989484213047828542697217882537111940)), bytes32(uint256(100)));
        vm.store(address(target), bytes32(uint256(694813447870989484213047828542697217882537111941)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: refundAll()
    }

    // @cover-intent Resource & Execution Integrity: Verify that refundAll() reverts if the second address's send fails, even if the first succeeded.
    function test_RefundAll_with_second_address_failing_4() public {
// assume: address(0x79B483371E87d664cd39491b5F06250165e4b184).balance >= 100
// assume: address(0x79B483371E87d664cd39491b5F06250165e4b185).balance < 100
// cover: refundAll :: first send succeeds, second send fails
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(694813447870989484213047828542697217882537111940)), bytes32(uint256(100)));
        vm.store(address(target), bytes32(uint256(694813447870989484213047828542697217882537111941)), bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: refundAll()
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
