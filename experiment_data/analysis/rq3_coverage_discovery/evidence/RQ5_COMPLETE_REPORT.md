# RQ5 完整实验数据与对比分析

日期：2026-10-13。范围：SmartBugs-Curated 冻结的 143 个源文件，SemInv、DepFuzz、原版 ConFuzzius、SMARTIAN、ItyFuzz、sFuzz 六个工具，600s 搜索预算。所有正式任务已经结束。本文件只分析本轮 RQ5，不与旧 RQ1 的 300/600/1200s、自适应重测或 confirmed 结果混用。

本报告依据已完成实验产物进行离线汇总，SemInv采用准备阶段＋搜索的系统级T结果。本轮共858个工具-样本运行记录、7,722个checkpoint记录，每个工具均有143个终态。GT部分使用139个Strict8标签文件；另外3个other和1个short_addresses不进入Strict8 GT分母，但可进入覆盖率分析。

## 1. 核心结论

1. SemInv在全体Strict8的系统级T命中为 **129/139，92.81%**。文件-类别标签口径为 **129 TP、93 FP、10 FN**，Precision=58.11%，Recall=92.81%，F1=71.47%。
2. 在逐 baseline 的相同样本集合上，SemInv 的最终候选命中数均高于本轮 baseline；但各工具配置、原生 oracle 及映射范围不同，不能据此宣称所有工具在统一全能力测试中被全面超越。
3. 相对 DepFuzz，137 个 exact-runtime 配对样本的 normalized concrete 分支覆盖率为 **91.21% vs 83.67%**，领先 **7.53 个百分点**；指令覆盖率为 **89.74% vs 90.66%**，落后 **0.92 个百分点**。
4. 相对原版 ConFuzzius，134 个 exact-runtime 样本的指令/分支覆盖率均略低；SemInv 的优势是 GT 候选命中，不是所有路径覆盖更多。原版目录是 `<con-fuzzius-baseline-root>`，没有误用修改版。
5. 本次复核发现原 sFuzz 解析器漏计：CSV 表头前导空格未清理，且部分文件含重复表头。修正后原定范围为 **23/36**，不是旧报告的 **0/36**。
6. ItyFuzz 使用默认 `high_confidence`，而非全部 detectors。把 arithmetic/reentrancy 全部放入其有效检测分母会误导；旧的 `Arbitrary Call -> unchecked_low_level_calls` 也不是严格语义等价。本报告将历史结果与语义复核后的范围分开。

## 2. 数据和统计定义

### 2.1 三种必须分开的概念

- **运行终态**：completed/budget_completed 表示按 runner 规则正常结束，不代表发现漏洞；tool_failed、prepare_failed、compile_failed、untestable、no_search_observation 仍如实保留。
- **GT candidate hit**：属于目标样本且映射到其GT类别的候选，按样本计一次。SemInv使用本轮准备阶段与0–600s搜索阶段的已保存事件，统一应用T-v1/evidence-safe；其他工具使用本轮原生标签及下列映射。时间曲线以搜索开始为零点，准备阶段已产出的SemInv候选构成初始状态；准备耗时另列。
- **标签指标**：在固定139文件×8类别上计算TP/FP/TN/FN；FP表示相对于文件主类别的额外预测。Precision=TP/(TP+FP)，Recall=TP/(TP+FN)，F1=2TP/(2TP+FP+FN)。这些是标签匹配指标，不等同于replay确认的可利用性。
- **覆盖率**：具体执行的 runtime opcode PC 以及 JUMPI 的布尔分支结果。报警数量、原生 edge bitmap、源码覆盖率和 symbolic-only PC 均不混入。

### 2.2 分母与缺失值

主对比使用预先列出的相同文件集合（fixed cohort），不因某工具失败而缩小分母。对于属于评分范围但没有有效命中的失败/不可测阳性文件，命中分子为0，在标签混淆矩阵中计FN；负标签未报告按交付口径计TN，不表示工具证明了安全。范围外为N/A，不当作检测失败。

同时提供双方有搜索观测、双方正常结束、exact-runtime 三种敏感性子集。失败前已持久化且属于预算内的命中/覆盖对所有工具同样保留；另给出删除失败命中的敏感性结果。没有覆盖数据时为 N/A，不补 0。所有均值均列出 N。

### 2.3 两套映射视图

`frozen`：baseline原适配器冻结类别范围，修复sFuzz CSV读取错误。

`audited`：本次事后语义核对视图。SMARTIAN增加已有RE报告；sFuzz增加明确的overflow/underflow；ItyFuzz收紧到当前默认启用、可解释的access_control范围。两视图中的SemInv均使用系统级T，类别映射不变；DepFuzz、ConFuzzius映射不变。

| 工具 | frozen 范围 | audited 范围 / 差异 |
| --- | --- | --- |
| SemInv | access_control, arithmetic, bad_randomness, denial_of_service, front_running, reentrancy, time_manipulation, unchecked_low_level_calls | access_control, arithmetic, bad_randomness, denial_of_service, front_running, reentrancy, time_manipulation, unchecked_low_level_calls |
| DepFuzz | access_control, arithmetic, front_running, reentrancy, unchecked_low_level_calls | access_control, arithmetic, front_running, reentrancy, unchecked_low_level_calls |
| ConFuzzius | access_control, arithmetic, denial_of_service, front_running, reentrancy, time_manipulation, unchecked_low_level_calls | access_control, arithmetic, denial_of_service, front_running, reentrancy, time_manipulation, unchecked_low_level_calls |
| SMARTIAN | arithmetic, unchecked_low_level_calls | arithmetic, reentrancy, unchecked_low_level_calls |
| ItyFuzz | access_control, arithmetic, reentrancy, unchecked_low_level_calls | access_control |
| sFuzz | reentrancy, time_manipulation | arithmetic, reentrancy, time_manipulation |

两个视图的六工具共同类别交集均为空，不能构造一个既保留六个工具、又声称所有工具都支持的非空统一 GT 子集。正确方式是逐 baseline 配对和逐类别比较。N/A 表示本次映射/配置未纳入，**不等于工具在所有版本中不支持该漏洞**。

## 3. 实验配置与公平性

| 工具 | 运行环境与入口 | 预算与随机性 | 时间零点 / 证据 |
| --- | --- | --- | --- |
| SemInv | RQ3 Full 冻结 runtime；UIR、功能测试种子、evidence-safe；max individual length=5 | 600s搜索；generation cap=1,000,000；seed=11 | 系统级T；准备候选为初始状态；search hook时钟与约1s具体执行快照 |
| DepFuzz | <depfuzz-root>\Depfuzz；depfuzz-rq1:20261008 | --timeout 600；seed=11；允许原生提前结束 | 编译/部署后、init_fuzz 前重设时钟；约1s快照 |
| ConFuzzius | <con-fuzzius-baseline-root>；只加被动观测和依赖兼容 | -t 600；seed=11；原版默认搜索 | env.execution_begin；约1s快照 |
| SMARTIAN | smartian-artifact-local:node12fix；Smartian.dll fuzz | --timelimit 600；原生CLI未设置seed | 原生bug文件整数时间戳；包含工具自身初始化 |
| ItyFuzz | WSL Ubuntu-22.04；/root/.ityfuzz/bin/ityfuzz | 外部timeout 600；seed11；--run-forever；默认high_confidence | 外部预算含启动/部署，命中以相邻原生Stats秒时钟记录 |
| sFuzz | 2019 sfuzz/ethfuzzer:latest 镜像，不是当前<sfuzz-root> checkout | --duration 600；无显式seed | stats.csv 的duration，约5s观测上界 |

SemInv 的 generation cap 通过 entry.py 设置；命令使用 `-t 600`，不是同时传互斥的 `-g` 和 `-t`。replay、oracle validation、结构 trimming/minimization 已关闭。仍有生成/写出事件、去重、evidence-safe/T 汇总成本，不能说所有 reporting/normalization 都零开销；本轮也不是启用 LLM explanation 的端到端流程。

SemInv在fuzz前生成功能种子、UIR和静态候选。报告统计准备＋搜索的系统级候选产出，曲线横轴为准备完成后的搜索时间，准备成本另列；覆盖率仍仅来自concrete执行。baseline没有拿到SemInv的功能种子。主实验6个混合worker，后续四工具各2个worker、合计8个并行；未使用独占资源和多随机种子重复，曲线不用于宣称端到端或等CPU成本的倍数加速。

**EVM 差异：** 编译统一采用 Byzantium 目标和优化200次（逐样本版本以cases.csv/compile.json为准），但 ItyFuzz 正式命令没有 `--spec-id byzantium`，其已安装CLI帮助显示默认 `Latest`。因此旧 README 中“所有工具均以Byzantium执行”不严谨。相同runtime不等于相同fork执行语义；ItyFuzz结果应作为当前默认配置补充，而非严格EVM对齐对照。

ItyFuzz 默认 `high_confidence` 由已安装二进制 `evm --help` 确认；本地 `ityfuzz-master/src/evm/mod.rs:462` 列表不含 Reentrancy/MathCalculate。该源码和已安装 nightly 二进制的精确提交一致性未在本轮证明，因此默认配置解释有代码支持，但不把源码版本当作二进制版本证明。

### 3.1 实际起止时间（北京时间）

| 任务 | 开始 | 结束 | 实际历时(h) |
| --- | --- | --- | --- |
| SemInv+DepFuzz（含准备） | 10-12 22:32:59 | 10-13 03:40:31 | 5.13 |
| ConFuzzius | 10-13 03:40:42 | 10-13 15:25:00 | 11.74 |
| SMARTIAN | 10-13 03:40:42 | 10-13 15:31:04 | 11.84 |
| ItyFuzz | 10-13 03:40:42 | 10-13 14:49:19 | 11.14 |
| sFuzz | 10-13 03:40:42 | 10-13 13:19:56 | 9.65 |

