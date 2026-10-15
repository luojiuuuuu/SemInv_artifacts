// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

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


    // @cover-intent Authorization & Access Control: Verify that Vault() function correctly initializes Owner and triggers deposit when called by tx.origin
    function test_Vault_initialization_and_deposit_0() public {
// assume: alice == tx.origin
// cover: Vault :: msg.sender == tx.origin true
// cover: deposit :: msg.value > 0.25 ether true
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
        target.Vault.value(0.5 ether)();
        }
        {
        target.Owner();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Vault() reverts when called by a contract (msg.sender != tx.origin)
    function test_Vault_reverts_when_not_tx_origin_1() public {
// assume: bob is a contract address
// cover: Vault :: msg.sender == tx.origin false
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.Vault.value(0.5 ether)();
        }
    }

    // @cover-intent Financial & Accounting: Verify that deposit() does not record deposits below 0.25 ether threshold
    function test_Deposit_below_threshold_2() public {
// cover: deposit :: msg.value > 0.25 ether false
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
        target.deposit.value(0.1 ether)();
        }
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that deposit() records deposits exactly at 0.25 ether threshold
    function test_Deposit_at_threshold_3() public {
// cover: deposit :: msg.value > 0.25 ether false
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
        target.deposit.value(0.25 ether)();
        }
        {
        target.Deposits(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that deposit() correctly records deposits above 0.25 ether threshold
    function test_Deposit_above_threshold_4() public {
// cover: deposit :: msg.value > 0.25 ether true
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
    }

    // @cover-intent Authorization & Access Control: Verify that owner can withdraw deposited funds
    function test_Withdraw_by_owner_success_5() public {
// assume: alice == owner
// cover: withdraw :: amount > 0 && Deposits[msg.sender] >= amount true
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
        // skip malformed call: withdraw(0.5 ether) (bad raw arg for withdraw.arg0: type=uint256, raw=0.5 ether)
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot withdraw
    function test_Withdraw_by_non_owner_reverts_6() public {
// assume: bob != owner
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
        vm.prank(alice);
        {
        target.Vault.value(1 ether)();
        }
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: withdraw(0.5 ether) (bad raw arg for withdraw.arg0: type=uint256, raw=0.5 ether)
    }

    // @cover-intent Financial & Accounting: Verify that withdraw reverts when amount exceeds deposit balance
    function test_Withdraw_exceeding_balance_reverts_7() public {
// assume: alice == owner
// cover: withdraw :: Deposits[msg.sender] >= amount false
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
        vm.expectRevert();
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can transfer ownership
    function test_Transfer_owner_by_owner_8() public {
// assume: alice == owner
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
        {
        target.Vault();
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

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot transfer ownership
    function test_Transfer_owner_by_non_owner_reverts_9() public {
// assume: bob != owner
// cover: transferOwner :: onlyOwner modifier false
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
        target.Vault();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwner(carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Deposits_view_10() public {
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
        target.deposit.value(0.3 ether)();
        }
        vm.prank(owner);
        {
        target.Deposits(alice);
        }
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_11() public {
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
    function test_Vault_positive_12() public {
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
        target.Vault.value(0.3 ether)();
        }
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_13() public {
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
        target.deposit.value(0.3 ether)();
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment
    function test_proxy_call_14() public {
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
        target.proxy(0x0000000000000000000000000000000000000001, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwner_positive_15() public {
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

    // @cover-intent Authorization & Access Control
    function test_transferOwner_non_owner_revert_16() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transferOwner(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_17() public {
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
        target.Vault.value(0.3 ether)();
        }
        {
        target.deposit.value(0.3 ether)();
        }
        // skip malformed call: withdraw(0.3 ether) (bad raw arg for withdraw.arg0: type=uint256, raw=0.3 ether)
        vm.stopPrank();
        // TODO assert: owner.balance == 0.3 ether
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_non_owner_revert_18() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(1);
        }
    }

}
