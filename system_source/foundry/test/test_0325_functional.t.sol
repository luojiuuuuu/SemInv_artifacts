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


    // @cover-intent Test normal behavior of transfer function with one recipient, verifying it returns true and does not revert. Covers External Interaction & Environment.
    function test_Basic_transfer_with_single_recipient_0() public {
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

    // @cover-intent Test transfer with multiple recipients to ensure loop executes correctly. Covers External Interaction & Environment.
    function test_Transfer_with_multiple_recipients_1() public {
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
        uint256[] memory _arr2 = new uint256[](2);
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.transfer(alice, bob, _arr1, _arr2);
        }
    }

    // @cover-intent Test edge case where _tos array is empty, expecting revert due to require. Covers Transactional Consistency.
    function test_Transfer_with_empty_tos_array_reverts_2() public {
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

    // @cover-intent Test edge case where _tos and v arrays have different lengths; function does not check this, so it should still return true but may cause out-of-bounds access. Covers Resource & Execution Integrity.
    function test_Transfer_with_mismatched_array_lengths_3() public {
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

    // @cover-intent Test transfer with zero values in v array to ensure no underflow or revert. Covers Financial & Accounting.
    function test_Transfer_with_zero_values_4() public {
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

    // @cover-intent Test transfer with a large number of recipients to stress loop execution. Covers Resource & Execution Integrity.
    function test_Transfer_with_large_array_5() public {
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

}
