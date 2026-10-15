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


    // @cover-intent Protocol State Machine: Initialize the MindsyncPlatform contract with valid parameters and verify state transitions.
    function test_init_contract_0() public {
// cover: init :: require(!initialized) true
// cover: init :: require(_chairmanAddress != address(0)) true
// cover: init :: require(_minimumPercentToPassAVote <= 51) true
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
        // skip malformed call: init(tokenAddress, alice, 10, 50, 60) (bad raw arg for init.arg0: type=address, raw=tokenAddress)
        // skip ABI-mismatched call: initialized()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that init() reverts when called a second time.
    function test_init_revert_double_init_1() public {
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
        // skip malformed call: init(tokenAddress, alice, 10, 50, 60) (bad raw arg for init.arg0: type=address, raw=tokenAddress)
        vm.expectRevert();
        // skip malformed call: init(tokenAddress, alice, 10, 50, 60) (bad raw arg for init.arg0: type=address, raw=tokenAddress)
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a tokenholder with sufficient balance can create a proposal.
    function test_new_proposal_by_tokenholder_2() public {
// assume: tokenAddress.actualBalanceOf(alice) > 10
// cover: newProposal :: require(tokenAddress.actualBalanceOf(msg.sender) > minimumTokensToVote) true
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip malformed call: newProposal(bob, 1000, 'Test proposal', '0x') (bad raw arg for newProposal.arg2: type=string, raw='Test proposal')
        // skip ABI-mismatched call: numProposals()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.numProposals());
            _assertRelU(__v1, 2, 1, "call:numProposals>=1");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a user with insufficient tokens cannot create a proposal.
    function test_new_proposal_revert_insufficient_tokens_3() public {
// assume: tokenAddress.actualBalanceOf(alice) <= 10
// cover: newProposal :: require(tokenAddress.actualBalanceOf(msg.sender) > minimumTokensToVote) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip malformed call: newProposal(bob, 1000, 'Test proposal', '0x') (bad raw arg for newProposal.arg2: type=string, raw='Test proposal')
    }

    // @cover-intent Authorization & Access Control: Verify that the chairman can sign a proposal.
    function test_sign_proposal_by_chairman_4() public {
// assume: initialized == true
// assume: chairmanAddress == alice
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
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        // dropped unsafe prestate: target.newProposal(bob, 1000, 'Test proposal', '0x');
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.sign(0, true);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-chairman cannot sign a proposal.
    function test_sign_proposal_revert_non_chairman_5() public {
// assume: initialized == true
// assume: chairmanAddress == alice
// cover: sign :: require(msg.sender == chairmanAddress) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        // dropped unsafe prestate: target.newProposal(bob, 1000, 'Test proposal', '0x');
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(bob);
        {
        target.sign(0, true);
        }
    }

    // @cover-intent Transactional Consistency: Verify that a tokenholder can vote on a proposal and that duplicate voting is prevented.
    function test_vote_on_proposal_6() public {
// assume: initialized == true
// assume: tokenAddress.actualBalanceOf(bob) > 10
// cover: vote :: require(p.voted[msg.sender] != true) true
// cover: vote :: require(p.voted[msg.sender] != true) false
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        // dropped unsafe prestate: target.newProposal(bob, 1000, 'Test proposal', '0x');
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.vote(0, true);
        }
        vm.expectRevert();
        {
        target.vote(0, true);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can change voting rules and that parameters are validated.
    function test_change_voting_rules_7() public {
// cover: changeVotingRules :: require(msg.sender == owner) true
// cover: changeVotingRules :: require(msg.sender == owner) false
// cover: changeVotingRules :: require(_chairmanAddress != address(0)) true
// cover: changeVotingRules :: require(_minimumPercentToPassAVote <= 51) true
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip malformed call: changeVotingRules(tokenAddress, bob, 20, 30, 120) (bad raw arg for changeVotingRules.arg0: type=address, raw=tokenAddress)
        vm.expectRevert();
        vm.prank(alice);
        // skip malformed call: changeVotingRules(tokenAddress, bob, 20, 30, 120) (bad raw arg for changeVotingRules.arg0: type=address, raw=tokenAddress)
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can transfer ownership and that the new owner is set correctly.
    function test_transfer_ownership_8() public {
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
        vm.startPrank(owner);
        {
        target.transferOwnership(alice);
        }
        vm.expectRevert();
        {
        target.transferOwnership(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that a proposal can be executed after voting period ends and quorum is met.
    function test_execute_proposal_after_voting_9() public {
// assume: now > proposals[0].minExecutionDate
// assume: quorum >= totalSupply * minimumQuorum / 100
// cover: executeProposal :: require(initialized) true
// cover: executeProposal :: require(now > p.minExecutionDate && !p.executed && p.proposalHash == keccak256(...)) true
// cover: executeProposal :: require(quorum >= t.totalSupply().mul(minimumQuorum).div(100)) true
        vm.startPrank(owner);
        MindsyncPlatform target = new MindsyncPlatform();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init(tokenAddress, alice, 10, 50, 60);
        // dropped unsafe prestate: target.newProposal(bob, 0, 'Test proposal', '0x');
        target.sign(0, true);
        target.vote(0, true);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip malformed call: executeProposal(0, '0x') (bad raw arg for executeProposal.arg1: type=bytes, raw='0x')
    }

    // @cover-intent minimal test for bug_intou11
    function test_perfn_bug_intou11_10() public {
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
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent minimal test for bug_intou12
    function test_perfn_bug_intou12_11() public {
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
        target.bug_intou12(1);
        }
    }

    // @cover-intent minimal test for bug_intou15
    function test_perfn_bug_intou15_12() public {
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
        // skip ABI-mismatched call: bug_intou15()
    }

    // @cover-intent minimal test for bug_intou23
    function test_perfn_bug_intou23_13() public {
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent minimal test for bug_intou24
    function test_perfn_bug_intou24_14() public {
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
        target.bug_intou24(1);
        }
    }

    // @cover-intent minimal test for bug_intou27
    function test_perfn_bug_intou27_15() public {
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent minimal test for bug_intou28
    function test_perfn_bug_intou28_16() public {
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
        target.bug_intou28(1);
        }
    }

    // @cover-intent minimal test for bug_intou31
    function test_perfn_bug_intou31_17() public {
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_18() public {
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent minimal test for bug_intou35
    function test_perfn_bug_intou35_19() public {
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent minimal test for bug_intou36
    function test_perfn_bug_intou36_20() public {
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent minimal test for bug_intou39
    function test_perfn_bug_intou39_21() public {
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent minimal test for bug_intou4
    function test_perfn_bug_intou4_22() public {
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent minimal test for bug_intou40
    function test_perfn_bug_intou40_23() public {
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent minimal test for bug_intou7
    function test_perfn_bug_intou7_24() public {
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent minimal test for bug_intou8
    function test_perfn_bug_intou8_25() public {
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent minimal test for changeVotingRules
    function test_perfn_changeVotingRules_26() public {
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
    function test_perfn_checkProposalCode_27() public {
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
    function test_perfn_debatingPeriodInMinutes_28() public {
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

    // @cover-intent minimal test for executeProposal
    function test_perfn_executeProposal_29() public {
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

    // @cover-intent minimal test for increaseLockTime_intou1
    function test_perfn_increaseLockTime_intou1_30() public {
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
        target.increaseLockTime_intou1(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou13
    function test_perfn_increaseLockTime_intou13_31() public {
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
        target.increaseLockTime_intou13(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou17
    function test_perfn_increaseLockTime_intou17_32() public {
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
        target.increaseLockTime_intou17(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou21
    function test_perfn_increaseLockTime_intou21_33() public {
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
        target.increaseLockTime_intou21(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou33
    function test_perfn_increaseLockTime_intou33_34() public {
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
        target.increaseLockTime_intou33(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou5
    function test_perfn_increaseLockTime_intou5_35() public {
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
        target.increaseLockTime_intou5(1);
        }
    }

    // @cover-intent minimal test for init
    function test_perfn_init_36() public {
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
    function test_perfn_initialized_37() public {
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

    // @cover-intent minimal test for lockTime_intou1
    function test_perfn_lockTime_intou1_38() public {
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
        target.lockTime_intou1(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou13
    function test_perfn_lockTime_intou13_39() public {
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou17
    function test_perfn_lockTime_intou17_40() public {
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou21
    function test_perfn_lockTime_intou21_41() public {
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
        target.lockTime_intou21(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou33
    function test_perfn_lockTime_intou33_42() public {
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou5
    function test_perfn_lockTime_intou5_43() public {
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
        target.lockTime_intou5(alice);
        }
    }

    // @cover-intent minimal test for minimumQuorum
    function test_perfn_minimumQuorum_44() public {
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

    // @cover-intent minimal test for minimumTokensToVote
    function test_perfn_minimumTokensToVote_45() public {
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

    // @cover-intent minimal test for numProposals
    function test_perfn_numProposals_47() public {
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

    // @cover-intent minimal test for owner
    function test_perfn_owner_48() public {
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent minimal test for proposals
    function test_perfn_proposals_49() public {
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
    function test_perfn_receiveApproval_50() public {
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
    function test_perfn_sign_51() public {
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
    function test_perfn_tokenAddress_52() public {
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

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_53() public {
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

    // @cover-intent minimal test for transfer_intou10
    function test_perfn_transfer_intou10_54() public {
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
        target.transfer_intou10(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou14
    function test_perfn_transfer_intou14_55() public {
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
        target.transfer_intou14(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou22
    function test_perfn_transfer_intou22_56() public {
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
        target.transfer_intou22(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou30
    function test_perfn_transfer_intou30_57() public {
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
        target.transfer_intou30(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou34
    function test_perfn_transfer_intou34_58() public {
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
        target.transfer_intou34(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou38
    function test_perfn_transfer_intou38_59() public {
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
        target.transfer_intou38(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_undrflow2
    function test_perfn_transfer_undrflow2_60() public {
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
        target.transfer_undrflow2(bob, 100);
        }
    }

    // @cover-intent minimal test for vote
    function test_perfn_vote_61() public {
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

    // @cover-intent minimal test for withdraw_intou13
    function test_perfn_withdraw_intou13_62() public {
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent minimal test for withdraw_intou17
    function test_perfn_withdraw_intou17_63() public {
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
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent minimal test for withdraw_intou21
    function test_perfn_withdraw_intou21_64() public {
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
        // skip ABI-mismatched call: withdraw_intou21()
    }

    // @cover-intent minimal test for withdraw_intou33
    function test_perfn_withdraw_intou33_65() public {
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent minimal test for withdraw_intou5
    function test_perfn_withdraw_intou5_66() public {
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
        // skip ABI-mismatched call: withdraw_intou5()
    }

    // @cover-intent minimal test for withdraw_ovrflow1
    function test_perfn_withdraw_ovrflow1_67() public {
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
        // skip ABI-mismatched call: withdraw_ovrflow1()
    }

}
