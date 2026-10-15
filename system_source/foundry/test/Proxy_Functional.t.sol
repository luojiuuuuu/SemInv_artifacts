// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/proxy.sol";

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

contract Proxy_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Proxy_FunctionalTest() public {
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


    // @cover-intent Verify that forward() can be called by any address without owner restriction, demonstrating missing access control on delegatecall
    function test_Authorization_Access_Control_Delegatecall_without_owner_check_0() public {
// cover: forward :: require(callee.delegatecall(_data)) true
        vm.startPrank(owner);
        Proxy target = new Proxy();
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
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
        vm.prank(bob);
        // skip malformed call: forward(0x0000000000000000000000000000000000000002, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Verify that forward() reverts when delegatecall target is address(0), as delegatecall to zero address will fail
    function test_External_Interaction_Environment_Delegatecall_to_zero_address_1() public {
// cover: forward :: require(callee.delegatecall(_data)) false
        vm.startPrank(owner);
        Proxy target = new Proxy();
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
        // skip malformed call: forward(0x0000000000000000000000000000000000000000, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Verify that forward() succeeds with empty bytes data to a valid contract address
    function test_External_Interaction_Environment_Delegatecall_with_empty_data_2() public {
// cover: forward :: require(callee.delegatecall(_data)) true
        vm.startPrank(owner);
        Proxy target = new Proxy();
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
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Verify that forward() reverts when delegatecall target is an EOA (non-contract address) with non-empty data
    function test_External_Interaction_Environment_Delegatecall_with_non_empty_data_to_non_contract_3() public {
// cover: forward :: require(callee.delegatecall(_data)) false
        vm.startPrank(owner);
        Proxy target = new Proxy();
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
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0xdeadbeef") (bad raw arg for forward.arg1: type=bytes, raw="0xdeadbeef")
    }

    // @cover-intent Verify that forward() can be called multiple times by different users without restriction, demonstrating missing access control
    function test_Authorization_Access_Control_Multiple_calls_by_different_users_4() public {
// cover: forward :: require(callee.delegatecall(_data)) true
        vm.startPrank(owner);
        Proxy target = new Proxy();
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
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
        vm.prank(alice);
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
        vm.prank(bob);
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
        vm.prank(carol);
        // skip malformed call: forward(0x0000000000000000000000000000000000000001, "0x") (bad raw arg for forward.arg1: type=bytes, raw="0x")
    }

    // @cover-intent External Interaction & Environment
    function test_forward_delegatecall_5() public {
        vm.startPrank(owner);
        Proxy target = new Proxy();
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
        target.forward(0x0000000000000000000000000000000000000001, hex"");
        }
    }

}
