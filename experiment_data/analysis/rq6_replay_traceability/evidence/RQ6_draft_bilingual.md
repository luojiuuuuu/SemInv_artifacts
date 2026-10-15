# RQ6 Draft: Witness Reproducibility and Explanation Coverage

## English Version

### RQ6: How reproducible are the reported witnesses, how much can their transaction sequences be reduced, and what explanation coverage do the reports provide?

#### Study design

We analyze SemInv transaction traces and explanation reports on SmartBugs Curated. The cohort contains 139 contract runs and 880 reported events: 735 with dynamic transaction sequences and 145 source-pattern findings without sequences. It includes events from successful, timed-out, failed, and untestable runs. Search budgets were 300 seconds for 62 runs, 600 seconds for 33 runs, and 1,200 seconds for 44 runs.

For each dynamic event, we replay the saved processed sequence in a fresh process and deployment. Each replay admits one saved sequence, runs one generation with seed 1, disables data-dependency expansion and constraint solving, and applies the `evidence-safe` filter. A replay counts as reproducing the recorded signal when all requested transactions execute and the expected program counter (PC) and detector type reappear. We report the number of events reproducing this signal in all three runs over the full dynamic cohort; a timeout or incomplete sequence counts as unreproduced. This is a direct replay rate for detector signals.

For sequence reduction, we compare raw and processed transaction counts. The per-sequence reduction is the decrease in transaction count divided by the raw count. We report signal retention as the number of shortened sequences that reproduce the signal in all three runs divided by the shortened sequences with an exact raw sequence that reproduces it in all three runs. Calldata comparisons use the same paired cases. A sequence is *one-transaction deletion-minimal under the detector predicate* when every non-empty single-transaction deletion has been tested and none preserves the predicate. This operational definition follows program-reduction studies that specify a property test and distinguish local deletion minimality from broader minimality claims [1–4].

We measure explanation-text coverage as the number of retained events with an exactly associated, successfully parsed explanation divided by all retained events. We separately record whether the explanation context matches the target contract's source.

#### Results

**Detector-signal reproducibility.** The expected PC and detector type reappeared in all three replays for 514 of 735 dynamic sequences (69.93%). Another 219 sequences completed without the signal, while two replay attempts timed out. The trace-level review of shortened cases below identifies missing initialization and cross-transaction state as causes in the examined arithmetic examples.

Exact raw sequences were available for 614 of the 735 dynamic events. Their first replay observed the signal in 420 cases, did not observe it in 192, and timed out in two. In the paired subset where both raw and processed replays completed (612 events), 408 signals appeared in both, 12 appeared only for the raw sequence, and 192 appeared in neither. The two events that timed out on both sides are excluded from this completed-pair comparison. The 12 raw-only cases show that shortening sometimes removes prerequisites for reaching the reported program point; T0128 and T0136 provide trace-level examples of this state dependence.

**Sequence reduction.** The processed sequences contain 1,387 reported transactions, compared with 1,473 transactions in the raw-length metadata, an aggregate reduction of 86 transactions (5.84%). Sixty-four of 735 dynamic events were shortened. Of the 234 events whose raw-length metadata exceeded one transaction, 64 were shortened; across these cases, the mean per-event reduction was 42.79% and the median was 50.00%.

Exact raw sequences were available for 52 of the 64 shortened cases. Thirty-two of these raw sequences reproduced the detector signal in all three runs. After reduction, 20 retained three-run signal reproducibility and 12 did not. The observed retention rate is therefore `20/32 = 62.50%` for the shortened cases with a reproducible raw baseline. In those 20 retained cases, the aggregate transaction count decreased from 65 to 43, a 33.85% reduction; aggregate calldata decreased from 6,195 to 4,036 bytes, a 34.85% reduction. Eight reduced sequences contain a single transaction. The other 12 retained cases underwent 35 single-transaction deletion attempts: seven deletions preserved the detector signal and 28 did not. Six sequences lost the signal under every tested deletion and are one-transaction deletion-minimal under this predicate; the other six are not.

Two arithmetic cases explain the observed losses. In T0128, the raw sequence calls `init()` and then `run(0)`, reaching the reported PC; the reduced sequence keeps only `run(0)`, which returns before initialization. The input is zero and does not trigger underflow, showing that reaching the detector PC alone can overstate the arithmetic consequence. In T0136, initialization and subtraction occur in separate calls. Reduction removes the first call, so the remaining call initializes a fresh deployment and returns before subtraction. Together, the cases expose two distinct weaknesses in signal-only reduction: a detector signal may not correspond to the claimed arithmetic consequence, and a shorter trace may discard a state transition required to reach it.

