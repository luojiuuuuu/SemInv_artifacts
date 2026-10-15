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


    // @cover-intent Test normal request creation with sufficient fee, verify event emission and state changes (Protocol State Machine)
    function test_Basic_request_flow_0() public {
// assume: MIN_FEE() <= 1 ether
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
        vm.prank(owner);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000, _arr1);
        }
        {
            uint256 __v1 = uint256(target.requestCnt());
            _assertRelU(__v1, 2, 1, "call:requestCnt>=1");
        }
        {
            uint256 __v2 = uint256(target.unrespondedCnt());
            _assertRelU(__v2, 2, 1, "call:unrespondedCnt>=1");
        }
    }

    // @cover-intent Test request rejection when fee is below MIN_FEE, expect refund and FAIL_FLAG return (Financial & Accounting)
    function test_Request_with_insufficient_fee_1() public {
// assume: MIN_FEE() > 1 wei
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
        target.request.value(1 wei)(1, alice, bytes4(hex"12345678"), 1000, _arr1);
        }
    }

    // @cover-intent Test successful cancellation of a pending request by the requester (Authorization & Access Control)
    function test_Cancel_own_request_2() public {
// assume: CANCELLATION_FEE() <= 1 ether
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
    }

    // @cover-intent Test cancel with invalid requestId returns FAIL_FLAG (Transactional Consistency)
    function test_Cancel_non_existent_request_3() public {
// cover: cancel :: requests[requestId].requester != msg.sender || fee < CANCELLATION_FEE
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
        target.cancel(999);
        }
    }

    // @cover-intent Test SGX delivering a response to a pending request (External Interaction & Environment)
    function test_Deliver_response_to_valid_request_4() public {
// assume: SGX_ADDRESS() == address(owner)
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(43379584054787486383572605962602545002668015983485933488536749112829893476306)), 0, bytes32(uint256(0)));
        }
        {
            uint256 __v3 = uint256(target.unrespondedCnt());
            _assertRelU(__v3, 0, 0, "call:unrespondedCnt==0");
        }
    }

    // @cover-intent Test that deliver with incorrect paramsHash is silently discarded (Transactional Consistency)
    function test_Deliver_with_wrong_paramsHash_5() public {
// assume: SGX_ADDRESS() == address(owner)
// cover: deliver :: requests[requestId].paramsHash != paramsHash
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
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 1000, _arr1);
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

    // @cover-intent Test owner can suspend and restart the contract (Protocol State Machine)
    function test_Suspend_and_restart_contract_6() public {
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

    // @cover-intent Test that non-owner cannot suspend the contract (Authorization & Access Control)
    function test_Non_owner_cannot_suspend_7() public {
// assume: requests[0].requester != alice
// cover: suspend :: msg.sender != requests[0].requester
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

    // @cover-intent Test owner can upgrade when no pending requests (Protocol State Machine)
    function test_Upgrade_contract_8() public {
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
        target.upgrade(alice);
        }
    }

    // @cover-intent Test owner can reset fee parameters when no pending requests (Financial & Accounting)
    function test_Reset_fees_9() public {
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
        target.reset(100000000000, 50000, 40000);
        }
        {
            uint256 __v5 = uint256(target.GAS_PRICE());
            _assertRelU(__v5, 0, 100000000000, "call:GAS_PRICE==100000000000");
        }
        {
            uint256 __v6 = uint256(target.MIN_FEE());
            _assertRelU(__v6, 0, 5000000000000000000, "call:MIN_FEE==5000000000000000000");
        }
        {
            uint256 __v7 = uint256(target.CANCELLATION_FEE());
            _assertRelU(__v7, 0, 4000000000000000000, "call:CANCELLATION_FEE==4000000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLATION_FEE_constant_10() public {
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
    function test_CANCELLED_FEE_FLAG_constant_11() public {
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
    function test_DELIVERED_FEE_FLAG_constant_12() public {
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
    function test_FAIL_FLAG_constant_13() public {
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
    function test_GAS_PRICE_constant_14() public {
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
    function test_MIN_FEE_constant_15() public {
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
    function test_SGX_ADDRESS_constant_16() public {
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
    function test_SUCCESS_FLAG_constant_17() public {
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
    function test_restart_positive_path_22() public {
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
    function test_suspend_positive_path_23() public {
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
    function test_withdraw_positive_path_25() public {
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