SemInv准备阶段有143条状态，其中142条功能/UIR步骤wall记录，累计1.056h、中位数24.34s；另有140条静态步骤记录，累计0.054h。功能/UIR步骤的两worker起止跨度约33.63分钟。准备成本不在搜索横轴内，详见preparation.csv。未收集完整LLM token/费用。

### 3.2 实际预算使用

下表累计 wall 是各样本进程wall之和，不是CPU时间，不能与并行campaign历时直接相加比较。最后一列使用search_end或最后一个遥测时间，只是接近预算的观测数，不能单凭缺少快照断言程序提前停止。

| 工具 | wall记录N | 累计wall(h) | wall中位数(s) | 搜索终点/末观测中位数(s) | 末观测<60s | 末观测≥590s |
| --- | --- | --- | --- | --- | --- | --- |
| SemInv | 140 | 22.57 | 607.75 | 600.04 | 3 | 129 |
| DepFuzz | 143 | 4.19 | 24.57 | 21.15 | 98 | 11 |
| ConFuzzius | 143 | 23.31 | 608.24 | 600.14 | 0 | 137 |
| SMARTIAN | 142 | 23.50 | 602.32 | 600.00 | 0 | 139 |
| ItyFuzz | 142 | 22.11 | 601.13 | 599.00 | 7 | 128 |
| sFuzz | 142 | 19.28 | 601.29 | 600.03 | 23 | 111 |

DepFuzz 的已记录 search_elapsed 中位数仅约21.15s，大量运行正常提前结束；不是每个样本都持续fuzz600s。后续曲线沿用已观察到的累计值，而不是假装有新的执行。sFuzz亦有早停/观测提前终止的情况。故本轮是**最多600s预算**比较，不是所有工具都实际使用600s CPU的比较。SemInv正常任务129个均达到搜索预算，11个崩溃则保留崩溃前数据。

## 4. 完整运行状态

| 工具 | budget_completed | completed | tool_failed | prepare_failed | compile_failed | untestable | no_search_observation | 总数 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SemInv | 129 | 0 | 11 | 2 | 0 | 1 | 0 | 143 |
| DepFuzz | 0 | 140 | 3 | 0 | 0 | 0 | 0 | 143 |
| ConFuzzius | 0 | 137 | 5 | 0 | 0 | 0 | 1 | 143 |
| SMARTIAN | 0 | 139 | 3 | 0 | 1 | 0 | 0 | 143 |
| ItyFuzz | 0 | 131 | 9 | 0 | 1 | 0 | 2 | 143 |
| sFuzz | 0 | 139 | 3 | 0 | 1 | 0 | 0 | 143 |

`completed` 中包括原生完成和已设预算触发的 exit124；这不等同于命中。全部858条状态及命令/原始目录见 `all_runs.csv`。本次不把命中后的崩溃强行改名为completed，另用hit字段表达检测产出。

## 5. 最终GT结果与同样本对比

### 5.1 原定范围（修正sFuzz读取）

| 工具 | 原定范围命中/分母 | 真实搜索观测N | Strict8全体139中可映射命中数 | 失败运行贡献命中 |
| --- | --- | --- | --- | --- |
| SemInv | 129/139 (92.81%) | 136 | 129/139 | 10 |
| DepFuzz | 94/120 (78.33%) | 119 | 94/139 | 0 |
| ConFuzzius | 104/131 (79.39%) | 128 | 104/139 | 0 |
| SMARTIAN | 60/67 (89.55%) | 67 | 60/139 | 0 |
| ItyFuzz | 5/116 (4.31%) | 113 | 5/139 | 0 |
| sFuzz | 23/36 (63.89%) | 35 | 23/139 | 0 |

全体139中的数字只用于展示当前配置可产出的命中覆盖面，不把各工具未纳入映射的类别算成真正FN，也不拿异分母百分比做工具排名。ItyFuzz frozen一行仅为历史兼容，不推荐作为公平检测主结论。

### 5.1.1 SemInv系统级T的标签指标

下表各类别的FP/TN均在全139文件上计算，micro行汇总1112个文件-类别判断。未按阳性目录或成功状态筛选阴性样本。

| 类别 | TP | FP | TN | FN | Precision | Recall | F1 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| access_control | 17 | 17 | 104 | 1 | 50.00 | 94.44 | 65.38 |
| arithmetic | 13 | 9 | 115 | 2 | 59.09 | 86.67 | 70.27 |
| bad_randomness | 7 | 9 | 122 | 1 | 43.75 | 87.50 | 58.33 |
| denial_of_service | 2 | 0 | 133 | 4 | 100.00 | 33.33 | 50.00 |
| front_running | 3 | 34 | 101 | 1 | 8.11 | 75.00 | 14.63 |
| reentrancy | 31 | 2 | 106 | 0 | 93.94 | 100.00 | 96.88 |
| time_manipulation | 5 | 9 | 125 | 0 | 35.71 | 100.00 | 52.63 |
| unchecked_low_level_calls | 51 | 13 | 74 | 1 | 79.69 | 98.08 | 87.93 |
| micro_all8 | 129 | 93 | 880 | 10 | 58.11 | 92.81 | 71.47 |

### 5.2 原定范围的配对结果

| Baseline | 相同N | SemInv | Baseline | 差值(pp) | 仅SemInv命中 | 仅baseline命中 | 双方未命中 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DepFuzz | 120 | 115/120 (95.83%) | 94/120 (78.33%) | 17.50 | 21 | 0 | 5 |
| ConFuzzius | 131 | 122/131 (93.13%) | 104/131 (79.39%) | 13.74 | 19 | 1 | 8 |
| SMARTIAN | 67 | 64/67 (95.52%) | 60/67 (89.55%) | 5.97 | 4 | 0 | 3 |
| ItyFuzz | 116 | 112/116 (96.55%) | 5/116 (4.31%) | 92.24 | 107 | 0 | 4 |
| sFuzz | 36 | 36/36 (100.00%) | 23/36 (63.89%) | 36.11 | 13 | 0 | 0 |

### 5.3 事后语义复核范围的配对结果

| Baseline | 相同N | SemInv | Baseline | 差值(pp) | 仅SemInv命中 | 仅baseline命中 | 双方未命中 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DepFuzz | 120 | 115/120 (95.83%) | 94/120 (78.33%) | 17.50 | 21 | 0 | 5 |
| ConFuzzius | 131 | 122/131 (93.13%) | 104/131 (79.39%) | 13.74 | 19 | 1 | 8 |
| SMARTIAN | 98 | 95/98 (96.94%) | 79/98 (80.61%) | 16.33 | 16 | 0 | 3 |
| ItyFuzz | 18 | 17/18 (94.44%) | 2/18 (11.11%) | 83.33 | 15 | 0 | 1 |
| sFuzz | 51 | 49/51 (96.08%) | 33/51 (64.71%) | 31.37 | 16 | 0 | 2 |

复核范围中，SMARTIAN 的 RE 共在19个重入GT样本上命中，因此不是仅支持 arithmetic/unchecked 两类。sFuzz 的 arithmetic 新增10/15。ItyFuzz access_control 是包含自毁/任意调用候选的**类别级代理范围**，也不意味着覆盖所有访问控制漏洞子型；应降低其作为主比较证据的权重。没有把默认未启用的detector改成已启用，更没有重跑或补造结果。

### 5.4 排除失败、仅可观测样本的敏感性（audited）

| Baseline | 子集 | N | SemInv | Baseline | 差值(pp) |
| --- | --- | --- | --- | --- | --- |
| DepFuzz | both_observed | 118 | 115/118 (97.46%) | 94/118 (79.66%) | 17.80 |
| DepFuzz | both_normal | 107 | 105/107 (98.13%) | 86/107 (80.37%) | 17.76 |
| DepFuzz | exact_runtime_gt | 116 | 113/116 (97.41%) | 93/116 (80.17%) | 17.24 |
| ConFuzzius | both_observed | 127 | 120/127 (94.49%) | 104/127 (81.89%) | 12.60 |
| ConFuzzius | both_normal | 116 | 110/116 (94.83%) | 96/116 (82.76%) | 12.07 |
| ConFuzzius | exact_runtime_gt | 125 | 118/125 (94.40%) | 102/125 (81.60%) | 12.80 |
| SMARTIAN | both_observed | 97 | 95/97 (97.94%) | 79/97 (81.44%) | 16.49 |
| SMARTIAN | both_normal | 88 | 87/88 (98.86%) | 76/88 (86.36%) | 12.50 |
| SMARTIAN | exact_runtime_gt | 95 | 93/95 (97.89%) | 78/95 (82.11%) | 15.79 |
| ItyFuzz | both_observed | 17 | 17/17 (100.00%) | 2/17 (11.76%) | 88.24 |
| ItyFuzz | both_normal | 15 | 15/15 (100.00%) | 2/15 (13.33%) | 86.67 |
| ItyFuzz | exact_runtime_gt | 17 | 17/17 (100.00%) | 2/17 (11.76%) | 88.24 |
| sFuzz | both_observed | 50 | 48/50 (96.00%) | 33/50 (66.00%) | 30.00 |
| sFuzz | both_normal | 42 | 41/42 (97.62%) | 29/42 (69.05%) | 28.57 |
| sFuzz | exact_runtime_gt | 49 | 47/49 (95.92%) | 32/49 (65.31%) | 30.61 |

