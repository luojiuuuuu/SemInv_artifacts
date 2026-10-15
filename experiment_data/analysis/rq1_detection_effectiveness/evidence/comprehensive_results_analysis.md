# RQ1：SemInv检测效果与覆盖率的完整统计分析

日期：2026-10-13。结果版本：T-v1，300s首轮 + 600s超时重测替换。本文是新的完整结果入口；旧版报告及原始实验产物保持不变。

## 1. 研究问题与主要发现

**RQ1：在SB Curated上，SemInv能否在兼顾漏报与误报的情况下提高漏洞检测效果，并在共同输入与检测类别上保持优势？其执行覆盖率呈现怎样的差异？**

本报告从全量检测、共同范围比较、逐类别表现和执行覆盖四个层面回答这一问题。

- 在固定139个文件、8类的1112个文件-类别判断上，SemInv得到125 TP、64 FP、909 TN、14 FN；Recall为89.93%，FPR为6.58%，Accuracy为92.99%，micro-F1为76.22%，Macro-F1为64.43%。
- 在八个baseline各自的共同文件、共同评分类别上，SemInv的Recall、Accuracy和F1均更高。该结论在加入可获得的其他类别文件作为阴性样本后仍成立；FPR并非普遍更低。
- SemInv检出了全部52个Unchecked low-level calls正例，在Access control和Reentrancy上分别达到94.44%和87.10%的Recall。DoS仍是检出短板；Front running和Time manipulation的主要限制是标签外告警。
- 同文件、同目标、同可执行runtime的89例上，SemInv的normalized concrete branch为89.60%，DepFuzz为85.40%；normalized concrete instruction分别为86.45%和93.59%。优势集中在分支结果覆盖，不能概括为所有覆盖指标领先。

## 2. 实验设置

### 2.1 数据与工具

数据集为 `<smartbugs-upstream-root>/comp_dataset` 的Strict8范围：139个Solidity源文件，8个主类别。计分单位是“源文件-漏洞类别”，不是单条告警、单个函数或文件中声明的每个合约。一个文件的同类重复告警只计一次。八类之外的4个文件不进入Strict8，范围选择与工具运行结果无关。

对比工具包括静态分析工具Slither、SmartCheck，符号执行工具Mythril，以及ConFuzzius、sFuzz、SMARTIAN、ItyFuzz和DepFuzz五个fuzz baseline。SemInv运行的是 `<seminv-workspace>` 中已修改的语义检测流水线；ConFuzzius baseline使用已归档的baseline预测，不用SemInv产物替代。

SemInv默认使用evidence-safe和T-v1：校验同轮事件归属，读取同轮保留的静态与动态证据，应用既有证据过滤；对带时间源码证据的保留 `block_dependency` 事件映射 `time_manipulation`。T输出是检测告警，不自动等同于成功复现的exploit。规则对所有样本一致应用，不按ground truth选择报告类别，也不跨run合并告警。

### 2.2 预算、运行选择与状态

统一复现实验的目标timeout为600s。本文件使用现有实测记录，SemInv按指定方式选择结果：保留300s首轮中未被调度为timeout的62例，以600s重测结果替换其余77例，不纳入1200s结果。该选择不是两个run告警的并集，也不是139例均独立运行600s。

| 工具/数据源 | 本文件记录的实际执行配置 |
|---|---|
| SemInv | 300s首轮 + timeout样本600s替换；Foundry与fuzz阶段分别受限，非端到端600s；归档命令为10 generations、Byzantium、minimization timeout 60s，启用minimization validation和LLM RCA，未显式固定seed。 |
| SMARTIAN、ItyFuzz | 归档正式实验为300s、seed1；没有对应全量600s实测记录。 |
| DepFuzz | 使用启用覆盖适配器的1200s、seed1实验。 |
| ConFuzzius、sFuzz、Mythril、Slither、SmartCheck | 论文既有实验导出；当前指标文件不能独立核验其全部timeout参数。 |

因此，下文是既有实测数据的检测效果比较，不是已完成的全工具等预算600s评测，不作运行效率或同等时间内优越性的结论。预算信息集中列于本节。

执行状态与检测结果分别保存。timeout保留timeout失败状态，并保留截至终止时已保存、可归属的告警；计分不把命中样本改写为正常完成。本次选定结果为91 success、44 timeout、3 tool_failed、1 untestable。其中44个timeout贡献37 TP和29 FP；三个tool_failed贡献3 TP和1 FP。

### 2.3 指标定义

每个文件有一个主类别阳性标签，其他被评价类别作为标签阴性。设预测类别与主类别一致为TP；未报告该主类别为FN；报告其他被评价类别为FP；未报告其他类别为TN。

| 指标 | 定义 | 方向 |
|---|---|---|
| Recall | TP / (TP + FN) | 越高越好 |
| FPR | FP / (FP + TN) | 越低越好 |
| Accuracy | (TP + TN) / (TP + FP + TN + FN) | 越高越好 |
| F1 | 2TP / (2TP + FP + FN) | 越高越好 |
| Precision（补充） | TP / (TP + FP) | 越高越好 |
| Macro-F1（补充） | 各被评价类别F1的等权平均 | 越高越好 |

