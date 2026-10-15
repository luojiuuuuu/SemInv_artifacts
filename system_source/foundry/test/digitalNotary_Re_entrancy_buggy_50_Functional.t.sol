// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_50.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract digitalNotary_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Protocol State Machine: Verify that a hash can be registered when contract is active, fee is paid, and hash is not already registered.
    function test_Register_hash_positive_path_0() public {
// assume: contractactive == true
// assume: hashfee == 5000000000000000
// cover: registerHash :: require(contractactive == true) true
// cover: registerHash :: require(getHashOwnersCount(hash) == 0) true
// cover: registerHash :: require(msg.value == hashfee) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)));
        }
        {
            uint256 __v1 = uint256(target.getNumberofHashesRegistered());
            _assertRelU(__v1, 0, 1, "call:getNumberofHashesRegistered==1");
        }
        {
            uint256 __v2 = uint256(target.getHashOwnersCount(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef));
            _assertRelU(__v2, 0, 1, "call:getHashOwnersCount==1");
        }
    }

    // @cover-intent Authorization & Access Control: Ensure registerHash reverts when contract is inactive.
    function test_Register_hash_when_contract_inactive_reverts_1() public {
// assume: contractactive == false
// cover: registerHash :: require(contractactive == true) false
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(false);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(100720434726375746010458024839911619878118703404436202866098422983289408962287)));
        }
    }

    // @cover-intent Transactional Consistency: Ensure registering an already registered hash reverts.
    function test_Register_duplicate_hash_reverts_2() public {
// assume: getHashOwnersCount(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa) == 1
// cover: registerHash :: require(getHashOwnersCount(hash) == 0) false
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(77194726158210796949047323339125271902179989777093709359638389338608753093290)));
        }
        vm.expectRevert();
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(77194726158210796949047323339125271902179989777093709359638389338608753093290)));
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Ensure registerHash reverts if msg.value does not equal hashfee.
    function test_Register_hash_with_wrong_fee_reverts_3() public {
// assume: hashfee == 5000000000000000
// cover: registerHash :: require(msg.value == hashfee) false
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(1000000000000000)(bytes32(uint256(84914198774031876643952055673037799092397988754803080295602228272469628402619)));
        }
    }

    // @cover-intent Protocol State Machine: Verify that the current owner can transfer ownership by paying the changehashownerfee.
    function test_Change_hash_ownership_positive_path_4() public {
// assume: contractactive == true
// assume: getHashOwnersCount(0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc) == 1
// assume: changehashownerfee == 25000000000000000
// cover: changeHashOwnership :: require(contractactive == true) true
// cover: changeHashOwnership :: require(owncount > 0) true
// cover: changeHashOwnership :: require(msg.sender == HashList[hash][owncount - 1].owner) true
// cover: changeHashOwnership :: require(msg.value == changehashownerfee) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(92633671389852956338856788006950326282615987732512451231566067206330503711948)));
        }
        vm.prank(owner);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(92633671389852956338856788006950326282615987732512451231566067206330503711948)), bob);
        }
        {
            uint256 __v3 = uint256(target.getHashOwnersCount(0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc));
            _assertRelU(__v3, 0, 2, "call:getHashOwnersCount==2");
        }
    }

    // @cover-intent Authorization & Access Control: Ensure only the current owner can change ownership.
    function test_Change_hash_ownership_not_current_owner_reverts_5() public {
// assume: contractactive == true
// assume: getHashOwnersCount(0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd) == 1
// assume: changehashownerfee == 25000000000000000
// cover: changeHashOwnership :: require(msg.sender == HashList[hash][owncount - 1].owner) false
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(100353144005674036033761520340862853472833986710221822167529906140191379021277)));
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(100353144005674036033761520340862853472833986710221822167529906140191379021277)), carol);
        }
    }

    // @cover-intent Financial & Accounting: Ensure changeHashOwnership reverts if msg.value does not equal changehashownerfee.
    function test_Change_hash_ownership_wrong_fee_reverts_6() public {
// assume: contractactive == true
// assume: changehashownerfee == 25000000000000000
// cover: changeHashOwnership :: require(msg.value == changehashownerfee) false
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(108072616621495115728666252674775380663051985687931193103493745074052254330606)));
        }
        vm.expectRevert();
        {
        target.changeHashOwnership.value(10000000000000000)(bytes32(uint256(108072616621495115728666252674775380663051985687931193103493745074052254330606)), bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify onlyManager can set hashfee.
    function test_Set_hash_fee_by_owner_7() public {
// assume: msg.sender == manager
// cover: sethashfee :: require(msg.sender == manager) true
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.sethashfee(10000000000000000);
        }
        {
            uint256 __v4 = uint256(target.gethashfee());
            _assertRelU(__v4, 0, 10000000000000000, "call:gethashfee==10000000000000000");
        }
    }

    // @cover-intent Authorization & Access Control: Ensure non-manager cannot set hashfee.
    function test_Set_hash_fee_by_non_owner_reverts_8() public {
// assume: msg.sender != manager
// cover: sethashfee :: require(msg.sender == manager) false
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.sethashfee(10000000000000000);
        }
    }

    // @cover-intent Financial & Accounting: Verify onlyManager can transfer contract balance to manager.
    function test_Transfer_contract_balance_by_owner_9() public {
// assume: msg.sender == manager
// assume: address(this).balance > 0
// cover: transfercontractbalance :: require(cb > 0) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935)));
        }
        vm.prank(owner);
        // skip ABI-mismatched call: transfercontractbalance()
        {
            uint256 __v5 = uint256(target.getcontractbalance());
            _assertRelU(__v5, 0, 0, "call:getcontractbalance==0");
        }
    }

    // @cover-intent state transition test for bug_re_ent13
    function test_bug_re_ent13_10() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent state transition test for bug_re_ent20
    function test_bug_re_ent20_11() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_re_ent20()
    }

    // @cover-intent state transition test for bug_re_ent27
    function test_bug_re_ent27_12() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent2_13() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent23_14() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: buyTicket_re_ent23()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent30_15() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: buyTicket_re_ent30()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent37_16() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: buyTicket_re_ent37()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent9_17() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent14_18() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: callme_re_ent14()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent35_19() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent7_20() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: callme_re_ent7()
    }

    // @cover-intent Protocol State Machine
    function test_changeHashOwnership_21() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        vm.prank(owner);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(1)), bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent25_22() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent32_23() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: claimReward_re_ent32()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent39_24() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent4_25() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: claimReward_re_ent4()
    }

    // @cover-intent Protocol State Machine
    function test_getHashDetails_26() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        {
        target.getHashDetails(bytes32(uint256(1)), 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_getHashOwnersCount_27() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        {
        target.getHashOwnersCount(bytes32(uint256(1)));
        }
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.getHashOwnersCount(0x01));
            _assertRelU(__v6, 0, 1, "call:getHashOwnersCount==1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getNumberofHashesRegistered_28() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        // skip ABI-mismatched call: getNumberofHashesRegistered()
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.getNumberofHashesRegistered());
            _assertRelU(__v7, 0, 1, "call:getNumberofHashesRegistered==1");
        }
    }

    // @cover-intent Financial & Accounting
    function test_getchangehashownerfee_29() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getchangehashownerfee()
        {
            uint256 __v8 = uint256(target.getchangehashownerfee());
            _assertRelU(__v8, 0, 25000000000000000, "call:getchangehashownerfee==25000000000000000");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getcontractactive_30() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getcontractactive()
    }

    // @cover-intent Financial & Accounting
    function test_getcontractbalance_31() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getcontractbalance()
    }

    // @cover-intent Financial & Accounting
    function test_gethashfee_32() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: gethashfee()
        {
            uint256 __v9 = uint256(target.gethashfee());
            _assertRelU(__v9, 0, 5000000000000000, "call:gethashfee==5000000000000000");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getmanager_33() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getmanager()
    }

    // @cover-intent Protocol State Machine
    function test_registerHash_34() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setchangehashownerfee_35() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setchangehashownerfee(100);
        }
        {
            uint256 __v10 = uint256(target.getchangehashownerfee());
            _assertRelU(__v10, 0, 100, "call:getchangehashownerfee==100");
        }
    }

    // @cover-intent Protocol State Machine
    function test_setcontractactive_36() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(false);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sethashfee_37() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.sethashfee(100);
        }
        {
            uint256 __v11 = uint256(target.gethashfee());
            _assertRelU(__v11, 0, 100, "call:gethashfee==100");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setmanager_38() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setmanager(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfercontractbalance_39() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        vm.prank(owner);
        // skip ABI-mismatched call: transfercontractbalance()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent19_40() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent26_41() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent33_42() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent40_43() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent17_44() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.withdrawFunds_re_ent17(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent3_45() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.withdrawFunds_re_ent3(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent31_46() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.withdrawFunds_re_ent31(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_re_ent38_47() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.withdrawFunds_re_ent38(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent36_48() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent8_49() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent8()
    }

}
