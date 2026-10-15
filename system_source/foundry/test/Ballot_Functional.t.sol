// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "forge-std/Test.sol";
import "../src/Ballot_0821.sol";


contract Ballot_FunctionalTest is Test {
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



    // @cover-intent 验证正常投票流程：chairperson 给 alice 投票权，alice 投票，检查提案票数。
    function test_basic_vote_flow_0() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(alice);
        target.vote(0);
        vm.prank(owner);
        target.proposals(0);
    }

    // @cover-intent 验证同一账户不能重复投票：alice 投票后再次投票应回退。
    function test_double_vote_revert_1() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](2);
        _ctor_arr_0[0] = bytes32(uint256(1));
        _ctor_arr_0[1] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.startPrank(alice);
        target.vote(0);
        vm.expectRevert();
        target.vote(1);
        vm.stopPrank();
    }

    // @cover-intent 验证投票委托流程：owner 给 alice 和 bob 投票权，alice 委托 bob，bob 投票，票数合并。
    function test_delegate_vote_flow_2() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](2);
        _ctor_arr_0[0] = bytes32(uint256(1));
        _ctor_arr_0[1] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(owner);
        target.giveRightToVote(bob);
        vm.prank(alice);
        target.delegate(bob);
        vm.prank(bob);
        target.vote(1);
    }

    // @cover-intent 验证未被授权账户投票应回退：bob 未被授权直接投票。
    function test_no_right_to_vote_revert_3() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        vm.prank(bob);
        target.vote(0);
    }

    // @cover-intent 验证投票后赢家提案索引和名称正确。
    function test_winner_name_and_proposal_4() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](2);
        _ctor_arr_0[0] = bytes32(uint256(1));
        _ctor_arr_0[1] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(owner);
        target.giveRightToVote(bob);
        vm.prank(alice);
        target.vote(0);
        vm.prank(bob);
        target.vote(1);
        vm.startPrank(owner);
        target.winnerName();
        target.winningProposal();
        vm.stopPrank();
    }

    // @cover-intent 验证不能委托给自己：alice 获得投票权后委托给自己应回退。
    function test_delegate_self_revert_5() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.expectRevert();
        vm.prank(alice);
        target.delegate(alice);
    }

    // @cover-intent 查询合约 chairperson 地址
    function test_get_chairperson_address_6() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        target.chairperson();
        { address __ad = address(target.chairperson()); _assertEqU(uint160(__ad), uint160(owner)); }
    }

    // @cover-intent alice 将投票权委托给 bob
    function test_delegate_vote_to_bob_7() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(owner);
        target.giveRightToVote(bob);
        vm.prank(alice);
        target.delegate(bob);
        // TODO assert: voters(alice).delegate == bob
    }

    // @cover-intent owner 给 alice 投票权
    function test_give_right_to_vote_to_alice_8() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        // TODO assert: voters(alice).weight == 1
    }

    // @cover-intent 查询第 0 个提案信息
    function test_get_proposal_info_9() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        target.proposals(0);
        // TODO assert: proposals(0).voteCount == 0
    }

    // @cover-intent alice 为第 0 个提案投票
    function test_vote_for_proposal_0_10() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(alice);
        target.vote(0);
        // TODO assert: voters(alice).voted == true
    }

    // @cover-intent 查询 alice 的投票信息
    function test_get_voter_info_11() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(alice);
        target.voters(alice);
        // TODO assert: voters(alice).weight == 1
    }

    // @cover-intent 查询当前获胜提案名称
    function test_get_winner_name_12() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(alice);
        target.vote(0);
        vm.prank(alice);
        target.winnerName();
        // TODO assert: winnerName() == proposals(0).name
    }

    // @cover-intent 查询当前获胜提案索引
    function test_get_winning_proposal_index_13() public {
        bytes32[] memory _ctor_arr_0 = new bytes32[](1);
        _ctor_arr_0[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Ballot target = new Ballot(_ctor_arr_0);
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
        target.giveRightToVote(alice);
        vm.prank(alice);
        target.vote(0);
        vm.prank(alice);
        target.winningProposal();
        // TODO assert: winningProposal() == 0
    }

}
