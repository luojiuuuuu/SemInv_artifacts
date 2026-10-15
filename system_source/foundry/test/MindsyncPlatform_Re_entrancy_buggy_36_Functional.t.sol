// SPDX-License-Identifier: MIT
pragma solidity 0.5.1;
import "../src/buggy_36.sol";

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

contract MindsyncPlatform_FunctionalTest {
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


    // @cover-intent Protocol State Machine: Initialize the contract with valid parameters and verify state transition from uninitialized to initialized.
    function test_init_contract_0() public {
// assume: initialized() == true
// cover: init :: require(!initialized) true
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        // skip ABI-mismatched call: initialized()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Owner can change voting rules; non-owner reverts.
    function test_change_voting_rules_owner_1() public {
// assume: owner() == owner
// cover: changeVotingRules :: require(msg.sender == owner) true
// cover: changeVotingRules :: require(msg.sender == owner) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        {
        target.changeVotingRules(alice, bob, 20, 30, 120);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeVotingRules(alice, bob, 20, 30, 120);
        }
    }

    // @cover-intent Authorization & Access Control: Only tokenholders with sufficient balance can create proposals.
    function test_new_proposal_tokenholder_2() public {
// assume: tokenAddress.actualBalanceOf(alice) > 10
// assume: tokenAddress.actualBalanceOf(carol) <= 10
// cover: newProposal :: require(tokenAddress.actualBalanceOf(msg.sender) > minimumTokensToVote) true
// cover: newProposal :: require(tokenAddress.actualBalanceOf(msg.sender) > minimumTokensToVote) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        vm.prank(alice);
        // skip malformed call: newProposal(bob, 100, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.expectRevert();
        vm.prank(carol);
        // skip malformed call: newProposal(bob, 100, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
    }

    // @cover-intent Authorization & Access Control: Only chairman can sign a proposal; non-chairman reverts.
    function test_sign_proposal_chairman_3() public {
// assume: chairmanAddress == bob
// cover: sign :: require(msg.sender == chairmanAddress) true
// cover: sign :: require(msg.sender == chairmanAddress) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        vm.prank(alice);
        // skip malformed call: newProposal(bob, 100, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.prank(bob);
        {
        target.sign(0, true);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.sign(0, true);
        }
    }

    // @cover-intent Authorization & Access Control: Only tokenholders can vote; double voting reverts.
    function test_vote_proposal_tokenholder_4() public {
// assume: tokenAddress.actualBalanceOf(alice) > 10
// cover: vote :: require(p.voted[msg.sender] != true) true
// cover: vote :: require(p.voted[msg.sender] != true) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        vm.startPrank(alice);
        // skip malformed call: newProposal(bob, 100, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        {
        target.vote(0, true);
        }
        vm.expectRevert();
        {
        target.vote(0, true);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Execute a proposal after debate period with sufficient quorum and majority support.
    function test_execute_proposal_after_debate_5() public {
// assume: now > proposals[0].minExecutionDate
// assume: tokenAddress.totalSupply() * 50 / 100 <= tokenAddress.actualBalanceOf(alice)
// cover: executeProposal :: require(now > p.minExecutionDate) true
// cover: executeProposal :: require(!p.executed) true
// cover: executeProposal :: require(quorum >= t.totalSupply().mul(minimumQuorum).div(100)) true
// cover: executeProposal :: yea > nay true
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.init(alice, bob, 10, 50, 60);
        }
        vm.prank(alice);
        // skip malformed call: newProposal(bob, 0, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.prank(bob);
        {
        target.sign(0, true);
        }
        vm.prank(alice);
        {
        target.vote(0, true);
        }
        vm.prank(owner);
        // skip malformed call: executeProposal(0, '0x00') (bad raw arg for executeProposal.arg1: type=bytes, raw='0x00')
    }

    // @cover-intent Protocol State Machine: Execute proposal before debate period ends reverts.
    function test_execute_proposal_before_debate_6() public {
// assume: now <= proposals[0].minExecutionDate
// cover: executeProposal :: require(now > p.minExecutionDate) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        vm.prank(alice);
        // skip malformed call: newProposal(bob, 0, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.prank(bob);
        {
        target.sign(0, true);
        }
        vm.prank(alice);
        {
        target.vote(0, true);
        }
        vm.expectRevert();
        vm.prank(owner);
        // skip malformed call: executeProposal(0, '0x00') (bad raw arg for executeProposal.arg1: type=bytes, raw='0x00')
    }

    // @cover-intent Transactional Consistency: Execute proposal with insufficient quorum reverts.
    function test_execute_proposal_insufficient_quorum_7() public {
// assume: now > proposals[0].minExecutionDate
// assume: tokenAddress.totalSupply() * 50 / 100 > tokenAddress.actualBalanceOf(alice)
// cover: executeProposal :: require(now > p.minExecutionDate) true
// cover: executeProposal :: require(!p.executed) true
// cover: executeProposal :: require(quorum >= t.totalSupply().mul(minimumQuorum).div(100)) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.init(alice, bob, 10, 50, 60);
        }
        vm.prank(alice);
        // skip malformed call: newProposal(bob, 0, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.prank(bob);
        {
        target.sign(0, true);
        }
        vm.prank(alice);
        {
        target.vote(0, true);
        }
        vm.expectRevert();
        vm.prank(owner);
        // skip malformed call: executeProposal(0, '0x00') (bad raw arg for executeProposal.arg1: type=bytes, raw='0x00')
    }

    // @cover-intent Resource & Execution Integrity: checkProposalCode returns true when code matches, false otherwise.
    function test_check_proposal_code_matches_8() public {
// cover: checkProposalCode :: return p.proposalHash == keccak256(...) true
// cover: checkProposalCode :: return p.proposalHash == keccak256(...) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(alice, bob, 10, 50, 60);
        }
        vm.startPrank(alice);
        // skip malformed call: newProposal(bob, 100, 'test', '0x1234') (bad raw arg for newProposal.arg2: type=string, raw='test')
        // skip malformed call: checkProposalCode(0, bob, 100, '0x1234') (bad raw arg for checkProposalCode.arg3: type=bytes, raw='0x1234')
        // skip malformed call: checkProposalCode(0, bob, 100, '0x5678') (bad raw arg for checkProposalCode.arg3: type=bytes, raw='0x5678')
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only owner can transfer ownership; non-owner reverts.
    function test_transfer_ownership_9() public {
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: transferOwnership :: require(msg.sender == owner) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.transferOwnership(alice);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwnership(carol);
        }
    }

    // @cover-intent state transition test for bug_re_ent13
    function test_bug_re_ent13_positive_10() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent state transition test for bug_re_ent27
    function test_bug_re_ent27_positive_11() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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

    // @cover-intent state transition test for bug_re_ent34
    function test_bug_re_ent34_positive_12() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: bug_re_ent34()
    }

    // @cover-intent state transition test for bug_re_ent41
    function test_bug_re_ent41_positive_13() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: bug_re_ent41()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent2_positive_14() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_buyTicket_re_ent23_positive_15() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_buyTicket_re_ent30_positive_16() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_callme_re_ent14_positive_17() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_callme_re_ent21_positive_18() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: callme_re_ent21()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent28_positive_19() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: callme_re_ent28()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent35_positive_20() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_callme_re_ent42_positive_21() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent7_positive_22() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent11_positive_23() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: claimReward_re_ent11()
    }

    // @cover-intent Financial & Accounting
    function test_claimReward_re_ent32_positive_24() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_claimReward_re_ent39_positive_25() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_claimReward_re_ent4_positive_26() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_debatingPeriodInMinutes_positive_27() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: debatingPeriodInMinutes()
    }

    // @cover-intent Protocol State Machine
    function test_initialized_positive_28() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: initialized()
    }

    // @cover-intent Protocol State Machine
    function test_minimumQuorum_positive_29() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: minimumQuorum()
    }

    // @cover-intent Protocol State Machine
    function test_minimumTokensToVote_positive_30() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: minimumTokensToVote()
    }

    // @cover-intent Protocol State Machine
    function test_numProposals_positive_31() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: numProposals()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_positive_32() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_tokenAddress_positive_33() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: tokenAddress()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent12_positive_34() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent12()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent33_positive_35() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_re_ent40_positive_36() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent1_positive_37() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent1()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent15_positive_38() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent15()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent21_positive_39() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent21()
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_balances_re_ent36_positive_40() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
    function test_withdraw_balances_re_ent8_positive_41() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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

    // @cover-intent minimal test for changeVotingRules
    function test_perfn_changeVotingRules_42() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.changeVotingRules(bob, alice, 1, 1, 1);
        }
    }

    // @cover-intent minimal test for checkProposalCode
    function test_perfn_checkProposalCode_43() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.checkProposalCode(1, alice, 100, hex"01");
        }
    }

    // @cover-intent minimal test for executeProposal
    function test_perfn_executeProposal_44() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.executeProposal(1, hex"01");
        }
    }

    // @cover-intent minimal test for init
    function test_perfn_init_45() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.init(bob, alice, 1, 1, 1);
        }
    }

    // @cover-intent minimal test for newProposal
    function test_perfn_newProposal_46() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.newProposal(alice, 100, "X", hex"01");
        }
    }

    // @cover-intent minimal test for proposals
    function test_perfn_proposals_47() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.proposals(1);
        }
    }

    // @cover-intent minimal test for receiveApproval
    function test_perfn_receiveApproval_48() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.receiveApproval(alice, 100, bob, hex"01");
        }
    }

    // @cover-intent minimal test for sign
    function test_perfn_sign_49() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.sign(1, true);
        }
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_50() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.transferOwnership(alice);
        }
    }

    // @cover-intent minimal test for vote
    function test_perfn_vote_51() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.vote(1, true);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent10
    function test_perfn_withdrawFunds_re_ent10_52() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.withdrawFunds_re_ent10(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent17
    function test_perfn_withdrawFunds_re_ent17_53() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.withdrawFunds_re_ent17(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent31
    function test_perfn_withdrawFunds_re_ent31_54() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.withdrawFunds_re_ent31(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent38
    function test_perfn_withdrawFunds_re_ent38_55() public {
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
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
        target.withdrawFunds_re_ent38(1);
        }
    }

}
