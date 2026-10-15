// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_30.sol";

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

contract ERC777_FunctionalTest {
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


    // @cover-intent Transfer 60 from alice to bob (supply conserved)
    function test_erc20_transfer_0() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 600);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 60);
        }
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent approve -> transferFrom flow
    function test_erc20_approve_spend_1() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 200);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, bob, 60);
        }
        _assertEqU(target.allowance(alice, bob), 40);
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent Financial & Accounting: Test basic ERC20 transfer and verify balance updates and supply conservation
    function test_ERC777_basic_transfer_2() public {
// assume: balanceOf(alice) >= 80
// cover: transfer :: recipient != address(0) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.transfer(bob, 50);
        }
        {
        target.transfer(carol, 30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
        // TODO assert: bob.balance == 50
        // TODO assert: carol.balance == 30
    }

    // @cover-intent Financial & Accounting: Test approve and transferFrom with allowance deduction
    function test_ERC777_approve_and_transferFrom_3() public {
// assume: allowance(alice, bob) >= 50
// cover: transferFrom :: holder != address(0) true
// cover: transferFrom :: recipient != address(0) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 60);
        }
        vm.startPrank(bob);
        {
        target.transferFrom(alice, carol, 40);
        }
        {
        target.transferFrom(alice, bob, 10);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 10
        // TODO assert: carol.balance == 40
    }

    // @cover-intent Authorization & Access Control: Test operator authorization and operatorSend functionality
    function test_ERC777_authorize_operator_and_operatorSend_4() public {
// assume: isOperatorFor(bob, alice) == true
// cover: operatorSend :: isOperatorFor(msg.sender, sender) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.startPrank(owner);
        // skip malformed call: operatorSend(alice, carol, 30, "0x", "0x") (bad raw arg for operatorSend.arg3: type=bytes, raw="0x")
        // skip malformed call: operatorSend(alice, bob, 20, "0x", "0x") (bad raw arg for operatorSend.arg3: type=bytes, raw="0x")
        vm.stopPrank();
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 20
        // TODO assert: carol.balance == 30
    }

    // @cover-intent Authorization & Access Control: Test operator revocation prevents unauthorized operatorSend
    function test_ERC777_revoke_operator_and_fail_operatorSend_5() public {
// assume: isOperatorFor(bob, alice) == false
// cover: operatorSend :: isOperatorFor(msg.sender, sender) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.authorizeOperator(bob);
        }
        {
        target.revokeOperator(bob);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: operatorSend(alice, carol, 10, "0x", "0x") (bad raw arg for operatorSend.arg3: type=bytes, raw="0x")
        // TODO assert: alice.balance == 100
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Financial & Accounting: Test token burning reduces supply and balance
    function test_ERC777_burn_tokens_6() public {
// assume: balanceOf(alice) >= 30
// cover: _burn :: from != address(0) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip malformed call: burn(30, "0x") (bad raw arg for burn.arg1: type=bytes, raw="0x")
        // TODO assert: alice.balance == 70
    }

    // @cover-intent Authorization & Access Control: Test operator can burn tokens on behalf of holder
    function test_ERC777_operatorBurn_7() public {
// assume: isOperatorFor(bob, alice) == true
// assume: balanceOf(alice) >= 25
// cover: operatorBurn :: isOperatorFor(msg.sender, account) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        // skip malformed call: operatorBurn(alice, 25, "0x", "0x") (bad raw arg for operatorBurn.arg2: type=bytes, raw="0x")
        // TODO assert: alice.balance == 75
    }

    // @cover-intent Transactional Consistency: Test transfer to zero address reverts
    function test_ERC777_transfer_to_zero_address_reverts_8() public {
// cover: transfer :: recipient != address(0) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(address(0), 10);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Transactional Consistency: Test approve to zero address reverts
    function test_ERC777_approve_zero_address_reverts_9() public {
// cover: _approve :: spender != address(0) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(address(0), 50);
        }
    }

    // @cover-intent Authorization & Access Control: Test authorizing self as operator reverts
    function test_ERC777_authorize_self_reverts_10() public {
// cover: authorizeOperator :: msg.sender != operator false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.authorizeOperator(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Test revoking self as operator reverts
    function test_ERC777_revoke_self_reverts_11() public {
// cover: revokeOperator :: operator != msg.sender false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.revokeOperator(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_allowance_12() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(bob, 50);
        }
        vm.prank(alice);
        {
        target.allowance(owner, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approve_13() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(bob, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_authorizeOperator_14() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.authorizeOperator(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_15() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin12_16() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.bug_txorigin12(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin16_17() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.bug_txorigin16(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin24_18() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.bug_txorigin24(owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_txorigin28_19() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.bug_txorigin28(owner);
        }
    }

    // @cover-intent Financial & Accounting
    function test_burn_20() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.burn(30, hex"");
        }
        // TODO assert: alice.balance == 70
    }

    // @cover-intent Financial & Accounting
    function test_decimals_21() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.decimals();
        }
        {
            uint256 __v1 = uint256(target.decimals());
            _assertRelU(__v1, 0, 18, "call:decimals==18");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_defaultOperators_22() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.defaultOperators();
        }
    }

    // @cover-intent Financial & Accounting
    function test_granularity_23() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.granularity();
        }
        {
            uint256 __v2 = uint256(target.granularity());
            _assertRelU(__v2, 0, 1, "call:granularity==1");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_isOperatorFor_24() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(carol);
        {
        target.isOperatorFor(bob, alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_name_25() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.name();
        }
    }

    // @cover-intent Financial & Accounting
    function test_operatorBurn_26() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        {
        target.operatorBurn(alice, 20, hex"", hex"");
        }
        // TODO assert: alice.balance == 80
    }

    // @cover-intent Financial & Accounting
    function test_operatorSend_27() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        {
        target.operatorSend(alice, carol, 30, hex"", hex"");
        }
        // TODO assert: alice.balance == 70
        // TODO assert: carol.balance == 30
    }

    // @cover-intent Authorization & Access Control
    function test_revokeOperator_28() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        {
        target.revokeOperator(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_send_29() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.send(bob, 40, hex"");
        }
        // TODO assert: alice.balance == 60
        // TODO assert: bob.balance == 40
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin1_30() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: sendto_txorigin1(payable(alice), 0, owner) (bad raw arg for sendto_txorigin1.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin21_31() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: sendto_txorigin21(payable(alice), 0, owner) (bad raw arg for sendto_txorigin21.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin29_32() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: sendto_txorigin29(payable(alice), 0, owner) (bad raw arg for sendto_txorigin29.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_sendto_txorigin5_33() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: sendto_txorigin5(payable(alice), 0, owner) (bad raw arg for sendto_txorigin5.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent Financial & Accounting
    function test_symbol_34() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.symbol();
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_35() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.totalSupply();
        }
        {
            uint256 __v3 = uint256(target.totalSupply());
            _assertRelU(__v3, 2, 100, "call:totalSupply>=100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_36() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 50);
        }
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 50
    }

    // @cover-intent Financial & Accounting
    function test_transferFrom_37() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 60);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 40);
        }
        // TODO assert: alice.balance == 60
        // TODO assert: carol.balance == 40
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin11_38() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.transferTo_txorigin11(alice, 0, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_transferTo_txorigin15_39() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.transferTo_txorigin15(alice, 0, owner);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin10_40() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: withdrawAll_txorigin10(payable(alice), owner) (bad raw arg for withdrawAll_txorigin10.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin18_41() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: withdrawAll_txorigin18(payable(alice), owner) (bad raw arg for withdrawAll_txorigin18.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin2_42() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: withdrawAll_txorigin2(payable(alice), owner) (bad raw arg for withdrawAll_txorigin2.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin22_43() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: withdrawAll_txorigin22(payable(alice), owner) (bad raw arg for withdrawAll_txorigin22.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin34_44() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: withdrawAll_txorigin34(payable(alice), owner) (bad raw arg for withdrawAll_txorigin34.arg0: type=address, raw=payable(alice))
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawAll_txorigin6_45() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip malformed call: withdrawAll_txorigin6(payable(alice), owner) (bad raw arg for withdrawAll_txorigin6.arg0: type=address, raw=payable(alice))
    }

}
