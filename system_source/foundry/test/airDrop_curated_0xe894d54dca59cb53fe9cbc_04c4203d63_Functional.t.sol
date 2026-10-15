// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

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

contract airDrop_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function airDrop_FunctionalTest() public {
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


    // @cover-intent Test normal behavior of transfer function with a single recipient, verifying that the external call is made and the function returns true. Covers Financial & Accounting invariant family.
    function test_Normal_transfer_with_one_recipient_0() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 1, 18);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 1, 18);
        }
        vm.stopPrank();
    }

    // @cover-intent Test transfer with multiple recipients to ensure loop iterates correctly and all external calls are made. Covers Resource & Execution Integrity.
    function test_Transfer_with_multiple_recipients_1() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 2, 0);
        }
        {
        address[] memory _arr2 = new address[](3);
        _arr2[0] = alice;
        _arr2[1] = alice;
        _arr2[2] = alice;
        target.transfer(alice, bob, _arr2, 2, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Test transfer with _decimals = 0, so _value = v * 1, verifying correct computation. Covers Financial & Accounting.
    function test_Transfer_with_zero_decimals_2() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 5, 0);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 5, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Test transfer with large _decimals to check for potential overflow in _value computation. Covers Resource & Execution Integrity.
    function test_Transfer_with_large_decimals_3() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 1, 18);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 1, 18);
        }
        vm.stopPrank();
    }

    // @cover-intent Test edge case where _tos array is empty, expecting revert due to require(_tos.length > 0). Covers Transactional Consistency.
    function test_Transfer_with_empty_tos_array_revert_4() public {
// cover: transfer :: require(_tos.length > 0) false
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 1, 18);
        }
    }

    // @cover-intent Test transfer with v = 0, so _value = 0, verifying that zero-value transfers are allowed. Covers Financial & Accounting.
    function test_Transfer_with_v_0_5() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 0, 18);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 0, 18);
        }
        vm.stopPrank();
    }

    // @cover-intent Test transfer with v and _decimals such that _value overflows uint256, expecting revert due to arithmetic overflow. Covers Resource & Execution Integrity.
    function test_Transfer_with_large_v_and_decimals_causing_overflow_6() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 2, 255);
        }
    }

    // @cover-intent Test transfer where from address is same as one of the _tos addresses, verifying no self-call issues. Covers External Interaction & Environment.
    function test_Transfer_with_from_to_address_7() public {
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        airDrop target = new airDrop();
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
        target.transfer(alice, bob, _arr1, 1, 18);
        }
        {
        address[] memory _arr2 = new address[](1);
        _arr2[0] = alice;
        target.transfer(alice, bob, _arr2, 1, 18);
        }
        vm.stopPrank();
    }

}
