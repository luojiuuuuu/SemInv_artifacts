# SemInv 与现有 Fuzz 工具：覆盖率与命中随时间的变化

分析更新：2026-10-15。本文档依据已经完成的 RQ5 实验及离线采集产物，给出新增章节的统计口径、完整数据分析、图表安排和英文正文草稿。现有 RQ1 的 Precision、Recall、FPR、F1 继续承担总体检测效果评价；本章研究搜索过程中的执行覆盖、候选发现时间和追加预算收益。

## 1. 章节定位与主要结论

建议章节名为 **Coverage and Discovery Dynamics**，研究问题为：**How does SemInv compare with existing fuzzers in concrete execution coverage and the accumulation of GT-matching candidates over time?**

现有数据支持的主线是：SemInv 在较短搜索预算下保持较高的累计 GT 匹配命中；其具体分支覆盖优于 DepFuzz 和 ItyFuzz，对原版 ConFuzzius 则有小幅覆盖差距。更多执行覆盖与更多候选命中并不等价，命中差异还涉及输入序列、状态、检测器和报告规则。现有比较可以展示这种差异，机制因果归因仍应结合消融实验。

关键证据如下。

- 五工具共同的 128 个 runtime 上，SemInv 在 600s 的指令/分支宏平均覆盖为 **89.72%/91.04%**；DepFuzz 为 **90.78%/83.53%**；原版 ConFuzzius 为 **91.69%/92.37%**；SMARTIAN 为 **88.66%/70.58%**；ItyFuzz 为 **40.91%/34.48%**。SMARTIAN 为保存语料回放观测，其他四工具为全部搜索执行观测。
- SemInv 对 DepFuzz 的分支覆盖优势同时出现在宏平均、微平均及逐合约比较中。在两工具较大的 137 个配对样本上，分支宏平均高 **7.53 个百分点**，109 个样本更高、2 个相同、26 个更低。
- 在按检测范围配对的五组主比较中，SemInv 在 10s 检查点分别得到 **112/120、119/131、93/98、47/51、17/18** 个 T 命中；对应 DepFuzz、ConFuzzius、SMARTIAN、sFuzz、ItyFuzz 为 **84/120、97/131、63/98、25/51、2/18**。
- 在同时满足检测范围和 runtime 配对的 125 个 SemInv/ConFuzzius 样本上，命中为 **118 vs 102**。SemInv 独有的 17 个命中中，有 **10 个样本两工具的指令、分支覆盖率均相同**。
- SemInv 在全体 Strict8 上的累计命中于 60s 检查点达到本轮最终值 129，随后至 600s 没有新增目标 GT 命中；128 个共同样本上，其分支覆盖仍增加 **3.77 个百分点**。SMARTIAN 在 120–600s 新增的 3 个命中均来自重入类别。

ItyFuzz 与其他 fuzz baseline 一起进入常规表格和主曲线。覆盖率主图只保留 (a) 指令和 (b) 分支两个子图，均展示 SemInv、DepFuzz、ConFuzzius、SMARTIAN、ItyFuzz；图例直接使用工具名，采集方式在本报告设置与建议图注中说明。sFuzz 不进入该图，其原生指标保留在第 6.2 节。本章重点呈现时间过程，不重复总体实验中的 F1 等终点指标。

## 2. 统一且可解释的统计口径

### 2.1 数据与时间轴

固定数据集为 143 个源文件，其中 139 个属于 Strict8 GT 类别。其余 3 个 other 和 1 个 short_addresses 可以进入执行覆盖分析，不进入 Strict8 命中分母。本轮采用最多 600s 搜索预算；SemInv 为 RQ3 Full 对应设置、seed=11、高 generation cap，并关闭 replay/minimization 等后处理。原版 ConFuzzius 使用 `ConFuzzius_orignal`，不是修改后的 SemInv 仓库。

检查点为 0、10、30、60、120、180、300、450、600s。SemInv 沿用总体实验的 T 口径，0s 初始状态包含准备阶段已有候选。横轴是各工具可取得的搜索/运行日志时钟：SemInv、DepFuzz、ConFuzzius 有搜索观测时钟，SMARTIAN/ItyFuzz 命中使用原生时间记录，sFuzz 使用统计快照时间上界。下文统一讨论搜索预算下的累计命中，不展开命中来源。

ItyFuzz 命中来自原始正式轮，覆盖来自使用相同目标编译产物的独立观察器轮。各工具采用已记录的运行环境、检测器配置和观测实现，未控制为相同 CPU 成本，也未单独测量插桩开销。因此本章比较当前配置下的观测结果，不据此推导端到端加速倍数或将差异全部归因于搜索算法。

### 2.2 Hit 的含义与比较集合

每个文件首次产生与其 GT 类别匹配的候选后，累计命中计为 1；相同样本的重复候选不重复计数。SemInv 使用 T/evidence-safe，baseline 使用已核对的原生标签映射。这里的 hit 是 **GT-matching candidate hit**，不等于 replay 确认的可利用漏洞。

不同工具检测范围不同，使用逐 baseline 的固定共同范围。本文采用现有报告中的 `audited` 映射，属于事后标签语义核对，不描述成预先注册的映射。SMARTIAN 纳入已保存的重入标签，sFuzz 纳入明确的 overflow/underflow；原定 `frozen` 结果保留在原报告中。

| 配对 baseline | 本轮纳入的 GT 类别 | 固定 N | 主要用途 |
| --- | --- | ---: | --- |
| DepFuzz | access_control、arithmetic、front_running、reentrancy、unchecked_low_level_calls | 120 | 命中时间主比较 |
| ConFuzzius | 上述五类及 denial_of_service、time_manipulation | 131 | 命中时间主比较 |
| SMARTIAN | arithmetic、reentrancy、unchecked_low_level_calls | 98 | 命中时间主比较 |
| sFuzz | arithmetic、reentrancy、time_manipulation | 51 | 命中时间主比较 |
| ItyFuzz | high_confidence 配置下可映射的 access_control 类别代理 | 18 | 命中时间主比较 |