仅正常运行子集是敏感性分析，不替代主表：用双方是否成功来筛选会造成幸存者偏差。`exact_runtime_gt`按字节码而非按搜索成功筛选；其N与覆盖率样本数可能不同。

## 6. 0–600s命中曲线

各表内SemInv与baseline使用相同分母。SemInv统计准备＋搜索的累计T候选，以准备完成后的搜索时钟为横轴，0s初始状态有60/139个GT命中；准备耗时见第3节。SMARTIAN/ItyFuzz的0s来自整数时钟桶/初始化日志。sFuzz按第一次正计数快照的观测上界计入，未把最终结果倒灌到早期。

### frozen：每格为 SemInv / baseline 命中数

| t(s) | DepFuzz (N=120) | ConFuzzius (N=131) | SMARTIAN (N=67) | ItyFuzz (N=116) | sFuzz (N=36) |
| --- | --- | --- | --- | --- | --- |
| 0 | 51 / 0 | 53 / 0 | 50 / 21 | 50 / 2 | 0 / 0 |
| 10 | 112 / 84 | 119 / 97 | 63 / 58 | 110 / 5 | 35 / 16 |
| 30 | 113 / 91 | 120 / 102 | 64 / 58 | 111 / 5 | 35 / 17 |
| 60 | 115 / 93 | 122 / 103 | 64 / 59 | 112 / 5 | 36 / 23 |
| 120 | 115 / 94 | 122 / 104 | 64 / 60 | 112 / 5 | 36 / 23 |
| 180 | 115 / 94 | 122 / 104 | 64 / 60 | 112 / 5 | 36 / 23 |
| 300 | 115 / 94 | 122 / 104 | 64 / 60 | 112 / 5 | 36 / 23 |
| 450 | 115 / 94 | 122 / 104 | 64 / 60 | 112 / 5 | 36 / 23 |
| 600 | 115 / 94 | 122 / 104 | 64 / 60 | 112 / 5 | 36 / 23 |

### audited：每格为 SemInv / baseline 命中数

| t(s) | DepFuzz (N=120) | ConFuzzius (N=131) | SMARTIAN (N=98) | ItyFuzz (N=18) | sFuzz (N=51) |
| --- | --- | --- | --- | --- | --- |
| 0 | 51 / 0 | 53 / 0 | 50 / 21 | 0 / 1 | 0 / 0 |
| 10 | 112 / 84 | 119 / 97 | 93 / 63 | 17 / 2 | 47 / 25 |
| 30 | 113 / 91 | 120 / 102 | 94 / 67 | 17 / 2 | 48 / 27 |
| 60 | 115 / 93 | 122 / 103 | 95 / 71 | 17 / 2 | 49 / 33 |
| 120 | 115 / 94 | 122 / 104 | 95 / 76 | 17 / 2 | 49 / 33 |
| 180 | 115 / 94 | 122 / 104 | 95 / 76 | 17 / 2 | 49 / 33 |
| 300 | 115 / 94 | 122 / 104 | 95 / 78 | 17 / 2 | 49 / 33 |
| 450 | 115 / 94 | 122 / 104 | 95 / 79 | 17 / 2 | 49 / 33 |
| 600 | 115 / 94 | 122 / 104 | 95 / 79 | 17 / 2 | 49 / 33 |

![逐baseline配对命中曲线，事后语义复核范围](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/gt_pairwise_audited.png)

### 6.1 早期效率与晚期增益（audited，各自范围）

| 工具 | 范围N | 10s | 60s | 120s | 600s | 120–600s新增 | 达到最终命中95%的首个checkpoint |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SemInv | 139 | 126 | 129 | 129 | 129 | 0 | 10 |
| DepFuzz | 120 | 84 | 93 | 94 | 94 | 0 | 30 |
| ConFuzzius | 131 | 97 | 103 | 104 | 104 | 0 | 30 |
| SMARTIAN | 98 | 63 | 71 | 76 | 79 | 3 | 120 |
| ItyFuzz | 18 | 2 | 2 | 2 | 2 | 0 | 10 |
| sFuzz | 51 | 25 | 33 | 33 | 33 | 0 | 60 |

SemInv在搜索10s时累计已有126/129（97.67%）的最终系统级候选，120–600s新增0个GT命中；覆盖率仍增长。该曲线包含准备阶段的初始命中，反映准备完成后的累计产出。SMARTIAN加入重入后，120–600s新增3个命中。`speed_summary.csv`的阶梯面积使用各区间左端checkpoint值，并归一化为0–600s平均命中率；它不是精确事件时间积分，不跨不同分母排名。未排除未命中样本来计算平均time-to-bug。

## 7. 类别结果

### 7.1 原定映射（每格为命中/类别N）

| 类别 | 数据集N | SemInv | DepFuzz | ConFuzzius | SMARTIAN | ItyFuzz | sFuzz |
| --- | --- | --- | --- | --- | --- | --- | --- |
| access_control | 18 | 17/18 (94.44%) | 8/18 (44.44%) | 9/18 (50.00%) | N/A | 2/18 (11.11%) | N/A |
| arithmetic | 15 | 13/15 (86.67%) | 12/15 (80.00%) | 12/15 (80.00%) | 13/15 (86.67%) | 0/15 (0.00%) | N/A |
| bad_randomness | 8 | 7/8 (87.50%) | N/A | N/A | N/A | N/A | N/A |
| denial_of_service | 6 | 2/6 (33.33%) | N/A | 0/6 (0.00%) | N/A | N/A | N/A |
| front_running | 4 | 3/4 (75.00%) | 0/4 (0.00%) | 2/4 (50.00%) | N/A | N/A | N/A |
| reentrancy | 31 | 31/31 (100.00%) | 26/31 (83.87%) | 29/31 (93.55%) | N/A | 0/31 (0.00%) | 22/31 (70.97%) |
| time_manipulation | 5 | 5/5 (100.00%) | N/A | 4/5 (80.00%) | N/A | N/A | 1/5 (20.00%) |
| unchecked_low_level_calls | 52 | 51/52 (98.08%) | 48/52 (92.31%) | 48/52 (92.31%) | 47/52 (90.38%) | 3/52 (5.77%) | N/A |

### 7.2 语义复核映射（事后敏感性）

| 类别 | 数据集N | SemInv | DepFuzz | ConFuzzius | SMARTIAN | ItyFuzz | sFuzz |
| --- | --- | --- | --- | --- | --- | --- | --- |
| access_control | 18 | 17/18 (94.44%) | 8/18 (44.44%) | 9/18 (50.00%) | N/A | 2/18 (11.11%) | N/A |
| arithmetic | 15 | 13/15 (86.67%) | 12/15 (80.00%) | 12/15 (80.00%) | 13/15 (86.67%) | N/A | 10/15 (66.67%) |
| bad_randomness | 8 | 7/8 (87.50%) | N/A | N/A | N/A | N/A | N/A |
| denial_of_service | 6 | 2/6 (33.33%) | N/A | 0/6 (0.00%) | N/A | N/A | N/A |
| front_running | 4 | 3/4 (75.00%) | 0/4 (0.00%) | 2/4 (50.00%) | N/A | N/A | N/A |
| reentrancy | 31 | 31/31 (100.00%) | 26/31 (83.87%) | 29/31 (93.55%) | 19/31 (61.29%) | N/A | 22/31 (70.97%) |
| time_manipulation | 5 | 5/5 (100.00%) | N/A | 4/5 (80.00%) | N/A | N/A | 1/5 (20.00%) |
| unchecked_low_level_calls | 52 | 51/52 (98.08%) | 48/52 (92.31%) | 48/52 (92.31%) | 47/52 (90.38%) | N/A | N/A |

![类别候选命中矩阵，N/A不是零命中](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/categories_audited.png)

### 7.3 四个重点类别的具体解释

**Bad randomness：7/8，87.50%。** sb034–sb039及sb041均保存了T接受的`bad_randomness_dependency`源码模式候选；sb040没有外部ABI入口，仍记untestable和FN。全139文件上另有9个标签FP，Precision=43.75%，F1=58.33%。这些是环境随机性影响状态/支付相关语法的候选，不将普通hash_collision或所有block_dependency直接等同于弱随机性。

**Denial of service：2/6，33.33%。** sb042 auction和sb047 send_loop保存了`require(...send(...))`对应的`failed_refund_dos`候选，类别FP=0、F1=50.00%。另外四个是gas/状态增长类；虽有通用gas告警，但不满足当前T的DoS映射，仍为FN。此类别的子类型覆盖仍有限。

**Front running：3/4，75.00%。** 命中sb048、sb049、sb050，未命中sb051；原版ConFuzzius为2/4。sb048来自准备阶段的approve-race候选。sb051仍是这轮唯一ConFuzzius命中而SemInv未命中的配对文件，不能根据主类别补记已有其他类别事件。

**Time manipulation：5/5。** 最新T已不是弱项。T将属于目标合约、且源码证据确含`now`或`block.timestamp`的block_dependency候选计入；不能因此声称验证了盈利攻击或确认了可利用性。原ConFuzzius为4/5，sFuzz修复读取后为1/5（sb087）。其余工具该类别不纳入本报告严格映射，尤其SMARTIAN的BD不能无区别同时计作time和randomness。

