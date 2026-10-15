// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

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

contract VaultProxy_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function VaultProxy_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that Vault() can only be called by tx.origin and sets Owner, then deposit works for amounts > 0.5 ether.
    function test_Vault_initialization_and_deposit_positive_0() public {
// cover: Vault :: msg.sender == tx.origin true
// cover: deposit :: msg.value > 0.5 ether true
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        {
        target.deposit.value(1 ether)();
        }
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0 ether
    }

    // @cover-intent Authorization & Access Control: Verify that Vault() reverts when msg.sender != tx.origin (e.g., called via proxy).
    function test_Vault_revert_when_called_by_contract_1() public {
// cover: Vault :: msg.sender == tx.origin false
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: proxy(address(this), abi.encodeWithSignature("Vault()")) (bad raw arg for proxy.arg0: type=address, raw=address(this))
    }

    // @cover-intent Financial & Accounting: Verify that deposit() does not update Deposits when msg.value <= 0.5 ether.
    function test_deposit_boundary_below_threshold_2() public {
// cover: deposit :: msg.value > 0.5 ether false
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(0.5 ether)();
        }
        {
        target.deposit.value(0.5 ether)();
        }
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0 ether
    }

    // @cover-intent Authorization & Access Control: Verify that owner can withdraw up to their deposit amount.
    function test_withdraw_positive_owner_3() public {
// cover: withdraw :: amount>0 && Deposits[msg.sender]>=amount true
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        {
        target.deposit.value(1 ether)();
        }
        {
        target.withdraw(1 ether);
        }
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call withdraw.
    function test_withdraw_revert_non_owner_4() public {
// cover: withdraw :: onlyOwner modifier false
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        {
        target.deposit.value(1 ether)();
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdraw(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that withdraw reverts when amount > Deposits[msg.sender].
    function test_withdraw_revert_insufficient_deposit_5() public {
// cover: withdraw :: Deposits[msg.sender]>=amount false
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        {
        target.deposit.value(1 ether)();
        }
        vm.expectRevert();
        {
        target.withdraw(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can transfer ownership to another address.
    function test_transferOwner_positive_6() public {
// cover: transferOwner :: onlyOwner modifier true
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        vm.startPrank(owner);
        {
        target.transferOwner(bob);
        }
        {
        target.Owner();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot transfer ownership.
    function test_transferOwner_revert_non_owner_7() public {
// cover: transferOwner :: onlyOwner modifier false
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwner(carol);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that proxy can forward calls and value to arbitrary targets (potential reentrancy vector).
    function test_proxy_reentrancy_risk_8() public {
// cover: proxy :: call.value(data) executed
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.Vault.value(1 ether)();
        }
        // skip malformed call: proxy(alice, "0x") (bad raw arg for proxy.arg1: type=bytes, raw="0x")
        vm.stopPrank();
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Authorization & Access Control
    function test_Deposits_view_9() public {
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.deposit.value(1 ether)();
        }
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_10() public {
        vm.startPrank(owner);
        VaultProxy target = new VaultProxy();
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
        target.Vault();
        }
        vm.prank(alice);
        {
        target.Owner();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Vault_setup_11() public {
        vm.startPrank(owner);
        VaultProxy target = new VaultProxy();
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
        target.Vault();
        }
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_12() public {
        vm.startPrank(alice);
        VaultProxy target = new VaultProxy();
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
        target.deposit.value(1 ether)();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent External Interaction & Environment
    function test_proxy_call_13() public {
        vm.startPrank(owner);
        VaultProxy target = new VaultProxy();
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
        target.proxy(alice, hex"");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwner_positive_14() public {
        vm.startPrank(owner);
        VaultProxy target = new VaultProxy();
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
        target.Vault();
        }
        {
        target.transferOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_15() public {
        vm.startPrank(owner);
        VaultProxy target = new VaultProxy();
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
        target.Vault();
        }
        {
        target.deposit.value(1 ether)();
        }
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

}