GT 范围内的失败样本保留在固定分母中，失败前预算内已保存的有效命中予以保留；超出当前标签映射范围的类别为 N/A。各配对面板内的分母一致，不同面板之间不按百分比直接排名。六工具的严格共同检测类别交集为空，不能构造有意义的六工具同一 GT 分母总排名。

各工具未进入部分**类别命中对比**的原因如下。这里描述本轮配置和已采用的标签映射，不表示该工具所有版本都不能检测这些漏洞，也不把 N/A 计作零命中。

| Baseline | 本轮类别命中表中的 N/A | 未纳入的具体原因 |
| --- | --- | --- |
| DepFuzz | bad_randomness、denial_of_service、time_manipulation | 本轮采用的 DEP5 映射限于上述五类，没有为这三类建立可独立归类的候选映射。 |
| ConFuzzius | bad_randomness | 本轮 Block Dependency 映射用于 time_manipulation，没有从该标签再独立识别 bad_randomness；不将同一个依赖标签同时扩张为两个类别。 |
| SMARTIAN | access_control、bad_randomness、denial_of_service、front_running、time_manipulation | 本轮纳入有明确对应关系的 IB、ME、RE；BD 等原生信号没有建立到这些 Strict8 类别的独立映射，尤其不能不分语义地同时计为 randomness 和 time。 |
| sFuzz | access_control、bad_randomness、denial_of_service、front_running、unchecked_low_level_calls | 本轮已核对的映射使用 overflow/underflow、reentrancy、timestamp；其他原生字段未建立与这些 GT 类别一致的映射，不能仅按名称相似计入。 |
| ItyFuzz | 除 access_control 外的七个 Strict8 类别 | 当前 high_confidence 配置采用可映射的 Selfdestruct/Arbitrary Call 类别代理；未将可选或不同语义的 oracle 当作本轮已启用的类别检测器。 |

在当前按文件 GT 二值计数方式下，H(t)/N 数学上就是该范围的 recall@t。本章的新信息来自时间过程、早期产出和后期增益，不将最终 hit rate 包装成独立于 Recall 的新准确率指标。

### 2.3 Concrete 覆盖率

对同一目标 runtime 使用相同反汇编与尾部元数据处理规则。指令分母为 opcode 起始 PC，排除 PUSH 立即数；分子为目标执行中实际观测的 PC 与分母的交集。normalized concrete 分支分母为 `2 × JUMPI 数量`，分子为实际观测的 `(JUMPI PC, condition != 0)` 二元结果集合。该覆盖率不是任意长度路径覆盖，也不等于可行路径百分比。

工具间覆盖比较要求处理元数据后的 runtime 一致，且指令/分支分母相同。采集范围为目标入口执行；符号求解路径、报警计数和不同非零条件值均不额外计作分支。每个检查点取不晚于该时点的最后累计快照；缺失为 N/A。正常早停后沿用最后累计值，保留失败前的有效执行覆盖。

主图采用固定 **128 个共同样本**，即原四工具 130 样本集合与 SMARTIAN/SemInv 的 135 样本 runtime 配对集合的交集。相对原四工具集合移除 `sb007`、`sb054`，原因是缺少有效 SMARTIAN 回放，不根据覆盖高低筛选。五条曲线均在这个交集上从逐样本计数重算，不沿用 130/135 样本的旧均值。10–600s 每个检查点均有全部 128 个样本的记录；0s 缺少五工具共同记录，不人为补零。宏平均为每合约等权，微平均为覆盖数总和除以分母总和。

SMARTIAN 使用保存语料的插桩回放，指标定义、目标 runtime 和分母与其他工具一致，时间采用 testcase 文件名中的原始发现秒数，而不是回放耗时。SemInv、DepFuzz、ConFuzzius、ItyFuzz 使用全部搜索执行观测。因此主图比较共同样本上的已观测 concrete 覆盖，不将 SMARTIAN 曲线等同为它的全部搜索覆盖；终值、增量、时间均值和类别表均沿用这一采集说明。sFuzz 的 `stats.csv` 缺少目标 PC 集合和 JUMPI 真/假集合，原生分母也不同，故不进入该图和统一覆盖表。缺席原因不涉及覆盖数值高低。

## 3. 命中随时间变化

### 3.1 五组 baseline 配对

下表每格为 SemInv / baseline 的累计命中数。列内分母固定。

| 搜索时钟 t(s) | DepFuzz N=120 | ConFuzzius N=131 | SMARTIAN N=98 | sFuzz N=51 | ItyFuzz N=18 |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 51 / 0 | 53 / 0 | 50 / 21 | 0 / 0 | 0 / 1 |
| 10 | 112 / 84 | 119 / 97 | 93 / 63 | 47 / 25 | 17 / 2 |
| 30 | 113 / 91 | 120 / 102 | 94 / 67 | 48 / 27 | 17 / 2 |
| 60 | 115 / 93 | 122 / 103 | 95 / 71 | 49 / 33 | 17 / 2 |
| 120 | 115 / 94 | 122 / 104 | 95 / 76 | 49 / 33 | 17 / 2 |
| 180 | 115 / 94 | 122 / 104 | 95 / 76 | 49 / 33 | 17 / 2 |
| 300 | 115 / 94 | 122 / 104 | 95 / 78 | 49 / 33 | 17 / 2 |
| 450 | 115 / 94 | 122 / 104 | 95 / 79 | 49 / 33 | 17 / 2 |
| 600 | 115 / 94 | 122 / 104 | 95 / 79 | 49 / 33 | 17 / 2 |

![Paired GT candidate discovery over time](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/fuzz_section_hits.png)

图中阶梯保持最近检查点的累计值；阶梯的跳变位置表示观测检查点，不声称所有漏洞恰在这些时刻发现。小图展示前 60s，主图保留 600s 预算及 SMARTIAN 的后期增长。0s 的含义采用第 2.1 节设置及工具原生整数时间桶。

### 3.2 时间积分与趋稳速度

使用检查点左端值计算 `AUC_H = sum[H(t_i) × (t_(i+1)-t_i)] / (600 × N)`，以百分数表示。它是在固定共同范围中、整个预算期间的平均已命中比例；相对于同一累计过程的精确时间积分，这是保守的检查点近似。它同时受到发现速度和最终命中数影响，不是纯粹的吞吐指标。

