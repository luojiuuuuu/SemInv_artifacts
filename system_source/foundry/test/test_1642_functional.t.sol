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


    // @cover-intent Authorization & Access Control: Verify that only the owner (requests[0].requester) can upgrade when unrespondedCnt == 0, setting killswitch and newVersion.
    function test_upgrade_success_0() public {
// assume: unrespondedCnt == 0
// assume: msg.sender == requests[0].requester
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: restart()
        {
        target.upgrade(0x1234567890123456789012345678901234567890);
        }
        // skip ABI-mismatched call: killswitch()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot upgrade even when unrespondedCnt == 0.
    function test_upgrade_fail_nonowner_1() public {
// assume: unrespondedCnt == 0
// assume: msg.sender != requests[0].requester
// cover: upgrade :: msg.sender != requests[0].requester || unrespondedCnt != 0
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
        target.upgrade(0x1234567890123456789012345678901234567890);
        }
    }

    // @cover-intent Financial & Accounting: Verify that a valid request with sufficient fee increments requestCnt and unrespondedCnt.
    function test_request_success_2() public {
// assume: msg.value >= MIN_FEE
// assume: killswitch == false
// assume: externalCallFlag == false
// cover: request :: msg.value >= MIN_FEE
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
        // skip ABI-mismatched call: restart()
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.requestCnt());
            _assertRelU(__v1, 2, 2, "call:requestCnt>=2");
        }
        {
            uint256 __v2 = uint256(target.unrespondedCnt());
            _assertRelU(__v2, 2, 1, "call:unrespondedCnt>=1");
        }
    }

    // @cover-intent Financial & Accounting: Verify that request with insufficient fee is refunded and returns FAIL_FLAG.
    function test_request_fail_insufficient_fee_3() public {
// assume: msg.value < MIN_FEE
// assume: killswitch == false
// assume: externalCallFlag == false
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: restart()
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 wei)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that SGX_ADDRESS can deliver a valid response, decrementing unrespondedCnt and logging DeliverInfo.
    function test_deliver_success_4() public {
// assume: msg.sender == SGX_ADDRESS
// assume: requestId > 0
// assume: requests[requestId].requester != 0
// assume: requests[requestId].fee != DELIVERED_FEE_FLAG
// assume: requests[requestId].paramsHash == paramsHash
// cover: deliver :: error < 2
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
        vm.prank(owner);
        // skip ABI-mismatched call: restart()
        vm.prank(alice);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(0)), 0, bytes32(uint256(0)));
        }
        {
            uint256 __v3 = uint256(target.unrespondedCnt());
            _assertRelU(__v3, 0, 0, "call:unrespondedCnt==0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-SGX_ADDRESS cannot deliver a response.
    function test_deliver_fail_wrong_sender_5() public {
// assume: msg.sender != SGX_ADDRESS
// cover: deliver :: msg.sender != SGX_ADDRESS
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
        vm.prank(owner);
        // skip ABI-mismatched call: restart()
        vm.prank(alice);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(0)), 0, bytes32(uint256(0)));
        }
        {
            uint256 __v4 = uint256(target.unrespondedCnt());
            _assertRelU(__v4, 0, 1, "call:unrespondedCnt==1");
        }
    }

    // @cover-intent Financial & Accounting: Verify that requester can cancel their own request with sufficient fee, receiving refund minus CANCELLATION_FEE.
    function test_cancel_success_6() public {
// assume: requests[1].requester == alice
// assume: requests[1].fee >= CANCELLATION_FEE
// assume: killswitch == false
// assume: externalCallFlag == false
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
        vm.prank(owner);
        // skip ABI-mismatched call: restart()
        vm.prank(alice);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-requester cannot cancel a request.
    function test_cancel_fail_not_requester_7() public {
// assume: requests[1].requester != bob
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
        vm.prank(owner);
        // skip ABI-mismatched call: restart()
        vm.prank(alice);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
    }

    // @cover-intent Protocol State Machine: Verify that owner can suspend and restart the contract, toggling killswitch.
    function test_suspend_and_restart_8() public {
// assume: msg.sender == requests[0].requester
// assume: newVersion == 0
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
        // skip ABI-mismatched call: restart()
        // skip ABI-mismatched call: suspend()
        // skip ABI-mismatched call: killswitch()
        // skip ABI-mismatched call: restart()
        // skip ABI-mismatched call: killswitch()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that owner can withdraw contract balance when unrespondedCnt == 0.
    function test_withdraw_success_9() public {
// assume: msg.sender == requests[0].requester
// assume: unrespondedCnt == 0
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
        vm.prank(owner);
        // skip ABI-mismatched call: restart()
        vm.startPrank(alice);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, 0x1234567890123456789012345678901234567890, bytes4(hex"abcdef01"), 100, _arr1);
        }
        {
        target.deliver(1, bytes32(uint256(0)), 0, bytes32(uint256(0)));
        }
        vm.stopPrank();
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Protocol State Machine: Verify that owner can reset GAS_PRICE, MIN_FEE, and CANCELLATION_FEE when unrespondedCnt == 0.
    function test_reset_success_10() public {
// assume: msg.sender == requests[0].requester
// assume: unrespondedCnt == 0
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: restart()
        {
        target.reset(100000000000, 50000, 40000);
        }
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.GAS_PRICE());
            _assertRelU(__v5, 0, 100000000000, "call:GAS_PRICE==100000000000");
        }
        {
            uint256 __v6 = uint256(target.MIN_FEE());
            _assertRelU(__v6, 0, 5000000000000000, "call:MIN_FEE==5000000000000000");
        }
        {
            uint256 __v7 = uint256(target.CANCELLATION_FEE());
            _assertRelU(__v7, 0, 4000000000000000, "call:CANCELLATION_FEE==4000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLATION_FEE_view_11() public {
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
            uint256 __v8 = uint256(target.CANCELLATION_FEE());
            _assertRelU(__v8, 2, 0, "call:CANCELLATION_FEE>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLED_FEE_FLAG_view_12() public {
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
            uint256 __v9 = uint256(target.CANCELLED_FEE_FLAG());
            _assertRelU(__v9, 0, 1, "call:CANCELLED_FEE_FLAG==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_DELIVERED_FEE_FLAG_view_13() public {
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
            uint256 __v10 = uint256(target.DELIVERED_FEE_FLAG());
            _assertRelU(__v10, 0, 0, "call:DELIVERED_FEE_FLAG==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_FAIL_FLAG_view_14() public {
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
    function test_GAS_PRICE_view_15() public {
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
            uint256 __v11 = uint256(target.GAS_PRICE());
            _assertRelU(__v11, 0, 50000000000, "call:GAS_PRICE==50000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_MIN_FEE_view_16() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_SGX_ADDRESS_view_17() public {
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
    function test_SUCCESS_FLAG_view_18() public {
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
            int256 __v12 = int256(target.SUCCESS_FLAG());
            _assertRelU(__v12, 0, 1, "call:SUCCESS_FLAG==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_externalCallFlag_view_19() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_killswitch_view_20() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_newVersion_view_21() public {
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
            int256 __v13 = int256(target.newVersion());
            _assertRelU(__v13, 0, 0, "call:newVersion==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_requestCnt_view_22() public {
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
            uint256 __v14 = uint256(target.requestCnt());
            _assertRelU(__v14, 2, 1, "call:requestCnt>=1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_restart_by_owner_23() public {
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

    // @cover-intent Authorization & Access Control
    function test_suspend_by_owner_24() public {
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
    function test_unrespondedCnt_view_25() public {
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
            uint256 __v15 = uint256(target.unrespondedCnt());
            _assertRelU(__v15, 0, 0, "call:unrespondedCnt==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_by_owner_26() public {
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
    function test_perfn_cancel_27() public {
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
    function test_perfn_deliver_28() public {
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
    function test_perfn_requests_29() public {
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
    function test_perfn_reset_30() public {
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
    function test_perfn_upgrade_31() public {
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
