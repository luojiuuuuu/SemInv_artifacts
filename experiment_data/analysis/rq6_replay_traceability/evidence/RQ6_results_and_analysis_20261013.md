# RQ6：现有反例、回放、缩减与解释产物的汇总分析

日期：2026-10-13。分析对象：历史 RQ1 T 最终选中运行及其独立验证产物。本文是结果审计，不是新实验，也不是对原始结果的覆盖更新。

## 1. 结论摘要

现有材料足以补充一项有实测数据的“反例诊断复现与报告可用性分析”，但尚不足以将 RQ6 写成已经完成的“严格漏洞复现、有效最小化和解释正确性评估”。主要结果如下。

| 维度 | 可核实结果 | 合理解释 |
|---|---|---|
| 候选池 | 139 个选中运行，880 条 T 保留事件；735 条动态序列，145 条无序列 source-pattern 事件 | 880 是事件数，不是独立确认的漏洞数 |
| 处理后回放 | 514/735，69.93%，在新进程中重现相同 PC 和检测类型；这 514 条均达到 3/3 | 诊断稳定复现，不等于相同安全后果 |
| 原始序列回放 | 614 条有精确原始文件；420 条命中、192 条未命中、2 条超时 | 另 121 条缺原始文件，不能作为原始回放成功或失败 |
| 缩减 | 64 条长度减少；其中 52 条可作原始/处理后精确配对 | 长度减少是结构事实，不自动等于有效最小化 |
| 缩减后诊断保留 | 在原始可稳定复现的 32 条缩短案例中，20 条仍复现，12 条丢失；保留率 62.50% | 这是当前最需要披露的负面结果 |
| 删除敏感性 | 12 条序列、35 次单步删除；7 次删除后仍命中；6 条序列的所有已测试删除均失去诊断 | 不能据此声称严格漏洞 1-minimal 或全局最短 |
| 模型请求 | 823/823 请求成功且 JSON 可解析，无剩余网络/解析失败 | API 恢复完成，不代表解释质量评估完成 |
| 本次 T 事件解释覆盖 | 735/880，83.52%；动态事件 735/735，无序列事件 0/145 | 这是生成覆盖率，不是自定义“支持率” |
| 解释输入审计 | 对应 T 的 735 次请求中，57 次含不同源码的静态上下文，165 次没有静态分析上下文 | 需先区分输入适配问题和模型错误 |
| 独立解释评估 | 独立根因参考 0；已填人工标注 0/300 槽位 | 正确率、根因准确率、因果覆盖和评审一致性均为未测 |

**最重要的区分：检测成功、诊断回放成功、漏洞严格确认、解释生成成功、解释正确，分别是不同事件。不能用其中一项替代另一项。** 本分析不改变历史 RQ1 的 TP/FP/FN、覆盖率或预算内发现时间。

## 2. 数据来源与统计单位

### 2.1 主队列

主队列由 [冻结清单](<seminv-workspace>/validation/RQ1_T_20261012_225409/frozen/manifest.json)、[880 条事件](<seminv-workspace>/validation/RQ1_T_20261012_225409/frozen/events.json)、[735 条 finding 载荷](<seminv-workspace>/validation/RQ1_T_20261012_225409/frozen/finding_payloads.json)和 [139 个选中运行](<seminv-workspace>/validation/RQ1_T_20261012_225409/frozen/selected_runs.json)确定，关联 [RQ1 T 原报告](<previous-artifact-root>/revision/RQ1_T_final_comparison_analysis_20261011.md)。

这些运行来自逐轮延时后的最终选取：300s 轮 62 个、600s 轮 33 个、1200s 轮 44 个。因此不能把队列描述为“139 个合约都进行了同配置的独立 1200s 运行”。对应事件分别为 210、222、448 条。

| 原运行清单状态 | 运行数 | T 保留事件 | 有动态序列 | 独立回放诊断命中 |
|---|---:|---:|---:|---:|
| success | 112 | 635 | 547 | 368 |
| timeout | 21 | 204 | 150 | 124 |
| tool_failed | 5 | 41 | 38 | 22 |
| untestable | 1 | 0 | 0 | 0 |
| 合计 | 139 | 880 | 735 | 514 |

上表保留的是冻结运行清单状态，不用事后回放状态替换原状态。失败或超时运行已有的事件也进入分析，没有只保留正常退出运行。原运行 timeout 与本次每次回放的 90s watchdog 超时是两个不同维度。