| Baseline | SemInv AUC_H (%) | Baseline AUC_H (%) | SemInv 达到自身最终命中 95% 的首个检查点 | Baseline 对应检查点 |
| --- | ---: | ---: | ---: | ---: |
| DepFuzz | 94.78 | 76.54 | 10s | 30s |
| ConFuzzius | 92.10 | 77.74 | 10s | 30s |
| SMARTIAN | 96.05 | 76.48 | 10s | 120s |
| sFuzz | 94.25 | 62.52 | 10s | 60s |
| ItyFuzz | 92.87 | 11.02 | 10s | 10s |

这些结果支持“SemInv 在较短搜索预算内保持较高累计候选产出”。达到自身最终命中 95% 的时间用于描述曲线趋稳；最终只找到少量目标的工具也可能很早趋稳，因而该时间必须与命中数一起解读。现有单轮数据不支持把 10s vs 120s 写成端到端 12 倍加速。

### 3.3 哪些类别需要较长搜索

每格依次为 10s / 60s / 600s 累计命中。N/A 表示当前映射不覆盖该类别，各 baseline 的缺席原因逐项列于第 2.2 节；它不表示该类别上已经运行但零命中。

| 类别（GT N） | SemInv | DepFuzz | ConFuzzius | SMARTIAN | sFuzz | ItyFuzz |
| --- | --- | --- | --- | --- | --- | --- |
| access_control (18) | 17 / 17 / 17 | 7 / 8 / 8 | 8 / 9 / 9 | N/A | N/A | 2 / 2 / 2 |
| arithmetic (15) | 12 / 13 / 13 | 11 / 12 / 12 | 12 / 12 / 12 | 13 / 13 / 13 | 9 / 10 / 10 | N/A |
| bad_randomness (8) | 7 / 7 / 7 | N/A | N/A | N/A | N/A | N/A |
| denial_of_service (6) | 2 / 2 / 2 | N/A | 0 / 0 / 0 | N/A | N/A | N/A |
| front_running (4) | 2 / 3 / 3 | 0 / 0 / 0 | 2 / 2 / 2 | N/A | N/A | N/A |
| reentrancy (31) | 30 / 31 / 31 | 21 / 26 / 26 | 26 / 29 / 29 | 5 / 12 / 19 | 16 / 22 / 22 | N/A |
| time_manipulation (5) | 5 / 5 / 5 | N/A | 4 / 4 / 4 | N/A | 0 / 1 / 1 | N/A |
| unchecked_low_level_calls (52) | 51 / 51 / 51 | 45 / 47 / 48 | 45 / 47 / 48 | 45 / 46 / 47 | N/A | N/A |

重入最能体现时间过程差异：SemInv 在 10s 已有 30 个命中，SMARTIAN 从 10s 的 5 个增长至 60s 的 12 个、120s 的 16 个和最终 19 个。反过来，arithmetic 上 SMARTIAN 在 10s 已达到 13 个，SemInv 当时为 12 个；不应概括为 SemInv 在每个类别和每个时刻都更早。

Bad randomness 和 DoS 的累计命中在 10s 时分别为 7 和 2，随后保持不变。DoS 剩余的 gas/状态增长子型在本轮没有成为 T 接受的 GT 命中；继续搜索到 600s 没有改变这一点。这里支持的解释是当前候选/子型覆盖仍有限，不能把缺口统称为 timeout。Time manipulation 本轮是 5 个早期命中，相关结果是 timestamp 依赖证据，不把它等同为盈利攻击验证。ItyFuzz 当前检测配置映射到 access_control 的 2 个命中均在首个 10s 检查点前出现。

## 4. 具体执行覆盖率与追加预算收益

### 4.1 五工具 128 个共同 runtime 的主比较

固定 N=128；所有数字为百分数。SMARTIAN 为 corpus replay，其他四工具为 all-search observations，采集方式见第 2.3 节。宏/微平均不能互换。

论文 Table 7 的紧凑替换版如下，与当前覆盖率图使用同一 128 样本集合。相对截图中的旧表，新增 SMARTIAN，并将原四工具的 130 样本均值统一重算为 128 样本均值。增量由未舍入的 600s 与 60s 宏平均相减得到，单位为百分点；每列最高值加粗。

**Execution coverage at 600 seconds and additional coverage gain from 60 to 600 seconds on 128 common contracts.**

| Tool | 600s Cov. (%) Instr. | 600s Cov. (%) Branch | 60–600s Gain (pp) Instr. | 60–600s Gain (pp) Branch |
| --- | ---: | ---: | ---: | ---: |
| SemInv | 89.72 | 91.04 | **4.47** | **3.77** |
| DepFuzz | 90.78 | 83.53 | 0.58 | 0.71 |
| ConFuzzius | **91.69** | **92.37** | 1.15 | 0.98 |
| SMARTIAN | 88.66 | 70.58 | 1.00 | 0.86 |
| ItyFuzz | 40.91 | 34.48 | 2.43 | 2.00 |

Note: Instr. and Branch denote instruction and branch coverage, respectively, macro-averaged across contracts. SMARTIAN coverage is measured by saved-corpus replay; the other tools use all-search observations.

可直接插入论文的 [LaTeX 表格](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/tables/fuzz_section_coverage_table.tex) 保持原表的双层表头和 booktabs 排版。下表保留宏/微平均的完整对照数据。

| 工具 | 600s 指令 macro | 600s 指令 micro | 600s 分支 macro | 600s 分支 micro |
| --- | ---: | ---: | ---: | ---: |
| SemInv | 89.72 | 73.50 | 91.04 | 78.84 |
| DepFuzz | 90.78 | 75.24 | 83.53 | 75.97 |
| ConFuzzius | 91.69 | 78.53 | 92.37 | 81.83 |
| SMARTIAN | 88.66 | 79.10 | 70.58 | 68.33 |
| ItyFuzz | 40.91 | 23.60 | 34.48 | 20.86 |
| sFuzz | N/A | N/A | N/A | N/A |