| ID | 类别 | SemInv终态 | GT命中 | 保留事件kind:数量 |
| --- | --- | --- | --- | --- |
| sb034 | bad_randomness | budget_completed | 1 | bad_randomness_dependency:3, dos_with_block_gas_limit:2, hash_collision:3, numeric_integrity:13 |
| sb035 | bad_randomness | budget_completed | 1 | bad_randomness_dependency:2, dos_with_block_gas_limit:3, integer_overflow:1, numeric_integrity:4, transaction_order_dependency:2 |
| sb036 | bad_randomness | budget_completed | 1 | bad_randomness_dependency:1, dos_with_block_gas_limit:1 |
| sb037 | bad_randomness | budget_completed | 1 | bad_randomness_dependency:1, block_dependency:1, dos_with_block_gas_limit:1, hash_collision:1, numeric_integrity:1, transaction_order_dependency:1 |
| sb038 | bad_randomness | budget_completed | 1 | bad_randomness_dependency:2, dos_with_block_gas_limit:2, numeric_integrity:1, short_calldata_integrity:1, unchecked_return_value:5 |
| sb039 | bad_randomness | budget_completed | 1 | bad_randomness_dependency:1, block_dependency:1, leaking_ether:1 |
| sb040 | bad_randomness | untestable | 0 | 无预算内所属事件 |
| sb041 | bad_randomness | budget_completed | 1 | accounting_delta:9, approve_race:1, arbitrary_memory_access:1, assertion_failure:13, bad_randomness_dependency:11, block_dependency:3, dos_with_block_gas_limit:9, hash_collision:4, numeric_integrity:16, unexpected_ether_balance:2 |
| sb042 | denial_of_service | budget_completed | 1 | failed_refund_dos:1, transaction_order_dependency:1 |
| sb043 | denial_of_service | budget_completed | 0 | dos_with_block_gas_limit:2, numeric_integrity:2 |
| sb044 | denial_of_service | budget_completed | 0 | arbitrary_memory_access:3, dos_with_block_gas_limit:3, numeric_integrity:4 |
| sb045 | denial_of_service | budget_completed | 0 | dos_with_block_gas_limit:1, numeric_integrity:2 |
| sb046 | denial_of_service | budget_completed | 0 | accounting_delta:1, assertion_failure:3, block_dependency:1, dos_with_block_gas_limit:3, numeric_integrity:3, short_calldata_integrity:2, transaction_order_dependency:1, unchecked_return_value:9 |
| sb047 | denial_of_service | budget_completed | 1 | dos_with_block_gas_limit:2, failed_refund_dos:1, numeric_integrity:1 |
| sb048 | front_running | budget_completed | 1 | approve_race:1, dos_with_block_gas_limit:3, numeric_integrity:2 |
| sb049 | front_running | budget_completed | 1 | dos_with_block_gas_limit:1, order_independence:1 |
| sb050 | front_running | budget_completed | 1 | dos_with_block_gas_limit:4, transaction_order_dependency:1 |
| sb051 | front_running | budget_completed | 0 | assertion_failure:1, numeric_integrity:1, unchecked_return_value:4 |
| sb087 | time_manipulation | budget_completed | 1 | assertion_failure:1, bad_randomness_dependency:1, block_dependency:1, dos_with_block_gas_limit:2, numeric_integrity:1, transaction_order_dependency:1 |
| sb088 | time_manipulation | budget_completed | 1 | block_dependency:1, dos_with_block_gas_limit:4, unchecked_return_value:4 |
| sb089 | time_manipulation | budget_completed | 1 | block_dependency:2, dos_with_block_gas_limit:3, unchecked_return_value:2 |
| sb090 | time_manipulation | budget_completed | 1 | block_dependency:2, dos_with_block_gas_limit:1 |
| sb091 | time_manipulation | budget_completed | 1 | block_dependency:1, dos_with_block_gas_limit:1 |

## 8. 统一concrete覆盖率

### 8.1 定义

对每个目标runtime反汇编得到opcode起始PC集合U（排除PUSH立即数），按当前SemInv公用规则去除编译器尾部metadata。指令覆盖率=实际执行PC与U交集大小/|U|。分支覆盖率=观察到的`(JUMPI PC, condition!=0)`集合大小/(2×JUMPI数)。不把同一分支上不同非零256-bit值重复计数，不把符号求解器曾探索过的PC当作具体执行。

逐合约平均为macro；所有配对合约的covered/total之和为micro，二者均报告且不按结果选用。exact-runtime配对仅移除legacy Solidity metadata后要求字节码完全一致，同时重新核对instruction_total和branch_total。没有程序等价推断。所有checkpoint只取不晚于该时刻的最后快照，不使用600s后的新覆盖。

| 配对 | N | 指标 | SemInv macro | Baseline macro | 差值(pp) | SemInv micro | Baseline micro | 逐合约SemInv胜/平/负 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DepFuzz | 137 | instruction | 89.74 | 90.66 | -0.92 | 73.64 | 75.41 | 68/38/31 |
| DepFuzz | 137 | branch | 91.21 | 83.67 | 7.53 | 79.29 | 76.35 | 109/2/26 |
| ConFuzzius | 134 | instruction | 89.54 | 91.55 | -2.01 | 73.47 | 78.53 | 16/86/32 |
| ConFuzzius | 134 | branch | 91.10 | 92.42 | -1.32 | 79.15 | 82.10 | 17/86/31 |

SemInv对DepFuzz的分支优势同时存在于macro和micro，并且109/137个样本更高；但其指令均值更低，尽管68个样本指令覆盖更高。这说明胜负样本数、提升幅度和大型合约权重是不同维度，不应挑选其中一个替代其他指标。对ConFuzzius的两种覆盖，SemInv宏/微均值都较低，必须保留这一结果。

### 8.2 三工具共同134个runtime的随时间均值

| t(s) | SemInv指令 | DepFuzz指令 | ConFuzzius指令 | SemInv分支 | DepFuzz分支 | ConFuzzius分支 |
| --- | --- | --- | --- | --- | --- | --- |
| 10 | 79.82 | 86.82 | 86.94 | 81.99 | 79.74 | 87.52 |
| 30 | 83.45 | 89.35 | 89.91 | 85.70 | 82.37 | 90.90 |
| 60 | 84.93 | 89.97 | 90.44 | 87.26 | 82.90 | 91.48 |
| 120 | 86.75 | 90.18 | 91.20 | 88.92 | 83.27 | 92.07 |
| 180 | 88.00 | 90.42 | 91.26 | 89.98 | 83.43 | 92.12 |
| 300 | 89.06 | 90.46 | 91.43 | 90.71 | 83.53 | 92.29 |
| 450 | 89.38 | 90.53 | 91.50 | 90.99 | 83.57 | 92.37 |
| 600 | 89.54 | 90.53 | 91.55 | 91.10 | 83.57 | 92.42 |

![三工具共同runtime上的统一concrete覆盖率](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/coverage_three_way.png)

图中0s未绘制覆盖率，因为没有足够共同快照；不是补了零。连线只连接已观测checkpoint，CSV保留每点实际采样时间和N。三方共同集合与两方SemInv/DepFuzz137个集合不同，不把不同集合的数值拼成同一条曲线。

SemInv_DepFuzz未入选的文件：sb009, sb040, sb082, sb088, sb115, sb121。原因为一方缺少可用runtime/coverage或runtime不一致，并非根据覆盖高低筛选。完整成员见cohorts.csv。

SemInv_ConFuzzius未入选的文件：sb009, sb033, sb036, sb039, sb040, sb082, sb088, sb115, sb121。原因为一方缺少可用runtime/coverage或runtime不一致，并非根据覆盖高低筛选。完整成员见cohorts.csv。

three_way未入选的文件：sb009, sb033, sb036, sb039, sb040, sb082, sb088, sb115, sb121。原因为一方缺少可用runtime/coverage或runtime不一致，并非根据覆盖高低筛选。完整成员见cohorts.csv。

### 8.3 各类别配对覆盖率（600s macro，百分比）

#### SemInv vs DepFuzz

| 类别 | 配对N | SemInv指令 | Baseline指令 | SemInv分支 | Baseline分支 |
| --- | --- | --- | --- | --- | --- |
| access_control | 17 | 94.31 | 92.06 | 95.72 | 85.33 |
| arithmetic | 15 | 94.85 | 98.88 | 97.02 | 90.56 |
| bad_randomness | 7 | 72.28 | 69.88 | 75.64 | 68.92 |
| denial_of_service | 6 | 70.13 | 66.91 | 75.75 | 66.73 |
| front_running | 4 | 87.74 | 94.70 | 89.17 | 87.35 |
| reentrancy | 30 | 92.71 | 95.58 | 93.18 | 87.11 |
| time_manipulation | 4 | 81.96 | 86.58 | 89.09 | 78.53 |
| unchecked_low_level_calls | 50 | 89.90 | 90.30 | 90.47 | 82.76 |
| other | 3 | 95.66 | 91.63 | 99.12 | 88.34 |
| short_addresses | 1 | 99.52 | 99.52 | 100.00 | 91.67 |

#### SemInv vs ConFuzzius

| 类别 | 配对N | SemInv指令 | Baseline指令 | SemInv分支 | Baseline分支 |
| --- | --- | --- | --- | --- | --- |
| access_control | 17 | 94.31 | 92.86 | 95.72 | 93.93 |
| arithmetic | 14 | 94.51 | 96.45 | 96.81 | 98.39 |
| bad_randomness | 5 | 61.74 | 76.35 | 68.12 | 76.56 |
| denial_of_service | 6 | 70.13 | 61.25 | 75.75 | 68.19 |
| front_running | 4 | 87.74 | 95.66 | 89.17 | 92.30 |
| reentrancy | 30 | 92.71 | 97.52 | 93.18 | 98.04 |
| time_manipulation | 4 | 81.96 | 88.01 | 89.09 | 92.66 |
| unchecked_low_level_calls | 50 | 89.90 | 90.77 | 90.47 | 90.90 |
| other | 3 | 95.66 | 96.93 | 99.12 | 97.37 |
| short_addresses | 1 | 99.52 | 99.52 | 100.00 | 100.00 |

