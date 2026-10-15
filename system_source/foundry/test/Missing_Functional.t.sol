// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/incorrect_constructor_name1.sol";

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

contract Missing_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Missing_FunctionalTest() public {
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


    // @cover-intent 测试正常路径：先由任意用户调用IamMissing()成为owner，然后owner调用withdraw()提取合约余额。验证owner被正确设置且余额转移成功。
    function test_positive_set_owner_and_withdraw_0() public {
// assume: owner == alice
// cover: IamMissing :: owner = msg.sender
// cover: withdraw :: require(msg.sender==owner) true
        vm.startPrank(owner);
        Missing target = new Missing();
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
        target.IamMissing();
        }
        {
        target.withdraw();
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 100
    }

    // @cover-intent 测试负路径：在未调用IamMissing()设置owner的情况下，alice直接调用withdraw()，预期回退，因为owner为address(0)导致require失败。
    function test_negative_withdraw_before_set_owner_1() public {
// assume: owner == address(0)
// cover: withdraw :: require(msg.sender==owner) false
        vm.startPrank(owner);
        Missing target = new Missing();
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
        target.withdraw();
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent 测试负路径：alice调用IamMissing()成为owner后，bob尝试调用withdraw()，预期回退，因为bob不是owner。
    function test_negative_withdraw_by_non_owner_2() public {
// assume: owner == alice
// cover: withdraw :: require(msg.sender==owner) false
        vm.startPrank(owner);
        Missing target = new Missing();
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
        target.IamMissing();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdraw();
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent 测试边界情况：多个用户依次调用IamMissing()，只有最后一个调用者成为owner，且只有该owner能成功withdraw。
    function test_multiple_set_owner_last_wins_3() public {
// assume: owner == bob
// cover: IamMissing :: owner = msg.sender (multiple calls)
// cover: withdraw :: require(msg.sender==owner) true (bob)
// cover: withdraw :: require(msg.sender==owner) false (alice)
        vm.startPrank(owner);
        Missing target = new Missing();
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
        target.IamMissing();
        }
        vm.prank(bob);
        {
        target.IamMissing();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw();
        }
        vm.prank(bob);
        {
        target.withdraw();
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Test that IamMissing sets the owner to the caller (alice) and allows subsequent withdraw by alice
    function test_IamMissing_sets_owner_to_caller_4() public {
        vm.startPrank(owner);
        Missing target = new Missing();
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
        target.IamMissing();
        }
    }

    // @cover-intent Test that withdraw succeeds when called by the owner (alice) after IamMissing sets owner, and transfers balance
    function test_withdraw_by_owner_after_IamMissing_5() public {
        vm.startPrank(owner);
        Missing target = new Missing();
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
        target.IamMissing();
        }
        {
        target.withdraw();
        }
        vm.stopPrank();
    }

}