137 个合约至少有一条 T 事件，132 个至少有一条动态事件，129 个至少有一条诊断命中。129/132 只能说明“至少一个诊断可重现”，不能作为全部反例的可靠性。

735 条动态事件的 `(source, PC, detector type)` 键均不同，但同一合约内不同 PC/类型仍可能共享根因，故不等于 735 个独立漏洞。3 次回放是稳定性重复，不是 3 个新样本；人工解释的三个条件也是配对条件，不是三个新漏洞。

### 2.2 本次只做的操作

读取原始产物，重算统计、逐项连接解释和事件、从已有日志提取 ABI、重建已保存请求的 prompt 以核对来源。没有重新 fuzz、重新回放、重新调用模型或修改原实验/主搜索代码。

新结果全部位于 [独立分析目录](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013)。冻结清单中 5 项输入，包括历史预测表、事件表、T 报告和两项核心代码，以及 139 个源文件和运行 manifest，均通过原有摘要比对，见 [完整性核对](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/integrity.json)。该核对不声称覆盖了历史目录中的每个文件。

## 3. 回放：定义、总体和分层结果

### 3.1 本次实际验证了什么

已有 [独立回放实现](<seminv-workspace>/validation/RQ1_T_20261012_225409/replay.py)使用 `<seminv-workspace>` 的实现和项目虚拟环境，每次新进程、新部署，只执行一条保存序列；population=1、generation=1、seed=1、`--seed-strategy only`、关闭数据依赖扩展和约束求解、使用 `evidence-safe`，每次 watchdog=90s。它不是原始 ConFuzzius 基线实验，也不继续搜索新的序列。

诊断命中须完整执行所请求的交易步数，并再次报告相同 PC 和检测类型。事务发生 EVM revert/error 并不自动等同回放基础设施失败，因为某些检测本身可能围绕失败执行触发。

严格成功还应判断同一目标、安全义务及安全后果，并保证所需初态。当前 735 条保存 finding 的指定 trace 字段均为空、显式 setup 均为空；新回放记录提供交易输入和执行错误标志，但不是完整的状态差分/安全后果证明。因此严格成功数和比例均保持 **N/A（未建立判据和证据）**，不是 0，也不是 514。

### 3.2 总体结果

| 序列/阶段 | 分母 | 同 PC/类型命中 | 未命中 | watchdog 超时 | 未尝试或不适用 |
|---|---:|---:|---:|---:|---:|
| processed 首次回放 | 735 | 514 | 219 | 2 | 0 |
| processed 首次命中者再做两次 | 1,028 次尝试，514 条事件 | 1,028 | 0 | 0 | 首次未命中者没有追加重复 |
| 原始序列首次回放 | 614 | 420 | 192 | 2 | 121 条动态事件缺精确 raw 文件 |
| 缩短且原始首次命中者再做两次 | 64 次尝试，32 条事件 | 64 | 0 | 0 | 仅这一有针对性的子集 |
| source-pattern | 145 | N/A | N/A | N/A | 无动态序列 |

动态队列诊断命中率和 3/3 率均为 **514/735=69.93%**。若以全部 T 事件为分母，具有本轮稳定诊断证据的事件占 **514/880=58.41%**；这不是把 145 条 source-pattern 判为回放失败，而是明确整体证据覆盖范围。

132 个有动态事件的合约，逐合约计算命中比例再取均值为 74.27%，中位数 77.50%。它与事件级 69.93% 权重不同，作为辅助诊断并列，不能选更高的一个替换主分母。不对这一固定池的单次审计做“统计显著领先”检验。

### 3.3 按源文件目录类别分层

下表是**样本所属目录类别**，不是每条事件检测到的漏洞类别。一个 reentrancy 样本也可能报告 numeric_integrity，不能把其所有事件称为 reentrancy witness。

| 样本类别 | 合约 | T 事件 | 动态 | source-pattern | 命中 | 未命中 | 超时 | 动态诊断命中率 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Access control | 18 | 95 | 86 | 9 | 62 | 24 | 0 | 72.09% |
| Arithmetic | 15 | 76 | 75 | 1 | 48 | 27 | 0 | 64.00% |
| Bad randomness | 8 | 51 | 25 | 26 | 17 | 8 | 0 | 68.00% |
| Denial of service | 6 | 43 | 34 | 9 | 27 | 7 | 0 | 79.41% |
| Front running | 4 | 15 | 11 | 4 | 8 | 3 | 0 | 72.73% |
| Reentrancy | 31 | 219 | 210 | 9 | 98 | 112 | 0 | 46.67% |
| Time manipulation | 5 | 17 | 12 | 5 | 7 | 5 | 0 | 58.33% |
| Unchecked low-level calls | 52 | 364 | 282 | 82 | 247 | 33 | 2 | 87.59% |
| 合计 | 139 | 880 | 735 | 145 | 514 | 219 | 2 | 69.93% |