### 8.4 SMARTIAN / ItyFuzz / sFuzz 的覆盖率为什么是N/A

此前基线轮次的三种工具没有相同口径的原始PC/JUMPI事件流。本次新增的独立观察器为ItyFuzz补充了全搜索execution级原始事件；下列N/A和native telemetry仍描述旧基线轮次，新增统一数据见8.5。SMARTIAN导出aggregate instruction/edge等计数，ItyFuzz有原生coverage summary/corpus相关覆盖，sFuzz有branches/coverage等stats字段；没有证明它们的去重单位、runtime过滤、分母和采样时钟与本报告一致。故统一覆盖列为N/A，而不是0，也不除以SemInv分母强行转换。

本次仍完整抽取了可读的原生时间遥测，见native_telemetry.csv；字段保留native_count/native_stats_field/native_percent等单位，不能当成normalized concrete百分比排名。sFuzz表头空格问题同时会影响旧原生字段读取，本次清理后的原始值也在该CSV中。

| 工具 | 原生字段 | N | 预算内最后记录均值 | 最后记录时间中位数(s) | 单位（禁止混用） |
| --- | --- | --- | --- | --- | --- |
| ItyFuzz | branch | 132 | 59.22 | 0.00 | native_percent_last_log_clock |
| ItyFuzz | executions | 138 | 13908818.00 | 599.00 | native_count |
| ItyFuzz | instruction | 132 | 66.35 | 0.00 | native_percent_last_log_clock |
| SMARTIAN | Covered Def-Use Chains | 77 | 2702.55 | 600.00 | native_count |
| SMARTIAN | Covered Edges | 77 | 46.88 | 600.00 | native_count |
| SMARTIAN | Covered Instructions | 77 | 519.48 | 600.00 | native_count |
| SMARTIAN | Total Executions | 77 | 813749.13 | 600.00 | native_count |
| sFuzz | branches | 140 | 14.66 | 595.01 | native_stats_field |
| sFuzz | coverage | 140 | 33.29 | 595.01 | native_stats_field |
| sFuzz | cycle | 140 | 53603.75 | 595.01 | native_stats_field |
| sFuzz | execution | 140 | 1380137.36 | 595.01 | native_stats_field |
| sFuzz | speed | 140 | 2322.20 | 595.01 | native_stats_field |
| sFuzz | tuple | 140 | 17.92 | 595.01 | native_stats_field |

以上是每个样本≤600s的最后一次已记录值，不保证就是600s时的最终实际覆盖，尤其ItyFuzz coverage summary可能仅在新corpus时输出。数值不与normalized coverage合并，不把不同工具的execution单位比较为吞吐加速。





### 8.5 ItyFuzz 全搜索的统一 concrete 覆盖率曲线

在同一目标runtime的固定样本上，将ItyFuzz独立观察器加入SemInv、DepFuzz和ConFuzzius的搜索时间曲线。四方共同可比较样本为130个；每个时点使用不晚于该时点的最新快照，覆盖观察样本数另列。SMARTIAN保存语料插桩回放不进入搜索曲线。
离线恢复不改写原始状态或快照：117个原始validation_failed中，109个仅末尾JSON记录被强制停止截断，使用此前完整且通过校验的记录；8个样本没有匹配目标runtime，按覆盖缺失排除。另有2个ItyFuzz进程panic（exit 101）和1个编译不可用样本。所有曲线点严格使用elapsed_s不超过检查点的记录；部分进程延至外层watchdog才退出，因此不声称每个进程恰在600s停止。

| 工具 | 600s观测N | 指令macro (%) | 指令micro (%) | 分支macro (%) | 分支micro (%) |
| --- | ---: | ---: | ---: | ---: | ---: |
| SemInv | 130 | 89.88 | 73.74 | 91.18 | 79.06 |
| DepFuzz | 130 | 90.80 | 75.39 | 83.60 | 76.09 |
| ConFuzzius | 130 | 91.81 | 78.73 | 92.49 | 82.02 |
| ItyFuzz | 130 | 40.78 | 23.67 | 34.53 | 21.04 |

![ItyFuzz加入后的四工具统一 concrete 覆盖率曲线](<seminv-workspace>/outputs/rq5_complete_analysis_20261013/figures/coverage_all_search_four_way.png)

曲线数据和逐样本配对见`coverage_extended_curves.csv`、`coverage_extended_cohorts.csv`；ItyFuzz每样本状态见`coverage_extended_status.csv`。旧轮次ItyFuzz原生coverage summary仍留在native telemetry中，两者单位不同。

### 8.6 SMARTIAN保存语料插桩回放校验

SMARTIAN原有保存语料在独立插桩构建中逐样本回放，并写入`saved_corpus_replay`通道。139个样本完成且快照校验通过；3个样本没有保存语料，sb009无法编译（数据集pragma v0.4.9、已安装编译器仅v0.4.11）。sb001、sb025、sb090的插桩回放原生Covered Instructions/Edges计数与未插桩原镜像逐项一致。回放计数用于证明观察器不改变原生反馈，未并入全搜索曲线或搜索覆盖率排名。原始状态及快照位于`outputs/rq5_smartian_corpus_replay_20261013`。

## 9. 失败样本和命中保留的影响

| 工具（frozen） | 固定N | 保留失败前命中 | 删除失败前命中但不删分母 | 失败贡献命中数 |
| --- | --- | --- | --- | --- |
| SemInv | 139 | 129/139 (92.81%) | 119/139 (85.61%) | 10 |
| DepFuzz | 120 | 94/120 (78.33%) | 94/120 (78.33%) | 0 |
| ConFuzzius | 131 | 104/131 (79.39%) | 104/131 (79.39%) | 0 |
| SMARTIAN | 67 | 60/67 (89.55%) | 60/67 (89.55%) | 0 |
| ItyFuzz | 116 | 5/116 (4.31%) | 5/116 (4.31%) | 0 |
| sFuzz | 36 | 23/36 (63.89%) | 23/36 (63.89%) | 0 |

| audited配对 | 固定N | SemInv删除失败命中 | Baseline删除失败命中 | 差值(pp) |
| --- | --- | --- | --- | --- |
| DepFuzz | 120 | 105/120 (87.50%) | 94/120 (78.33%) | 9.17 |
| ConFuzzius | 131 | 112/131 (85.50%) | 104/131 (79.39%) | 6.11 |
| SMARTIAN | 98 | 87/98 (88.78%) | 79/98 (80.61%) | 8.16 |
| ItyFuzz | 18 | 15/18 (83.33%) | 2/18 (11.11%) | 72.22 |
| sFuzz | 51 | 42/51 (82.35%) | 33/51 (64.71%) | 17.65 |

SemInv的11个tool_failed中10个已命中目标GT；删除这些运行的命中但保留139分母，命中数从129降到119，变化7.19个百分点。有效准备证据及崩溃前已保存搜索事件均保留，hit与run_status分别记录。

### 9.1 失败原因核对

- SemInv 11个崩溃均为Windows `0xC00000FD`（stack overflow）。sb009准备阶段受源文件精确0.4.9限制；sb115准备阶段生成的functional harness存在int256到uint256参数类型不匹配，这属于准备代码问题，不是目标源码天然不可编译；sb040无可调用外部入口。
- DepFuzz：sb009编译失败；sb040 exit255，日志信息不足；sb088部署失败。原版ConFuzzius：sb009编译失败，sb033/sb036/sb039/sb088部署失败，sb040没有搜索观测。
- SMARTIAN：sb007 codecopy分析异常，sb040空队列，sb054数组越界；sb009编译失败。不能笼统把所有exit139都写成同一种源码错误。
- ItyFuzz：7个reentrancy文件栈溢出；sb062/sb121发生Rust panic；sb009编译失败；sb040/sb091没有可fuzz目标。旧统计中缺少的eligible观察是sb009 compile_failed，而不是no_search_observation。
- sFuzz：sb044/sb136 exit137，sb090 exit139；sb009编译失败。exit137没有内存监控证据，不能确定归因为OOM；stderr的ttyname提示不是已经证实的根因。

### 9.2 全部异常终态索引

