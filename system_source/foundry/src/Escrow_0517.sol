// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;

library SafeMath0517 {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b; require(c >= a, "overflow"); return c;
    }
}

contract Escrow_0517 {
    using SafeMath0517 for uint256;

    address payable public arbiter;
    address payable public beneficiary;
    address payable public depositor;
    uint256 public deposited;

    event Deposited(address indexed from, uint256 value);
    event Released(address indexed to, uint256 value);

    constructor(address payable _arbiter, address payable _beneficiary) public {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
    }

    function deposit() external payable {
        require(msg.sender == depositor, "only depositor");
        require(msg.value > 0, "no value");
        deposited = deposited.add(msg.value);
        emit Deposited(msg.sender, msg.value);
    }

    function release() external {
        require(msg.sender == arbiter, "only arbiter");
        uint256 amount = deposited;
        deposited = 0;
        beneficiary.transfer(amount);
        emit Released(beneficiary, amount);
    }

    // 0.5.x fallback 需要显式 payable
    function() external payable {
    }
}