### 3.4 按实际 detector kind 分层

| kind | 动态事件 | 命中 | 未命中 | 超时 | 诊断命中率 |
|---|---:|---:|---:|---:|---:|
| numeric_integrity | 251 | 195 | 56 | 0 | 77.69% |
| dos_with_block_gas_limit | 156 | 154 | 0 | 2 | 98.72% |
| unchecked_return_value | 62 | 57 | 5 | 0 | 91.94% |
| reentrancy | 40 | 19 | 21 | 0 | 47.50% |
| assertion_failure | 39 | 38 | 1 | 0 | 97.44% |
| hash_collision | 39 | 7 | 32 | 0 | 17.95% |
| block_dependency | 28 | 13 | 15 | 0 | 46.43% |
| transaction_order_dependency | 23 | 3 | 20 | 0 | 13.04% |
| short_calldata_integrity | 21 | 0 | 21 | 0 | 0.00% |
| access_noninterference | 19 | 13 | 6 | 0 | 68.42% |
| integer_overflow | 15 | 0 | 15 | 0 | 0.00% |
| arbitrary_memory_access | 11 | 0 | 11 | 0 | 0.00% |
| integer_underflow | 8 | 8 | 0 | 0 | 100.00% |
| leaking_ether | 6 | 5 | 1 | 0 | 83.33% |
| accounting_delta | 5 | 0 | 5 | 0 | 0.00% |
| unsafe_delegatecall | 4 | 0 | 4 | 0 | 0.00% |
| tx_origin_boundary | 3 | 0 | 3 | 0 | 0.00% |
| unexpected_ether_balance | 3 | 1 | 2 | 0 | 33.33% |
| order_independence | 1 | 0 | 1 | 0 | 0.00% |
| unprotected_selfdestruct | 1 | 1 | 0 | 0 | 100.00% |

另外 145 条 source-pattern 分别为 unchecked_return_value 95、bad_randomness_dependency 42、approve_race 6、failed_refund_dos 2，无动态回放比例。

这一区分对先前关心的类别尤其重要：Bad randomness 目录下的 17/25 不能解释成 17 条随机性攻击已复现；真正 `bad_randomness_dependency` 的 42 条全是无序列报告。Front running 的实际排序依赖诊断为 3/23，而非目录表中的 8/11。Time manipulation 相关 `block_dependency` 为 13/28，其含义仍是依赖诊断，不是攻击者成功改变收益。

按产物中已有 invariant family 标签，动态结果为 I1 0/5、I2 14/27、I4 3/24、I5 395/480、I6 96/190、未标明 6/9；没有 I3 标记事件。该字段缺失保持缺失，不事后补标签以声称六族全覆盖，完整数据见 [families.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/families.csv)。

### 3.5 未重现和超时的解释边界

219 条未命中并不是 219 个已证明的 FP。原因可能涉及原始初态/前缀缺失、输入或环境重建、全局历史依赖、检测器触发语义，以及实际误报；现有结果不能将它们全部归入某一个原因。

733 次完成的 processed 首次回放中，239 次至少一笔交易出现 EVM error，其中 163 次仍命中、76 次未命中。其余 143 次未命中没有记录到 EVM error。因此“全部是合约 revert 导致”不成立。

仅有 2 条 processed 回放 watchdog 超时，均为 `dos_with_block_gas_limit`，不是本轮主要缺口：T0616 对应 `unchecked_low_level_calls/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol`，T0837 对应 `unchecked_low_level_calls/0xf2570186500a46986f3139f65afedc2afe4f445d.sol`。它们的原始回放也超时；当前不将其判成没有漏洞。

历史 735 条 finding 内部 oracle 字段有 726 条 `error/detector_replay_process_error`、9 条 `passed`；9 条 `passed` 的 returncode 均为 1，本次 processed 只有 3 条重现。故旧字段不能直接充当独立严格确认数。本轮独立验证结果与旧字段同时保留，不覆盖旧记录，也不据此反推历史每次执行的完整原因。

## 4. 缩减：长度收益与诊断损失必须同时报告

