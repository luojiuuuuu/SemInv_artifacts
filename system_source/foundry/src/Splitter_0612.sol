// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IPinger {
    function ping() external;
}

contract Splitter_0612 {
    address payable public A;
    address payable public B;
    IPinger public pinger; // 用于展示 try/catch 外部调用

    event Split(uint256 half);
    event PingOk();
    event PingFail(bytes data);

    constructor(address payable _A, address payable _B, IPinger _pinger) public {
        require(_A != address(0) && _B != address(0), "zero");
        A = _A; B = _B; pinger = _pinger;
    }

    // 0.6 引入 receive 与新的 fallback 语义
    receive() external payable {
        uint256 half = msg.value / 2;
        A.transfer(half);
        B.transfer(msg.value - half);
        emit Split(half);

        // 0.6 支持 try/catch（仅外部调用/创建）
        try pinger.ping() {
            emit PingOk();
        } catch (bytes memory data) {
            emit PingFail(data);
        }
    }

    fallback() external payable { }
}
