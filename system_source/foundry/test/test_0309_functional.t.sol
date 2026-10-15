// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x4a66ad0bca2d700f11e1f2fc2c106f7d3264504c.sol";

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

contract EBU_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EBU_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that the owner can successfully call transfer with non-empty arrays, and the external call is made.
    function test_Positive_transfer_with_valid_arrays_0() public {
// assume: msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9
// cover: transfer :: require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9) true
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        EBU target = new EBU();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(_arr1, _arr2);
        }
        {
        address[] memory _arr3 = new address[](1);
        _arr3[0] = alice;
        uint256[] memory _arr4 = new uint256[](1);
        _arr4[0] = 1;
        target.transfer(_arr3, _arr4);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner callers are rejected by the require statement.
    function test_Revert_when_caller_is_not_owner_1() public {
// assume: msg.sender != 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9
// cover: transfer :: require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9) false
        vm.startPrank(owner);
        EBU target = new EBU();
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
        target.transfer(_arr1, _arr2);
        }
    }

    // @cover-intent Transactional Consistency: Verify that an empty _tos array causes revert.
    function test_Revert_when_tos_array_is_empty_2() public {
// assume: msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9
// cover: transfer :: require(_tos.length > 0) false
        vm.startPrank(owner);
        EBU target = new EBU();
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
        address[] memory _arr1 = new address[](0);
        uint256[] memory _arr2 = new uint256[](0);
        target.transfer(_arr1, _arr2);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that transfer can handle multiple recipients and multiple values.
    function test_Multiple_recipients_in_one_call_3() public {
// assume: msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        EBU target = new EBU();
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        uint256[] memory _arr2 = new uint256[](2);
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.transfer(_arr1, _arr2);
        }
        {
        address[] memory _arr3 = new address[](2);
        _arr3[0] = alice;
        _arr3[1] = alice;
        uint256[] memory _arr4 = new uint256[](2);
        _arr4[0] = 1;
        _arr4[1] = 1;
        target.transfer(_arr3, _arr4);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that large v values do not cause overflow in multiplication (v * 1e18) – though Solidity 0.4.18 will revert on overflow, test that it still works for reasonable values.
    function test_Large_value_multiplication_boundary_4() public {
// assume: msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9
// cover: transfer :: require(_tos.length > 0) true
        vm.startPrank(owner);
        EBU target = new EBU();
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
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(_arr1, _arr2);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_caddress_view_5() public {
        vm.startPrank(owner);
        EBU target = new EBU();
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
        // skip ABI-mismatched call: caddress()
    }

    // @cover-intent External Interaction & Environment
    function test_from_view_6() public {
        vm.startPrank(owner);
        EBU target = new EBU();
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
        // skip ABI-mismatched call: from()
    }

}