### 4.1 长度分布

| 原始元数据长度层 | 动态事件 | 长度减少 | 原始交易总数 | processed 总数 | processed 诊断命中 |
|---|---:|---:|---:|---:|---:|
| 1 | 501 | 0 | 501 | 501 | 327 |
| 2–3 | 71 | 37 | 168 | 126 | 41 |
| ≥4 | 163 | 27 | 804 | 760 | 146 |
| 合计 | 735 | 64 | 1,473 | 1,387 | 514 |

64/735=8.71% 的动态记录变短；限于原本多交易的 234 条，64/234=27.35% 变短。全体交易总数减少 86，即 5.84%。这些是已保存长度的结构统计；121 条缺精确 raw 文件，不能把元数据中的原始长度误称为完整原始轨迹均已找回。

原始平均长度 2.004，processed 1.887；两者中位数都为 1。仅对 64 条变短记录计算，逐记录缩减率平均 42.79%、中位数 50.00%。后两个数字必须带“变短子集”限定，不宜单独作为系统总体压缩成绩。

### 4.2 原始/processed 配对结果

614 条有精确 raw 的事件中，612 条两侧回放均完成，配对结果如下；另 2 条两侧均超时，单列而非混进“不命中”。

| 原始诊断 | processed 命中 | processed 未命中 | 合计 |
|---|---:|---:|---:|
| 命中 | 408 | 12 | 420 |
| 未命中 | 0 | 192 | 192 |
| 合计 | 408 | 204 | 612 |

整体已命中原始序列的诊断保留率为 408/420=97.14%，但多数序列没有被缩短，不能用它说明最小化可靠。

64 条缩短记录中只有 52 条有精确 raw；这 52 条中，20 条两侧均命中、12 条原始命中但 processed 丢失、20 条两侧都不命中。32 条原始命中者均补做到了 3/3，其中 20 条 processed 也达到 3/3。因此真正针对“已缩短且原始可复现”的诊断保留率为 **20/32=62.50%**，诊断损失率为 **12/32=37.50%**。这仍不是 TP 保留率，因为尚无逐反例独立 TP 判定。

### 4.3 保留诊断的 20 条缩短案例

| 指标 | 结果 |
|---|---:|
| 原始 → processed 交易总数 | 65 → 43 |
| 按总交易数计算缩减 | 33.85% |
| 逐记录缩减率均值 / 中位数 | 37.58% / 33.33% |
| 原始 → processed calldata 总字节 | 6,195 → 4,036 |
| 按总字节计算缩减 | 34.85% |
| processed 为单交易 | 8 |
| processed 仍多交易且执行单步删除审计 | 12 |

calldata 字节只包含保存的输入数据，不含交易外壳、gas、部署与准备状态。52 条精确配对缩短记录的总 calldata 从 9,289 降为 5,744 字节，但其含 12 条诊断损失和 20 条两侧未命中，不能称为“漏洞保持的 38.16% 输入压缩”。

12 条多交易案例共穷尽 35 个非空单步删除位置：7 次删除后仍命中、28 次未命中；6 条每次删除都未命中，6 条至少一次删除仍命中。剩下 8 条单交易没有进行空序列对照。当前最稳妥名称是“单步删除诊断敏感性”，不是严格安全后果下的局部最小性。

### 4.4 12 条诊断丢失案例

| ID | 源文件（类别内） | kind | 长度变化 |
|---|---|---|---:|
| T0019 | access_control/incorrect_constructor_name3.sol | transaction_order_dependency | 5→3 |
| T0128 | arithmetic/integer_overflow_multitx_multifunc_feasible.sol | numeric_integrity | 2→1 |
| T0136 | arithmetic/integer_overflow_multitx_onefunc_feasible.sol | numeric_integrity | 2→1 |
| T0254 | denial_of_service/list_dos.sol | unchecked_return_value | 2→1 |
| T0334 | reentrancy/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol | block_dependency | 2→1 |
| T0354 | reentrancy/0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol | block_dependency | 2→1 |
| T0382 | reentrancy/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol | block_dependency | 2→1 |
| T0391 | reentrancy/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol | block_dependency | 3→1 |
| T0423 | reentrancy/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol | block_dependency | 2→1 |
| T0437 | reentrancy/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol | block_dependency | 2→1 |
| T0451 | reentrancy/etherstore.sol | block_dependency | 5→3 |
| T0652 | unchecked_low_level_calls/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol | unchecked_return_value | 5→1 |