汇总F1使用micro计数。无预测时Precision记0；有正例而无命中时Recall、F1为0。N/A表示当前严格映射未评价该类别，不代入0参与宏平均。表中百分数保留两位，差值以未舍入值计算，pp表示百分点。

这里的FP是相对于单主类别标注的额外类别预测，不是逐告警人工复现后的真假判定。一个多漏洞文件可能包含未被主标签覆盖的真实问题；本报告仍统一按原标签计FP，不单独豁免SemInv。

## 3. tool_failed与untestable的统一处理

本节只规定运行失败、输入不适用和报告缺失的处理；timeout采用实验设置中的统一规则。

| 情况 | 对所有工具一致的计分方式 | 记录方式 |
|---|---|---|
| tool_failed，保留有效部分告警 | 有效告警照常计TP或FP；没有命中的真实标签计FN。 | 保留失败状态和原始原因，不用是否命中决定状态。 |
| tool_failed，无有效告警 | 已纳入任务保留在分母中；被评价主类别计FN，未报告的阴性标签计TN。 | TN仅表示未交付该告警，不表示证明安全。 |
| 编译失败或部署失败 | 不因个别工具失败而删除任务；按保存的告警及缺失检测计分。 | 保留compile_failed等原始状态。 |
| untestable：不满足具体执行前提 | 原始139文件主结果保留；可另列按输入条件预先定义的适用子集。 | 不把单工具不适用当成全局不可测试。 |
| 无JSON、无日志片段、无最终摘要 | 保留已有记录；没有可用预测则按未交付告警处理。 | 保留缺失状态，不能仅据此断言崩溃。 |
| 当前严格映射未覆盖的漏洞类别 | 不进入该工具共同类别范围；对应类别比较记N/A。 | 这是本地映射边界，不是工具完整能力声明。 |
| 所有工具均不支持或均无法分析同一输入 | 可在预先定义的共同可分析子集中一致剔除，公布清单；原始任务清单保留。 | 本批可全局剔除的文件为0。 |
| 所有工具均未检出，但能够分析 | 保留FN。 | 不把未检出误作不可测试。 |

上述规则把“任务是否成功执行”与“交付了哪些检测结果”分开，既不奖励删除困难输入，也不抹去失败前的有效发现。所有工具保留TP与FP两种告警，而非只恢复命中的告警。

### 3.1 SemInv具体案例

| 文件 | 状态 | 保留预测 | 计分贡献 |
|---|---|---|---|
| `front_running/ERC20.sol` | tool_failed | front_running | 1 TP、0 FP |
| `reentrancy/reentrance.sol` | tool_failed | reentrancy | 1 TP、0 FP |
| `reentrancy/simple_dao.sol` | tool_failed | reentrancy、unchecked_low_level_calls | 1 TP、1 FP |
| `bad_randomness/random_number_generator.sol` | untestable | 无 | 1 FN、7 TN |

前三例从原始退出码恢复失败状态，保留既有事件。最后一例没有外部ABI入口，错误类型为 `empty_abi_or_no_external_entry`；Slither仍能分析并报告其Bad randomness，因此不能从整个数据集中剔除。

### 3.2 Baseline记录与可解释性

下表对应第5节主比较的文件范围。仅列非正常或缺失记录，不把含义不同的状态强行合并为“崩溃率”。

| Baseline | N | 非正常/缺失记录 | 处理 |
|---|---:|---|---|
| ConFuzzius | 133 | 29 no_fuzz_summary | 不删除；沿用已解析告警。 |
| Mythril | 133 | 26 timeout_or_exception | 保留混合原始状态，不能据此得到准确tool_failed数。 |
| Slither | 120 | 2 json_missing | 不删除，不声称两例均崩溃。 |
| SmartCheck | 108 | 0 | 全部记录为ok。 |
| sFuzz | 54 | 3 missing_log_section、3 no_status_block | 六例均保留；不再只计48个有完整日志的样本。 |
| SMARTIAN | 67 | 1 compile_failed | 保留TownCrier编译失败例，不再只计66例。 |
| ItyFuzz | 116 | 3 compile_failed、10 failed | 均保留。 |
| DepFuzz | 139 | 1 compile_failed、4 tool_failed | 均保留已有有效预测。 |

139个文件均至少有一个在相应主类别范围内提供正常报告的baseline，逐文件证据见 `global_exclusion_audit.csv`。历史导出之外的缺失文件不虚构为正常运行、空预测，也不据此补造FP/TN。

## 4. SemInv全量结果

| 范围 | N | TP | FP | TN | FN | Recall | FPR | Accuracy | F1 | Precision | Macro-F1 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **全139文件主结果** | **139** | **125** | **64** | **909** | **14** | **89.93%** | **6.58%** | **92.99%** | **76.22%** | **66.14%** | **64.43%** |
| 138个ABI适用文件，补充 | 138 | 125 | 64 | 902 | 13 | 90.58% | 6.63% | 93.03% | 76.45% | 66.14% | 64.72% |

