# -*- coding: utf-8 -*-
from pathlib import Path
from typing import Dict, Any, List

HEADER_08 = """// SPDX-License-Identifier: MIT
pragma solidity ^{PRAGMA};
import "forge-std/Test.sol";
import "../src/{FILENAME}.sol";

contract {CONTRACT}_FunctionalTest is Test {{
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);

{TESTS}
}}
"""

HEADER_04 = """// SPDX-License-Identifier: MIT
pragma solidity {PRAGMA};
import "../src/{FILENAME}.sol";

contract {CONTRACT}_FunctionalTest {{
    address alice;
    address bob;

    function {CONTRACT}_FunctionalTest() public {{
        alice = address(0xA11CE);
        bob   = address(0xB0B);
    }}

    // 关键：把 HEADER_04 改成允许测试合约收 ETH（只要能收钱，withdraw() 就不会因为“收款方拒收”而 revert）
    function() public payable {{ }}

{TESTS}
}}
"""

TEST_TMPL_08 = """
    /// @cover-intent {intent}
    function test_{name}_{idx}() public {{
{body}
    }}
"""

TEST_TMPL_04 = """
    // @cover-intent {intent}
    function test_{name}_{idx}() public {{
{body}
    }}
"""

def _solidity_literal(typ: str, name: str = ""):
    t = typ.strip()
    n = (name or "").lower()

    # 1) 整数/定点
    if t.startswith("uint") or t.startswith("int"):
        if "decimal" in n or "decimals" in n:
            return "18"
        if "amount" in n or "supply" in n or "value" in n or "cap" in n:
            return "1000"
        return "1"

    # 2) 地址
    if t == "address":
        return "alice"  # 测试合约里会定义 alice

    # 3) 布尔
    if t == "bool":
        return "true"

    # 4) 字符串
    if t == "string":
        if "name" in n:
            return '"RemiCoin"'
        if "symbol" in n or "sym" in n:
            return '"RMC"'
        return '"X"'

    # 5) bytes 动态
    if t == "bytes":
        return 'hex"01"'

    # 6) bytesN 固定长
    if t.startswith("bytes"):
        return "bytes32(0)"

    # 7) 数组（给空数组）
    if t.endswith("[]"):
        base = t[:-2]
    
    # 兜底
    return "0"

def _ctor_args_from_abi(abi: list, legacy: bool):
    for it in abi:
        if it.get("type") == "constructor":
            args = []
            for i in it.get("inputs", []):
                args.append(_solidity_literal(i["type"], i.get("name","")))
            return ", ".join(args)
    return ""

def gen_tests_from_abi(
    contract_name: str,                      # 来自 -c
    abi: List[dict],
    standards: List[str],
    solc_version: str = "0.8.24",
    source_path: str = None                  # 来自 -s（用于 import 文件名）
) -> str:
    legacy_04 = solc_version.startswith("v0.4.") or solc_version.startswith("0.4.")
    pragma = solc_version.lstrip("v")  # 例如 v0.4.26 -> 0.4.26

    filename = Path(source_path).stem if source_path else contract_name

    tests = []
    idx = 0

    # 每个测试函数里自行 new 合约（避免 setUp 依赖）
    ctor_args = _ctor_args_from_abi(abi, legacy_04)
    if ctor_args:
        new_stmt = f"{contract_name} target = new {contract_name}({ctor_args});"
    else:
        new_stmt = f"{contract_name} target = new {contract_name}();"

    for item in abi:
        if item.get("type") != "function":
            continue
        name = item["name"]
        state = item.get("stateMutability")

        # 生成函数调用参数（带参数名以便填合适字面量）
        call_args = ", ".join(_solidity_literal(i["type"], i.get("name","")) for i in item.get("inputs", []))
        call = f"target.{name}({call_args});"

        body_lines = [f"        {new_stmt}"]

        if state in ("view", "pure"):
            body_lines.append(f"        {call}")
            intent = f"invoke {name} (read-only)"
        else:
            body_lines.append(f"        {call}")
            body_lines.append(f"        require(true);")  # 0.4.x 无 forge-std 断言，兜底
            intent = f"invoke {name} (state change)"

        body = "\n".join(body_lines)

        if legacy_04:
            tests.append(TEST_TMPL_04.format(intent=intent, name=name, idx=idx, body=body))
        else:
            tests.append(TEST_TMPL_08.format(intent=intent, name=name, idx=idx, body=body))
        idx += 1

    header = HEADER_04 if legacy_04 else HEADER_08
    return header.format(
        PRAGMA=pragma,
        FILENAME=filename,         # import "../src/{FILENAME}.sol";
        CONTRACT=contract_name,    # contract {CONTRACT}_FunctionalTest
        TESTS="".join(tests),
    )

def write_foundry_test(out_dir: Path, contract: str, content: str) -> str:
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{contract}_Functional.t.sol"
    out_path.write_text(content, encoding="utf-8")
    return str(out_path)