T0128 的 [源码](<seminv-workspace>/comp_dataset/arithmetic/integer_overflow_multitx_multifunc_feasible.sol)要求先 `init()`，否则 `run()` 提前返回。已有原始回放执行初始化选择器 `0xe1c7392a` 后执行 `run`，processed 仅有 `run`，因此无法到达目标 PC。T0136 的 [源码](<seminv-workspace>/comp_dataset/arithmetic/integer_overflow_multitx_onefunc_feasible.sol)第一次 `run` 只设初始化标志并返回，单次调用同样不足。两例说明准备交易不可无条件删除。T0128 保存的目标调用参数为 0，故“到达 numeric_integrity 诊断”本身也不证明实际整数回绕或损失。

7 条 `block_dependency` 丢失占损失案例过半；其序列经常由 `Put;Collect` 等多调用变为只保留 `Put`。日志支持“删减后诊断消失”，但不能仅凭函数名认定每例具体根因。完整函数/选择器与历史 oracle 状态见 [diagnostic_losses.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/diagnostic_losses.csv)。

## 5. 解释：请求恢复、真实覆盖和输入质量

### 5.1 网络恢复结果和模型身份

已有恢复产物说明：112 份旧报告包含 619 次 ProxyError，另 27 个运行无旧报告，其中 23 个仍有 204 条可输入记录。独立恢复用直接连接绕开系统代理，累计得到 823 条可解析响应，分布在 135 份 `ok` 报告。另 4 份 `skipped` 是两处目录缺失、两处无可分析输入，不是仍然连接失败。

请求模型均为 `deepseek-chat`，响应记录服务模型均为 `deepseek-flash`；恢复代码 temperature=0.2，每请求 timeout=120s。应以“请求名与响应服务名分别披露”的方式记录，不能将事后响应模型冒充原实验的实际服务版本。它们是事后 RCA 文本，没有回写检测真值或 RQ1 成绩。

### 5.2 823 条响应与 880 条 T 事件不是直接相除关系

| 输入类型 | 恢复请求 | 精确关联本 T 队列 | 不在本 T 队列 |
|---|---:|---:|---:|
| violation_events 内的单事件 | 721 | 649 | 72 |
| 独立 finding JSON | 100 | 86 | 14 |
| 聚合 report JSON | 2 | 0 | 2 |
| 合计 | 823 | 735 | 88 |

精确关联使用运行目录与 event_id，或 finding 路径/其明确记录的 event_id，不做模糊文本匹配。735 次请求与 735 条动态 T 事件一一对应；145 条无序列事件没有匹配解释。队列外 86 个单事件/finding 不应因为生成成功自动加入 T 结果，也不能仅凭不在 T 队列便判成 FP。

两个聚合输入为 `hybrid_replay_report.json` 和 `semantic_invariant_report.json`。恢复脚本的 fallback 排除了部分索引，但没有排除这两个汇总文件，因此它们被当作输入生成了解释；它们不能作为两个独立漏洞解释。完整输入身份见 [explanations.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/explanations.csv)。

### 5.3 新发现：静态上下文来源错配

本分析重新构造了全部 823 个 prompt，其摘要均与响应日志记录一致。因此可以追溯本轮恢复实际使用的上下文，而不仅是根据当前目录猜测。

静态上下文来源路径不一致涉及 13 个运行、68 次请求。比对路径所指源文件内容后，其中 3 个运行、11 次请求属于内容完全相同的副本；真正不同源码内容为 **10 个运行、57 次请求**，全部对应 T 动态事件。

| 对应 T 的解释上下文状态 | 请求数 | 占 735 条动态解释 |
|---|---:|---:|
| 静态上下文源文件与目标内容相同 | 513 | 69.80% |
| 静态上下文来自不同内容的源文件 | 57 | 7.76% |
| 没有静态分析上下文 | 165 | 22.45% |

这里的“内容相同”是现存来源文件身份核对，不是静态分析事实正确性的独立认证；“无静态分析”不代表没有源码和 finding 输入。57 条也不能直接算解释错误，仍需检查具体论断是否实际使用了错误上下文。