sFuzz 的 N/A 原因是原生聚合指标不能还原统一 PC/JUMPI 覆盖，已有原生时间表见第 6.2 节；它不进入本表数值比较。

SemInv 对 DepFuzz 的分支宏平均优势为 7.51 个百分点，微平均优势为 2.88 个百分点；指令宏平均低 1.06 个百分点。对 ConFuzzius，指令和分支宏平均分别低 1.97 和 1.33 个百分点。对 ItyFuzz，指令和分支宏平均分别高 48.81 和 56.56 个百分点。差值均由未舍入数值计算，最后显示两位小数。

相对于 SMARTIAN 的已保存语料回放，SemInv 指令宏平均高 1.06 个百分点，但指令微平均低 5.60 个百分点；分支宏/微平均分别高 20.46/10.51 个百分点。这是已观测结果的差值，不扩展为双方全部搜索覆盖的严格排名。原 130 样本四工具结果保留在派生数据及补充图中，不与当前 128 样本均值混用；本轮没有多随机种子显著性证据。

| t(s) | SemInv 指令 | DepFuzz 指令 | ConFuzzius 指令 | SMARTIAN 指令 | ItyFuzz 指令 | SemInv 分支 | DepFuzz 分支 | ConFuzzius 分支 | SMARTIAN 分支 | ItyFuzz 分支 |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 10 | 80.19 | 86.92 | 87.02 | 86.00 | 36.72 | 82.07 | 79.56 | 87.46 | 68.30 | 30.94 |
| 30 | 83.78 | 89.55 | 89.99 | 86.67 | 38.17 | 85.71 | 82.27 | 90.79 | 68.87 | 32.25 |
| 60 | 85.26 | 90.20 | 90.54 | 87.66 | 38.48 | 87.27 | 82.82 | 91.39 | 69.72 | 32.48 |
| 120 | 87.12 | 90.41 | 91.32 | 88.53 | 38.49 | 88.93 | 83.21 | 92.00 | 70.45 | 32.48 |
| 180 | 88.43 | 90.67 | 91.39 | 88.61 | 38.49 | 90.05 | 83.37 | 92.06 | 70.52 | 32.48 |
| 300 | 89.22 | 90.71 | 91.57 | 88.64 | 39.77 | 90.64 | 83.48 | 92.24 | 70.56 | 33.53 |
| 450 | 89.56 | 90.78 | 91.65 | 88.65 | 40.01 | 90.92 | 83.53 | 92.32 | 70.57 | 33.74 |
| 600 | 89.72 | 90.78 | 91.69 | 88.66 | 40.91 | 91.04 | 83.53 | 92.37 | 70.58 | 34.48 |

![Five-tool concrete coverage on 128 common runtimes](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/fuzz_section_coverage.png)

图 (a) 为指令覆盖、(b) 为 normalized concrete 分支覆盖，五工具均使用同一 128 样本集合和分母，图例仅列工具名。SMARTIAN 曲线按原始 testcase 发现时间组织保存语料回放覆盖，其余四条曲线来自全部搜索执行；相关说明保留在报告和建议图注，不放入图内。两个面板均保留 0–100% 纵轴，线段只连接有记录的检查点。

原 [130 样本四工具全搜索图](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/fuzz_section_coverage_all_search.pdf)作为独立补充保留，不是当前主图。它未含 SMARTIAN，是因为该工具现有数据为保存语料回放；未含 sFuzz，是因为缺少统一 PC/JUMPI 原始记录。

### 4.2 继续搜索带来多少收益

以下增量和时间均值均使用图 (a,b) 的 128 样本集合。SMARTIAN 一行表示原发现时间对应的保存语料覆盖增量，不是全部搜索执行增量；sFuzz 缺少同定义的 PC/JUMPI 记录，未纳入。

| 工具 | 60–600s 新增指令覆盖(pp) | 60–600s 新增分支覆盖(pp) | 120–600s 新增指令覆盖(pp) | 120–600s 新增分支覆盖(pp) |
| --- | ---: | ---: | ---: | ---: |
| SemInv | 4.47 | 3.77 | 2.60 | 2.11 |
| DepFuzz | 0.58 | 0.71 | 0.37 | 0.32 |
| ConFuzzius | 1.15 | 0.98 | 0.37 | 0.37 |
| SMARTIAN | 1.00 | 0.86 | 0.12 | 0.14 |
| ItyFuzz | 2.43 | 2.00 | 2.42 | 2.00 |

SemInv 早期指令覆盖低于 DepFuzz 和 ConFuzzius，随后逐步缩小差距；其指令与分支覆盖在所有观测点均高于 ItyFuzz。SemInv 在较晚时间仍有执行覆盖增量，但这些增量没有带来更多累计 GT 命中。ItyFuzz 在 120–600s 的指令和分支分别增加 2.42 和 2.00 个百分点；SMARTIAN 保存语料在同区间也有 0.12 和 0.14 个百分点的增量。不能据此声称 60s 对其他数据集、随机种子或漏洞子型同样充分。

以 10–600s 的检查点左端值计算覆盖率时间均值，SemInv/DepFuzz/ConFuzzius/SMARTIAN/ItyFuzz 的指令均值为 **87.95%/90.45%/91.19%/88.34%/39.12%**，分支均值为 **89.53%/83.18%/91.88%/70.29%/33.00%**。SMARTIAN 的时间均值保持其语料回放解释。0–10s 缺乏共同起始快照，积分区间限定为 590s，未将缺失区间补成零。

DepFuzz 本轮大量样本原生提前结束，搜索末观测中位数约 21.15s；其曲线后段包含保留的累计值。SemInv 正常任务持续至预算，失败任务保留前缀。因此“更大的后期覆盖增量”是当前运行策略的观测结果，还不能独立归因于某个搜索模块的持续能力。

### 4.3 分支覆盖的类别分布

下表与图 (a,b) 使用同一个 128 样本集合，报告 600s 的分支宏平均百分比。覆盖不依赖该类别是否启用检测器，因此五工具均可列出；SMARTIAN 为保存语料回放。sFuzz 缺席源于覆盖定义/数据不匹配，而不是不支持表中类别。

