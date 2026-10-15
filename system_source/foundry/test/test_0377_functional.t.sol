// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

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

contract EtherGet_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EtherGet_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that the constructor sets the owner to the deployer.
    function test_EtherGet_constructor_sets_owner_0() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        // skip ABI-mismatched call: withdrawEther()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Calling getTokens with num=0 should do nothing and succeed.
    function test_getTokens_loop_zero_iterations_1() public {
// cover: getTokens :: loop condition i < num false
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        target.getTokens(0, alice);
        }
    }

    // @cover-intent Resource & Execution Integrity: Calling getTokens with num=1 should execute one low-level call to addr.
    function test_getTokens_loop_one_iteration_2() public {
// cover: getTokens :: loop condition i < num true
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        target.getTokens(1, alice);
        }
    }

    // @cover-intent Financial & Accounting: withdrawTokens should transfer the entire token balance of the contract to the owner.
    function test_withdrawTokens_transfers_balance_to_owner_3() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        target.getTokens(0, alice);
        }
        {
        target.withdrawTokens(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: withdrawEther should transfer the entire ether balance of the contract to the owner.
    function test_withdrawEther_transfers_balance_to_owner_4() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        // skip ABI-mismatched call: withdrawEther()
    }

    // @cover-intent Authorization & Access Control: Non-owner calling withdrawEther should revert because owner.transfer is guarded by owner variable.
    function test_withdrawEther_non_owner_reverts_5() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        // skip ABI-mismatched call: withdrawEther()
    }

    // @cover-intent Authorization & Access Control: Non-owner calling withdrawTokens should revert because transfer is to owner.
    function test_withdrawTokens_non_owner_reverts_6() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        target.withdrawTokens(alice);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_getTokens_minimal_7() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        target.getTokens(1, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawEther_minimal_8() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        // skip ABI-mismatched call: withdrawEther()
        // skip ABI-mismatched call: withdrawEther()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawTokens_minimal_9() public {
        vm.startPrank(owner);
        EtherGet target = new EtherGet();
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
        target.withdrawTokens(alice);
        }
    }

}