| 目标合约/源文件 | 被带入的静态上下文来源 | 请求数 |
|---|---|---:|
| Wallet / arbitrary_location_write_simple.sol | WALLET / reentrancy/0xcead721…sol | 8 |
| Missing / incorrect_constructor_name2.sol | incorrect_constructor_name1.sol | 1 |
| Missing / incorrect_constructor_name3.sol | incorrect_constructor_name1.sol | 3 |
| Wallet / wallet_02_refund_nosub.sol | WALLET / reentrancy/0xcead721…sol | 5 |
| Wallet / wallet_03_wrong_constructor.sol | WALLET / reentrancy/0xcead721…sol | 6 |
| Wallet / wallet_04_confused_sign.sol | WALLET / reentrancy/0xcead721…sol | 6 |
| IntegerOverflowAdd / integer_overflow_add.sol | insecure_transfer.sol | 3 |
| DosGas / dos_address.sol | newvul/gas1.sol | 4 |
| airdrop / 0x4051334…sol | airDrop / 0xe894d54…sol | 10 |
| Lotto / etherpot_lotto.sol | lotto.sol | 11 |

恢复客户端从 `<previous-artifact-root>/system_source` 导入 prompt builder，在 `<seminv-workspace>` 工作目录读取按合约名组织的 `foundry/<contract>_meta`；名称重用及 Windows 大小写不敏感与观察到的错配相符。Wallet 的上下文实际描述另一个 WALLET 的 Acc/LogFile/MinSum，至少一条模型响应也主动指出这点。此处确认的是具体输入错配；没有据此声称所有解释或原 fuzz 过程均被污染。

现有 139 个选中运行中，136 个有来源和合约名均匹配的运行专属 `artifacts/l3_foundry/analysis.json`，上述 10 个错配运行均在其中。因此后续可在独立验证目录用它们构造新版本解释，无需重跑主搜索；本次只记录可行性，没有替换上下文或重发请求。详见 [context_audit.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/context_audit.csv)。

### 5.4 ABI 与新回放证据的利用情况

823 次恢复请求均以 `abi=[]` 构建上下文。旧恢复说明中“ABI 未持久化”不能扩大理解为所有现有产物都无 ABI：本次在已有回放 stdout 中成功解析到 129 个源文件的 ABI，并独立保存为 [abis_from_existing_replay_logs.json](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/abis_from_existing_replay_logs.json)。它们是进一步增强解释输入的材料，不代表当前解释已经使用。

恢复客户端读取历史 finding/event，而不是 `explanations/sample.json` 中整理的新回放记录。因此当前文本不能标作“以此次独立严格回放轨迹为输入”的实验条件，更不能用它与尚未生成的一般源码告警条件比较质量。

### 5.5 100 条样本和人工评估状态

| 项目 | 当前状态 |
|---|---|
| 样本 | 100 条，来自 60 个源文件 |
| 目录类别 | 前四类各 13 条，后四类各 12 条 |
| 后端 | source-pattern 45，dynamic 55 |
| 动态长度 | 原始单交易 48，多交易 7 |
| 回放诊断 | 命中 37，未命中 18，无序列 45 |
| 与恢复文本匹配 | 55/100；其中上下文内容错配 6，无静态分析 6，来源内容相同 43 |
| 独立根因参考 | 0/100 |
| 三条件人工槽位 | 300，已填标签 0 |

抽样实现先按目录分组，组内优先无序列、再单交易，再轮流取类别并尽量避免相同 `(source, kind)`。所以它是类别均衡的诊断样本，不是总体等概率随机样本，也不覆盖全部六个 invariant family。其 source-pattern 占比 45%，明显高于全池 145/880=16.48%；若未来人工评估，必须说明这一抽样方式，不能直接把样本平均值当作全池无偏估计。

300 是预留槽位，不是已完成的 300 条解释或 300 份人类评价；已有 55 条可连接文本也不构成三条件配对实验。没有独立参考和人工标签时，事实正确率、根因准确率、必要因果链覆盖、完整解释通过率、kappa/alpha 都为 N/A。模型自身的 confidence 或 uncertainties 不能代替评审。

823 条响应均有全部 11 个预期顶层字段且 root_cause 非空；high/medium/low 自报置信度为 207/473/143，所有响应都有 uncertainties。这只说明结构性可用，不说明事实成立，不构造新的 EvidenceScore 或“有据支持率”。

## 6. 成本与资源

### 6.1 独立回放附加成本

| 阶段 | 尝试数 | 进程耗时之和/s | 单次中位数/s | 单次 P95/s |
|---|---:|---:|---:|---:|
| processed 首次 | 735 | 7,509.901 | 9.844 | 12.681 |
| processed 后两次 | 1,028 | 8,288.492 | 7.907 | 9.510 |
| original 首次 | 614 | 5,310.098 | 9.055 | 12.194 |
| original 后两次 | 64 | 472.172 | 7.313 | 8.488 |
| 单步删除 | 35 | 266.121 | 7.563 | 8.411 |
| 合计 | 2,476 | 21,846.784 | 8.578 | 11.734 |

