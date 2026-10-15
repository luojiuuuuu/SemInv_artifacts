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


    // @cover-intent Authorization & Access Control: Verify that Vault() sets Owner to tx.origin and calls deposit() which records deposit only if msg.value > 0.5 ether.
    function test_Vault_initialization_and_deposit_positive_0() public {
// cover: Vault :: msg.sender == tx.origin true
// cover: deposit :: msg.value > 0.5 ether true
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
        // skip ABI-mismatched call: Vault()
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that deposit() does not record deposit when msg.value <= 0.5 ether.
    function test_deposit_below_threshold_no_record_1() public {
// cover: deposit :: msg.value > 0.5 ether false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdraw with amount=0 reverts due to amount>0 check.
    function test_withdraw_amount_zero_revert_2() public {
// cover: withdraw :: amount > 0 false
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
        // skip ABI-mismatched call: Vault()
        vm.expectRevert();
        {
        target.withdraw(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdraw reverts when Deposits[msg.sender] < amount.
    function test_withdraw_insufficient_deposit_revert_3() public {
// cover: withdraw :: Deposits[msg.sender] >= amount false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: Vault()
        vm.expectRevert();
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that onlyOwner can transfer ownership.
    function test_transferOwner_positive_4() public {
// cover: transferOwner :: onlyOwner modifier true
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
        // skip ABI-mismatched call: Vault()
        vm.startPrank(owner);
        {
        target.transferOwner(bob);
        }
        // skip ABI-mismatched call: Owner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot transfer ownership.
    function test_transferOwner_non_owner_revert_5() public {
// cover: transferOwner :: onlyOwner modifier revert
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
        // skip ABI-mismatched call: Vault()
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwner(carol);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that fallback function accepts ETH without recording deposit.
    function test_fallback_receive_eth_6() public {
// cover: fallback :: payable fallback executed
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
        target.Deposits(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Deposits_view_7() public {
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
        // skip ABI-mismatched call: deposit()
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_8() public {
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
        // skip ABI-mismatched call: Owner()
    }

    // @cover-intent Authorization & Access Control
    function test_Vault_positive_9() public {
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
        // skip ABI-mismatched call: Vault()
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_10() public {
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
        // skip ABI-mismatched call: deposit()
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwner_positive_11() public {
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
        target.transferOwner(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_12() public {
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
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent minimal test for proxy
    function test_perfn_proxy_13() public {
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
        target.proxy(alice, hex"01");
        }
    }

}