主结果保留全部输入。适用子集仅少1 FN和7 TN，不能以90.58%的条件Recall代替全量89.93%。

### 数据构成与指标含义

139个主类别正例中，Unchecked low-level calls占52例，Reentrancy占31例，两类合计59.71%。micro-F1受到这些较大类别的影响，Macro-F1为64.43%，说明各类别仍不均衡。

全量判断包含139个阳性槽和973个阴性槽。这不是一个包含973个独立安全合约的数据集。全部不报告的预测器也会有87.50% Accuracy和0% FPR，但Recall、F1均为0。因此92.99%的Accuracy须结合89.93%的Recall、76.22%的F1解释，不能用Accuracy单独证明检测能力。

## 5. 主比较与原有范围配对

### 5.1 共同类别范围

“类别范围”指本次已经建立的严格告警映射，不等同于工具原生支持的全部oracle。特别是SMARTIAN、ItyFuzz和sFuzz仍有未纳入此映射的原生/辅助告警。

| 工具 | N | 类别数K | 评价范围 |
|---|---:|---:|---|
| SemInv | 139 | 8 | 全八类。 |
| ConFuzzius、Mythril | 133 | 7 | 除DoS外的七类。 |
| Slither | 120 | 6 | 除Arithmetic、Front running外的六类。 |
| SmartCheck | 108 | 7 | 除Reentrancy外的七类。 |
| sFuzz | 54 | 3 | Access control、Reentrancy、Time manipulation。 |
| SMARTIAN | 67 | 2 | Arithmetic、Unchecked low-level calls。 |
| ItyFuzz | 116 | 4 | Access control、Arithmetic、Reentrancy、Unchecked low-level calls。 |
| DepFuzz | 139 | 5 | Access control、Arithmetic、Front running、Reentrancy、Unchecked low-level calls。 |

前七个baseline范围纳入主类别属于其映射集合的全部文件；DepFuzz保留139文件，其中120个正例属于其五类，另外19个文件贡献五类阴性判断。所有范围均保留第3节的失败与不适用记录。

### 5.2 主表：整体检测效果

本表可沿用论文原整体结果表的列结构，并补充三个新增baseline。N、K不同，表内绝对F1不能直接作为统一任务排名；严格优劣判断使用下一表的配对值。

| 工具 | N | K | TP/FP/TN/FN | Recall | FPR | Accuracy | F1 |
|---|---:|---:|---|---:|---:|---:|---:|
| **SemInv T** | **139** | **8** | **125/64/909/14** | **89.93%** | **6.58%** | **92.99%** | **76.22%** |
| ConFuzzius | 133 | 7 | 74/55/743/59 | 55.64% | 6.89% | 87.76% | 56.49% |
| Mythril | 133 | 7 | 78/113/685/55 | 58.65% | 14.16% | 81.95% | 48.15% |
| Slither | 120 | 6 | 106/203/397/14 | 88.33% | 33.83% | 69.86% | 49.42% |
| SmartCheck | 108 | 7 | 76/91/557/32 | 70.37% | 14.04% | 83.73% | 55.27% |
| sFuzz | 54 | 3 | 21/7/101/33 | 38.89% | 6.48% | 75.31% | 51.22% |
| SMARTIAN | 67 | 2 | 60/2/65/7 | 89.55% | 2.99% | 93.28% | 93.02% |
| ItyFuzz | 116 | 4 | 4/3/345/112 | 3.45% | 0.86% | 75.22% | 6.50% |
| DepFuzz | 139 | 5 | 92/28/547/28 | 76.67% | 4.87% | 91.94% | 76.67% |

### 5.3 相同文件、相同类别的配对结果

每个单元格均为“SemInv / baseline”，百分数；双方文件集合与K相同，N沿用5.1。四项主要指标不包含补充Precision。

| 配对对象 | N×K | SemInv TP/FP/TN/FN | Recall | FPR | Accuracy | F1 | SemInv领先项数 |
|---|---|---|---|---|---|---|---:|
| ConFuzzius | 133×7 | 123/61/737/10 | 92.48 / 55.64 | 7.64 / 6.89 | 92.37 / 87.76 | 77.60 / 56.49 | 3/4 |
| Mythril | 133×7 | 123/61/737/10 | 92.48 / 58.65 | 7.64 / 14.16 | 92.37 / 81.95 | 77.60 / 48.15 | 4/4 |
| Slither | 120×6 | 109/38/562/11 | 90.83 / 88.33 | 6.33 / 33.83 | 93.19 / 69.86 | 81.65 / 49.42 | 4/4 |
| SmartCheck | 108×7 | 98/35/613/10 | 90.74 / 70.37 | 5.40 / 14.04 | 94.05 / 83.73 | 81.33 / 55.27 | 4/4 |
| sFuzz | 54×3 | 48/8/100/6 | 88.89 / 38.89 | 7.41 / 6.48 | 91.36 / 75.31 | 87.27 / 51.22 | 3/4 |
| SMARTIAN | 67×2 | 65/1/66/2 | 97.01 / 89.55 | 1.49 / 2.99 | 97.76 / 93.28 | 97.74 / 93.02 | 4/4 |
| ItyFuzz | 116×4 | 109/20/328/7 | 93.97 / 3.45 | 5.75 / 0.86 | 94.18 / 75.22 | 88.98 / 6.50 | 3/4 |
| DepFuzz | 139×5 | 112/45/530/8 | 93.33 / 76.67 | 7.83 / 4.87 | 92.37 / 91.94 | 80.87 / 76.67 | 3/4 |

