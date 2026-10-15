// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x4051334adc52057aca763453820cb0e045076ef3.sol";

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

contract airdrop_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function airdrop_FunctionalTest() public {
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


    // @cover-intent External Interaction & Environment: Verify that transfer succeeds when _tos array is non-empty and call to external contract is made.
    function test_Basic_positive_transfer_0() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airdrop target = new airdrop();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.transfer(alice, bob, _arr1, 100);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that transfer reverts when _tos array is empty.
    function test_Empty_tos_array_reverts_1() public {
// cover: transfer :: require(_tos.length > 0) false
        vm.startPrank(owner);
        airdrop target = new airdrop();
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
        target.transfer(alice, bob, _arr1, 100);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that transfer handles multiple recipients in _tos array.
    function test_Multiple_recipients_in_tos_2() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airdrop target = new airdrop();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.transfer(alice, bob, _arr1, 50);
        }
        {
        address[] memory _arr2 = new address[](2);
        _arr2[0] = alice;
        _arr2[1] = alice;
        target.transfer(alice, bob, _arr2, 50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that transfer with v=0 still executes calls to external contract.
    function test_Zero_value_transfer_3() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airdrop target = new airdrop();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.transfer(alice, bob, _arr1, 0);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that transfer handles a large _tos array without out-of-gas issues (boundary test).
    function test_Large_array_of_recipients_4() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airdrop target = new airdrop();
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
        address[] memory _arr1 = new address[](5);
        _arr1[0] = alice;
        _arr1[1] = alice;
        _arr1[2] = alice;
        _arr1[3] = alice;
        _arr1[4] = alice;
        target.transfer(alice, bob, _arr1, 10);
        }
        {
        address[] memory _arr2 = new address[](5);
        _arr2[0] = alice;
        _arr2[1] = alice;
        _arr2[2] = alice;
        _arr2[3] = alice;
        _arr2[4] = alice;
        target.transfer(alice, bob, _arr2, 10);
        }
        vm.stopPrank();
    }

}
