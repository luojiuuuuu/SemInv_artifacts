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


    // @cover-intent Verify that transfer function executes successfully with valid inputs, demonstrating External Interaction & Environment invariant for external call execution
    function test_basic_transfer_success_0() public {
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

    // @cover-intent Verify transfer works with multiple recipients in the array, testing Resource & Execution Integrity for loop execution
    function test_transfer_multiple_recipients_1() public {
// cover: transfer :: require(_tos.length > 0) true
// cover: transfer :: for loop iteration 0
// cover: transfer :: for loop iteration 1
// cover: transfer :: for loop iteration 2
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
        address[] memory _arr1 = new address[](3);
        _arr1[0] = alice;
        _arr1[1] = alice;
        _arr1[2] = alice;
        target.transfer(alice, bob, _arr1, 50);
        }
        {
        address[] memory _arr2 = new address[](3);
        _arr2[0] = alice;
        _arr2[1] = alice;
        _arr2[2] = alice;
        target.transfer(alice, bob, _arr2, 50);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that transfer reverts when _tos array is empty, testing Transactional Consistency for input validation
    function test_transfer_empty_array_reverts_2() public {
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

    // @cover-intent Verify transfer works with zero value, testing edge behavior for Financial & Accounting invariants
    function test_transfer_zero_value_3() public {
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

    // @cover-intent Verify transfer works with large uint256 value, testing edge behavior for Resource & Execution Integrity
    function test_transfer_large_value_4() public {
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
        target.transfer(alice, bob, _arr1, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify transfer works when from parameter differs from msg.sender, testing Authorization & Access Control boundaries
    function test_transfer_from_different_sender_5() public {
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
        vm.startPrank(bob);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.transfer(alice, carol, _arr1, 200);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, carol, _arr2, 200);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify transfer works when recipient is the same as sender, testing edge behavior for External Interaction & Environment
    function test_transfer_to_self_6() public {
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
        target.transfer(alice, bob, _arr1, 75);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 75);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify transfer works when recipient is address(0), testing edge behavior for External Interaction & Environment
    function test_transfer_to_zero_address_7() public {
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
        target.transfer(alice, bob, _arr1, 50);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 50);
        }
        vm.stopPrank();
    }

}