**配对结果支持SemInv在这八组的Recall、Accuracy和F1均更高，而不是在全部指标上领先。** 四个指标共享同一组混淆计数，“3/4”是描述性结果，不是三个独立显著性证据。

### 5.4 较弱结果的具体解释

**SMARTIAN主表F1更高。** SMARTIAN的93.02%只涉及两类67例，其中52例、即77.61%为Unchecked low-level calls；SemInv的76.22%涉及全八类，包含较难的Front running、Time manipulation和DoS。共同67例上SemInv为97.74%，不是76.22%。这种差异确实来自评价任务不同，不能据主表跨行断言SemInv更弱或更强。

**ConFuzzius、sFuzz和ItyFuzz的配对FPR更低。** 同样本比较已经消除了样本构成差异，剩余差距不能再归因于不同数据集。SemInv分别多6、1、17个FP，同时多49、27、105个TP，表现为更高检出率与更多额外告警之间的权衡。ItyFuzz仅命中4/116，低FPR主要描述其本地交付结果中的低告警量，不能脱离Recall解释为整体检测更可靠，也不能外推为其原生工具普遍无效。

**DepFuzz的误报更少。** 五类139文件上，SemInv比DepFuzz多20 TP，也多17 FP，因此F1高4.20 pp，Accuracy只高0.43 pp；Precision为71.34%对76.67%，FPR为7.83%对4.87%。这里应表述为较好的检出与综合F1，而不是更低误报。

## 6. 扩展阴性样本的配对检验

原类别子集会排除其他主类别文件，从而漏掉发生在这些文件上的标签外预测。本节对有全139条预测的工具加入这些文件；同一行双方仍使用完全相同的文件与K。Mythril、Slither、SmartCheck现有导出仅有133/120/108条，维持其可核验范围，不将未导出的文件补成空预测。

下表仍为“SemInv / baseline”，百分数。这里的“全部可获得文件”依据归档记录存在性，不按是否成功或是否命中筛选。

| 配对对象 | N×K | Recall | FPR | Accuracy | F1 |
|---|---|---|---|---|---|
| ConFuzzius | 139×7 | 92.48 / 55.64 | 7.62 / 6.67 | 92.39 / 88.18 | 76.88 / 56.27 |
| Mythril | 133×7 | 92.48 / 58.65 | 7.64 / 14.16 | 92.37 / 81.95 | 77.60 / 48.15 |
| Slither | 120×6 | 90.83 / 88.33 | 6.33 / 33.83 | 93.19 / 69.86 | 81.65 / 49.42 |
| SmartCheck | 108×7 | 90.74 / 70.37 | 5.40 / 14.04 | 94.05 / 83.73 | 81.33 / 55.27 |
| sFuzz | 139×3 | 88.89 / 38.89 | 4.41 / 7.99 | 94.72 / 85.13 | 81.36 / 40.38 |
| SMARTIAN | 139×2 | 97.01 / 89.55 | 9.00 / 7.58 | 92.45 / 91.73 | 86.09 / 83.92 |
| ItyFuzz | 139×4 | 93.97 / 3.45 | 5.91 / 0.68 | 94.06 / 79.32 | 86.85 / 6.50 |
| DepFuzz | 139×5 | 93.33 / 76.67 | 7.83 / 4.87 | 92.37 / 91.94 | 80.87 / 76.67 |

扩大阴性样本后，八组的Recall、Accuracy和F1优势均保留，但幅度改变。例如SMARTIAN比较中，SemInv的FP从1增为19，SMARTIAN从2增为16；F1优势由4.72 pp缩小为2.17 pp，FPR则由领先转为落后。sFuzz比较中，双方FP由8/7增为16/29，SemInv的FPR转为更低。这些变化说明不能只选最有利的子集报告。

所有baseline的严格类别交集为空，例如SMARTIAN当前两类与sFuzz当前三类没有交集。因此本报告采用成对共同类别，而不构造一个虚假的“所有工具共同八类”排行榜。

## 7. 八类结果与原因分析

### 7.1 SemInv全139文件上的逐类结果

每一类的FP、TN均在全部139文件中计算。正例数为TP+FN，阴性数为139减正例数。