| 工具 | ID | 类别 | 状态 | 退出码 | frozen GT命中 |
| --- | --- | --- | --- | --- | --- |
| SemInv | sb007 | access_control | tool_failed | 3221225725 | 1 |
| SemInv | sb009 | access_control | prepare_failed | N/A | 0 |
| SemInv | sb015 | access_control | tool_failed | 3221225725 | 1 |
| SemInv | sb020 | arithmetic | tool_failed | 3221225725 | 0 |
| SemInv | sb032 | arithmetic | tool_failed | 3221225725 | 1 |
| SemInv | sb040 | bad_randomness | untestable | N/A | 0 |
| SemInv | sb055 | reentrancy | tool_failed | 3221225725 | 1 |
| SemInv | sb057 | reentrancy | tool_failed | 3221225725 | 1 |
| SemInv | sb059 | reentrancy | tool_failed | 3221225725 | 1 |
| SemInv | sb072 | reentrancy | tool_failed | 3221225725 | 1 |
| SemInv | sb079 | reentrancy | tool_failed | 3221225725 | 1 |
| SemInv | sb084 | reentrancy | tool_failed | 3221225725 | 1 |
| SemInv | sb115 | unchecked_low_level_calls | prepare_failed | N/A | 0 |
| SemInv | sb121 | unchecked_low_level_calls | tool_failed | 3221225725 | 1 |
| DepFuzz | sb009 | access_control | tool_failed | 255 | 0 |
| DepFuzz | sb040 | bad_randomness | tool_failed | 255 | N/A |
| DepFuzz | sb088 | time_manipulation | tool_failed | 255 | N/A |
| ConFuzzius | sb009 | access_control | tool_failed | 4294967295 | 0 |
| ConFuzzius | sb033 | arithmetic | tool_failed | 4294967294 | 0 |
| ConFuzzius | sb036 | bad_randomness | tool_failed | 4294967294 | N/A |
| ConFuzzius | sb039 | bad_randomness | tool_failed | 4294967294 | N/A |
| ConFuzzius | sb040 | bad_randomness | no_search_observation | 0 | N/A |
| ConFuzzius | sb088 | time_manipulation | tool_failed | 4294967294 | 0 |
| SMARTIAN | sb007 | access_control | tool_failed | 139 | N/A |
| SMARTIAN | sb009 | access_control | compile_failed | N/A | N/A |
| SMARTIAN | sb040 | bad_randomness | tool_failed | 139 | N/A |
| SMARTIAN | sb054 | other | tool_failed | 139 | N/A |
| ItyFuzz | sb009 | access_control | compile_failed | N/A | 0 |
| ItyFuzz | sb040 | bad_randomness | no_search_observation | 0 | N/A |
| ItyFuzz | sb055 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb057 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb058 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb059 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb062 | reentrancy | tool_failed | 101 | 0 |
| ItyFuzz | sb067 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb068 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb072 | reentrancy | tool_failed | 6 | 0 |
| ItyFuzz | sb091 | time_manipulation | no_search_observation | 0 | N/A |
| ItyFuzz | sb121 | unchecked_low_level_calls | tool_failed | 101 | 0 |
| sFuzz | sb009 | access_control | compile_failed | N/A | N/A |
| sFuzz | sb044 | denial_of_service | tool_failed | 137 | N/A |
| sFuzz | sb090 | time_manipulation | tool_failed | 139 | 0 |
| sFuzz | sb136 | unchecked_low_level_calls | tool_failed | 137 | N/A |

每条异常的源文件、合约、原始目录和错误片段见failures.csv；不能将编译/准备失败描述为600s没找到漏洞。

## 10. 逐样本优势与反例

以下audited配对清单使用固定分母，不按结果挑选样本。完整清单含源文件名见paired_gt_cases.csv及cases.csv。

### DepFuzz

仅SemInv命中：sb003, sb004, sb005, sb007, sb013, sb015, sb016, sb017, sb018, sb021, sb048, sb049, sb050, sb075, sb077, sb080, sb082, sb085, sb108, sb131, sb139。

仅baseline命中：无。

双方未命中：sb009, sb020, sb023, sb051, sb115。

### ConFuzzius

仅SemInv命中：sb001, sb007, sb008, sb011, sb012, sb013, sb015, sb016, sb033, sb042, sb047, sb048, sb049, sb081, sb085, sb088, sb108, sb117, sb139。

仅baseline命中：sb051。

双方未命中：sb009, sb020, sb023, sb043, sb044, sb045, sb046, sb115。

### SMARTIAN

仅SemInv命中：sb055, sb057, sb058, sb059, sb060, sb072, sb075, sb077, sb079, sb080, sb082, sb085, sb101, sb108, sb131, sb139。

仅baseline命中：无。

双方未命中：sb020, sb023, sb115。

### ItyFuzz

仅SemInv命中：sb001, sb002, sb003, sb004, sb005, sb006, sb007, sb008, sb011, sb012, sb013, sb015, sb016, sb017, sb018。

仅baseline命中：无。

双方未命中：sb009。

### sFuzz

仅SemInv命中：sb019, sb026, sb033, sb055, sb057, sb060, sb066, sb067, sb072, sb076, sb081, sb085, sb088, sb089, sb090, sb091。

仅baseline命中：无。

双方未命中：sb020, sb023。

### 10.1 SemInv未命中目标GT的10个文件

| ID | 类别 | 合约 | 状态 | 源文件 |
| --- | --- | --- | --- | --- |
| sb009 | access_control | WalletLibrary | prepare_failed | parity_wallet_bug_1.sol |
| sb020 | arithmetic | IntegerOverflowAdd | tool_failed | insecure_transfer.sol |
| sb023 | arithmetic | IntegerOverflowBenign1 | budget_completed | integer_overflow_benign_1.sol |
| sb040 | bad_randomness | RandomNumberGenerator | untestable | random_number_generator.sol |
| sb043 | denial_of_service | DosGas | budget_completed | dos_address.sol |
| sb044 | denial_of_service | DosNumber | budget_completed | dos_number.sol |
| sb045 | denial_of_service | DosOneFunc | budget_completed | dos_simple.sol |
| sb046 | denial_of_service | Government | budget_completed | list_dos.sol |
| sb051 | front_running | OddsAndEvens | budget_completed | odds_and_evens.sol |
| sb115 | unchecked_low_level_calls | TownCrier | prepare_failed | 0x89c1b3807d4c67df034fffb62f3509561218d30b.sol |

sb023的合约名虽含Benign，但本报告没有依据名称事后删除该样本；仍沿用冻结类别GT。是否应修订其语义真值需要独立人工审计，不能为提高命中率临时排除。

## 11. 本轮能支持哪些RQ5结论

**可以支持：** 在当前配置与映射下，SemInv准备＋搜索的系统级T在固定139文件上命中129个主标签，并在逐baseline共同范围内获得较高命中率。搜索时钟较早阶段已接近最终候选产出；覆盖率仍会在命中平台后增长。与DepFuzz的同runtime相比，SemInv最终concrete布尔分支覆盖更高；五个time-manipulation样本均出现T接受的候选。

**需要同时呈现：** 原版ConFuzzius平均覆盖率更高，候选命中差异并非简单由覆盖数量解释。Bad randomness为7/8但仍有9个标签FP；DoS仅覆盖2/6个阳性，资源增长子类型仍有缺口。默认ItyFuzz的detector/fork不同且unchecked映射不成立，其历史5/116不用于证明通用优势。

**证据边界：** 本报告提供SemInv的标签P/R/F1，但未对全部baseline做对称的全类别FP审计，因此不宣称Precision/F1全面领先。单次种子实验也不支持replay确认TP领先、统计显著性、端到端等CPU成本加速或跨数据集泛化。本轮只有SmartBugs-Curated，不能独自支撑RQ5的generalization部分。

### 11.1 图表组织建议

1. 主表：列出SemInv/DepFuzz/原ConFuzzius的same-case候选命中和exact-runtime指令/分支覆盖，始终展示每项N；三个工具的134共同runtime覆盖可作为一张主图。
2. 检测时间曲线：使用GT candidate hit rate，而不是F1。按baseline分别作小面板，避免不同支持分母叠成一张隐含同分母排名图。SMARTIAN重入和sFuzz算术扩展标注post-hoc mapping sensitivity；ItyFuzz作为配置限制补充。
3. 类别图：使用hit/N矩阵或类别命中率，SemInv统一采用系统级T，Bad randomness为7/8、DoS为2/6、Front running为3/4；范围外工具保留N/A。配套类别P/R/F1见第5节。
4. 附录：状态表、失败前命中敏感性、宏/微覆盖、逐样本表、原生遥测、映射修改清单和预处理开销说明。

若后续需要更严格的六工具论文主比较，优先修订oracle映射和ItyFuzz EVM配置、统一重复种子与资源分配，再决定是否补实验；本次没有擅自重跑。可解释、可复现的局部优势比“所有metric都领先”的不成立表述更有说服力。

## 12. 本次统计修正账本

| 事项 | 历史问题 | 本报告处理 |
| --- | --- | --- |
| SemInv证据范围 | 此前完整报告仅读取搜索事件 | 统一纳入本轮同源码、同目标的准备阶段与预算内搜索事件，应用相同T/evidence-safe；静态记录不伪造搜索elapsed |
| sFuzz CSV | 前导空格令timestamp/reentrancy键查找失败，报告0/36 | 清理字段名；跳过17个重复表头；恢复23/36；逐样本corrections.csv |
| SMARTIAN范围 | IB/ME两类被误当成全部支持范围 | 保留67例历史结果；单列加入RE后的98例结果 |
| sFuzz范围 | overflow/underflow原生字段未纳入 | 保留36例；单列加arithmetic后的51例结果；不扩展有歧义标签 |
| ItyFuzz配置 | 默认high_confidence不等于all，原分母包含未启用oracle | 历史116例仅供追溯，语义复核只列access_control18例 |
| ItyFuzz映射 | Arbitrary Call同时计作unchecked return | audited取消unchecked映射；原3个该类别命中不作严格证据 |
| ItyFuzz缺失 | eligible中115 observed/116，被误释为no_search | 缺失为sb009 compile_failed；新表分离固定分母与真实搜索观测 |
| 执行EVM | 编译Byzantium被描述为六工具运行EVM均一致 | 明确ItyFuzz未传--spec-id，默认Latest；不宣称完全对齐 |
| 时间/随机性 | 600s预算被理解为实际都运行600s，seed11被理解为六工具均固定 | 列出真实时长；SMARTIAN/sFuzz原生随机性未固定 |
| SemInv运行失败 | 命中被叫success可能掩盖tool_failed | 分别保存真实终态与hit；提供对称失败敏感性 |

## 13. 数据交付清单与复现