**Explanation coverage and source context.** Of 880 reported events, 735 had an exactly associated, successfully parsed explanation, covering all 735 dynamic events and none of the 145 source-pattern events. Thus, text coverage is `735/880 = 83.52%` overall and 100% for dynamic events. Among the 735 associated explanations, 513 used source context matching the target contract, 57 used context from a different source file, and 165 had no static-analysis context. The mismatches span 10 contracts, although run-specific, contract-matched static-analysis artifacts were available. This points to source association and context selection as concrete opportunities to improve the explanation pipeline.

#### Discussion

Across the cohort, 514 of 735 dynamic sequences reproduced the recorded signal in all three replays, and 20 of 32 shortened cases with a reproducible raw sequence retained it. The T0128 and T0136 traces show how initialization affects these observations: one reaches a detector PC without underflow, while the other loses a required state transition after reduction. Explanation text was associated with every dynamic event; among those explanations, 57 used a different source file and 165 had no static-analysis context. These counts characterize replay, reduction, and explanation artifacts under the stated procedures. The reduction criterion follows established evaluations that define preservation through an explicit property test [1–4].

#### References

[1] Chengnian Sun, Yuanbo Li, Qirun Zhang, Tianxiao Gu, and Zhendong Su. “Perses: Syntax-Guided Program Reduction.” ICSE 2018, pp. 361–371. [DOI](https://doi.org/10.1145/3180155.3180236).

[2] Zhenyang Xu, Yongqiang Tian, Mengxiao Zhang, Gaosen Zhao, Yu Jiang, and Chengnian Sun. “Pushing the Limit of 1-Minimality of Language-Agnostic Program Reduction.” OOPSLA 2023, PACMPL 7(OOPSLA1), Article 97. [DOI](https://doi.org/10.1145/3586049).

[3] Zhenyang Xu, Yongqiang Tian, Mengxiao Zhang, and Chengnian Sun. “Boosting Program Reduction with the Missing Piece of Syntax-Guided Transformations.” OOPSLA 2025, PACMPL 9(OOPSLA2), Article 275. [DOI](https://doi.org/10.1145/3763053).

[4] Mengxiao Zhang, Yongqiang Tian, Zhenyang Xu, Yiwen Dong, Shin Hwei Tan, and Chengnian Sun. “LPR: Large Language Models-Aided Program Reduction.” ISSTA 2024, pp. 261–273. [DOI](https://doi.org/10.1145/3650212.3652126).

---

## 中文版

### RQ6：已报告的反例有多大比例能够重现？其交易序列可以缩减多少？报告覆盖了多少解释文本？

#### 实验设计

我们分析 SemInv 在 SmartBugs Curated 上生成的交易轨迹与解释报告。队列包含 139 次合约运行和 880 条报告事件：735 条带有动态交易序列，145 条为没有序列的 source-pattern 报告。队列包含成功、超时、工具失败及不可测试运行中的事件。搜索预算分别为：62 次运行采用 300 秒，33 次采用 600 秒，44 次采用 1,200 秒。

对于每条动态事件，我们在全新进程和部署中重放保存的 processed 序列。每次只输入一条序列，运行一代，固定随机种子为 1，关闭数据依赖扩展与约束求解，并启用 `evidence-safe`。所有请求交易均执行且再次报告预期程序计数器（PC）与检测器类型，记为**检测信号重现**。统计完整动态队列中三次回放均重现信号的事件数；超时或未完成序列计为未重现。

序列缩减以原始与 processed 交易数之差除以原始交易数计算。信号保留率为：在具有精确原始序列且原始序列三次均重现信号的缩短案例中，processed 序列也三次重现信号的比例。calldata 总量仅在相同配对案例上比较。所有非空单笔删除均已测试且没有一次删除保留信号时，称序列达到**检测器判据下的单交易删除局部最小**。这一操作性定义与程序缩减研究一致：明确指定属性测试，并将局部删除最小性与更广义的最小性主张区分 [1–4]。

解释文本覆盖率为与保留事件精确关联且成功解析的文本数除以全部保留事件数。另统计解释上下文中的源码是否与目标合约匹配。

#### 实验结果

**检测信号重现。** 735 条动态序列中，514 条在三次回放中均重现预期 PC 与检测器类型，占 69.93%。另有 219 条完成执行但未出现信号，2 条回放超时。对算术缩短案例的轨迹分析显示，初始化缺失和跨交易状态依赖会导致信号丢失。

735 条动态事件中有 614 条存在精确原始序列。首次重放时，420 条观测到信号，192 条未观测到，2 条超时。在原始与 processed 两侧均完成的 612 条配对事件中，408 条两侧均观测到信号，12 条仅原始序列观测到，192 条两侧均未观测到。两侧均超时的 2 条事件不纳入这一已完成配对比较。12 条仅原始序列命中的案例表明，缩减有时会删除到达报告程序位置所需的前置操作；T0128 和 T0136 给出了状态依赖的轨迹实例。

**交易序列缩减。** processed 序列共包含 1,387 笔报告交易，原始长度元数据共 1,473 笔，合计减少 86 笔（5.84%）。735 条动态事件中有 64 条被缩短。在原始长度超过一笔交易的 234 条事件中，64 条被缩短；这些案例的逐事件缩减率均值为 42.79%，中位数为 50.00%。

64 条缩短案例中有 52 条具有精确原始序列。其中 32 条原始序列三次均重现检测信号。缩减后，20 条仍三次重现，12 条未能重现。因此，在原始序列可复现的缩短案例中，信号保留率为 `20/32 = 62.50%`。这 20 条保留案例的交易总数从 65 减至 43，缩减 33.85%；calldata 总字节数从 6,195 减至 4,036，缩减 34.85%。其中 8 条缩减为单交易。其余 12 条保留案例共执行 35 次单笔删除测试：7 次删除后信号仍在，28 次删除后信号消失。6 条序列在所有已测删除下均失去信号，满足该检测器判据下的单交易删除局部最小；另外 6 条不满足。

两个算术案例解释了信号丢失的原因。T0128 的原始序列先调用 `init()`，再调用 `run(0)` 并到达报告 PC；缩减后只保留 `run(0)`，因合约尚未初始化而提前返回。原始输入为 0，并未触发下溢，说明仅到达检测器 PC 可能高估实际算术后果。T0136 的初始化和减法分别发生在两次调用中；缩减删除首次初始化调用后，剩余调用在新部署中转而执行初始化，并在减法前返回。两个案例揭示了仅以检测信号为目标的缩减存在两类问题：检测器信号未必对应所称的算术后果，且缩短序列可能删除到达该状态所需的转换。

**解释覆盖与源码上下文。** 880 条报告事件中，735 条有精确关联且成功解析的解释文本，覆盖全部 735 条动态事件，未覆盖 145 条 source-pattern 事件。因此，文本覆盖率为 `735/880 = 83.52%`，动态事件子集中为 100%。在 735 条已关联解释中，513 条使用了与目标合约匹配的源码上下文，57 条使用了其他源文件上下文，165 条没有静态分析上下文。57 条错配涉及 10 个合约；对应运行目录中已有合约匹配的运行专属静态分析产物。这表明解释流程的源码关联与上下文选择仍有改进空间。

#### 讨论

总体上，735 条动态序列中有 514 条在三次回放中均重现记录信号；原始序列可稳定重现的 32 条缩短案例中，20 条保留了信号。T0128 和 T0136 的轨迹分别显示，检测 PC 命中不必然伴随下溢，而移除初始化调用会使后续交易无法到达原报告位置。解释文本关联到全部动态事件，其中 57 条采用了其他源文件上下文，165 条没有静态分析上下文。缩减判据通过显式属性测试定义，与程序缩减研究的评价方式一致 [1–4]。

#### 参考文献

[1] Chengnian Sun, Yuanbo Li, Qirun Zhang, Tianxiao Gu, and Zhendong Su. “Perses: Syntax-Guided Program Reduction.” ICSE 2018, pp. 361–371. [DOI](https://doi.org/10.1145/3180155.3180236).

[2] Zhenyang Xu, Yongqiang Tian, Mengxiao Zhang, Gaosen Zhao, Yu Jiang, and Chengnian Sun. “Pushing the Limit of 1-Minimality of Language-Agnostic Program Reduction.” OOPSLA 2023, PACMPL 7(OOPSLA1), Article 97. [DOI](https://doi.org/10.1145/3586049).

[3] Zhenyang Xu, Yongqiang Tian, Mengxiao Zhang, and Chengnian Sun. “Boosting Program Reduction with the Missing Piece of Syntax-Guided Transformations.” OOPSLA 2025, PACMPL 9(OOPSLA2), Article 275. [DOI](https://doi.org/10.1145/3763053).

[4] Mengxiao Zhang, Yongqiang Tian, Zhenyang Xu, Yiwen Dong, Shin Hwei Tan, and Chengnian Sun. “LPR: Large Language Models-Aided Program Reduction.” ISSTA 2024, pp. 261–273. [DOI](https://doi.org/10.1145/3650212.3652126).

---

## 整合说明（不属于论文正文）

当前 OOPSLA 源稿已包含 RQ5“Evidence Quality and Root-Cause Explanation”。本稿应替换旧 RQ5，而不是作为新 RQ6 并列添加；同时应删除旧稿的 EvidenceScore 和 83.61% supportedness 主张。当前结果支持报告重放、缩减保留和解释覆盖，不支持旧的 supportedness 数值。
