// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

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

contract TownCrier_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TownCrier_FunctionalTest() public {
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


    // @cover-intent Test normal request and delivery flow (Financial & Accounting).
    function test_Request_and_Deliver_Success_0() public {
// assume: MIN_FEE <= 1 ether
// cover: request :: msg.value >= MIN_FEE
// cover: deliver :: msg.sender == SGX_ADDRESS && requestId > 0 && requests[requestId].requester != 0 && requests[requestId].fee != DELIVERED_FEE_FLAG
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)), 0, bytes32(uint256(0)));
        }
    }

    // @cover-intent Test request reverts when fee is below MIN_FEE (Financial & Accounting).
    function test_Request_with_Insufficient_Fee_1() public {
// assume: MIN_FEE > 1 wei
// cover: request :: msg.value < MIN_FEE
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 wei)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
    }

    // @cover-intent Test successful cancellation by requester (Authorization & Access Control).
    function test_Cancel_Request_Success_2() public {
// assume: CANCELLATION_FEE <= 1 ether
// cover: cancel :: requests[requestId].requester == msg.sender && fee >= CANCELLATION_FEE
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
    }

    // @cover-intent Test cancellation fails when caller is not the requester (Authorization & Access Control).
    function test_Cancel_Non_Owner_Request_3() public {
// cover: cancel :: requests[requestId].requester != msg.sender || fee < CANCELLATION_FEE
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Test upgrade by owner when no pending requests (Protocol State Machine).
    function test_Upgrade_When_UnrespondedCnt_Zero_4() public {
// assume: unrespondedCnt() == 0
// cover: upgrade :: msg.sender == requests[0].requester && unrespondedCnt == 0
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.upgrade(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Test upgrade fails when there are pending requests (Protocol State Machine).
    function test_Upgrade_Revert_When_UnrespondedCnt_NonZero_5() public {
// assume: unrespondedCnt() > 0
// cover: upgrade :: msg.sender == requests[0].requester && unrespondedCnt == 0 (false)
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
        vm.prank(owner);
        {
        target.upgrade(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Test suspend and restart cycle (Protocol State Machine).
    function test_Suspend_and_Restart_6() public {
// assume: newVersion() == 0
// cover: suspend :: msg.sender == requests[0].requester
// cover: restart :: msg.sender == requests[0].requester && newVersion == 0
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: suspend()
        // skip ABI-mismatched call: restart()
        vm.stopPrank();
    }

    // @cover-intent Test owner withdraws contract balance (Financial & Accounting).
    function test_Withdraw_When_UnrespondedCnt_Zero_7() public {
// assume: unrespondedCnt() == 0
// cover: withdraw :: msg.sender == requests[0].requester && unrespondedCnt == 0
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
        {
        target.deliver(1, bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)), 0, bytes32(uint256(0)));
        }
        vm.stopPrank();
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Test reset of gas price and fees (Financial & Accounting).
    function test_Reset_Parameters_8() public {
// assume: unrespondedCnt() == 0
// cover: reset :: msg.sender == requests[0].requester && unrespondedCnt == 0
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.reset(100000000000, 20000, 15000);
        }
    }

    // @cover-intent Test delivery of a cancelled request (Transactional Consistency).
    function test_Deliver_Cancelled_Request_9() public {
// cover: deliver :: requests[requestId].fee == CANCELLED_FEE_FLAG
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"00000000"), 1000, _arr1);
        }
        {
        target.cancel(1);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)), 0, bytes32(uint256(0)));
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLATION_FEE_view_10() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: CANCELLATION_FEE()
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLED_FEE_FLAG_view_11() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: CANCELLED_FEE_FLAG()
    }

    // @cover-intent Resource & Execution Integrity
    function test_DELIVERED_FEE_FLAG_view_12() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: DELIVERED_FEE_FLAG()
    }

    // @cover-intent Resource & Execution Integrity
    function test_FAIL_FLAG_view_13() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: FAIL_FLAG()
    }

    // @cover-intent Resource & Execution Integrity
    function test_GAS_PRICE_view_14() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: GAS_PRICE()
    }

    // @cover-intent Resource & Execution Integrity
    function test_MIN_FEE_view_15() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: MIN_FEE()
    }

    // @cover-intent Resource & Execution Integrity
    function test_SGX_ADDRESS_view_16() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: SGX_ADDRESS()
    }

    // @cover-intent Resource & Execution Integrity
    function test_SUCCESS_FLAG_view_17() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: SUCCESS_FLAG()
    }

    // @cover-intent Protocol State Machine
    function test_externalCallFlag_view_18() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: externalCallFlag()
    }

    // @cover-intent Protocol State Machine
    function test_killswitch_view_19() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: killswitch()
    }

    // @cover-intent Protocol State Machine
    function test_newVersion_view_20() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: newVersion()
    }

    // @cover-intent Resource & Execution Integrity
    function test_requestCnt_view_21() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: requestCnt()
    }

    // @cover-intent Protocol State Machine
    function test_restart_success_22() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: suspend()
        // skip ABI-mismatched call: restart()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_suspend_success_23() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: suspend()
    }

    // @cover-intent Resource & Execution Integrity
    function test_unrespondedCnt_view_24() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: unrespondedCnt()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_success_25() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent minimal test for cancel
    function test_perfn_cancel_26() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.cancel(1);
        }
    }

    // @cover-intent minimal test for deliver
    function test_perfn_deliver_27() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.deliver(1, bytes32(uint256(1)), 1, bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for requests
    function test_perfn_requests_28() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.requests(1);
        }
    }

    // @cover-intent minimal test for reset
    function test_perfn_reset_29() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.reset(1, 1, 1);
        }
    }

    // @cover-intent minimal test for upgrade
    function test_perfn_upgrade_30() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.upgrade(alice);
        }
    }

}