| 类别 | 共同 N | SemInv | DepFuzz | ConFuzzius | SMARTIAN | ItyFuzz |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| access_control | 16 | 95.45 | 84.64 | 93.55 | 71.69 | 42.07 |
| arithmetic | 14 | 96.81 | 90.21 | 98.39 | 62.51 | 47.95 |
| bad_randomness | 5 | 68.12 | 62.68 | 76.56 | 70.07 | 12.05 |
| denial_of_service | 6 | 75.75 | 66.73 | 68.19 | 60.54 | 39.31 |
| front_running | 4 | 89.17 | 87.35 | 92.30 | 71.68 | 31.28 |
| reentrancy | 29 | 92.95 | 87.01 | 97.97 | 75.22 | 22.64 |
| time_manipulation | 3 | 85.45 | 76.93 | 90.21 | 69.52 | 28.44 |
| unchecked_low_level_calls | 48 | 91.03 | 82.93 | 91.34 | 71.02 | 37.06 |
| other | 2 | 98.68 | 92.24 | 96.05 | 73.16 | 38.55 |
| short_addresses | 1 | 100.00 | 91.67 | 100.00 | 66.67 | 50.00 |

SemInv 对 DepFuzz 和 ItyFuzz 的分支优势分布在全部八个 Strict8 类别；对 ConFuzzius 则在 access_control 和 DoS 较高，其余六类较低。与 SMARTIAN 语料回放相比，SemInv 在 bad_randomness 的已观测分支覆盖更低，在其余七个 Strict8 类别更高；这一比较仍保留采集范围区别。宏平均按合约等权，不能用类别胜负数替代微平均。小类别仅有 3–6 个共同样本，类别差值应视为本轮观察。

## 5. 将覆盖率与命中联系起来

为了避免把不同集合的命中与覆盖拼接，下面进一步要求“GT 在双方映射范围内”且“双方有相同 runtime 的有效覆盖”。这是解释关联的子集，不替代包含失败样本的固定 GT 主比较。

| Baseline | 同一集合 N | SemInv / baseline 命中 | SemInv / baseline 指令 macro | SemInv / baseline 分支 macro |
| --- | ---: | ---: | ---: | ---: |
| DepFuzz | 116 | 113 / 93 | 91.84 / 93.19 | 92.74 / 85.43 |
| ConFuzzius | 125 | 118 / 102 | 90.42 / 91.96 | 91.75 / 92.87 |

本表未列 SMARTIAN，因为其 normalized 覆盖来自保存语料回放，不是命中轮次的全部执行；未列 sFuzz，因为缺少统一 concrete 覆盖。ItyFuzz 已进入覆盖和命中两项主比较，但这两项来自不同轮次，不能拼成同一次搜索的命中—覆盖关联，因此不进入本表。这里要求同轮次是为了分析两种结果之间的关系，不影响 ItyFuzz 作为常规 baseline 的其他比较。

与 ConFuzzius 配对时，SemInv 独有命中 17 个，ConFuzzius 独有命中 1 个（sb051），故净增加 16 个。SemInv 独有的 17 个样本中，以下 10 个的指令与分支覆盖率均与 ConFuzzius 相同：sb001、sb007、sb008、sb013、sb015、sb016、sb048、sb049、sb085、sb139。

与 DepFuzz 配对时，SemInv 独有命中 20 个。sb048、sb085、sb131 的两种覆盖都没有高于 DepFuzz，但仍只有 SemInv 命中对应 GT。

| 样本 | 配对 baseline | GT 类别 | 指令覆盖 SemInv / baseline | 分支覆盖 SemInv / baseline |
| --- | --- | --- | ---: | ---: |
| sb001 | ConFuzzius | access_control | 98.03 / 98.03 | 93.33 / 93.33 |
| sb049 | ConFuzzius | front_running | 84.70 / 84.70 | 81.25 / 81.25 |
| sb085 | ConFuzzius | reentrancy | 94.75 / 94.75 | 86.84 / 86.84 |
| sb085 | DepFuzz | reentrancy | 94.75 / 97.73 | 86.84 / 88.16 |
| sb131 | DepFuzz | unchecked_low_level_calls | 51.06 / 58.36 | 70.83 / 73.44 |

相同覆盖率并不保证相同 PC 集合，更不保证相同交易顺序、存储状态或数值条件；候选定义与检测器也不同。因此，这些样本支持“粗粒度执行覆盖率不足以解释全部命中差异”。它们与 SemInv 强调语义候选的设计相符，但不能直接证明所有额外候选都是因不变量本身而发现，或证明 replay 后可利用。

## 6. 工具采集范围与补充结果

| 工具 | Hit–time | 同定义全部搜索覆盖 | 其他已有证据 | 在章节中的位置 |
| --- | --- | --- | --- | --- |
| DepFuzz | 有 | 有 | 原生提前结束情况 | 主比较 |
| ConFuzzius | 有 | 有 | 原版执行、共同 runtime | 主比较 |
| SMARTIAN | 有 | 当前没有全搜索 PC/JUMPI 流 | 全量保存语料插桩回放及原始发现时间 | Hit 主比较；回放覆盖并入 128 样本图 (a,b) |
| ItyFuzz | 有，采用 high_confidence 映射范围 | 有，独立观察器采集全部搜索执行 | 原生 telemetry、PC/JUMPI 快照 | 命中时间及覆盖率主比较 |
| sFuzz | 有 | 缺少可恢复的目标 PC/JUMPI 原始事件 | 原生覆盖时间序列 | Hit 主比较；覆盖主图不纳入，原生表见第 6.2 节 |

### 6.1 SMARTIAN 保存语料的实际可报告结果

139 个样本完成插桩回放，3 个没有保存语料，1 个编译不可用。以下保留与 SemInv runtime 一致且双方有有效观测的 **135 个样本**扩展结果。它不是当前主图集合；主图和第 4 节统一使用其中与四工具 130 集合相交的 128 个样本。

| 工具与采集通道 | 指令 macro (%) | 指令 micro (%) | 分支 macro (%) | 分支 micro (%) |
| --- | ---: | ---: | ---: | ---: |
| SemInv，600s 内全部搜索执行 | 89.59 | 73.40 | 91.08 | 79.09 |
| SMARTIAN，保存语料插桩回放 | 88.88 | 79.66 | 70.85 | 68.81 |