总和约 6.07 进程小时，**不是并发验证的实际墙钟总时长，也不是纯 CPU 时间**。processed 首次的 worker 内部计时中位数约 0.359s，而外层约 9.844s，说明进程启动、导入等外部开销显著；该内部计时也不是精确分离出的纯 EVM 时间。

这是发现后的额外验证成本，不能回填为原搜索预算内的完成时间。35 次删除的 266.121s 是本次删除敏感性审计成本，不是原运行整个最小化算法的总成本。没有充分日志支持历史最小化总开销时应保留 N/A。

### 6.2 模型 token 成本

| 范围 | 请求 | 输入 token | 输出 token | 总 token | 单请求总 token 中位数 |
|---|---:|---:|---:|---:|---:|
| 全部恢复请求 | 823 | 7,293,971 | 719,114 | 8,013,085 | 7,473 |
| 精确匹配 T 动态事件 | 735 | 6,691,598 | 652,603 | 7,344,201 | 7,507 |

全部请求记录的 prompt cache hit token 为 337,920，属于输入 token 的组成信息，不能再次加到总量中。全部响应完成时间戳首尾相差 1,187s，但缺少完整逐请求启动/队列时间，不能据此给出每次平均延时或完整生成墙钟时间。未取实时账单和价格，不估造货币费用。

## 7. 旧 RQ3 Full 产物作为独立补充

另一个现有数据源是 [rq3_fresh_sb143_20261011_101706 的 RQ6 inventory](<seminv-workspace>/ccfa-review-reports/rq6-full-inventory/inventory.json)。该轮配置为 600s 搜索、1200s 外层 watchdog，回放和最小化关闭；不是两个独立的 600s/1200s 搜索实验。

| Full 队列 | 计划运行 | 600s 内报告事件 | 多交易事件 | 精确 raw 配对 | 已验证回放/最小化 | 已生成解释 |
|---|---:|---:|---:|---:|---|---:|
| 全量 seed11，143 个源文件 | 143 | 1,242 | 603 | 1,242 | 未执行 | 0 |
| 24 样本 × 5 seeds | 120 | 707 | 437 | 707 | 未执行 | 0 |
| 去除上述 seed11 交叠后的全部 Full | 239 | 1,808 | 951 | 1,808 | 未执行 | 0 |

143+120 不能直接相加，24 个 seed11 运行重复出现在两个视图中，唯一运行数为 239。seed11 的 1,288 个保存 finding 中有 45 个被抑制，退出时报告 1,243 个，600s 内为 1,242 个；不能随意互换分母。全部 Full 的退出报告为 1,810，600s 内为 1,808。

全量 seed11 的状态为 131 budget_completed、9 tool_failed、2 prepare_failed、1 untestable；全部 239 个 Full 运行为 223、13、2、1。其保存字段说明具备序列和复现命令，但 oracle 为 skipped，不是严格复现成功。

该数据源的价值是：多交易案例较多，seed11 中 603/1242=48.55%，可以作为后续验证候选材料；原始轨迹配对比当前 T 池更齐全。它不能证明当前 T 队列的回放率、解释质量或缩减效果，更不能与当前 880 条直接合并。此前论文/汇总中的 confirmed、oracle-minimal、supported 等计数也必须保留其原定义，不与本次独立诊断混称。

## 8. RQ6 应如何组织及目前能支撑到哪里

建议分成三个可独立回答的子问题，以标准的计数、比例、配对保留、长度/字节缩减、耗时和 token 为主，不建立自定义综合支持分数。

| 子问题 | 目前可以写入的证据 | 当前不可声称 |
|---|---|---|
| 保存序列是否可在独立环境重现诊断？ | 514/735、完整失败/超时分布、514 条 3/3、目录和 detector 分层、成本 | 69.93% 是严格漏洞有效率；514 个独立 TP；回放过滤掉 219 个 FP |
| 简化减少了什么，是否保留诊断？ | 64 条变短、20/32 保留诊断、交易/字节变化、12 条损失案例、删除敏感性 | 所有变短序列均有效最小化；97.14% 代表缩减后的可靠性；全局最短 |
| 解释能否生成、输入是否适用？ | 823 个解析成功响应、735 个队列内解释、57 个上下文错配、token 成本 | 100% 解释正确；83.52% 解释被证据支持；已完成三条件人类评估 |