| 类别 | 正例 | TP | FP | TN | FN | Recall | FPR | Accuracy | F1 | Precision |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Access control | 18 | 17 | 5 | 116 | 1 | 94.44% | 4.13% | 95.68% | 85.00% | 77.27% |
| Arithmetic | 15 | 13 | 5 | 119 | 2 | 86.67% | 4.03% | 94.96% | 78.79% | 72.22% |
| Bad randomness | 8 | 7 | 10 | 121 | 1 | 87.50% | 7.63% | 92.09% | 56.00% | 41.18% |
| Denial of service | 6 | 2 | 0 | 133 | 4 | 33.33% | 0.00% | 97.12% | 50.00% | 100.00% |
| Front running | 4 | 3 | 19 | 116 | 1 | 75.00% | 14.07% | 85.61% | 23.08% | 13.64% |
| Reentrancy | 31 | 27 | 2 | 106 | 4 | 87.10% | 1.85% | 95.68% | 90.00% | 93.10% |
| Time manipulation | 5 | 4 | 9 | 125 | 1 | 80.00% | 6.72% | 92.81% | 44.44% | 30.77% |
| Unchecked low-level calls | 52 | 52 | 14 | 73 | 0 | 100.00% | 16.09% | 89.93% | 88.14% | 78.79% |

### 7.2 逐类Recall：全部baseline

各类阳性文件相同，表中均保留对应失败输入。N/A为当前映射未评价。此表只衡量阳性检出，不代替下一表的误报敏感比较。

| 类别（正例数） | SemInv | ConFuzzius | Mythril | Slither | SmartCheck | sFuzz | SMARTIAN | ItyFuzz | DepFuzz |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Access control (18) | 94.44 | 11.11 | 66.67 | 77.78 | 100.00 | 11.11 | N/A | 5.56 | 33.33 |
| Arithmetic (15) | 86.67 | 53.33 | 73.33 | N/A | 13.33 | N/A | 86.67 | 0.00 | 86.67 |
| Bad randomness (8) | 87.50 | 12.50 | 12.50 | 50.00 | 0.00 | N/A | N/A | N/A | N/A |
| Denial of service (6) | 33.33 | N/A | N/A | 33.33 | 33.33 | N/A | N/A | N/A | N/A |
| Front running (4) | 75.00 | 25.00 | 25.00 | N/A | 25.00 | N/A | N/A | N/A | 0.00 |
| Reentrancy (31) | 87.10 | 51.61 | 48.39 | 93.55 | N/A | 54.84 | N/A | 0.00 | 83.87 |
| Time manipulation (5) | 80.00 | 40.00 | 40.00 | 100.00 | 20.00 | 40.00 | N/A | N/A | N/A |
| Unchecked low-level calls (52) | 100.00 | 84.62 | 69.23 | 100.00 | 100.00 | N/A | 90.38 | 5.77 | 90.38 |

### 7.3 同样本逐类F1

使用第5节共同文件范围。每格为“SemInv / 对应baseline”的F1，单位%。SemInv的值随阴性文件范围改变，故不能固定一条SemInv曲线再与不同阴性集合的baseline曲线相减。

| 类别 | ConFuzzius | Mythril | Slither | SmartCheck | sFuzz | SMARTIAN | ItyFuzz | DepFuzz |
|---|---|---|---|---|---|---|---|---|
| Access control | 87.18/14.81 | 87.18/44.44 | 87.18/26.67 | 85.00/40.45 | 97.14/20.00 | N/A | 87.18/9.09 | 85.00/40.00 |
| Arithmetic | 78.79/57.14 | 78.79/53.66 | N/A | 83.87/19.05 | N/A | 89.66/86.67 | 78.79/0.00 | 78.79/61.90 |
| Bad randomness | 56.00/9.52 | 56.00/16.67 | 56.00/21.62 | 58.33/0.00 | N/A | N/A | N/A | N/A |
| Denial of service | N/A | N/A | 50.00/16.00 | 50.00/12.50 | N/A | N/A | N/A | N/A |
| Front running | 23.08/11.11 | 23.08/5.41 | N/A | 35.29/25.00 | N/A | N/A | N/A | 23.08/0.00 |
| Reentrancy | 90.00/65.31 | 90.00/37.04 | 90.00/66.67 | N/A | 93.10/70.83 | N/A | 90.00/0.00 | 90.00/86.67 |
| Time manipulation | 47.06/22.22 | 47.06/44.44 | 44.44/29.41 | 80.00/33.33 | 47.06/28.57 | N/A | N/A | N/A |
| Unchecked low-level calls | 88.89/87.13 | 88.89/80.00 | 88.89/73.76 | 93.69/95.41 | N/A | 100.00/94.95 | 92.04/10.91 | 88.14/90.38 |

### 7.4 四个关注类别

**Bad randomness。** SemInv命中7/8，漏掉的是没有外部ABI入口的文件。10个FP分别来自Unchecked low-level calls 6例、Access control 2例、Reentrancy 1例、Time manipulation 1例。因此主要问题是随机性依赖告警与单主类别标签之间的非一一对应，不能只删除不可测试样本来宣称100% Recall。配对F1高于四个有映射的baseline；相对Mythril，SemInv的Recall更高但FPR也更高（8.00%对2.40%）。

