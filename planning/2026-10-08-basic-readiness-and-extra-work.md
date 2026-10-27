# ASPIRE2A OpenFOAM Basic：现有证据、缺口与补充工作（2026-10-08）

本清单是提交与实验规划，不是作业提交授权。计分指标是 `simpleFoam` 的 `Average wall-clock time per time step`；4 节点、150 步计分，1/2 节点分别运行 40/80 步用于 scaling。Basic 只使用官方 v2512、原样的科学工作负载，以及 `hierarchical` 或 `scotch` 分区；KaHIP 属于 Bonus。规则：[2026 OpenFOAM task rules, F1–F2](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md)。

## 1. 当前可交的 Basic 候选

构建栈为 AOCC 5.0 + Open MPI 5.0.10，128 ranks/node，Scotch，stock `Opt`。原始日志和 Cd 已在远端核验，尚未打成提交包。

| 节点 | 步数 | PBS job | s/step | Cd 最终值 | 状态 |
| ---: | ---: | --- | ---: | ---: | --- |
| 1 | 40 | `19730481` | 13.352080 | 0.435988 | 原始运行已核验，单次 |
| 2 | 80 | `20047559` | 6.378504 | 0.327139 | 原始运行已核验，Cd 低于规则列出的约 0.34 参考值，需解释/复核 |
| 4 | 150 | `20064271` | 2.912440 | 0.284051 | 原始运行已核验，单次，正式 Basic 候选 |

在已核对的同栈、同 4 节点 512 ranks、150 步、无显式绑定数据中，hierarchical `(8 8 8)` 为 3.355476 s/step、Cd 约 0.2984；Scotch 为 2.912440，观测时间低约 13.2%。前者 Cd 偏离参考约 0.28–0.29，且只有单次；应标成探索性对照，不称严格有效基线。其他 hierarchical XYZ 的构建/绑定条件未完全匹配，不能并入这项纯分区效果。KaHIP 2.875901（无绑定）与 2.869257（加绑定）为 Bonus，不替代 Basic。

## 2. 先整理：不需要新作业

| 优先级 | 工作 | 交付物及完成标准 |
| --- | --- | --- |
| P0 | 锁定 Basic 三个原始运行的证据 | 保存每点原始 `simpleFoam` log、`coefficient.dat`、PBS stdout/stderr、各准备阶段日志；检查步数、metric、Cd 和最终状态一致。尤其审阅 2 节点 Cd 轨迹与字典。 |
| P0 | 核对 Basic 规则与 provenance | 保存实际 `caseDefinition`、`decomposeParDict`、`controlDict`，对照官方 case 做语义 diff；确认 `fvSchemes`、`fvSolution`、function objects、完整 Allrun 命令及 `-ybl`；记录官方 v2512 来源、`WM_*`、编译器/MPI、stock `-O3`、任何 `wmake/rules/*` patch。历史运行缺逐次 binary hash，应如实写明。 |
| P0 | 形成文本提交包与总表 | 一行一个正式运行：节点/ranks/步数/分区/绑定/构建/任务 ID/s-per-step/Cd/证据路径/Basic 或 Bonus。Basic 与 Bonus 分目录；提交包只含文本、图和演示文稿，不含 mesh、processor 目录或 binary。 |
| P0 | 完成 Basic 展示 | 单独展示工作负载和规则、Basic 1/2/4 scaling、4 节点同条件分区对照、Cd、当前 Basic 配置及局限。所有点注明单次运行；不把 PBS 总 walltime 当计分值。 |
| P1 | 解析现有 profiling | 已有旧 Scotch/KaHIP/hierarchical mpiP 可作方向性诊断，但其 40 步 Cd 文件继承自旧 150 步运行；不得用于 profile 正确性证明。干净 KaHIP A0/P0/A1 v2 已完成，应先本地解析其 mpiP 报告和控制组。 |

提交规则要求 4 节点 log、Cd、1/2/4 scaling、输入字典、构建与完整运行链、slides；MPI profiling 是强烈建议，而非必交成绩。当前最大提交风险是**证据尚未整理成可读文本包**，不是缺少新的 solver 时间。

## 3. 补跑：按增量价值排序

