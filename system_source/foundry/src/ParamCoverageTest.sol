// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ParamCoverageTest {

    struct Pair {
        uint256 a;
        bool b;
    }

    // -------------------------
    // 状态变量（用于简单验证）
    // -------------------------

    uint256 public lastSum;
    bytes32 public lastHash;
    uint256 public lastA;
    bool public lastB;
    uint256 public lastArrayLen;

    // -------------------------
    // 1️⃣ uint256[]
    // -------------------------
    function setUintArray(uint256[] memory arr) external {
        uint256 s = 0;
        for (uint i = 0; i < arr.length; i++) {
            s += arr[i];
        }
        lastSum = s;
        lastArrayLen = arr.length;
    }

    // -------------------------
    // 2️⃣ bytes32[]
    // -------------------------
    function setBytes32Array(bytes32[] memory arr) external {
        bytes32 h = keccak256(abi.encode(arr));
        lastHash = h;
        lastArrayLen = arr.length;
    }

    // -------------------------
    // 3️⃣ tuple(uint256,bool)
    // -------------------------
    function setTuple(uint256 x, bool y) external {
        lastA = x;
        lastB = y;
    }

    // -------------------------
    // 4️⃣ struct (tuple)
    // -------------------------
    function setStruct(Pair memory p) external {
        lastA = p.a;
        lastB = p.b;
    }

    // -------------------------
    // 5️⃣ struct[]
    // -------------------------
    function setStructArray(Pair[] memory arr) external {
        lastArrayLen = arr.length;

        if (arr.length > 0) {
            lastA = arr[0].a;
            lastB = arr[0].b;
        }
    }

    // -------------------------
    // 6️⃣ constructor (tuple[])
    // -------------------------
    constructor(Pair[] memory initPairs) {
        if (initPairs.length > 0) {
            lastA = initPairs[0].a;
            lastB = initPairs[0].b;
        }
        lastArrayLen = initPairs.length;
    }
}