**Denial of service。** 仅检出2/6，但无FP，F1为50.00%。与Slither、SmartCheck的2/6 Recall持平，后两者分别有17和24个FP，因此配对F1更低。剩余 `dos_address.sol`、`dos_number.sol`、`dos_simple.sol`、`list_dos.sol` 的记录包含泛化gas-limit/其他语义事件，未形成当前规则接受的DoS预测。这提示证据与oracle覆盖不足；不能将所有gas-limit候选直接升级成TP。97.12%的Accuracy主要来自133个阴性标签，不应描述为DoS检测充分。

**Front running。** 命中3/4，优于当前有映射baseline的0/4或1/4，但19个FP使F1仅23.08%。其中9个FP来自Reentrancy、3个来自Access control，其余分布于Arithmetic、Bad randomness、Time manipulation和Unchecked low-level calls。交易顺序/授权竞争类告警的范围较宽，是需要进一步核验的来源。与SmartCheck的同108文件比较排除了Reentrancy文件，SemInv FP由19降为10，F1为35.29%，高于SmartCheck的25.00%。这解释了配对子集与全量F1的差异，但不能将35.29%当作全139文件结果。

**Time manipulation。** 命中 `governmental_survey.sol`、`lottopollo.sol`、`roulette.sol`、`timed_crowdsale.sol`，漏掉 `ether_lotto.sol`。后者选定run正常结束，仅保留Bad randomness预测，没有可归属的时间事件，不能仅凭源码存在时间语义就补算时间TP。9个FP中8个来自Reentrancy、1个来自DoS；正常时间锁与可利用时间依赖在告警层仍可能混淆。与SmartCheck的108文件范围不含Reentrancy，SemInv只剩1 FP，F1为80.00%，而全量为44.44%。两者都是正确但不同任务的结果。Slither的时间Recall为100%，高于SemInv的80%；SemInv在共同120文件上FP为9、Slither为24，因此F1为44.44%对29.41%。

上述四类在现有映射的配对F1上均优于相应baseline，但绝对表现并非都强：DoS漏报突出，Front running与Time manipulation的Precision分别只有13.64%和30.77%。这比笼统称“弱类已经解决”更准确。

### 7.5 其余四类及残余漏报

- **Access control：** 17/18，唯一FN为 `parity_wallet_bug_1.sol`。共同范围内F1高于所有有映射baseline，但SmartCheck的18/18 Recall更高；其额外告警更多。
- **Arithmetic：** 13/15，与SMARTIAN、DepFuzz的阳性检出率持平。FN为 `insecure_transfer.sol` 和 `integer_overflow_benign_1.sol`，均保留原标签计分，不因名称含benign或证据规则较严格而事后删除。全量5 FP中2个来自Access control、2个来自Reentrancy、1个来自Unchecked low-level calls；在SMARTIAN两类子集中只剩1 FP。
- **Reentrancy：** 27/31、2 FP，F1为90.00%。Slither命中29/31，Recall更高，但配对F1为66.67%。SemInv的四个FN为 `0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol`、`0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol`、`reentrancy_dao.sol`、`spank_chain_payment.sol`。
- **Unchecked low-level calls：** 52/52，14 FP中7个来自Reentrancy。SemInv的高Recall不意味着最优F1：与SmartCheck同范围时为93.69%对95.41%，与DepFuzz同139文件时为88.14%对90.38%。前者同样52 TP但更少FP；后者为47 TP、5 FP，体现更保守的告警输出。

8个类别中的小类只含4至8个正例。例如Front running改变1个命中就改变25 pp Recall，Time manipulation则改变20 pp；类别结论应同时给出TP/正例数，而不只呈现百分比。

## 8. 全部fuzz baseline覆盖率

### 8.1 定义与可比范围

normalized concrete instruction coverage仅统计具体执行访问的目标runtime指令PC，占同一反汇编规则下指令PC集合的比例；PUSH立即数不作为独立指令。normalized concrete branch coverage将每个JUMPI的条件归一为false/true，以已观察到的 `(JUMPI PC, bool outcome)` 数除以 `2 × JUMPI数`。部署阶段与仅符号访问不计入具体runtime覆盖。

跨工具严格比较要求相同文件、相同目标合约和相同可执行runtime；仅去除两适配器一致处理的旧式0029元数据后比较字节码。覆盖率先按文件计算，再对共同观测取算术平均，不按指令规模加权。没有快照记缺失，既不补0也不按100%处理；每项同时报告有效观测数N。

### 8.2 覆盖数据清单

本表是可获得数据的清单，不将不同定义的原生数字混作一个排行榜。

| 工具/口径 | 有效N | Instruction/code | Branch | 其他原生记录 |
|---|---:|---:|---:|---|
| SemInv，observed原生/进度记录 | 127 | 83.35% | 85.89% | 包括有可用记录的非正常结束任务。 |
| SemInv，normalized concrete | 91 | 86.54% | 89.79% | 完整快照可统一重算。 |
| ConFuzzius，native | 108 | 85.22% | 83.83% | 分支原始条件去重，不等同于布尔分支结果。 |
| sFuzz，native | 107 | N/A | N/A | 原生coverage均值64.62%；含1条125%异常，未截断为100%。 |
| SMARTIAN，native计数 | 133 | N/A | N/A | 平均covered instructions 689.25、covered edges 46.05；无统一分母，不能写为百分率。 |
| ItyFuzz，目标合约coverage.json | 123 | 67.13% | 58.76% | 使用对应目标合约，不取日志最后一个辅助合约；指令分母规则不同。 |
| DepFuzz，native code | 136 | 92.73% | N/A | 原生code含符号探索访问，不能与concrete code直接等价。 |
| DepFuzz，normalized concrete | 137 | 88.74% | 82.31% | 由具体执行适配器记录，排除仅符号访问。 |