该表统一了 PC/JUMPI 的定义、分母和样本，但采集通道不同。它回答“本轮保存的 SMARTIAN 语料在回放时可以覆盖多少目标代码”，不回答“SMARTIAN 搜索期间总共执行过多少代码”。被丢弃或未保存的输入未在回放中出现，回放状态也不能自动视为原搜索状态的完全复现。不能将 70.85% 与 SemInv 的 91.08% 直接写成公平的全搜索分支优势，也不能把回放耗时放到搜索横轴上。

回放器的 `Replay.fs` 从 testcase 文件名提取原始发现秒数；`Rq5Coverage.cs` 在保存每个累计快照时将该秒数写入 `elapsed_s`。因此可以离线按原始时间桶重建“截至 t 保存的语料覆盖”，不需要重跑 fuzz。相同整数秒有多条累计记录时取文件顺序中的最后一条，避免误取该秒的初始空快照或较早用例。以下为保留的 135 样本扩展时间表，不直接用于 128 样本主图。

| 原始 testcase 时间桶 (s) | SMARTIAN 语料指令 macro (%) | SMARTIAN 语料分支 macro (%) |
| ---: | ---: | ---: |
| 0 | 47.98 | 36.27 |
| 10 | 85.90 | 68.44 |
| 30 | 86.63 | 69.03 |
| 60 | 87.66 | 69.87 |
| 120 | 88.49 | 70.56 |
| 180 | 88.57 | 70.63 |
| 300 | 88.82 | 70.81 |
| 450 | 88.87 | 70.83 |
| 600 | 88.88 | 70.85 |

未将 DepFuzz、ConFuzzius、ItyFuzz、sFuzz 加入此 135 样本语料表，因为它们没有本轮同协议的保存语料回放数据。SemInv 在上方终值表中只是同 runtime 的全搜索参照，不是语料回放测量。主图已在 128 样本上合并 SMARTIAN 与其他四工具的可用覆盖观测；本小节保留较大配对集合的来源数据，不构成六工具语料覆盖排名。

这个扩展仍有信息价值：SMARTIAN 保存语料的指令 micro 高于 SemInv 全搜索值，说明其语料在较大合约上的覆盖权重不同。完整报告同时保留该方向的结果，避免只取 macro 中对 SemInv 有利的数字。

### 6.2 sFuzz

sFuzz 的原生统计提供可用的候选累计时间记录，足以纳入 Hit–time 比较；其中 `coverage` 字段也可用于描述该工具自身的覆盖增长。共有 140 个样本、13,469 条原生统计快照。每个检查点取 `duration ≤ t` 的最近记录，140 个样本在 10–600s 每个检查点都可观测，早停或失败前已有累计值继续保留，不补造后续执行。

| stats duration (s) | sFuzz 原生 coverage 均值 (%) | 固定可观测 N |
| ---: | ---: | ---: |
| 10 | 27.81 | 140 |
| 30 | 30.20 | 140 |
| 60 | 31.10 | 140 |
| 120 | 32.09 | 140 |
| 180 | 32.58 | 140 |
| 300 | 32.99 | 140 |
| 450 | 33.25 | 140 |
| 600 | 33.29 | 140 |

原生覆盖从 10s 的 27.81% 增长至 600s 的 33.29%，60s 后再增加 2.19 个原生百分点。这说明本轮 sFuzz 在自身指标下仍有后期覆盖增长，不能据此与 SemInv 的 normalized 分支覆盖增量比较大小。sFuzz 不绘入本次 `fuzz_section_coverage.pdf`。

其 native edge/百分比没有给出本次目标 runtime 的逐 PC 和 JUMPI 布尔结果，无法由聚合统计逆推出相同分母的 concrete 覆盖。此前逐样本审计显示，140 个有统计的样本中，没有一个原生 `branches` 分母等于统一 runtime JUMPI 分母。正式运行采用 2019 Docker 镜像，其源码版本与 `<sfuzz-root>` checkout 不同，不能把另一个版本的实现直接用作本次二进制的换算依据。统一覆盖仍填 N/A。

其他五个工具没有按该 sFuzz 原生定义重测，所以不加入这个原生指标表；现有 concrete 百分比不能改名为 sFuzz 原生百分比。sFuzz 不进入统一覆盖时间积分、追加预算收益或覆盖优势计数。SMARTIAN 则已按相同 PC/JUMPI 定义加入主图和第 4 节，但保留语料回放与全搜索观测的区别。

### 6.3 非全 baseline 对比的范围与缺席原因索引

下表覆盖本章所有未使用全部五个 baseline 的比较形式，区分“现有证据不能进入”和“为同样本配对而单列”，不笼统将缺席写成工具不支持。

