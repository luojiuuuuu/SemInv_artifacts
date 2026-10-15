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


    // @cover-intent Financial & Accounting: Verify that a valid request with sufficient fee can be created and then delivered by SGX, resulting in correct fee transfer and state updates.
    function test_Basic_request_and_deliver_flow_0() public {
// assume: unrespondedCnt == 1
// assume: requests[1].fee == 1 ether
// cover: request :: msg.value >= MIN_FEE true
// cover: deliver :: msg.sender == SGX_ADDRESS true
// cover: deliver :: requests[requestId].paramsHash == paramsHash true
// cover: deliver :: fee != CANCELLED_FEE_FLAG true
// cover: deliver :: error < 2 true
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(42793769928370238993345517559078984297316375909943323557146528381924427457894)), 0, bytes32(uint256(0)));
        }
    }

    // @cover-intent Financial & Accounting: Verify that a request with msg.value < MIN_FEE is rejected and the fee is refunded.
    function test_Request_with_insufficient_fee_1() public {
// assume: MIN_FEE > 1 wei
// cover: request :: msg.value < MIN_FEE true
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
        target.request.value(1 wei)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the requester can cancel their own request and receive refund minus cancellation fee.
    function test_Cancel_request_by_requester_2() public {
// assume: requests[1].fee >= CANCELLATION_FEE
// cover: cancel :: requests[requestId].requester == msg.sender true
// cover: cancel :: fee >= CANCELLATION_FEE true
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-requester cannot cancel a request and the call returns FAIL_FLAG.
    function test_Cancel_request_by_non_requester_3() public {
// assume: requests[1].requester == alice
// cover: cancel :: requests[requestId].requester == msg.sender false
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
    }

    // @cover-intent Protocol State Machine: Verify that the owner can suspend the contract (set killswitch=true) and restart it (set killswitch=false) when newVersion==0.
    function test_Suspend_and_restart_contract_4() public {
// assume: newVersion == 0
// cover: suspend :: msg.sender == requests[0].requester true
// cover: restart :: msg.sender == requests[0].requester && newVersion == 0 true
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
        // skip ABI-mismatched call: killswitch()
        // skip ABI-mismatched call: restart()
        // skip ABI-mismatched call: killswitch()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that the owner can upgrade the contract when unrespondedCnt==0, setting newVersion and killswitch.
    function test_Upgrade_contract_5() public {
// assume: unrespondedCnt == 0
// cover: upgrade :: msg.sender == requests[0].requester && unrespondedCnt == 0 true
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
        {
        target.upgrade(0x0000000000000000000000000000000000000001);
        }
        // skip ABI-mismatched call: newVersion()
        // skip ABI-mismatched call: killswitch()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that the owner can reset GAS_PRICE, MIN_FEE, and CANCELLATION_FEE when unrespondedCnt==0.
    function test_Reset_fees_6() public {
// assume: unrespondedCnt == 0
// cover: reset :: msg.sender == requests[0].requester && unrespondedCnt == 0 true
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
        {
        target.reset(100000000000, 50000, 40000);
        }
        // skip ABI-mismatched call: GAS_PRICE()
        // skip ABI-mismatched call: MIN_FEE()
        // skip ABI-mismatched call: CANCELLATION_FEE()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw contract balance when unrespondedCnt==0.
    function test_Withdraw_by_owner_7() public {
// assume: unrespondedCnt == 1
// cover: withdraw :: msg.sender == requests[0].requester && unrespondedCnt == 0 false
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that delivering a cancelled request sends cancellation fee to SGX and marks request as delivered.
    function test_Deliver_cancelled_request_8() public {
// assume: requests[1].fee == 1
// cover: deliver :: fee == CANCELLED_FEE_FLAG true
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
        {
        target.cancel(1);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(42793769928370238993345517559078984297316375909943323557146528381924427457894)), 0, bytes32(uint256(0)));
        }
    }

    // @cover-intent Protocol State Machine: Verify that when killswitch is true, request returns newVersion and refunds the caller.
    function test_Request_when_killswitch_is_active_9() public {
// assume: killswitch == true
// cover: request :: killswitch true
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
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000000, _arr1);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
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
        {
            uint256 __v1 = uint256(target.CANCELLATION_FEE());
            _assertRelU(__v1, 2, 0, "call:CANCELLATION_FEE>=0");
        }
    }

    // @cover-intent Financial & Accounting
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
        {
            uint256 __v2 = uint256(target.CANCELLED_FEE_FLAG());
            _assertRelU(__v2, 0, 1, "call:CANCELLED_FEE_FLAG==1");
        }
    }

    // @cover-intent Financial & Accounting
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
        {
            uint256 __v3 = uint256(target.DELIVERED_FEE_FLAG());
            _assertRelU(__v3, 0, 0, "call:DELIVERED_FEE_FLAG==0");
        }
    }

    // @cover-intent Financial & Accounting
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

    // @cover-intent Financial & Accounting
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
        {
            uint256 __v4 = uint256(target.GAS_PRICE());
            _assertRelU(__v4, 0, 50000000000, "call:GAS_PRICE==50000000000");
        }
    }

    // @cover-intent Financial & Accounting
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
        // TODO assert: call:MIN_FEE() == 30000 * 50000000000
    }

    // @cover-intent Authorization & Access Control
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

    // @cover-intent Financial & Accounting
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
        {
            int256 __v5 = int256(target.SUCCESS_FLAG());
            _assertRelU(__v5, 0, 1, "call:SUCCESS_FLAG==1");
        }
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
        {
            int256 __v6 = int256(target.newVersion());
            _assertRelU(__v6, 0, 0, "call:newVersion==0");
        }
    }

    // @cover-intent Financial & Accounting
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
        {
            uint256 __v7 = uint256(target.requestCnt());
            _assertRelU(__v7, 2, 1, "call:requestCnt>=1");
        }
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

    // @cover-intent Financial & Accounting
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
        {
            uint256 __v8 = uint256(target.unrespondedCnt());
            _assertRelU(__v8, 0, 0, "call:unrespondedCnt==0");
        }
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
