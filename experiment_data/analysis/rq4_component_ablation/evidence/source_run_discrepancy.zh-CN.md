# RQ3 反向变化诊断：ReentrancyDAO

## 结论

143 份原始分类集的主 seed 11 结果中，唯一观察到“消融变体命中、Full 未命中”的源码是 `sb081`（`ReentrancyDAO`，`reentrancy_dao.sol`）。这是一个真实的运行时重入事件，不是报告归属或 T-v1 计分遗漏。现有证据不支持把它解释成 No Property Tests 带来的收益：该变体的搜索命令与 Full 相同，属性测试开关只在结果汇总时移除了属性报告通道。

最可能的解释是单次遗传搜索轨迹差异，且当前实现中有已定位的非确定性顺序来源：每代把子代 `Individual` 对象转成 `set` 再转回列表，而 `Individual` 没有实现 `__hash__`/`__eq__`。因此该集合按对象身份而非染色体内容去重，既不能可靠合并同基因组个体，又会依赖对象分配地址改变子代顺序。`PYTHONHASHSEED=11` 和 Python `random.seed(11)` 已设置，但这不能固定对象身份哈希的排列。Full 还有专属的 solver 决策快照钩子，会增加分配和运行开销；它可能进一步改变固定时间预算内的演化轨迹，但尚未做差分实验来单独量化其影响。

我另外在独立目录对 `sb081 / Full / seed 11` 做了一次完整 600 秒诊断运行，没有覆盖或改写正式批次。它仍未命中 line 18，覆盖率仍为 67.10%（104/155），共 844 代、63,373 笔交易。该重复运行支持 Full 在当前设置下稳定遇到这一搜索缺口，但不能单凭两次 Full 失败和一次 NoPropertyTests 成功估计命中概率。

## 结果核对

唯一反向样本在 139 个可比较源码中占 1/139（0.72 个百分点）。所有运行均为 `budget_completed`，未发现该样本的 timeout、崩溃或属性测试失败。

| 变体 | 重入命中 | 指令覆盖率 | 首次重入事件时间 |
|---|---:|---:|---:|
| Full | 否 | 67.10%（104/155） | — |
| Full 独立诊断重复 | 否 | 67.10%（104/155） | — |
| NoSymbolic | 否 | 67.10%（104/155） | — |
| LegacyNoUIR | 是 | 99.35%（154/155） | 36.563 秒 |
| LegacyNoUIR | 是 | 99.35%（154/155） | 318.531 秒 |
| NoUIRSearch + NoSymbolic | 是 | 97.42%（151/155） | 61.922 秒 |
| NoFunctionalSeeds | 是 | 99.35%（154/155） | 144.563 秒 |
| NoPropertyTests | 是 | 99.35%（154/155） | 135.438 秒 |
| LegacyNoUIR + NoSymbolic | 是 | 97.42%（151/155） | 62.688 秒 |

NoPropertyTests 原始事件记录指向 `reentrancy_dao.sol:18`，PC 152，且记录了可执行轨迹。关键前缀为同一 sender `0xdead…beef` 先调用 `deposit()` 并发送 value 1，再调用 `withdrawAll()`；这使 `credit[msg.sender] > 0`，并到达外部调用后写 storage 的重入模式。Full 的事件记录中没有该重入事件，故它不是后处理丢失。

Full 与 NoPropertyTests 的 `command.json` 在将各自输入/输出路径归一化后，70 个参数完全相同：都使用 seed 11、600 秒搜索预算、相同源码/编译器/提示/符号和 UIR 参数。Full 中属性通道也不是搜索时的在线反馈。completion 分析在 `property_enabled=false` 时将 `included_prop` 置空；搜索阶段仍运行相同的 fuzzer。这意味着 sb081 上 NoPropertyTests 的额外命中不能作为“去掉属性后搜索更有效”的证据。

## 代码层面的机制