| 结果位置 | 未同时纳入的 baseline | 具体原因及替代展示 |
| --- | --- | --- |
| 第 3.1–3.2 节各命中面板、AUC_H 和趋稳时间 | 每个面板只列一个 baseline；五个面板合计无缺席 | 五工具映射范围不同，六工具共同检测类别交集为空。各工具在自己的固定共同范围与 SemInv 比较，不能强制合为同一 GT 分母。 |
| 第 3.3 节类别命中表 | 各类别中标 N/A 的工具 | 第 2.2 节逐工具列明本轮未映射的类别及标签/配置原因；N/A 不记零，不扩大到算法能力判断。 |
| 第 4.1 节终值与图 (a,b)、第 4.2 节增量/时间积分、第 4.3 节类别覆盖 | sFuzz | 原生统计缺少可恢复的目标 PC/JUMPI 记录且分母不同，故未进入 128 样本主图。SMARTIAN 已纳入，采集方式为保存语料回放，见第 2.3 节。 |
| 保留的 `fuzz_section_coverage_all_search` 四工具 130 样本图 | SMARTIAN、sFuzz | 该补充图专门保留全部搜索执行观测，SMARTIAN 现有产物仅为语料回放，sFuzz 缺统一记录；不是当前五工具主图。 |
| 第 1 节 SemInv/DepFuzz 的 137 样本扩展配对 | ConFuzzius、ItyFuzz、SMARTIAN、sFuzz | 137 是二工具 runtime/观测交集，不是六工具集合。前三者已进入 128 样本主图；sFuzz 缺统一覆盖记录。该配对仅补充 SemInv/DepFuzz 的逐合约分布。 |
| 第 5 节同轮次命中—覆盖关联及具体样本 | SMARTIAN、sFuzz、ItyFuzz | 前两者缺同轮次统一全搜索覆盖；ItyFuzz 的命中与覆盖来自不同实验轮次，不能视作同一次搜索的联合观测。样例只解释本表配对，不宣称对未列工具成立。 |
| 第 6.1 节 SMARTIAN 语料曲线和参照终值 | DepFuzz、ConFuzzius、ItyFuzz、sFuzz | 没有本轮同协议的语料回放；SemInv 仅为配对全搜索终值参照。其他工具的全搜索曲线不能替代保存语料曲线。 |
| 第 6.2 节 sFuzz 原生覆盖曲线 | DepFuzz、ConFuzzius、SMARTIAN、ItyFuzz，以及 SemInv | 其他工具未按该原生指标重测，不能拿 concrete 指令/JUMPI 百分比与其直接排名。该面板用于保留 sFuzz 的实际可用时间证据。 |

以上限制均是当前实验产物与统计定义的边界，不是因 baseline 表现不利而剔除，也不表示后续不能通过统一观察器补采。现有数据支持全部工具的命中时间比较和五工具共同样本上的覆盖展示，但不能还原缺失的六工具统一全搜索曲线。

## 7. 可直接用于论文的英文正文草稿

### Coverage and Discovery Dynamics

We study how concrete execution coverage and GT-matching targets accumulate as the search budget increases. The experiment uses 143 SmartBugs-Curated source files, including 139 files with Strict8 labels, and a budget of up to 600 seconds per target. We compare SemInv with DepFuzz, the original ConFuzzius, SMARTIAN, ItyFuzz, and sFuzz on fixed pairwise cohorts within their mapped detector scopes. SemInv follows the same T policy as the overall evaluation, with candidates available after preparation included at time zero. Replay and minimization are disabled. Each curve records cumulative output on the available tool clock, retaining valid observations collected before a failed run ends.

For execution coverage, we use a common concrete definition on matching target runtimes. Instruction coverage counts executed opcode PCs, and branch coverage counts the two Boolean outcomes of each JUMPI. The figure uses the 128-target intersection of the four-tool all-search cohort and the SMARTIAN replay cohort. SMARTIAN's coverage is reconstructed from saved inputs using their original discovery timestamps; the other four tools provide all-search observations. This distinction applies throughout the coverage analysis.

At 600 seconds, macro instruction coverage is 89.72% for SemInv, 90.78% for DepFuzz, 91.69% for ConFuzzius, 88.66% for SMARTIAN, and 40.91% for ItyFuzz. Their macro branch coverage is 91.04%, 83.53%, 92.37%, 70.58%, and 34.48%, respectively. SemInv covers more branch outcomes than DepFuzz and ItyFuzz while trailing ConFuzzius by 1.33 percentage points. Micro branch coverage preserves these directions: 78.84%, 75.97%, 81.83%, 68.33%, and 20.86%. SMARTIAN's instruction micro-average, 79.10%, exceeds SemInv's 73.50%, despite the reverse order in macro averages. Its replay result describes saved inputs rather than all executions during search.

SemInv maintains a high cumulative candidate yield at short search budgets. At the 10-second checkpoint, it has 112, 119, 93, 47, and 17 GT hits on cohorts paired with DepFuzz, ConFuzzius, SMARTIAN, sFuzz, and ItyFuzz, respectively. The corresponding baselines have 84, 97, 63, 25, and 2. SemInv reaches at least 95% of its own final hit count by this checkpoint in all five cohorts. SMARTIAN continues to gain hits later, increasing from 76 at 120 seconds to 79 at 600 seconds. All three additional hits are in reentrancy. Arithmetic shows a different early pattern: SMARTIAN has 13 hits at 10 seconds, compared with SemInv's 12, and SemInv reaches 13 by 60 seconds.

Coverage expansion continues after candidate counts stabilize. Between 60 and 600 seconds, SemInv adds 4.47 percentage points of instruction coverage and 3.77 points of branch coverage on the 128-target cohort, while its cumulative GT hit count remains unchanged. The corresponding branch gains are 0.71 points for DepFuzz, 0.98 for ConFuzzius, and 2.00 for ItyFuzz. SMARTIAN's saved-corpus branch coverage grows by 0.86 points over the same discovery-time interval. SemInv thus continues to extend execution coverage after reaching its final GT yield in this run. Many DepFuzz runs terminate before the maximum budget, so later checkpoints retain their last observed coverage.

Execution coverage does not fully explain the candidate differences. On 125 targets with both a common detector scope and matching runtime for SemInv and ConFuzzius, the tools report 118 and 102 GT hits. Among SemInv's 17 exclusive hits, ten targets have identical instruction and branch coverage percentages across the two tools. Equal coverage percentages do not establish equal executed PC sets, transaction sequences, storage states, or oracle behavior. Thus, aggregate coverage alone cannot explain the observed candidate yield.

sFuzz is omitted from the coverage figure because its native aggregates provide neither target PC sets nor Boolean JUMPI outcomes. They cannot be converted to the common concrete definition. Its native coverage, reported separately, rises from 27.81% at 10 seconds to 33.29% at 600 seconds across 140 observed targets.

All five baselines enter the pairwise hit curves. Category-level N/A entries follow the mapped detector scopes. The joint hit-coverage analysis requires same-run all-search observations, excluding SMARTIAN's saved-corpus reconstruction and sFuzz's incompatible native metric. ItyFuzz's hits and normalized coverage come from separate runs, so it also remains outside that joint analysis while entering the separate comparisons. The retained 135-target SMARTIAN replay table and 140-target sFuzz native table use their own stated cohorts, not the 128-target figure cohort.