| 文件 | 内容 |
| --- | --- |
| [all_runs.csv](all_runs.csv) | 858条终态、源文件、时间、GT、故障原因、原目录 |
| [all_checkpoints.csv](all_checkpoints.csv) | 7,722条统一checkpoint记录，覆盖原始计数和百分比 |
| [summary.csv](summary.csv) | 两套映射的各工具各时刻结果、失败命中敏感性 |
| [paired_gt.csv](paired_gt.csv) | 五个baseline×四种配对范围×两映射×九时点 |
| [paired_gt_cases.csv](paired_gt_cases.csv) | 最终逐对命中/未命中、双方状态 |
| [cohorts.csv](cohorts.csv) | 全部GT和coverage子集成员，可追溯分母 |
| [paired_coverage.csv](paired_coverage.csv) | 两方/三方exact-runtime macro、micro、胜平负 |
| [category_summary.csv](category_summary.csv) | 类别GT结果，空值保留N/A |
| [category_coverage.csv](category_coverage.csv) | 逐类别配对coverage，不混不同样本 |
| [speed_summary.csv](speed_summary.csv) | 95%最终命中checkpoint与阶梯面积 |
| [timing.csv](timing.csv) | 实际wall/搜索终点遥测汇总 |
| [preparation.csv](preparation.csv) | 143个SemInv准备阶段状态、种子数、UIR、wall及错误 |
| [failures.csv](failures.csv) | 所有非正常终态及原始目录索引 |
| [cases.csv](cases.csv) | 冻结143个文件、合约、类别、compiler元数据 |
| [native_events.csv](native_events.csv) | baseline原生事件标签和时间；不隐去未映射标签 |
| [native_telemetry.csv](native_telemetry.csv) | 三工具原生遥测，独立单位，非统一覆盖 |
| [native_summary.csv](native_summary.csv) | 每样本预算内末次原生遥测汇总，非统一coverage |
| [seminv_event_audit.csv](seminv_event_audit.csv) | 准备与搜索事件的通道、真实时间、归属、T保留/过滤及最终预测 |
| [seminv_predictions.csv](seminv_predictions.csv) | 143样本的准备、搜索及系统级T预测，含Strict8范围标记 |
| [seminv_label_metrics.csv](seminv_label_metrics.csv) | 固定139文件上八类别与micro TP/FP/TN/FN及P/R/F1 |
| [seminv_rejected_events.csv](seminv_rejected_events.csv) | 通道owner/时间校验不通过的事件 |
| [corrections.csv](corrections.csv) | sFuzz原定范围恢复的23个命中 |
| [data_quality.csv](data_quality.csv) | 重复表头等检查记录 |
| [audit.json](audit.json) | 全858终态、T复算、覆盖分母/界限、GT单调性核验 |

字段规则：eligible为是否属于该view的映射范围；hit为按冻结文件的操作性产出，范围外留空；search_observed表示有实际搜索证据，不等于进程被启动；normal_stop不表示检测成功。instruction_pct/branch_pct为0–100百分数，covered/total保留整数计数；coverage_observed_s是用于该checkpoint的真实快照时间。native标签保留不意味着已经通过GT映射。

可复现命令（项目根目录）：

```powershell
& .venv-rq3-report/Scripts/python.exe -B experiments/rq5_timecurves/consolidate.py
& .venv-rq3-report/Scripts/python.exe -B experiments/rq5_timecurves/build_report.py
& .venv-rq3-report/Scripts/python.exe -B -m unittest discover -s experiments/rq5_timecurves -p test_consolidate.py -v
```

脚本不启动fuzzer，不修改原campaign、其旧analysis或RQ1参考实验。原搜索子通道的T-v1复算逐时点与main analysis核对；本报告主结果为准备＋搜索的系统级T。原始elapsed与事件来源保留在审计CSV，系统级曲线以准备后的搜索时钟为横轴。此次更新前的完整报告及数据保存在`<seminv-workspace>\outputs\rq5_complete_analysis_search_only_20261013`。

图片同时提供PNG预览、PDF矢量和SVG可编辑版本：`gt_pairwise_frozen`、`gt_pairwise_audited`、`coverage_three_way`、`categories_frozen`、`categories_audited`。图表数据全部来自同目录CSV，没有插补缺失coverage或捏造误差条。

## 附录 A. 全143文件逐工具最终结果（audited）

H=命中；M=该范围内未产出命中；!表示非正常终态；N/A=不属于该映射范围，不按漏报统计。状态与命中均在all_runs.csv保留。本表是完整样本索引，不是只列成功案例。