### E1. Scotch 4 节点未插桩重复（优先于新 flag）

- **问题**：2.912440 s/step 是单次运行；Scotch 与 KaHIP 无绑定单次只差约 1.27%，需要知道运行波动。
- **设计**：保持正式 Basic 的 AOCC/Open MPI、Scotch、512 ranks、绑定、输入及完整 Allrun 链不变，再做至少一次 150 步独立重复；保留新鲜 Cd、原始 metric、资源和 job provenance。若时间/配额允许，形成至少三次总样本更有说服力。
- **价值**：增强 Basic 成绩可信度；不应为了等待重复而推迟现有合规结果的提交。

### E2. 干净 Scotch A0/P0/A1 mpiP（最有助于故事闭环）

- **问题**：旧 Scotch profiling 的 Cd 是继承文件；干净的 v2 profiling 只针对 KaHIP。缺乏可核查的 Basic 机制图。
- **设计**：4 节点、512 ranks、同一 AOCC/Open MPI 二进制和固定 Scotch 分区；同一 allocation 内运行未插桩 A0、mpiP P0、未插桩 A1，各 40 步；每组从干净 case 生成新 `coefficient.dat`，保存 mpiP 报告、rank 映射、绑定设置及步骤 20–40 的相同计时窗口。若与 KaHIP v2 直接对比，须使绑定和其他条件相同；否则仅分析 Scotch 自身剩余成本。
- **价值**：可解释 Basic 中 Allreduce、Waitall、rank 分布与插桩开销。40 步是诊断，**不替代** 150 步未插桩成绩。

### E3. Basic 内的受控优化 A/B（仅当 E1/E2 或现有证据给出明确假设）

优先考虑一个变量：例如 Scotch 的 rank placement/NUMA 绑定，或一个 IEEE 安全的 AOCC `znver3` 编译设置。先确认两个配置除这个变量外完全相同、独立构建不会覆盖现有 Basic；用短窗口和未插桩控制组筛选。只有收益明显大于运行波动、Cd 与数值过程可接受时，再做 150 步正式验证。不要临时做多个 flag × MPI × 分区的大矩阵；`-Ofast`/`-ffast-math` 归 Bonus。

### E4. 可选的 Basic hierarchical 同条件对照

若要严格讲“Scotch 比最好的 hierarchical 更快”，需在同构建、同绑定、同 ranks、同输入下重新比较候选 XYZ，核对 Cd，再与 Scotch 重复对照。现有 `(32 16 1)` 结果涉及不同构建树，不能充当这个结论。截止日前不优先于 P0、E1/E2。

## 4. 决策与讲述边界

- **现在可说**：Scotch 是已核对的 4 节点 Basic 候选，2.912440 s/step；1/2/4 scaling 已有；相对一组同条件 hierarchical `(8 8 8)` 有明显单次改善；旧 mpiP 方向与分区表面积/性能差异一致。
- **现在不能说**：Scotch 已被证明是所有 Basic 参数的全局最优；AOCC 是稳定最快的纯编译器；profile 先发现问题后才选择 Scotch；KaHIP 的绑定版本是纯分区收益；旧 Scotch profile 的 Cd 已通过干净验证。
- **若只够做一件事**：完成 P0 文本提交包。若还有一个作业窗口，E1 强化正式成绩或 E2 强化解释，取决于当前更缺可信分数还是 profiling 故事。

任何新作业、构建或远端改动均须先给出具体脚本/配置 diff，并按仓库 `AGENTS.md` 取得相应授权；本文件没有准备或执行远端脚本。

## 5. 证据索引

- [`aspire2a-submission-readiness-2026-10-07.md`](analysis/aspire2a-submission-readiness-2026-10-07.md)：Basic 1/2/4 原始日志、Cd、构建与提交缺口。
- [`aspire2a-4n512-evidence-qa-2026-09-18.md`](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md)：4 节点分区对照与数据边界。
- [`aspire2a-step1-mpip-evidence-2026-09-23.md`](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md)：旧 Scotch/KaHIP/hierarchical profiling、继承 Cd 问题。
- [`2026-10-08-openfoam-results-and-storyline.md`](2026-10-08-openfoam-results-and-storyline.md)：现有整体故事线及其他补充计划。
