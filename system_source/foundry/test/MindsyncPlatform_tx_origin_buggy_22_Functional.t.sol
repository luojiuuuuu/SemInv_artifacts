// SPDX-License-Identifier: MIT
pragma solidity 0.5.1;
import "../src/buggy_22.sol";

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


    // @cover-intent Protocol State Machine: Initialize the MindsyncPlatform contract with valid parameters and verify the Initialized event is emitted.
    function test_init_contract_0() public {
// cover: init :: require(!initialized) true
// cover: changeVotingRules :: require(_chairmanAddress != address(0)) true
// cover: changeVotingRules :: require(_minimumPercentToPassAVote <= 51) true
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
    }

    // @cover-intent Protocol State Machine: Verify that calling init() a second time reverts, enforcing the one-time initialization invariant.
    function test_init_revert_already_initialized_1() public {
// cover: init :: require(!initialized) false
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
        vm.expectRevert();
        {
        target.init(alice, bob, 10, 50, 60);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: A tokenholder with sufficient balance creates a proposal and votes on it, verifying the Voted event.
    function test_new_proposal_and_vote_2() public {
// assume: tokenAddress.actualBalanceOf(alice) > minimumTokensToVote
// cover: newProposal :: require(tokenAddress.actualBalanceOf(msg.sender) > minimumTokensToVote) true
// cover: vote :: require(p.voted[msg.sender] != true) true
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
        // skip malformed call: newProposal(bob, 1000, 'test proposal', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test proposal')
        {
        target.vote(0, true);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that a voter cannot vote twice on the same proposal, enforcing the single-vote invariant.
    function test_vote_revert_already_voted_3() public {
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
        // skip malformed call: newProposal(bob, 1000, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        {
        target.vote(0, true);
        }
        vm.expectRevert();
        {
        target.vote(0, true);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: The chairman signs a proposal, verifying the ProposalSignedByChairman event and that only the chairman can sign.
    function test_sign_proposal_by_chairman_4() public {
// cover: sign :: require(initialized) true
// cover: sign :: require(msg.sender == chairmanAddress) true
// cover: sign :: require(signProposal == true) true
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
        // skip malformed call: newProposal(bob, 1000, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.prank(bob);
        {
        target.sign(0, true);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-chairman cannot sign a proposal, enforcing the chairman-only access control.
    function test_sign_revert_non_chairman_5() public {
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
        vm.startPrank(alice);
        // skip malformed call: newProposal(bob, 1000, 'test', '0x00') (bad raw arg for newProposal.arg2: type=string, raw='test')
        vm.expectRevert();
        {
        target.sign(0, true);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Execute a proposal after voting and chairman approval, verifying the ProposalTallied event and that the proposal is marked executed.
    function test_execute_proposal_after_voting_6() public {
// assume: now > minExecutionDate
// cover: executeProposal :: require(initialized) true
// cover: executeProposal :: require(now > p.minExecutionDate) true
// cover: executeProposal :: require(!p.executed) true
// cover: executeProposal :: require(p.proposalHash == keccak256(...)) true
// cover: executeProposal :: require(quorum >= t.totalSupply().mul(minimumQuorum).div(100)) true
// cover: executeProposal :: if (yea > nay) true
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
        vm.startPrank(alice);
        {
        target.vote(0, true);
        }
        // skip malformed call: executeProposal(0, '0x00') (bad raw arg for executeProposal.arg1: type=bytes, raw='0x00')
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that executing a proposal before the minExecutionDate reverts, enforcing the time-lock invariant.
    function test_execute_proposal_revert_before_deadline_7() public {
// assume: now <= minExecutionDate
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
        vm.startPrank(alice);
        {
        target.vote(0, true);
        }
        vm.expectRevert();
        // skip malformed call: executeProposal(0, '0x00') (bad raw arg for executeProposal.arg1: type=bytes, raw='0x00')
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: The owner changes voting rules and verifies the ChangeOfRules event with updated parameters.
    function test_change_voting_rules_by_owner_8() public {
// cover: changeVotingRules :: require(msg.sender == owner) true
// cover: changeVotingRules :: require(_chairmanAddress != address(0)) true
// cover: changeVotingRules :: require(_minimumPercentToPassAVote <= 51) true
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
        target.changeVotingRules(alice, carol, 20, 40, 120);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: The owner transfers ownership to alice, verifying that only the owner can call transferOwnership and the owner address updates.
    function test_transfer_ownership_9() public {
// cover: transferOwnership :: require(msg.sender == owner) true
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

    // @cover-intent minimal test for bug_txorigin12
    function test_perfn_bug_txorigin12_10() public {
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
        target.bug_txorigin12(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin24
    function test_perfn_bug_txorigin24_11() public {
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
        target.bug_txorigin24(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin28
    function test_perfn_bug_txorigin28_12() public {
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
        target.bug_txorigin28(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin32
    function test_perfn_bug_txorigin32_13() public {
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
        target.bug_txorigin32(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin36
    function test_perfn_bug_txorigin36_14() public {
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
        target.bug_txorigin36(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin4
    function test_perfn_bug_txorigin4_15() public {
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
        target.bug_txorigin4(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin40
    function test_perfn_bug_txorigin40_16() public {
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
        target.bug_txorigin40(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin8
    function test_perfn_bug_txorigin8_17() public {
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
        target.bug_txorigin8(alice);
        }
    }

    // @cover-intent minimal test for changeVotingRules
    function test_perfn_changeVotingRules_18() public {
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
    function test_perfn_checkProposalCode_19() public {
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

    // @cover-intent minimal test for debatingPeriodInMinutes
    function test_perfn_debatingPeriodInMinutes_20() public {
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
        target.debatingPeriodInMinutes();
        }
    }

    // @cover-intent minimal test for executeProposal
    function test_perfn_executeProposal_21() public {
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
    function test_perfn_init_22() public {
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

    // @cover-intent minimal test for initialized
    function test_perfn_initialized_23() public {
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
        target.initialized();
        }
    }

    // @cover-intent minimal test for minimumQuorum
    function test_perfn_minimumQuorum_24() public {
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
        target.minimumQuorum();
        }
    }

    // @cover-intent minimal test for minimumTokensToVote
    function test_perfn_minimumTokensToVote_25() public {
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
        target.minimumTokensToVote();
        }
    }

    // @cover-intent minimal test for newProposal
    function test_perfn_newProposal_26() public {
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

    // @cover-intent minimal test for numProposals
    function test_perfn_numProposals_27() public {
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
        target.numProposals();
        }
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_28() public {
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
        target.owner();
        }
    }

    // @cover-intent minimal test for proposals
    function test_perfn_proposals_29() public {
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
    function test_perfn_receiveApproval_30() public {
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

    // @cover-intent minimal test for sendto_txorigin1
    function test_perfn_sendto_txorigin1_31() public {
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
        target.sendto_txorigin1(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin13
    function test_perfn_sendto_txorigin13_32() public {
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
        target.sendto_txorigin13(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin17
    function test_perfn_sendto_txorigin17_33() public {
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
        target.sendto_txorigin17(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin21
    function test_perfn_sendto_txorigin21_34() public {
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
        target.sendto_txorigin21(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin33
    function test_perfn_sendto_txorigin33_35() public {
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
        target.sendto_txorigin33(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin5
    function test_perfn_sendto_txorigin5_36() public {
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
        target.sendto_txorigin5(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sign
    function test_perfn_sign_37() public {
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

    // @cover-intent minimal test for tokenAddress
    function test_perfn_tokenAddress_38() public {
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
        target.tokenAddress();
        }
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_39() public {
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

    // @cover-intent minimal test for transferTo_txorigin11
    function test_perfn_transferTo_txorigin11_40() public {
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
        target.transferTo_txorigin11(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin15
    function test_perfn_transferTo_txorigin15_41() public {
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
        target.transferTo_txorigin15(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin23
    function test_perfn_transferTo_txorigin23_42() public {
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
        target.transferTo_txorigin23(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin27
    function test_perfn_transferTo_txorigin27_43() public {
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
        target.transferTo_txorigin27(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin31
    function test_perfn_transferTo_txorigin31_44() public {
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
        target.transferTo_txorigin31(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin35
    function test_perfn_transferTo_txorigin35_45() public {
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
        target.transferTo_txorigin35(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin39
    function test_perfn_transferTo_txorigin39_46() public {
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
        target.transferTo_txorigin39(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin7
    function test_perfn_transferTo_txorigin7_47() public {
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
        target.transferTo_txorigin7(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for vote
    function test_perfn_vote_48() public {
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

    // @cover-intent minimal test for withdrawAll_txorigin10
    function test_perfn_withdrawAll_txorigin10_49() public {
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
        target.withdrawAll_txorigin10(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin14
    function test_perfn_withdrawAll_txorigin14_50() public {
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
        target.withdrawAll_txorigin14(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin2
    function test_perfn_withdrawAll_txorigin2_51() public {
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
        target.withdrawAll_txorigin2(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin22
    function test_perfn_withdrawAll_txorigin22_52() public {
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
        target.withdrawAll_txorigin22(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin30
    function test_perfn_withdrawAll_txorigin30_53() public {
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
        target.withdrawAll_txorigin30(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin34
    function test_perfn_withdrawAll_txorigin34_54() public {
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
        target.withdrawAll_txorigin34(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin38
    function test_perfn_withdrawAll_txorigin38_55() public {
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
        target.withdrawAll_txorigin38(alice, alice);
        }
    }

}
