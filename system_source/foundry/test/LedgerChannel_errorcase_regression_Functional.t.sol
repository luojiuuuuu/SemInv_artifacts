// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/spank_chain_payment.sol";

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

contract LedgerChannel_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function LedgerChannel_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that a channel can be created by Alice and joined by the intermediary (bob) with ETH and token deposits, resulting in an open channel.
    function test_Happy_path_create_and_join_a_ledger_channel_0() public {
// assume: Channels[0x01].isOpen == false before join
// assume: token.balanceOf(alice) >= 500
// assume: token.balanceOf(bob) >= 300
// cover: createChannel :: require(Channels[_lcID].partyAddresses[0] == address(0)) true
// cover: createChannel :: require(msg.value == _balances[0]) true
// cover: createChannel :: require(token.transferFrom(...)) true
// cover: joinChannel :: require(Channels[_lcID].isOpen == false) true
// cover: joinChannel :: require(msg.sender == Channels[_lcID].partyAddresses[1]) true
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x01, bob, 100, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(1)), _arr1);
        }
    }

    // @cover-intent Protocol State Machine: Verify that if the intermediary never joins, the creator can reclaim their deposit after the open timeout.
    function test_LCOpenTimeout_reclaim_deposit_after_timeout_1() public {
// assume: now <= LCopenTimeout for 0x02
// cover: LCOpenTimeout :: require(now > Channels[_lcID].LCopenTimeout) false
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x02, bob, 1, token, [10 ether, 50]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.expectRevert();
        {
        target.LCOpenTimeout(bytes32(uint256(2)));
        }
        vm.stopPrank();
        // TODO assert: alice.balance == initial - 10 ether
    }

    // @cover-intent Financial & Accounting: Verify that a participant can deposit additional ETH into an open channel, increasing the deposited balance.
    function test_Deposit_add_funds_to_an_open_channel_2() public {
// assume: Channels[0x03].isOpen == true
// cover: deposit :: require(Channels[_lcID].isOpen == true) true
// cover: deposit :: require(recipient == partyAddresses[0] || recipient == partyAddresses[1]) true
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x03, bob, 100, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(3)), _arr1);
        }
        vm.prank(alice);
        {
        target.deposit.value(50 ether)(bytes32(uint256(3)), alice, 50 ether, false);
        }
        vm.prank(bob);
        {
        target.deposit.value(20 ether)(bytes32(uint256(3)), bob, 20 ether, false);
        }
    }

    // @cover-intent Protocol State Machine: Verify that both parties can close the channel by providing signatures on the final balances, and funds are transferred.
    function test_Consensus_close_both_parties_agree_to_close_3() public {
// assume: Channels[0x04].isOpen == true
// assume: sigA is valid signature from alice on the state hash
// assume: sigI is valid signature from bob on the state hash
// cover: consensusCloseChannel :: require(Channels[_lcID].isOpen == true) true
// cover: consensusCloseChannel :: require(totalEthDeposit == _balances[0] + _balances[1]) true
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x04, bob, 100, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(4)), _arr1);
        }
        vm.prank(alice);
        // skip malformed call: consensusCloseChannel(0x04, 0, [80 ether, 70 ether, 400, 400], sigA, sigI) (bad raw arg for consensusCloseChannel.arg3: type=string, raw=sigA)
    }

    // @cover-intent Protocol State Machine: Verify that both parties can update the ledger channel state with new balances and a new VC root.
    function test_Update_LC_state_both_parties_sign_a_new_state_4() public {
// assume: Channels[0x05].isOpen == true
// assume: sigA is valid signature from alice on the state hash
// assume: sigI is valid signature from bob on the state hash
// cover: updateLCstate :: require(channel.sequence < updateParams[0]) true
// cover: updateLCstate :: require(channel.ethBalances[0] + channel.ethBalances[1] >= updateParams[2] + updateParams[3]) true
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x05, bob, 100, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(5)), _arr1);
        }
        vm.prank(alice);
        // skip malformed call: updateLCstate(0x05, [1, 0, 60 ether, 90 ether, 200, 600], 0x00, sigA, sigI) (bad raw arg for updateLCstate.arg3: type=string, raw=sigA)
    }

    // @cover-intent Protocol State Machine: Verify that after the update timeout, the channel can be closed byzantine-style, distributing balances.
    function test_Byzantine_close_close_after_update_timeout_with_no_open_VCs_5() public {
// assume: now < updateLCtimeout for 0x06
// cover: byzantineCloseChannel :: require(channel.updateLCtimeout < now) false
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x06, bob, 1, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(6)), _arr1);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x06, [1, 0, 60 ether, 90 ether, 200, 600], 0x00, sigA, sigI) (bad raw arg for updateLCstate.arg3: type=string, raw=sigA)
        vm.expectRevert();
        {
        target.byzantineCloseChannel(bytes32(uint256(6)));
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that a virtual channel can be initialized and then settled, updating the VC state.
    function test_Virtual_channel_init_and_settle_6() public {
// assume: Channels[0x07].updateLCtimeout < now
// assume: proof is valid merkle proof for the initial state under root 0x1234
// assume: sigA is valid signature from alice
// cover: initVCstate :: require(Channels[_lcID].updateLCtimeout < now) true
// cover: settleVC :: require(virtualChannels[_vcID].sequence < updateSeq) true
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x07, bob, 1, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(7)), _arr1);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x07, [1, 1, 60 ether, 90 ether, 200, 600], 0x1234, sigA, sigI) (bad raw arg for updateLCstate.arg3: type=string, raw=sigA)
        // skip malformed call: initVCstate(0x07, 0xvc01, proof, alice, carol, [10 ether, 5 ether], [5 ether, 5 ether, 100, 100], sigA) (bad raw arg for initVCstate.arg1: type=bytes32, raw=0xvc01)
        // skip malformed call: settleVC(0x07, 0xvc01, 1, alice, carol, [8 ether, 7 ether, 80, 120], sigA) (bad raw arg for settleVC.arg1: type=bytes32, raw=0xvc01)
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that a virtual channel can be closed after the settlement timeout, returning balances to the LC.
    function test_Close_virtual_channel_after_settlement_timeout_7() public {
// assume: now < virtualChannels[0xvc02].updateVCtimeout
// cover: closeVirtualChannel :: require(virtualChannels[_vcID].updateVCtimeout < now) false
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        // skip malformed call: createChannel(0x08, bob, 1, token, [100 ether, 500]) (bad raw arg for createChannel.arg3: type=address, raw=token)
        vm.prank(bob);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.joinChannel.value(50 ether)(bytes32(uint256(8)), _arr1);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x08, [1, 1, 60 ether, 90 ether, 200, 600], 0x1234, sigA, sigI) (bad raw arg for updateLCstate.arg3: type=string, raw=sigA)
        // skip malformed call: initVCstate(0x08, 0xvc02, proof, alice, carol, [10 ether, 5 ether], [5 ether, 5 ether, 100, 100], sigA) (bad raw arg for initVCstate.arg1: type=bytes32, raw=0xvc02)
        // skip malformed call: settleVC(0x08, 0xvc02, 1, alice, carol, [8 ether, 7 ether, 80, 120], sigA) (bad raw arg for settleVC.arg1: type=bytes32, raw=0xvc02)
        vm.expectRevert();
        // skip malformed call: closeVirtualChannel(0x08, 0xvc02) (bad raw arg for closeVirtualChannel.arg1: type=bytes32, raw=0xvc02)
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Channels_getter_8() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(1)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        {
        target.Channels(bytes32(uint256(1)));
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_LCOpenTimeout_positive_9() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(2)), bob, 1, 0x0000000000000000000000000000000000000000, _arr1);
        }
        {
        target.LCOpenTimeout(bytes32(uint256(2)));
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10
    }

    // @cover-intent Resource & Execution Integrity
    function test_NAME_getter_10() public {
        vm.startPrank(owner);
        LedgerChannel target = new LedgerChannel();
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
        // skip ABI-mismatched call: NAME()
    }

    // @cover-intent Resource & Execution Integrity
    function test_VERSION_getter_11() public {
        vm.startPrank(owner);
        LedgerChannel target = new LedgerChannel();
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
        // skip ABI-mismatched call: VERSION()
    }

    // @cover-intent Protocol State Machine
    function test_byzantineCloseChannel_positive_12() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(3)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(5)(bytes32(uint256(3)), _arr2);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x03, [1, 0, 8, 7, 0, 0], 0x0000000000000000000000000000000000000000000000000000000000000000, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
        {
        target.byzantineCloseChannel(bytes32(uint256(3)));
        }
        vm.stopPrank();
        // TODO assert: alice.balance >= 8
        // TODO assert: bob.balance >= 7
    }

    // @cover-intent Protocol State Machine
    function test_closeVirtualChannel_positive_13() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(20)(bytes32(uint256(4)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(10)(bytes32(uint256(4)), _arr2);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x04, [1, 1, 15, 15, 0, 0], 0x1111111111111111111111111111111111111111111111111111111111111111, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
        // skip malformed call: initVCstate(0x04, 0x05, '0x', alice, carol, [10, 0], [5, 5, 0, 0], '0x') (bad raw arg for initVCstate.arg2: type=bytes, raw='0x')
        {
        target.closeVirtualChannel(bytes32(uint256(4)), bytes32(uint256(5)));
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_consensusCloseChannel_positive_14() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(6)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(5)(bytes32(uint256(6)), _arr2);
        }
        vm.prank(alice);
        // skip malformed call: consensusCloseChannel(0x06, 0, [8, 7, 0, 0], '0x', '0x') (bad raw arg for consensusCloseChannel.arg3: type=string, raw='0x')
        // TODO assert: alice.balance == 8
        // TODO assert: bob.balance == 7
    }

    // @cover-intent Protocol State Machine
    function test_createChannel_positive_15() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(7)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        // TODO assert: alice.balance == 90
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_16() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(8)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(5)(bytes32(uint256(8)), _arr2);
        }
        vm.prank(alice);
        {
        target.deposit.value(5)(bytes32(uint256(8)), alice, 5, false);
        }
        // TODO assert: alice.balance == 80
    }

    // @cover-intent Resource & Execution Integrity
    function test_getChannel_positive_17() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(9)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        {
        target.getChannel(bytes32(uint256(9)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getVirtualChannel_positive_18() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(20)(bytes32(uint256(10)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(10)(bytes32(uint256(10)), _arr2);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x0a, [1, 1, 15, 15, 0, 0], 0x1111111111111111111111111111111111111111111111111111111111111111, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
        // skip malformed call: initVCstate(0x0a, 0x0b, '0x', alice, carol, [10, 0], [5, 5, 0, 0], '0x') (bad raw arg for initVCstate.arg2: type=bytes, raw='0x')
        {
        target.getVirtualChannel(bytes32(uint256(11)));
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_initVCstate_positive_19() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(20)(bytes32(uint256(12)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(10)(bytes32(uint256(12)), _arr2);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x0c, [1, 1, 15, 15, 0, 0], 0x1111111111111111111111111111111111111111111111111111111111111111, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
        // skip malformed call: initVCstate(0x0c, 0x0d, '0x', alice, carol, [10, 0], [5, 5, 0, 0], '0x') (bad raw arg for initVCstate.arg2: type=bytes, raw='0x')
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_joinChannel_positive_20() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(14)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(5)(bytes32(uint256(14)), _arr2);
        }
        // TODO assert: bob.balance == 95
    }

    // @cover-intent Resource & Execution Integrity
    function test_numChannels_getter_21() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(15)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(5)(bytes32(uint256(15)), _arr2);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: numChannels()
    }

    // @cover-intent Protocol State Machine
    function test_settleVC_positive_22() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(20)(bytes32(uint256(16)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(10)(bytes32(uint256(16)), _arr2);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x10, [1, 1, 15, 15, 0, 0], 0x1111111111111111111111111111111111111111111111111111111111111111, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
        // skip malformed call: initVCstate(0x10, 0x11, '0x', alice, carol, [10, 0], [5, 5, 0, 0], '0x') (bad raw arg for initVCstate.arg2: type=bytes, raw='0x')
        // skip malformed call: settleVC(0x10, 0x11, 1, alice, carol, [6, 4, 0, 0], '0x') (bad raw arg for settleVC.arg6: type=string, raw='0x')
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_updateLCstate_positive_23() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(10)(bytes32(uint256(18)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(5)(bytes32(uint256(18)), _arr2);
        }
        vm.prank(alice);
        // skip malformed call: updateLCstate(0x12, [1, 0, 8, 7, 0, 0], 0x0000000000000000000000000000000000000000000000000000000000000000, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
    }

    // @cover-intent Resource & Execution Integrity
    function test_virtualChannels_getter_24() public {
        vm.startPrank(alice);
        LedgerChannel target = new LedgerChannel();
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
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        target.createChannel.value(20)(bytes32(uint256(19)), bob, 100, 0x0000000000000000000000000000000000000000, _arr1);
        }
        vm.prank(bob);
        {
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.joinChannel.value(10)(bytes32(uint256(19)), _arr2);
        }
        vm.startPrank(alice);
        // skip malformed call: updateLCstate(0x13, [1, 1, 15, 15, 0, 0], 0x1111111111111111111111111111111111111111111111111111111111111111, '0x', '0x') (bad raw arg for updateLCstate.arg3: type=string, raw='0x')
        // skip malformed call: initVCstate(0x13, 0x14, '0x', alice, carol, [10, 0], [5, 5, 0, 0], '0x') (bad raw arg for initVCstate.arg2: type=bytes, raw='0x')
        {
        target.virtualChannels(bytes32(uint256(20)));
        }
        vm.stopPrank();
    }

}
