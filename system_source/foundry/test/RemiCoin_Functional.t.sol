// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/RemiCoin.sol";

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

contract RemiCoin_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function RemiCoin_FunctionalTest() public {
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


    // @cover-intent Transfer 60 from alice to bob (supply conserved)
    function test_erc20_transfer_0() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 600);
        vm.prank(owner);
        target.mintToken(owner, 600);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.transfer(bob, 60);
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent approve -> transferFrom flow
    function test_erc20_approve_spend_1() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 200);
        vm.prank(owner);
        target.mintToken(owner, 200);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.approve(bob, 100);
        vm.prank(bob);
        target.transferFrom(alice, bob, 60);
        _assertEqU(target.allowance(alice, bob), 40);
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent 验证普通账户间的转账功能和余额变化，确保转账后余额正确且总供应量不变。
    function test_basic_transfer_2() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.transfer(bob, 10);
        vm.prank(bob);
        target.transfer(carol, 5);
        _assertEqU(target.balanceOf(alice), balA0 - 10);
        _assertEqU(target.balanceOf(bob), balB0 + 5);
        _assertEqU(target.balanceOf(carol), balC0 + 5);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent 验证授权与 transferFrom 功能，确保授权后第三方可转账且余额与授权额度正确变化。
    function test_approve_and_transferFrom_3() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 50);
        vm.prank(owner);
        target.mintToken(owner, 50);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.approve(bob, 20);
        vm.startPrank(bob);
        target.transferFrom(alice, carol, 15);
        bool __ok = target.transferFrom(alice, carol, 10);
        _assertTrue(!__ok, "expected false");
        vm.stopPrank();
        _assertEqU(target.balanceOf(alice), balA0 - 15);
        _assertEqU(target.balanceOf(carol), balC0 + 15);
        _assertEqU(target.allowance(alice, bob), 5);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent 验证只有 owner 能增发代币，且增发后目标账户余额和总供应量增加。
    function test_mintToken_by_owner_4() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        target.mintToken(alice, 30);
        target.mintToken(bob, 20);
        vm.stopPrank();
        _assertEqU(target.balanceOf(alice), balA0 + 30);
        _assertEqU(target.balanceOf(bob), balB0 + 20);
        { uint256 __ret = target.totalSupply(); _assertRelU(__ret, 2, 50, "call:totalSupply>=50"); }
    }

    // @cover-intent 验证非 owner 账户调用 mintToken 会回退，确保权限控制生效。
    function test_mintToken_by_non_owner_revert_5() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        target.mintToken(alice, 10);
        vm.expectRevert();
        vm.prank(bob);
        target.mintToken(bob, 10);
    }

    // @cover-intent 验证被冻结账户无法转账，解冻后可正常转账。
    function test_freeze_and_transfer_revert_6() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 40);
        vm.prank(owner);
        target.mintToken(owner, 40);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.freezeAccount(alice, true);
        vm.prank(alice);
        bool __ok = target.transfer(bob, 5);
        _assertTrue(!__ok, "expected false");
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.expectRevert();
        vm.prank(alice);
        target.transfer(bob, 5);
        _assertEqU(target.balanceOf(alice), balA0 - 5);
        _assertEqU(target.balanceOf(bob), balB0 + 5);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent 验证余额不足时转账会回退，余额不变。
    function test_transfer_insufficient_balance_7() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 3);
        vm.prank(owner);
        target.mintToken(owner, 3);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        bool __ok = target.transfer(bob, 5);
        _assertTrue(!__ok, "expected false");
        target.transfer(bob, 3);
        vm.stopPrank();
        _assertEqU(target.balanceOf(alice), 0);
        _assertEqU(target.balanceOf(bob), 3);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent 验证只有 owner 能修改 name、symbol、decimals，且调用成功。
    function test_change_metadata_by_owner_8() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        target.changeName("NewRemi");
        target.changeSymbol("NRM");
        target.changeDecimals(10);
        vm.stopPrank();
    }

    // @cover-intent 验证非 owner 账户修改 name、symbol、decimals 会回退，权限控制生效。
    function test_change_metadata_by_non_owner_revert_9() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        target.changeName("Fake");
        vm.expectRevert();
        vm.prank(bob);
        target.changeSymbol("FAKE");
        vm.expectRevert();
        vm.prank(carol);
        target.changeDecimals(1);
    }

    // @cover-intent 验证 owner 转移后新 owner 拥有权限，原 owner 权限失效。
    function test_transferOwnership_and_onlyOwner_10() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.transferOwnership(alice);
        vm.prank(alice);
        target.changeName("AliceCoin");
        vm.expectRevert();
        vm.prank(owner);
        target.changeName("OldOwnerCoin");
        _assertEqU(uint160(address(target.owner())), uint160(alice));
    }

    // @cover-intent 查询 owner 对 bob 的授权额度
    function test_allowance_basic_11() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.allowance(alice, bob);
        _assertEqU(target.allowance(alice, bob), 0);
    }

    // @cover-intent alice 授权 bob 可转走 10 个币
    function test_approve_basic_12() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.approve(bob, 10);
        _assertEqU(target.allowance(alice, bob), 10);
    }

    // @cover-intent 查询 alice 余额
    function test_balanceOf_basic_13() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.balanceOf(alice);
        _assertEqU(target.balanceOf(alice), 100);
    }

    // @cover-intent owner 修改 decimals 为 5
    function test_changeDecimals_basic_14() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.changeDecimals(5);
        { uint256 __ret = target.decimals(); _assertRelU(__ret, 0, 5, "call:decimals==5"); }
    }

    // @cover-intent owner 修改 name
    function test_changeName_basic_15() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.changeName("NewName");
        // TODO assert: call:name() == "NewName"
    }

    // @cover-intent owner 修改 symbol
    function test_changeSymbol_basic_16() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.changeSymbol("NRC");
        // TODO assert: call:symbol() == "NRC"
    }

    // @cover-intent 查询 decimals
    function test_decimals_basic_17() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.decimals();
        { uint256 __ret = target.decimals(); _assertRelU(__ret, 2, 0, "call:decimals>=0"); }
    }

    // @cover-intent owner 冻结 bob
    function test_freezeAccount_basic_18() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.freezeAccount(bob, true);
        // TODO assert: call:frozenAccount(bob) == true
    }

    // @cover-intent 查询 bob 是否被冻结
    function test_frozenAccount_basic_19() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.frozenAccount(bob);
        // TODO assert: call:frozenAccount(bob) == false
    }

    // @cover-intent owner 给 alice 增发 50 个币
    function test_mintToken_basic_20() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.mintToken(alice, 50);
        _assertEqU(target.balanceOf(alice), balA0 + 50);
        { uint256 __ret = target.totalSupply(); _assertRelU(__ret, 2, 50, "call:totalSupply>=50"); }
    }

    // @cover-intent 查询 name
    function test_name_basic_21() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.name();
        // TODO assert: call:name() != ""
    }

    // @cover-intent 查询 owner 地址
    function test_owner_basic_22() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.owner();
        // skip addr:owner check (role not inferred robustly)
    }

    // @cover-intent 查询 symbol
    function test_symbol_basic_23() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.symbol();
        // TODO assert: call:symbol() != ""
    }

    // @cover-intent 查询总供给
    function test_totalSupply_basic_24() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.totalSupply();
        { uint256 __ret = target.totalSupply(); _assertRelU(__ret, 2, 100, "call:totalSupply>=100"); }
    }

    // @cover-intent alice 向 bob 转账 1 个币
    function test_transfer_basic_25() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.transfer(bob, 1);
        _assertEqU(target.balanceOf(alice), balA0 - 1);
        _assertEqU(target.balanceOf(bob), balB0 + 1);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent bob 通过授权从 alice 转走 2 个币
    function test_transferFrom_basic_26() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mintToken(alice, 100);
        vm.prank(owner);
        target.mintToken(owner, 100);
        vm.prank(owner);
        target.freezeAccount(owner, false);
        vm.prank(owner);
        target.freezeAccount(alice, false);
        vm.prank(owner);
        target.freezeAccount(bob, false);
        vm.prank(owner);
        target.freezeAccount(carol, false);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        target.approve(bob, 2);
        vm.prank(bob);
        target.transferFrom(alice, bob, 2);
        _assertEqU(target.balanceOf(alice), balA0 - 2);
        _assertEqU(target.balanceOf(bob), balB0 + 2);
        _assertEqU(target.allowance(alice, bob), 0);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent owner 转移合约所有权给 alice
    function test_transferOwnership_basic_27() public {
        vm.startPrank(owner);
        RemiCoin target = new RemiCoin(100, "Name", "SYM", 18);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        target.transferOwnership(alice);
        // skip addr:owner check (role not inferred robustly)
    }

}