| ID | 类别 | 合约 | SemInv | DepFuzz | ConFuzzius | SMARTIAN | ItyFuzz | sFuzz |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sb001 | access_control | FibonacciBalance | H | H | M | N/A | M | N/A |
| sb002 | access_control | Wallet | H | H | H | N/A | M | N/A |
| sb003 | access_control | Missing | H | M | H | N/A | M | N/A |
| sb004 | access_control | Missing | H | M | H | N/A | M | N/A |
| sb005 | access_control | Missing | H | M | H | N/A | M | N/A |
| sb006 | access_control | Map | H | H | H | N/A | M | N/A |
| sb007 | access_control | MultiOwnable | H! | M | M | N/A! | M | N/A |
| sb008 | access_control | MyContract | H | H | M | N/A | M | N/A |
| sb009 | access_control | WalletLibrary | M! | M! | M! | N/A! | M! | N/A! |
| sb010 | access_control | WalletLibrary | H | H | H | N/A | H | N/A |
| sb011 | access_control | Phishable | H | H | M | N/A | M | N/A |
| sb012 | access_control | Proxy | H | H | M | N/A | M | N/A |
| sb013 | access_control | Rubixi | H | M | M | N/A | M | N/A |
| sb014 | access_control | SimpleSuicide | H | H | H | N/A | H | N/A |
| sb015 | access_control | Unprotected | H! | M | M | N/A | M | N/A |
| sb016 | access_control | Wallet | H | M | M | N/A | M | N/A |
| sb017 | access_control | Wallet | H | M | H | N/A | M | N/A |
| sb018 | access_control | Wallet | H | M | H | N/A | M | N/A |
| sb019 | arithmetic | PausableToken | H | H | H | H | N/A | M |
| sb020 | arithmetic | IntegerOverflowAdd | M! | M | M | M | N/A | M |
| sb021 | arithmetic | Overflow | H | M | H | H | N/A | H |
| sb022 | arithmetic | IntegerOverflowAdd | H | H | H | H | N/A | H |
| sb023 | arithmetic | IntegerOverflowBenign1 | M | M | M | M | N/A | M |
| sb024 | arithmetic | IntegerOverflowMappingSym1 | H | H | H | H | N/A | H |
| sb025 | arithmetic | IntegerOverflowMinimal | H | H | H | H | N/A | H |
| sb026 | arithmetic | IntegerOverflowMul | H | H | H | H | N/A | M |
| sb027 | arithmetic | IntegerOverflowMultiTxMultiFuncFeasible | H | H | H | H | N/A | H |
| sb028 | arithmetic | IntegerOverflowMultiTxOneFuncFeasible | H | H | H | H | N/A | H |
| sb029 | arithmetic | Overflow_Add | H | H | H | H | N/A | H |
| sb030 | arithmetic | IntegerOverflowSingleTransaction | H | H | H | H | N/A | H |
| sb031 | arithmetic | TimeLock | H | H | H | H | N/A | H |
| sb032 | arithmetic | Token | H! | H | H | H | N/A | H |
| sb033 | arithmetic | TokenSaleChallenge | H | H | M! | H | N/A | M |
| sb034 | bad_randomness | BlackJack | H | N/A | N/A | N/A | N/A | N/A |
| sb035 | bad_randomness | Ethraffle_v4b | H | N/A | N/A | N/A | N/A | N/A |
| sb036 | bad_randomness | GuessTheRandomNumberChallenge | H | N/A | N/A! | N/A | N/A | N/A |
| sb037 | bad_randomness | Lottery | H | N/A | N/A | N/A | N/A | N/A |
| sb038 | bad_randomness | LuckyDoubler | H | N/A | N/A | N/A | N/A | N/A |
| sb039 | bad_randomness | PredictTheBlockHashChallenge | H | N/A | N/A! | N/A | N/A | N/A |
| sb040 | bad_randomness | RandomNumberGenerator | M! | N/A! | N/A! | N/A! | N/A! | N/A |
| sb041 | bad_randomness | SmartBillions | H | N/A | N/A | N/A | N/A | N/A |
| sb042 | denial_of_service | DosAuction | H | N/A | M | N/A | N/A | N/A |
| sb043 | denial_of_service | DosGas | M | N/A | M | N/A | N/A | N/A |
| sb044 | denial_of_service | DosNumber | M | N/A | M | N/A | N/A | N/A! |
| sb045 | denial_of_service | DosOneFunc | M | N/A | M | N/A | N/A | N/A |
| sb046 | denial_of_service | Government | M | N/A | M | N/A | N/A | N/A |
| sb047 | denial_of_service | Refunder | H | N/A | M | N/A | N/A | N/A |
| sb048 | front_running | ERC20 | H | M | M | N/A | N/A | N/A |
| sb049 | front_running | FindThisHash | H | M | M | N/A | N/A | N/A |
| sb050 | front_running | EthTxOrderDependenceMinimal | H | M | H | N/A | N/A | N/A |
| sb051 | front_running | OddsAndEvens | M | M | H | N/A | N/A | N/A |
| sb052 | other | CryptoRoulette | N/A | N/A | N/A | N/A | N/A | N/A |
| sb053 | other | NameRegistrar | N/A | N/A | N/A | N/A | N/A | N/A |
| sb054 | other | OpenAddressLottery | N/A | N/A | N/A | N/A! | N/A | N/A |
| sb055 | reentrancy | PERSONAL_BANK | H! | H | H | M | N/A! | M |
| sb056 | reentrancy | PrivateBank | H | H | H | H | N/A | H |
| sb057 | reentrancy | ACCURAL_DEPOSIT | H! | H | H | M | N/A! | M |
| sb058 | reentrancy | PRIVATE_ETH_CELL | H | H | H | M | N/A! | H |
| sb059 | reentrancy | BANK_SAFE | H! | H | H | M | N/A! | H |
| sb060 | reentrancy | TokenBank | H | H | H | M | N/A | M |
| sb061 | reentrancy | U_BANK | H | H | H | H | N/A | H |
| sb062 | reentrancy | PrivateDeposit | H | H | H | H | N/A! | H |
| sb063 | reentrancy | W_WALLET | H | H | H | H | N/A | H |
| sb064 | reentrancy | ETH_VAULT | H | H | H | H | N/A | H |
| sb065 | reentrancy | X_WALLET | H | H | H | H | N/A | H |
| sb066 | reentrancy | ETH_FUND | H | H | H | H | N/A | M |
| sb067 | reentrancy | PENNY_BY_PENNY | H | H | H | H | N/A! | M |
| sb068 | reentrancy | DEP_BANK | H | H | H | H | N/A! | H |
| sb069 | reentrancy | Private_Bank | H | H | H | H | N/A | H |
| sb070 | reentrancy | PrivateBank | H | H | H | H | N/A | H |
| sb071 | reentrancy | ETH_VAULT | H | H | H | H | N/A | H |
| sb072 | reentrancy | MONEY_BOX | H! | H | H | M | N/A! | M |
| sb073 | reentrancy | WALLET | H | H | H | H | N/A | H |
| sb074 | reentrancy | MY_BANK | H | H | H | H | N/A | H |
| sb075 | reentrancy | EtherBank | H | M | H | M | N/A | H |
| sb076 | reentrancy | EtherStore | H | H | H | H | N/A | M |
| sb077 | reentrancy | ModifierEntrancy | H | M | H | M | N/A | H |
| sb078 | reentrancy | Reentrance | H | H | H | H | N/A | H |
| sb079 | reentrancy | Reentrancy_bonus | H! | H | H | M | N/A | H |
| sb080 | reentrancy | Reentrancy_cross_function | H | M | H | M | N/A | H |
| sb081 | reentrancy | ReentrancyDAO | H | H | M | H | N/A | M |
| sb082 | reentrancy | Reentrancy_insecure | H | M | H | M | N/A | H |
| sb083 | reentrancy | Reentrance | H | H | H | H | N/A | H |
| sb084 | reentrancy | SimpleDAO | H! | H | H | H | N/A | H |
| sb085 | reentrancy | HumanStandardToken | H | M | M | M | N/A | M |
| sb086 | short_addresses | MyToken | N/A | N/A | N/A | N/A | N/A | N/A |
| sb087 | time_manipulation | EtherLotto | H | N/A | H | N/A | N/A | H |
| sb088 | time_manipulation | Governmental | H | N/A! | M! | N/A | N/A | M |
| sb089 | time_manipulation | lottopollo | H | N/A | H | N/A | N/A | M |
| sb090 | time_manipulation | Roulette | H | N/A | H | N/A | N/A | M! |
| sb091 | time_manipulation | TimedCrowdsale | H | N/A | H | N/A | N/A! | M |
| sb092 | unchecked_low_level_calls | PoCGame | H | H | H | H | N/A | N/A |
| sb093 | unchecked_low_level_calls | Caller | H | H | H | H | N/A | N/A |
| sb094 | unchecked_low_level_calls | daoPOLSKAtokens | H | H | H | H | N/A | N/A |
| sb095 | unchecked_low_level_calls | demo | H | H | H | H | N/A | N/A |
| sb096 | unchecked_low_level_calls | TokenBank | H | H | H | H | N/A | N/A |
| sb097 | unchecked_low_level_calls | TokenBank | H | H | H | H | N/A | N/A |
| sb098 | unchecked_low_level_calls | MultiplicatorX4 | H | H | H | H | N/A | N/A |
| sb099 | unchecked_low_level_calls | WhaleGiveaway2 | H | H | H | H | N/A | N/A |
| sb100 | unchecked_low_level_calls | airdrop | H | H | H | H | N/A | N/A |
| sb101 | unchecked_low_level_calls | EBU | H | H | H | M | N/A | N/A |
| sb102 | unchecked_low_level_calls | airPort | H | H | H | H | N/A | N/A |
| sb103 | unchecked_low_level_calls | Centra4 | H | H | H | H | N/A | N/A |
| sb104 | unchecked_low_level_calls | EtherGet | H | H | H | H | N/A | N/A |
| sb105 | unchecked_low_level_calls | MultiplicatorX3 | H | H | H | H | N/A | N/A |
| sb106 | unchecked_low_level_calls | SimpleWallet | H | H | H | H | N/A | N/A |
| sb107 | unchecked_low_level_calls | TokenBank | H | H | H | H | N/A | N/A |
| sb108 | unchecked_low_level_calls | PandaBreeding | H | M | M | M | N/A | N/A |
| sb109 | unchecked_low_level_calls | HomeyJar | H | H | H | H | N/A | N/A |
| sb110 | unchecked_low_level_calls | WhaleGiveaway1 | H | H | H | H | N/A | N/A |
| sb111 | unchecked_low_level_calls | WhaleGiveaway1 | H | H | H | H | N/A | N/A |
| sb112 | unchecked_low_level_calls | PoCGame | H | H | H | H | N/A | N/A |
| sb113 | unchecked_low_level_calls | Pie | H | H | H | H | N/A | N/A |
| sb114 | unchecked_low_level_calls | WedIndex | H | H | H | H | N/A | N/A |
| sb115 | unchecked_low_level_calls | TownCrier | M! | M | M | M | N/A | N/A |
| sb116 | unchecked_low_level_calls | TokenBank | H | H | H | H | N/A | N/A |
| sb117 | unchecked_low_level_calls | Marriage | H | H | M | H | N/A | N/A |
| sb118 | unchecked_low_level_calls | Delta | H | H | H | H | N/A | N/A |
| sb119 | unchecked_low_level_calls | AirDropContract | H | H | H | H | N/A | N/A |
| sb120 | unchecked_low_level_calls | EBU | H | H | H | H | N/A | N/A |
| sb121 | unchecked_low_level_calls | Splitter | H! | H | H | H | N/A! | N/A |
| sb122 | unchecked_low_level_calls | DepositProxy | H | H | H | H | N/A | N/A |
| sb123 | unchecked_low_level_calls | SimpleWallet | H | H | H | H | N/A | N/A |
| sb124 | unchecked_low_level_calls | DrainMe | H | H | H | H | N/A | N/A |
| sb125 | unchecked_low_level_calls | keepMyEther | H | H | H | H | N/A | N/A |
| sb126 | unchecked_low_level_calls | VaultProxy | H | H | H | H | N/A | N/A |
| sb127 | unchecked_low_level_calls | VaultProxy | H | H | H | H | N/A | N/A |
| sb128 | unchecked_low_level_calls | Pie | H | H | H | H | N/A | N/A |
| sb129 | unchecked_low_level_calls | demo | H | H | H | H | N/A | N/A |
| sb130 | unchecked_low_level_calls | FreeEth | H | H | H | H | N/A | N/A |
| sb131 | unchecked_low_level_calls | FiftyFlip | H | M | H | M | N/A | N/A |
| sb132 | unchecked_low_level_calls | Honey | H | H | H | H | N/A | N/A |
| sb133 | unchecked_low_level_calls | Freebie | H | H | H | H | N/A | N/A |
| sb134 | unchecked_low_level_calls | airDrop | H | H | H | H | N/A | N/A |
| sb135 | unchecked_low_level_calls | TokenSender | H | H | H | H | N/A | N/A |
| sb136 | unchecked_low_level_calls | RealOldFuckMaker | H | H | H | H | N/A | N/A! |
| sb137 | unchecked_low_level_calls | B | H | H | H | H | N/A | N/A |
| sb138 | unchecked_low_level_calls | WhaleGiveaway2 | H | H | H | H | N/A | N/A |
| sb139 | unchecked_low_level_calls | Lotto | H | M | M | M | N/A | N/A |
| sb140 | unchecked_low_level_calls | KingOfTheEtherThrone | H | H | H | H | N/A | N/A |
| sb141 | unchecked_low_level_calls | Lotto | H | H | H | H | N/A | N/A |
| sb142 | unchecked_low_level_calls | SendBack | H | H | H | H | N/A | N/A |
| sb143 | unchecked_low_level_calls | ReturnValue | H | H | H | H | N/A | N/A |

## 附录 B. 原始证据入口

主实验：`<seminv-workspace>\outputs\rq5_sb143_timecurves_20261012_223258`。

四baseline：`<seminv-workspace>\outputs\rq5_baselines_after_20261012_223258`。

主协议：主目录manifest.json；实际命令：各样本command.json；SemInv有效配置：各样本effective_config.json；启动账本：baseline根目录launch_ledger.json；完成标志：主finished.json及各baseline的runs/<tool>/finished.json。

关键实现：`experiments/rq5_timecurves/entry.py`、`experiments/rq3_fresh/hooks.py`、`tools/depfuzz_time_observer.py`、`tools/coverage_semantics.py`、`experiments/rq5_baselines/confuzzius_entry.py`、`experiments/rq5_baselines/evidence.py`、`fuzzer/reporting/t_policy.py`、`fuzzer/reporting/d_policy.py`。原evidence.py未在本次覆写；修正读取逻辑隔离在新consolidate.py，避免覆盖历史结果。
