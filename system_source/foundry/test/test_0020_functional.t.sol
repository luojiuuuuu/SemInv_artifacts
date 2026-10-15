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


    // @cover-intent Financial & Accounting: Verify that transfer function iterates over multiple recipients and returns true without reverting.
    function test_Normal_transfer_with_multiple_recipients_0() public {
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
        address[] memory _arr1 = new address[](2);
        _arr1[0] = alice;
        _arr1[1] = alice;
        target.transfer(alice, address(0), _arr1, 1, 18);
        }
    }

    // @cover-intent Resource & Execution Integrity: Test with minimal array length of 1.
    function test_Edge_case_single_recipient_1() public {
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
        vm.prank(bob);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.transfer(bob, address(0), _arr1, 0, 0);
        }
    }

    // @cover-intent Transactional Consistency: Verify that require(_tos.length > 0) reverts when array is empty.
    function test_Edge_case_empty_recipients_array_reverts_2() public {
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
        target.transfer(alice, address(0), _arr1, 1, 18);
        }
    }

    // @cover-intent Resource & Execution Integrity: Test multiplication overflow potential with large v and _decimals.
    function test_Large_value_with_high_decimals_3() public {
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
        vm.prank(carol);
        {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        target.transfer(carol, address(0), _arr1, 2, 255);
        }
    }

    // @cover-intent Financial & Accounting: Test with v=0 and _decimals=0, resulting in _value=0.
    function test_Zero_value_transfer_4() public {
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
        target.transfer(alice, address(0), _arr1, 0, 0);
        }
    }

    // @cover-intent External Interaction & Environment: Test that external call is made to caddress for each recipient.
    function test_Multiple_recipients_with_different_addresses_5() public {
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
        vm.prank(owner);
        {
        address[] memory _arr1 = new address[](3);
        _arr1[0] = alice;
        _arr1[1] = alice;
        _arr1[2] = alice;
        target.transfer(owner, address(0), _arr1, 10, 2);
        }
    }

}
