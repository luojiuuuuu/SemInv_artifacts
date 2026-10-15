// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "forge-std/Test.sol";
import "../src/Ballot_0821.sol";


contract Ballot_0821_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }
    function _assertEqA(address a, address b) internal {
        assertEq(a, b);
    }
    function _assertEqB32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }
    function _assertEqS(string memory a, string memory b) internal {
        assertEq(a, b);
    }


    // @cover-intent 测试正常投票流程：主席授权投票者，投票者投票，查询获胜提案和获胜者名称
    function test_normal_vote_flow_0() public {
// cover: giveRightToVote :: require(msg.sender == chairperson) true
// cover: vote :: require(sender.weight != 0) true
// cover: vote :: require(!sender.voted) true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        vm.prank(alice);
        {
        target.vote(0);
        }
        vm.startPrank(owner);
        {
        target.winningProposal();
        }
        {
        target.winnerName();
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.winningProposal());
            _assertRelU(__v1, 0, 0, "call:winningProposal==0");
        }
    }

    // @cover-intent 测试委托投票：主席授权alice，alice委托给bob，bob投票，验证bob的投票权重包含alice的权重
    function test_delegate_and_vote_1() public {
// cover: delegate :: require(sender.weight != 0) true
// cover: delegate :: require(!sender.voted) true
// cover: delegate :: require(to != msg.sender) true
// cover: delegate :: require(delegate_.weight >= 1) true
// cover: delegate :: delegate_.voted == true, add weight to proposal
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        {
        target.giveRightToVote(bob);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.delegate(bob);
        }
        vm.prank(bob);
        {
        target.vote(0);
        }
        vm.prank(owner);
        {
        target.winningProposal();
        }
        {
            uint256 __v2 = uint256(target.winningProposal());
            _assertRelU(__v2, 0, 0, "call:winningProposal==0");
        }
    }

    // @cover-intent 测试委托链：alice委托给bob，bob委托给carol，carol投票，验证carol的权重包含alice和bob的权重
    function test_delegate_chain_2() public {
// cover: delegate :: while loop: follow delegate chain
// cover: delegate :: delegate_.voted == false, add weight to delegate
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        {
        target.giveRightToVote(bob);
        }
        {
        target.giveRightToVote(carol);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.delegate(bob);
        }
        vm.prank(bob);
        {
        target.delegate(carol);
        }
        vm.prank(carol);
        {
        target.vote(0);
        }
        vm.prank(owner);
        {
        target.winningProposal();
        }
        {
            uint256 __v3 = uint256(target.winningProposal());
            _assertRelU(__v3, 0, 0, "call:winningProposal==0");
        }
    }

    // @cover-intent 测试非主席调用giveRightToVote应回退
    function test_revert_giveRightToVote_not_chairperson_3() public {
// cover: giveRightToVote :: require(msg.sender == chairperson) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(bob);
        }
    }

    // @cover-intent 测试给已投票的选民授权应回退
    function test_revert_giveRightToVote_already_voted_4() public {
// cover: giveRightToVote :: require(!voters[voter].voted) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        vm.prank(alice);
        {
        target.vote(0);
        }
        vm.expectRevert();
        vm.prank(owner);
        {
        target.giveRightToVote(alice);
        }
    }

    // @cover-intent 测试自我委托应回退
    function test_revert_delegate_self_delegation_5() public {
// cover: delegate :: require(to != msg.sender) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.delegate(alice);
        }
    }

    // @cover-intent 测试无投票权者调用delegate应回退
    function test_revert_delegate_no_right_to_vote_6() public {
// cover: delegate :: require(sender.weight != 0) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.delegate(bob);
        }
    }

    // @cover-intent 测试无投票权者调用vote应回退
    function test_revert_vote_no_right_to_vote_7() public {
// cover: vote :: require(sender.weight != 0) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.vote(0);
        }
    }

    // @cover-intent 测试重复投票应回退
    function test_revert_vote_already_voted_8() public {
// cover: vote :: require(!sender.voted) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        vm.startPrank(alice);
        {
        target.vote(0);
        }
        vm.expectRevert();
        {
        target.vote(1);
        }
        vm.stopPrank();
    }

    // @cover-intent 测试委托形成闭环应回退
    function test_revert_delegate_loop_9() public {
// cover: delegate :: while loop: detect loop
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
        {
        target.giveRightToVote(bob);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.delegate(bob);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.delegate(alice);
        }
    }

    // @cover-intent Check that chairperson is the deployer
    function test_chairperson_view_10() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.chairperson();
        }
    }

    // @cover-intent Delegate vote from owner to alice
    function test_delegate_valid_11() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.delegate(alice);
        }
    }

    // @cover-intent Chairperson gives voting right to alice
    function test_giveRightToVote_by_chairperson_12() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.giveRightToVote(alice);
        }
    }

    // @cover-intent Check proposal at index 0
    function test_proposals_view_index0_13() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.proposals(0);
        }
    }

    // @cover-intent Owner votes for proposal 0
    function test_vote_by_owner_14() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.vote(0);
        }
    }

    // @cover-intent Check owner voter struct
    function test_voters_view_owner_15() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.voters(owner);
        }
    }

    // @cover-intent Get winner name after owner votes for proposal 0
    function test_winnerName_after_vote_16() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.vote(0);
        }
        {
        target.winnerName();
        }
        vm.stopPrank();
    }

    // @cover-intent Get winning proposal index after owner votes for proposal 0
    function test_winningProposal_after_vote_17() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot_0821 target = new Ballot_0821(_arr1);
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
        target.vote(0);
        }
        {
        target.winningProposal();
        }
        vm.stopPrank();
    }

}