The results characterize the recorded configurations. Instrumentation overhead and CPU costs were not independently controlled.

### Suggested figure captions

**Candidate discovery.** Cumulative GT-matching candidates on fixed pairwise cohorts, covering all five baselines. SemInv uses the system-level T policy, including candidates available after preparation at time zero. Counts are held constant between recorded checkpoints; insets show the first 60 seconds. Each panel uses the same target set for the two compared tools. Different mapped detector scopes preclude a shared six-tool GT denominator. Tool-native clocks and reporting granularity are described in the experimental setup.

**Concrete execution coverage on common targets.** (a) Macro instruction coverage and (b) macro normalized JUMPI-outcome coverage for SemInv, DepFuzz, ConFuzzius, SMARTIAN, and ItyFuzz on 128 common target runtimes. SMARTIAN uses saved-corpus replay indexed by original testcase discovery-time buckets; the other four tools use all-search observations. Each checkpoint uses the latest available record no later than the recorded budget. All five curves have observations for all 128 targets at every plotted checkpoint. Zero-second coverage is omitted because common snapshots are unavailable. sFuzz is excluded because its native aggregates cannot reconstruct the shared PC/JUMPI definition.

**Compact all-search figure, when used separately.** Macro instruction and normalized JUMPI-outcome coverage on 130 common target runtimes. SMARTIAN is omitted because the available replay covers saved inputs rather than all search executions; sFuzz is omitted because its native aggregates lack the target PC/JUMPI sets needed for the common definition. Their available coverage measurements are reported separately.

## 8. 论文图表与现有结果的衔接

正文建议放两幅图和一张紧凑表：五组配对 Hit–time 图、128 个共同样本上的五工具双面板覆盖图，以及第 4.2 节的追加预算收益表。正文用第 5 节的相同覆盖但不同命中样本解释两幅图之间的关系。这样新增章节回答搜索过程的问题，不重复总体 Precision/FPR/F1 表。

第 3.3 节类别时间、第 4.3 节类别分支覆盖和第 6 节扩展时间表适合附录。ItyFuzz 和 SMARTIAN 均已纳入两幅主图；sFuzz 进入命中图，但不进入覆盖图。图内不增加 corpus replay 后缀，相关方法信息写在设置和图注中。每个仅覆盖部分 baseline 的表或图保留就地原因说明，并以第 6.3 节索引补齐。

正文主结论可用：**SemInv maintains a high cumulative GT yield at short search budgets and achieves higher normalized branch coverage than DepFuzz and ItyFuzz. Its additional candidate yield over ConFuzzius persists on matched runtimes even though aggregate coverage is slightly lower, indicating that coverage alone does not characterize candidate-discovery behavior.**

## 9. 数据、复算与验证

- `all_checkpoints.csv`：7,722 个原始汇总检查点；本文按工具、样本和检查点索引，无重复键。
- `paired_gt.csv`、`paired_gt_cases.csv`、`cohorts.csv`：固定 GT 配对、独有命中与共同 runtime 成员。
- `paired_coverage.csv`、`category_coverage.csv`：原有三方/两方覆盖与类别覆盖。本文按 covered/total 再计算均值并核对。
- `seminv_event_audit.csv`：T 候选及事件证据。
- `coverage_extended_curves.csv`、`coverage_extended_cohorts.csv`、原始 ItyFuzz JSONL：原四工具 130 样本覆盖数据，作为当前 128 样本交集的一个来源。仅恢复未换行 EOF 的残缺记录之前的完整记录，600s 以后观测不进入本章检查点。
- `rq5_smartian_corpus_replay_20261013`：139 个有效回放终态及原始 runtime/覆盖记录，其中 135 个可与 SemInv 配对；`Replay.fs` 与 `Rq5Coverage.cs` 确认快照时间来自原始用例文件名。
- `native_telemetry.csv`：sFuzz 原生覆盖时间曲线的数据源；固定 140 样本使用不晚于每个检查点的最近统计。
- `fuzz_comparison_metrics.json`：主图使用 `coverage.five_way` 的 128 样本与逐时点五工具覆盖，`coverage_main_cohort=five_way`；`category_coverage_main` 同步为 128 样本。原四工具覆盖和类别数据分别保留在 `coverage.four_way`、`category_coverage_four_way`。同时保留五组命中 AUC、SMARTIAN 135 样本回放、sFuzz 原生时间序列及 `comparison_availability` 缺席原因。
- 复算脚本：`experiments/rq5_timecurves/fuzz_comparison_section.py`。只读取已有实验数据，生成本文对应 JSON 和图像。
- 图件：`figures/fuzz_section_hits`、`figures/fuzz_section_coverage` 五工具双面板主图，以及 `figures/fuzz_section_coverage_all_search` 原四工具 130 样本补充图，均提供 PNG、PDF、SVG。线型与标记同时编码工具，未添加无重复实验支持的误差条。
- 主图证据结构：(a) 比较共同 runtime 的已观测指令覆盖；(b) 比较其 normalized JUMPI 覆盖。两图统一采用 128 样本，SMARTIAN 与其他工具的采集方式区别在报告及建议图注中说明，图内不设单独回放面板或 sFuzz 面板。
- `test_fuzz_comparison_section.py`：验证同秒累计记录取末条、禁止未来记录前移、sFuzz 固定观测集合和 600s 截断；两项回归测试通过。

从仓库根目录执行：

```powershell
.\.venv-rq3-report\Scripts\python.exe experiments\rq5_timecurves\fuzz_comparison_section.py
```

脚本校验 143×6×9 条检查点唯一性、GT 命中单调性、固定配对命中与既有汇总一致、覆盖分母一致、快照不晚于检查点及原四工具宏/微平均与原始汇总一致。新主图校验交集为 128、移除样本恰为 `sb007`/`sb054`、每工具每时点分母一致、覆盖有界且单调。SMARTIAN 135 样本时间序列终值须复现原回放汇总，时间戳须等于 testcase 文件名中的发现秒数；sFuzz 固定集合和原生覆盖单调性单独验证。本次工作没有重跑 fuzz，也没有修改历史实验状态、原始记录或 RQ1 参考文件。
