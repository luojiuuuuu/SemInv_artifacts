// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract DutchAuction_076 {
    address payable public immutable seller;
    uint256 public immutable startPrice;
    uint256 public immutable discountRate; // wei per second
    uint256 public immutable startAt;
    uint256 public immutable endsAt;
    bool public sold;

    event Bought(address indexed buyer, uint256 price);

    constructor(uint256 _startPrice, uint256 _discountRate, uint256 _duration) {
        require(_startPrice >= _discountRate * _duration, "price underflow");
        seller = msg.sender;
        startPrice = _startPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        endsAt = block.timestamp + _duration;
    }

    function getCurrentPrice() public view returns (uint256) {
        if (block.timestamp >= endsAt) return 0;
        uint256 elapsed = block.timestamp - startAt;
        return startPrice - discountRate * elapsed;
    }

    function buy() external payable {
        require(!sold, "sold");
        require(block.timestamp < endsAt, "ended");
        uint256 price = getCurrentPrice();
        require(msg.value >= price, "price");

        sold = true;
        seller.transfer(price);

        // 找零
        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        emit Bought(msg.sender, price);
    }
}