sFuzz异常对应 `FibonacciBalance.sol`，缺少可统一重算的trace/分母，不用于normalized排名。SMARTIAN保存的测试用例可以支持后续重放，但本次没有将测试用例数量或覆盖计数当作覆盖百分率。Slither、SmartCheck、Mythril不纳入fuzz执行覆盖表。

### 8.3 SemInv与DepFuzz严格配对

| 匹配范围 | N | SemInv instruction | DepFuzz instruction | 差值 | SemInv branch | DepFuzz branch | 差值 |
|---|---:|---:|---:|---:|---:|---:|---:|
| 同文件、同目标 | 91 | 86.54% | 92.21% | -5.68 pp | 89.79% | 84.29% | +5.50 pp |
| **同文件、同目标、同可执行runtime** | **89** | **86.45%** | **93.59%** | **-7.14 pp** | **89.60%** | **85.40%** | **+4.20 pp** |

主覆盖结论使用第二行。这89例有完整可比快照，不代表全部139例；SemInv在此配对中的观测均来自正常完成任务。覆盖数据的缺失性与完成状态相关，不能用该均值推断其他50个输入的执行覆盖。

分支结果覆盖较高但指令覆盖较低并不矛盾：访问某个条件分支两侧与访问更大范围的指令集合是不同目标。现有数据支持“SemInv在这些共同runtime上覆盖更多分支结果”，不直接证明该差异由某个单一模块导致；模块因果解释需要消融结果支持。

### 8.4 其他可获得的同文件、同目标原生比较

| Baseline | N | SemInv code / baseline code | SemInv branch / baseline branch |
|---|---:|---|---|
| ConFuzzius | 99 | 85.74% / 86.91% | 87.30% / 84.64% |
| ItyFuzz | 116 | 84.77% / 67.44% | 86.82% / 58.91% |

此表使用双方有值的原生/observed记录，故N与完整normalized快照数不同。同目标配对减少合约选择差异，但不能消除runtime、指令分母与分支定义的差异；仅作为上下文。尤其本轮SemInv相对ConFuzzius的原生code均值略低，不能沿用旧文“code和branch都更高”的笼统结论。

## 9. 论文表图组织与结果表述

### 9.1 保留现有结构并补充

1. **整体结果表：** 使用5.2，保留原有工具，增加SMARTIAN、ItyFuzz、DepFuzz；保留N、K和四项指标。
2. **共同范围比较：** 紧接主表加入5.3，或在正文突出ConFuzzius、SMARTIAN、DepFuzz的成对值，并完整保留八组数据于附录。扩展阴性样本检验使用第6节。
3. **逐类别图：** 原有F1图不因结果不理想而删除。适合改为7.3的“配对F1差值”热图或每baseline一个小面板，保证同一比较中的阴性范围一致；N/A留空。补充7.2的Recall图，标注TP/正例数，用于展示少数类的检出能力。若篇幅只能保留一幅检测效果图，以F1为主、Recall及FP留在对应表中。
4. **覆盖表：** 主体呈现8.3严格normalized配对；8.2保留全部fuzz baseline覆盖清单，8.4作为原生指标补充。不能用原生edge计数填入branch百分率列。

图表不应把全量SemInv F1与不同文件集合上的baseline逐类F1连成一张貌似同范围的排名曲线。配对图可以同时展示优势与例外，例如Unchecked low-level calls相对SmartCheck、DepFuzz仍有F1劣势。

### 9.2 可用于正文的结果段落

> 在SB Curated的139个文件上，SemInv检出125个主类别漏洞，产生64个额外类别预测，Recall、FPR、Accuracy和F1分别为89.93%、6.58%、92.99%和76.22%。为区分工具类别范围与检测效果，我们进一步在每个baseline对应的共同文件和评分类别上比较。SemInv在八组比较中的Recall、Accuracy和F1均更高，并在扩展可获得的阴性文件后保持这一趋势。相对ConFuzzius，SemInv的F1从56.49%提高到77.60%；相对SMARTIAN，共同67例上的F1为97.74%对93.02%；相对DepFuzz，共同五类139文件上的F1为80.87%对76.67%。这些改善并非普遍降低误报：在相同范围内，SemInv相对ConFuzzius和DepFuzz的FPR仍较高。

