// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/unprotected0.sol";

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

contract Unprotected_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Unprotected_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that any caller can change the owner because the function lacks the onlyowner modifier.
    function test_Unauthorized_owner_change_0() public {
// cover: changeOwner :: assignment to owner
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(bob);
        }
        vm.prank(bob);
        {
        target.changeOwner(carol);
        }
    }

    // @cover-intent Authorization & Access Control: Confirm that the constructor sets the deployer as owner, but any address can still change it.
    function test_Owner_change_by_original_deployer_1() public {
// cover: changeOwner :: assignment to owner
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(alice);
        }
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the same address can call changeOwner multiple times in a row.
    function test_Repeated_owner_change_by_same_address_2() public {
// cover: changeOwner :: assignment to owner
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(bob);
        }
        vm.prank(bob);
        {
        target.changeOwner(alice);
        }
        vm.prank(alice);
        {
        target.changeOwner(carol);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that an address can set itself as owner.
    function test_Owner_change_to_self_3() public {
// cover: changeOwner :: assignment to owner
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can be set to address(0) (no protection against zero address).
    function test_Owner_change_to_zero_address_4() public {
// cover: changeOwner :: assignment to owner
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(0x0000000000000000000000000000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_unauthorized_5() public {
        vm.startPrank(owner);
        Unprotected target = new Unprotected();
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
        target.changeOwner(bob);
        }
    }

}