- [`engine.py`](<seminv-workspace>/experiments/rq3_fresh/runtime/fuzzer/engine/engine.py:219) 用 `children=list(set(children))` 重排每代子代。
- [`individual.py`](<seminv-workspace>/experiments/rq3_fresh/runtime/fuzzer/engine/components/individual.py:22) 定义的 `Individual` 只有普通 `hash` 属性，没有 Python 特殊方法 `__hash__` 或 `__eq__`；因此 `set` 使用对象身份，实际不是稳定的内容去重。
- [`runner.py`](<seminv-workspace>/experiments/rq3_fresh/runner.py:84) 虽然为各运行设置了 `PYTHONHASHSEED`，但这不控制对象身份哈希。
- [`hooks.py`](<seminv-workspace>/experiments/rq3_fresh/hooks.py:169) 对 Full 单独包裹符号分支排序，并在每次排序时采集快照。它不改变排序函数本身的返回值，但其额外对象分配/耗时与上述不稳定子代顺序叠加，可能改变运行轨迹。
- Full 的 UIR 目标中包含 `deposit → withdrawAll` 对 `credit` 的 write-read 关系；但 [`runner.py`](<seminv-workspace>/experiments/rq3_fresh/runner.py:182) 将 `--uir-mutation-insert-rate` 固定为 `0`。该案例的 UIR 函数只标为 `dfg/state_update`，没有可触发字段变异的风险标签；Full 记录 892 次 UIR mutation 尝试、0 次应用、0 次序列插入，UIR solver 260 代均未触发。符号分支 solver 虽然有 10 次 SAT 尝试，但没有生成注入候选。故 Full 在此案例未利用已抽取到的跨交易关系构造同账户的存款—提款序列。
- 独立 Full 重复运行中，UIR mutation 3,155 次尝试仍为 0 次应用、0 次序列插入；UIR solver 仅因 `write_read_relation_uncovered` 触发 1 次，之后 843 代跳过；分支求解生成 2 个候选，但 0 个注入（均因低价值被丢弃）。这把缺口定位到“关系已有，但未生成有用的有序状态转换序列”。

这些代码和日志证据能解释为何一次 run 会反向，但还没有对 Full 专属观察钩子和子代排序做因子化差分，因此不应把具体反向轨迹完全归因于某一个组件。可以确定的是：它不是 `NoPropertyTests` 的因果收益，也不是检测器误报。另一次 Full 在更高单机吞吐下仍未命中，说明单纯增加该源码上的执行速度不足以弥补关系序列引导缺口。

## 对结果和稿件的处理

不应从原始结果中删除这 1 个有效命中，也不能将 NoPropertyTests 的事件直接回填给 Full。这样做会改变 arm 的实验定义和原始观测。主结果保持 `Full 128/139`、`NoPropertyTests 129/139`；该行差异只支持“单个源码上的检测集合不一致”，不支持 NoPropertyTests 整体优于 Full。解释应写成单次预算下的 search-trajectory discordance，并说明 NoPropertyTests 的搜索配置与 Full 相同，因此该样本不属于属性后端的正向/负向贡献证据。

要让 Full 合法地报告 sb081 命中，需要真实的新搜索运行。仅启用关系插入率也未必够：当前插入逻辑随机生成新 sender，不能保证 `deposit` 与 `withdrawAll` 使用相同的 `msg.sender`。可行的算法改进是按 `credit[msg.sender]` 的读写关系生成有序交易，并把两笔交易的 sender 绑定到同一账户；同时先把子代容器改成稳定的、基于规范化染色体内容的去重并保序。随后在独立的新协议版本中重跑 Full 与相关对照，报告新版本结果；不能把单案例诊断结果替换原 143 源码主结果。

## 建议的论文写法

“在 139 个可比较源码中，Full 与 NoPropertyTests 仅在 `ReentrancyDAO` 上出现一次命中不一致（128/139 对 129/139）。该源码的运行时重入需要先由同一账户存入正值，再由该账户调用提款。NoPropertyTests 与 Full 使用相同搜索命令，属性通道仅在汇总时关闭，因此该差异反映了单次遗传搜索轨迹的波动，而非去除属性测试带来的搜索收益。其余消融差异按配对总体指标解释。”

原始数据、实验源码及 RQ1 参考实验均保持不变。新增的单案例 Full 诊断保存在 [独立运行目录](<seminv-workspace>/outputs/rq3_reverse_diag_sb081_full_20261014_192858/diagnostic_result.md)，复现实用脚本见 [diagnose_reverse_full.py](<seminv-workspace>/experiments/rq3_completion/diagnose_reverse_full.py)。该诊断只作机制核查，不替换 143 源码主结果。
