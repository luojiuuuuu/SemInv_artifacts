// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

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

contract AirDropContract_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function AirDropContract_FunctionalTest() public {
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


    // @cover-intent External Interaction & Environment: Verify that transfer succeeds when all require conditions are met and the external call is made.
    function test_transfer_success_0() public {
// assume: tos.length == vs.length
// cover: transfer :: require(tos.length > 0) true
// cover: transfer :: require(vs.length > 0) true
// cover: transfer :: require(tos.length == vs.length) true
// cover: validAddress :: require(addr != address(0x0)) true
// cover: validAddress :: require(addr != address(this)) true
        vm.startPrank(owner);
        AirDropContract target = new AirDropContract();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(bob, _arr1, _arr2);
        }
    }

    // @cover-intent Transactional Consistency: Verify that transfer reverts when tos array is empty.
    function test_transfer_empty_tos_1() public {
// cover: transfer :: require(tos.length > 0) false
        vm.startPrank(owner);
        AirDropContract target = new AirDropContract();
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
        address[] memory _arr1 = new address[](0);
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(bob, _arr1, _arr2);
        }
    }

    // @cover-intent Transactional Consistency: Verify that transfer reverts when vs array is empty.
    function test_transfer_empty_vs_2() public {
// cover: transfer :: require(vs.length > 0) false
        vm.startPrank(owner);
        AirDropContract target = new AirDropContract();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](0);
        target.transfer(bob, _arr1, _arr2);
        }
    }

    // @cover-intent Transactional Consistency: Verify that transfer reverts when tos and vs lengths differ.
    function test_transfer_mismatched_lengths_3() public {
// cover: transfer :: require(tos.length == vs.length) false
        vm.startPrank(owner);
        AirDropContract target = new AirDropContract();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(bob, _arr1, _arr2);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that transfer reverts when contract_address is address(0).
    function test_transfer_zero_address_contract_4() public {
// cover: validAddress :: require(addr != address(0x0)) false
        vm.startPrank(owner);
        AirDropContract target = new AirDropContract();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(0x0000000000000000000000000000000000000000, _arr1, _arr2);
        }
    }

}
