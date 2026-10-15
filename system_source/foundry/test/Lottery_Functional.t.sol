// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/lottery.sol";

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

contract Lottery_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Lottery_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a bet placed on an even block number results in a win and the bet amount is returned to the sender.
    function test_Make_bet_on_even_block_number_0() public {
// assume: block.number % 2 == 0
// cover: makeBet :: won == true
// cover: makeBet :: msg.sender.send(msg.value) succeeds
        vm.startPrank(owner);
        Lottery target = new Lottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(2)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent Financial & Accounting: Verify that a bet placed on an odd block number results in a loss and the bet amount is kept by the contract.
    function test_Make_bet_on_odd_block_number_1() public {
// assume: block.number % 2 == 1
// cover: makeBet :: won == false
        vm.startPrank(owner);
        Lottery target = new Lottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(3)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        // TODO assert: alice.balance == 9 ether
    }

    // @cover-intent Authorization & Access Control: Verify that the organizer can retrieve all bets via getBets.
    function test_Get_bets_as_organizer_2() public {
// assume: msg.sender == organizer
// cover: getBets :: msg.sender == organizer
        vm.startPrank(owner);
        Lottery target = new Lottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(2)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.getBets();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-organizer cannot call getBets.
    function test_Get_bets_as_non_organizer_reverts_3() public {
// assume: msg.sender != organizer
// cover: getBets :: msg.sender != organizer
        vm.startPrank(owner);
        Lottery target = new Lottery();
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
        target.getBets();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the organizer can destroy the contract and send remaining balance to organizer.
    function test_Destroy_as_organizer_4() public {
// assume: msg.sender == organizer
// cover: destroy :: msg.sender == organizer
        vm.startPrank(owner);
        Lottery target = new Lottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(3)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.destroy();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-organizer cannot destroy the contract.
    function test_Destroy_as_non_organizer_reverts_5() public {
// assume: msg.sender != organizer
// cover: destroy :: msg.sender != organizer
        vm.startPrank(owner);
        Lottery target = new Lottery();
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
        target.destroy();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_makeBet_positive_path_6() public {
        vm.startPrank(owner);
        Lottery target = new Lottery();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        // TODO assert: alice.balance == initial_balance - 1 ether
    }

    // @cover-intent Authorization & Access Control
    function test_getBets_positive_path_7() public {
        vm.startPrank(owner);
        Lottery target = new Lottery();
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
        target.makeBet();
        }
        {
        target.getBets();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_destroy_positive_path_8() public {
        vm.startPrank(owner);
        Lottery target = new Lottery();
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
        target.destroy();
        }
    }

}