> 类别结果显示，SemInv对Access control、Reentrancy和Unchecked low-level calls具有较好的检出表现。Bad randomness命中7/8，Front running命中3/4，Time manipulation命中4/5，但后两类分别产生19和9个额外类别预测，限制了F1。DoS仅命中2/6，仍是主要漏报来源之一。覆盖分析进一步表明，在89个相同runtime的共同观测上，SemInv的具体分支结果覆盖率为89.60%，高于DepFuzz的85.40%，而具体指令覆盖率为86.45%，低于DepFuzz的93.59%。因此，实验支持SemInv在本基准上的整体检测与分支探索优势，同时显示出误报控制和部分类别检测方面的改进空间。

## 10. 结果适用范围

- **标签完整性：** 主类别标注适合类别级检出比较，但不足以判断每个额外告警是否真实可利用。本报告不将标签FP等同于已人工证伪的漏洞报告。
- **映射完整性：** 本地严格映射不覆盖所有baseline原生oracle，结果描述的是这些配置和已映射告警的交付效果。不能据K值声称baseline本质上不支持其余类别。
- **规则开发与独立验证：** T/evidence-safe的修订参考过当前数据，本文属于固定最终规则后的回顾性重评分，不是独立留出集验证；需要在独立数据上验证泛化改善。
- **系统效果与模块贡献：** SemInv同时利用同轮静态语义与动态证据，因此本节评估完整系统，不将全部增益归因于fuzz搜索或UIR单模块。
- **运行随机性：** 当前表是选定归档运行的结果，未估计多seed方差，不使用“统计显著优于”表述。小类样本数与相近差值须结合绝对TP/FP理解。
- **目标粒度：** 检测按源文件配对，不保证所有历史工具选择相同子合约；覆盖严格结论另加目标与runtime匹配。历史缺少预测导出的文件未被虚构补全。

## 11. 数据、复核与复现

本次仅离线读取归档结果，未运行fuzz/replay，未修改检测代码，未覆盖旧报告。新输出位于 [rq1_T_300plus600_20261013](<seminv-workspace>/outputs/rq1_T_300plus600_20261013)。

| 内容 | 文件 |
|---|---|
| 汇总脚本 | [report_rq1_t_300_600.py](<seminv-workspace>/tools/report_rq1_t_300_600.py) |
| 逐文件run选择，62个300s、77个600s | [selected_runs.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/selected_runs.csv) |
| 固定T预测和真实状态 | [predictions.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/predictions.csv) |
| 全量与适用子集指标 | [overall.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/overall.csv) |
| 全量1112个TP/FP/TN/FN判断 | [all_139_mapping.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/all_139_mapping.csv) |
| 八类指标 | [all_139_categories.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/all_139_categories.csv) |
| 两种文件范围的全部配对指标 | [paired_metrics.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/paired_metrics.csv) |
| 配对类别指标，含Recall/FPR/Accuracy/F1 | [paired_categories.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/paired_categories.csv) |
| 双方逐文件预测及baseline输入路径 | [paired_samples.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/paired_samples.csv) |
| 全部配对GT判断 | [paired_mapping.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/paired_mapping.csv) |
| 基线状态与全局排除审计 | [baseline_status.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/baseline_status.csv)、[global_exclusion_audit.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/global_exclusion_audit.csv) |
| 64个FP的来源类别、14个FN明细 | [fp_origins.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/fp_origins.csv)、[false_negatives.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/false_negatives.csv) |
| 全部fuzz覆盖观测及均值 | [coverage_inventory.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/coverage_inventory.csv)、[coverage_means.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/coverage_means.csv) |
| normalized严格配对及逐样本数据 | [paired_normalized_coverage.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/paired_normalized_coverage.csv)、[paired_normalized_coverage_samples.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/paired_normalized_coverage_samples.csv) |
| 原生辅助配对 | [native_coverage_pairs.csv](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/native_coverage_pairs.csv) |
| 选择与计分校验 | [verification.json](<seminv-workspace>/outputs/rq1_T_300plus600_20261013/verification.json) |

SemInv输入来自 [统一失败口径600s累计预测](<seminv-workspace>/outputs/seminv_T_unified_failure_policy_20261012/round_600s/predictions.csv)，并逐条与原实验600s consolidated summary和300s首轮核对。SMARTIAN/ItyFuzz来自 `smartian_ityfuzz_formal_300s_seed1_20260929`；DepFuzz来自 `depfuzz_coverage_adapter_full139_1200s_seed1_20261008`；其余baseline来自 `<previous-artifact-root>/experiment_data/analysis/rq1_detection/results/tool_metrics`。每组具体输入路径保存在配对明细中。

复现命令（PowerShell，工作目录 `<seminv-workspace>`）：

```powershell
& '<seminv-workspace>/.venv-seminv-a1/Scripts/python.exe' -B -X utf8 `
  tools/report_rq1_t_300_600.py --out outputs/rq1_T_300plus600_20261013
```

校验包括：139个文件键唯一；77个首轮timeout全部使用600s替换；其余62例run与预测未变；1200s输入为0；真实执行状态与raw退出记录一致；每组TP+FP+TN+FN=N×K；原有范围baseline预测逐项复现；三个静态/符号工具的未导出文件不补造；全局可剔除文件为0。