图表可采用以下结构，无须强行绘制未测质量曲线：

1. 回放状态堆叠图：735 动态事件分成 514 命中、219 未命中、2 超时，旁列 145 无序列；类别图必须标清按源目录还是 detector。
2. 缩减配对图：52 条精确配对缩短记录显示原始/最终长度，并以“两侧命中、诊断丢失、两侧未命中”区分颜色；12 条 raw 缺失另列，避免只展示成功压缩者。
3. 解释覆盖/输入状态表：823 请求到 735 T 事件的映射，再拆 513 来源内容匹配、57 错配、165 无静态上下文；把人工质量指标标为未测，不使用空数据生成高分柱状图。

没有 baseline 的同池独立回放、缩减和解释标注材料，不能据此声称 SemInv 在 RQ6 优于 SMARTIAN、DepFuzz、ItyFuzz 或其他检测基线。原 RQ1 的检测和覆盖率不是这里的解释质量对照。当前可做的是系统内原始/processed 配对及输入证据审计。

### 8.1 依据现有材料可继续推进的事项（本次未执行）

优先使用运行专属静态产物和已提取 ABI，隔离生成一个修正后的解释版本；排除聚合 report 输入，按 880 条队列清单显式处理动态和无序列两层；将独立回放结果作为新的输入字段，不能默默改写原 oracle 标签。

随后选择有完整初态和可审定安全义务的案例建立同后果判据，保留未决项；对解释准备独立根因参考和同事件三条件材料，进行双人盲审。当前 100 条样本可用于诊断性试评，但需要披露抽样倾斜，不能冒充六族均衡随机评估。

这些步骤不必重跑主 fuzz 搜索，不过“仅重新汇总”也不能产生缺失的安全后果和人类正确性证据。若不做这些补充，最稳妥的是将当前结果作为 RQ6 的实证子部分或补充材料，降低对“严格 witness 和解释质量已证实”的贡献表述。

## 9. 交付文件与复算

| 文件 | 内容 |
|---|---|
| [metrics.json](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/metrics.json) | 全部计数、分布、成本和旧 Full 分队列信息 |
| [events.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/events.csv) | 880 条事件的原始/processed 回放、长度、模型关联 |
| [attempts.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/attempts.csv) | 2,476 次验证尝试和原 outcome 路径 |
| [contracts.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/contracts.csv) | 139 个运行的状态和逐合约诊断比例 |
| [categories.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/categories.csv) / [detectors.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/detectors.csv) | 两种不同分层，防止混用 |
| [minimization.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/minimization.csv) | 64 条缩短记录及删除测试 |
| [replay_failures.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/replay_failures.csv) | 219 条未命中和 2 条超时 |
| [diagnostic_losses.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/diagnostic_losses.csv) | 12 条原始命中、处理后丢失的完整记录 |
| [explanations.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/explanations.csv) | 823 个请求的身份、T 匹配、模型、结构字段和 token |
| [context_audit.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/context_audit.csv) | 139 个上下文来源和可替代运行专属产物 |
| [sample_mapping.csv](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/sample_mapping.csv) | 100 条解释样本与已生成文本的关联 |
| [reconstructed_contexts.json](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/reconstructed_contexts.json) | 本次重建、与历史 prompt 摘要核对的上下文快照 |
| [analyze.py](<seminv-workspace>/validation/RQ1_T_20261012_225409/rq6_analysis_20261013/analyze.py) | 只读原材料、仅向本独立分析目录输出的复算入口 |

复算命令不访问模型 API、不进行回放或 fuzz，只更新本次新建分析目录中的派生统计：

```powershell
& '<seminv-workspace>\.venv-seminv-a1\Scripts\python.exe' -B -X utf8 `
  '<seminv-workspace>\validation\RQ1_T_20261012_225409\rq6_analysis_20261013\analyze.py'
```

解释质量定义参考本地 [RQ6 实验指导](<seminv-workspace>/ccfa-review-reports/rq-experiment-guides/RQ6-witness-and-explanation-quality.md)。其中目标值和建议实验属于设计材料，不当作已经实现的结果。旧 `summary/RQ6_readiness.md` 和 `explanations/manifest.json` 的“解释尚未生成”是早于 API recovery 的历史快照；本报告提供跨阶段最新核对，不改写这些历史文件。
