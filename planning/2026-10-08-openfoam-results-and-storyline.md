# OpenFOAM 现有结果与演示故事线（2026-10-08）

本文先整理已有证据，再列补充实验计划。数值是已归档的单次运行；`s/step` 指官方 `Average wall-clock time per time step`。不同节点数的要求步数分别为 40/80/150，不能将 PBS 总 walltime 当作计分指标。

## 1. 已有结果：哪些比较能直接使用

### 1.1 正式 Basic：AOCC / Open MPI / Scotch

| 节点 | ranks | 步数 | s/step | 最后一步 Cd | PBS job |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 128 | 40 | 13.352080 | 0.435988 | `19730481` |
| 2 | 256 | 80 | 6.378504 | 0.327139 | `20047559` |
| 4 | 512 | 150 | 2.912440 | 0.284051 | `20064271` |

来源：[`aspire2a-submission-readiness-2026-10-07.md`](analysis/aspire2a-submission-readiness-2026-10-07.md)。三组原始 solver 日志和 `coefficient.dat` 已在远端 scratch 核验，尚未组成提交包。2 节点 Cd 比规则所列约 0.34 的参考值低；规则没有给 Basic 硬性百分比阈值，应如实展示。

### 1.2 可控的 4 节点分区对照

这些运行均为 ASPIRE2A、4×128 ranks、150 步、AOCC 5.0 + Open MPI 5.0.10、stock `Opt`，无显式绑定。它们提供目前最清楚的优化主线。

| 分区 | 层级 | s/step | Cd | 解释 |
| --- | --- | ---: | ---: | --- |
| hierarchical `(8 8 8)` | Basic | 3.355476 | ~0.2984 | 诊断基线；Cd 高于官方约 0.28–0.29 参考值 |
| Scotch | Basic | 2.912440 | 0.284051 | 最终 Basic 配置 |
| weighted Scotch | Basic | 2.905191 | ~0.2886 | 单次比 Scotch 快约 0.25%，不足以声称稳定收益 |
| KaHIP `fast/0.01` | Bonus | 2.875901 | 0.280044 | 单次比 Scotch 快约 1.25%；不能替代 Basic |

Scotch 相对 hierarchical 的单次时间下降约 13.2%。这些运行不是重复试验；Cd 轨迹也有差异，不称“严格数值等价”。绑定的 KaHIP `20092999` 为 2.869257 s/step，是另一种放置配置，不放入纯分区对照。来源：[`aspire2a-4n512-evidence-qa-2026-09-18.md`](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md)、[`2026-apac-hpc-ai-presentation-plan.md`](2026-apac-hpc-ai-presentation-plan.md)。

### 1.3 其他 hierarchical 数据不能直接混排

- 4 节点 512 ranks 的 `(8 8 8)` 有 ICX、GCC、AOCC 结果，分别约 3.311、3.352、3.355 s/step；编译器/MPI 栈不同，不能用于挑选 hierarchical 几何形状。
- 4 节点 256 ranks 的 `(8 8 4)` 有 AOCC 约 6.943、GCC 约 7.067 s/step；rank 数不同，不能与 512-rank 表直接比较。
- 2026-10-08 只读核对远端原始 solver log，另有 4 节点、512 ranks 的 `(16 8 4)` **3.190876 s/step、Cd 0.273561** 和 `(32 16 1)` **3.007944 s/step、Cd 0.290022**；两者都正常到 150 步。`(32 16 1)` 是目前查到的 **最快 hierarchical 单次结果**，不是 `(8 8 8)`。但既有分析记录该组使用 PgoUse 树，绑定/构建配置与上述 stock `Opt` 对照不一致；不能把 3.355→3.008 全部归因于 xyz 划分，也不能把它作为同条件分区主图的基线。来源：远端 `cases/occdrivaer-occdrivaer_4node_aocc_hier32161_v1` 和 `...hier1684_v1` 的 `logFiles/50_simpleFoam*.log`、`system/include/caseDefinition`、`coefficient.dat`；另见 [`aspire2a-post-teammate-six-step-plan-2026-09-24.md`](analysis/aspire2a-post-teammate-six-step-plan-2026-09-24.md)。

### 1.4 编译栈筛选：可报告，但不能宣称 AOCC 是稳定最快的纯编译器

| 4 节点、512 ranks、KaHIP、无显式绑定 | s/step | 关键限制 |
| --- | ---: | --- |
| AOCC 5.0 + Open MPI 5.0.10 | 2.875901 | 单次结果，Bonus 分区 |
| GCC 15.2 + Open MPI 5.0.10 | 2.880512 | 比 AOCC 慢约 0.16%，小于可靠筛选所需差距 |
| ICX 2025.1.1 + Intel MPI | 2.898109 | MPI 也改变；是整套栈的比较 |

在 hierarchical `(8 8 8)` 下，ICX 的单次结果反而略快于 AOCC，因此不能声称 AOCC 对所有分区最优。最终保留 AOCC/Open MPI 的合理说法是：它具备已完成的 Basic Scotch 1/2/4 节点结果和有竞争力的 4 节点成绩；没有证据证明其编译器单独稳定优于 GCC/ICX。GCC `-O3 -march=znver3` 对 stock GCC 的 4 节点比较约为 2.882655 对 2.880512 s/step，单次差约 0.074%，不支持采用该 flag，也不代表其他 flags 无效。来源：[`aspire2a-compiler-codegen-audit-2026-09-17.md`](analysis/aspire2a-compiler-codegen-audit-2026-09-17.md)。

### 1.5 已有 profiling 的力度

