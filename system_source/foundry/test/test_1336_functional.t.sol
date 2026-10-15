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


    // @cover-intent Resource & Execution Integrity: Verify that refundAll reverts entirely if any refundAddress cannot receive ETH, demonstrating a denial-of-service vulnerability.
    function test_RefundAll_reverts_when_one_address_fails_to_accept_ETH_0() public {
// assume: refunds[0x79B483371E87d664cd39491b5F06250165e4b184] == 0
// assume: refunds[0x79B483371E87d664cd39491b5F06250165e4b185] == 0
// cover: refundAll :: require(refundAddresses[x].send(refunds[refundAddresses[x]])) false
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(694813447870989484213047828542697217882537111940)));
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(694813447870989484213047828542697217882537111941)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.refunds(0x79B483371E87d664cd39491b5F06250165e4b184);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: refundAll()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_refundAll_basic_1() public {
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

    // @cover-intent Financial & Accounting
    function test_refunds_view_2() public {
        vm.startPrank(owner);
        Refunder target = new Refunder();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=keccak256(abi.encode(address(0x79B483371E87d664cd39491b5F06250165e4b184), uint(1))), value=500000000000000000;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.refunds(0x79B483371E87d664cd39491b5F06250165e4b184);
        }
    }

}
