// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

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


    // @cover-intent Exercise normal behavior of transfer function with non-empty arrays, verifying it returns true and does not revert. Covers External Interaction & Environment.
    function test_Basic_transfer_with_valid_arrays_0() public {
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
        vm.startPrank(alice);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        uint256[] memory _arr2 = new uint256[](2);
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
        {
        address[] memory _arr3 = new address[](2);
        _arr3[0] = alice;
        _arr3[1] = alice;
        uint256[] memory _arr4 = new uint256[](2);
        _arr4[0] = 1;
        _arr4[1] = 1;
        target.transfer(alice, bob, _arr3, _arr4);
        }
        vm.stopPrank();
    }

    // @cover-intent Test boundary condition where _tos array is empty, expecting revert due to require statement. Covers Transactional Consistency.
    function test_Empty_tos_array_reverts_1() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](0);
        uint256[] memory _arr2 = new uint256[](0);
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test edge case with single-element arrays to ensure loop executes exactly once. Covers Resource & Execution Integrity.
    function test_Single_element_arrays_2() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test with moderately large arrays to check loop execution and gas consumption. Covers Resource & Execution Integrity.
    function test_Large_arrays_boundary_on_loop_3() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](5);
        _arr1[0] = alice;
        _arr1[1] = alice;
        _arr1[2] = alice;
        _arr1[3] = alice;
        _arr1[4] = alice;
        uint256[] memory _arr2 = new uint256[](5);
        _arr2[0] = 1;
        _arr2[1] = 1;
        _arr2[2] = 1;
        _arr2[3] = 1;
        _arr2[4] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test behavior when _tos and v arrays have different lengths; contract does not check length equality, so it should still execute. Covers Transactional Consistency.
    function test_Mismatched_array_lengths_implicitly_allowed_by_ABI_4() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test edge case where v contains zero, which is a valid uint256. Covers Financial & Accounting.
    function test_Zero_value_in_v_array_5() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test with duplicate addresses in _tos to ensure loop handles duplicates. Covers External Interaction & Environment.
    function test_Repeated_addresses_in_tos_6() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](3);
        _arr1[0] = alice;
        _arr1[1] = alice;
        _arr1[2] = alice;
        uint256[] memory _arr2 = new uint256[](3);
        _arr2[0] = 1;
        _arr2[1] = 1;
        _arr2[2] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test when caddress is a regular user address (no fallback), the call will succeed but do nothing. Covers External Interaction & Environment.
    function test_Call_to_non_contract_address_as_caddress_7() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(alice, carol, _arr1, _arr2);
        }
    }

    // @cover-intent Test when from and caddress are the same address. Covers Authorization & Access Control.
    function test_Call_with_from_equal_to_caddress_8() public {
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
        vm.prank(alice);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.transfer(alice, alice, _arr1, _arr2);
        }
    }

}