旧的多分区 mpiP 诊断显示 KaHIP、Scotch、hierarchical 的 MPI 占比约 26.64%、29.80%、37.08%，方向与时间和分区界面数量一致；旧目录的 Cd 文件有继承数据的来源问题，不能作为干净的正确性对照。干净的 40 步 KaHIP A0/P0/A1 v2 已完成，三份 coefficient 文件相同；两次未插桩控制组差 0.335%，profiling 估计开销 10.114%。v2 原始 mpiP 报告尚未在本地独立解析。已解析的 v1 P0 中，`Allreduce`、`Waitall` 分别占测得 MPI 时间约 51%、29%，但 v1 缺少 A1。`rank-seconds` 不是 solver walltime。来源：[`aspire2a-submission-readiness-2026-10-07.md`](analysis/aspire2a-submission-readiness-2026-10-07.md)、[`aspire2a-step3-mpip-v1-25695102.md`](../results/aspire2a-step3-mpip-v1-25695102.md)。

## 2. 演示顺序：按真实证据而非虚构时间线

1. **Case and platform**：OpenFOAM v2512、65M-cell occDrivAer、`simpleFoam`、ASPIRE2A AMD EPYC 7713；计分点为 4 节点、150 步平均每步 wall-clock，Cd 是 sanity check。远端 case README 明确说明本届 occDrivAer 是 **open-closed cooling**：冷却进气口封闭。此前把它简单称作“open-cooling case”不准确。
2. **Optimization strategy**：科学 workload 固定；研究构建栈、分区、rank/placement、flags 和 MPI 行为。这里可借鉴 seniors 的“维度”页，但不要承诺每个维度都有完整矩阵。
3. **Initial screening / 4-node baseline**：早期 ICX/hierarchical 是探索起点；后续 AOCC/GCC/ICX 与不同分区交叉筛选。只称“测试的构建栈”，不称“纯编译器筛选出 AOCC”。
4. **Decomposition result**：主图使用同一 AOCC/Open MPI、4×128、stock Opt、无显式绑定的 hierarchical `(8 8 8)`、Scotch、KaHIP；weighted Scotch 可在备用页。Basic 和 Bonus 分色，标 Cd 限制。
5. **Selected Basic scaling**：AOCC/Open MPI/Scotch 的 1/2/4 节点结果与 Cd。说明选择 Scotch 是因为它在规则允许的 Basic 方法中给出有效 4 节点结果，且相对 `(8 8 8)` 有较大观测收益；不是因为编译器筛选证明 AOCC 最快。
6. **Compiler/build follow-up**：AOCC/GCC/ICX 代表点、`znver3` 负结果、PGO 证据边界。此页可放在分区页后，符合真实探索逐步细化的顺序。
7. **Communication diagnosis**：分区界面与 mpiP 时间方向一致；区分旧多配置诊断、干净 v2 profile 和正式 150 步成绩。
8. **Best Basic / Bonus and limits**：Basic Scotch 2.912440；Bonus KaHIP 2.875901，同条件；绑定 KaHIP 2.869257 另标条件。

第 3 页若只留一页，建议上半区“Case / Hardware / Score”，下半区“Optimization dimensions / fixed workload”。不要照抄 seniors 对封闭进气口、Bernoulli 验证等与本届输入或证据未核对的描述。

## 3. 补充工作计划：先整理，再决定作业

### 不需要新作业的优先工作

1. 将现有 ASPIRE2A 结果整理成带 job ID、输入、构建、ranks、分区、绑定、步数、s/step、Cd、Basic/Bonus、证据路径的总表；分离正式运行和 profiling。
2. 整理提交包：正式 1/2/4 solver logs、`coefficient.dat`、输入字典、完整运行链日志、构建脚本与说明。原始 scratch 文件尚未复制本地；远端传输形式仍为 TBD。
3. 解析已完成的干净 mpiP v2 报告，核对调用占比和报告页脚；记录 40 步诊断和约 10% 插桩开销。
4. 生成四张图：Basic scaling；同栈分区比较；构建栈代表点；分区界面与 MPI 诊断。所有图注明运行条件、Basic/Bonus 与单次测量。

### 补充 flag 作业：建议的最小实验，而非完整矩阵

先核对 AOCC `OptZnver3` 规则路径和已失败的构建原因；若能形成独立平台且不覆盖 stock `Opt`，使用相同 AOCC/Open MPI、同一固定 **Scotch** 分区、4×128 ranks、相同绑定和输入，仅改变 `-march=znver3`，做 stock 对 tuned 的配对。这样候选仍属于 Basic。先以干净的 40 步窗口筛选，若出现明显超出控制组波动的收益且 Cd/残差保持，再各做 150 步正式验证；不因 0.1% 级单次差异声称收益。`-Ofast`/`-ffast-math` 是 Bonus，不进入 Basic flag 候选。构建、脚本、模块、作业与远端操作均需按仓库规则展示 diff 并获明确批准。

### Profiling 闭环：最小可验证路径

1. 先完成 v2 报告的零机时解析，明确 `Allreduce`/`Waitall` 和 rank 分布，而不直接把 MPI 占比当作潜在加速比例。
2. 若要证明“换分区降低 MPI 成本”，以同一干净 40 步 A0/P0/A1 方法分别 profile Scotch 和 hierarchical；固定 AOCC 二进制、4×128 ranks、绑定、输入、计时窗口，保存新鲜 Cd 文件。与 KaHIP v2 比较时，明确 KaHIP 是 Bonus。
3. 若 profile 指向可控的 MPI/placement 参数，只选一个参数做 A/B；用未插桩控制组确认差异超过噪声，再做 150 步正式验证与 Cd 核对。没有 A/B 收益时，故事止于“解释了现有分区差异和剩余瓶颈”。

新实验不是提交当前 Basic 结果的前置条件。仓库 `AGENTS.md` 要求任何优化实验、构建或作业提交，以及远端执行文件的准备和同步，先展示具体 diff 并获得明确批准。
