# OpenFOAM 展示故事线与后续实验计划

更新：2026-10-25。本文用于重排演示文稿；所有时间为 `simpleFoam` 日志中的平均每步 wall-clock 秒数，越低越好。新 `(16 8 4)` stock Opt 结果已核验；Scotch A/B/C 三轮已完成，但计时波动和 B 组 Cd 限制了结论。详情见 [2026-10-25 作业核查](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md)。

## 一句话主线

在固定 DrivAer 工作负载、AOCC/Open MPI stock Opt 构建与 4 节点运行条件下，先筛选 hierarchical 的 XYZ，再比较 Basic 合法的 hierarchical、plain Scotch 和 weighted Scotch；用 150 步正式计时与 Cd 确认最终 Basic 配置，随后用相同 PMPI 方法解释三者的通信成本。KaHIP、flags、PGO 和绑核是独立探索，不倒推成 Basic 选择的因果依据。

## 1. Workload and evaluation

- Case：`occDrivAerStaticMesh`，约 65,334,765 cells；DrivAer 外部气流，冷却入口关闭。
- Solver：OpenFOAM.com v2512 `simpleFoam`；ASPIRE2A AMD EPYC 7713。
- Basic 运行链：`decomposePar` → `restore0Dir` → `renumberMesh` → `potentialFoam` → `applyBoundaryLayer` → `simpleFoam`。保持 mesh、solver 源码、`fvSchemes`、`fvSolution` 不变。
- 节点／步数／rank：1 节点 40 步 128 ranks；2 节点 80 步 256 ranks；4 节点 150 步 512 ranks。4 节点为计分点。
- 正式指标：solver 日志的 `Average wall-clock time per time step`，不是 PBS 总 walltime，也不是把总时间除以步数。正确性检查为新鲜 `coefficient.dat` 的 Cd 及轨迹。

**建议画面**：左侧 case/solver 三行，右侧原生表格列出 1/2/4 nodes、ranks 和 steps，底部一行标记 scoring metric。

## 2. Strategy and controls

主线控制条件：AOCC 5.0 + Open MPI 5.0.10，OpenFOAM v2512 stock `Opt` (`-O3`)，每节点 128 ranks，`ppr:128:node`，无显式绑核。4 节点分区对照保持同一输入与 150 步，只改变 mesh decomposition。使用 AOCC 是为了延续有完整 Basic 数据的工作构建，并非筛选证明它是所有节点数的最快编译器。

**建议画面**：横向四步流程：Stack feasibility → Hierarchical XYZ → Basic decomposition → Scored run & PMPI diagnosis。把 Bonus/flags/PGO 画成旁支。

## 3. Compiler / MPI stack survey（背景，不作为胜出筛选）

已有 4 节点 KaHIP 代表点：AOCC + Open MPI 2.8759；GCC + Open MPI 2.8805；ICX + Intel MPI 2.8981 s/step。AOCC 与 GCC 差约 0.16%，均只有单次；ICX 同时更换了 MPI，因此比较的是构建栈，不是纯编译器。1/2 节点的历史代表点可保留在小表中，但必须核对各点分区和构建条件，不能把不同设置串成受控的“三编译器 scaling”图。ICX 与 Intel MPI 是当时所选的 Intel 构建栈搭配，不是 ICX 必须使用 Intel MPI。

**可讲结论**：没有足够证据宣称普适最快编译器；采用 AOCC + Open MPI 作为 Basic 分区实验的一致平台。

## 4. Hierarchical 内部 XYZ 筛选

| XYZ | 构建／条件 | 4-node 150-step s/step | Cd(150) | 解释 |
|---|---|---:|---:|---|
| `(8 8 8)` | 历史 stock Opt；at-run binary hash 缺失 | 3.3555 | 0.298430 | 参考点，Cd 轨迹需复核 |
| `(16 8 4)` | stock Opt、无 profiler；job `25906053.pbs101` | **3.291328** | **0.273561** | 新鲜 150 步对照；Cd 轨迹需复核 |
| `(32 16 1)` | stock Opt、无 profiler；job `25826705.pbs101` | **3.064002** | **0.290022** | 两组新对照中更快的 hierarchical 候选 |

新 `(16 8 4)` 的 PBS 与脚本退出码均为 0，solver 日志有完整 150 步，`coefficient.dat` 于该作业运行期间新生成且包含 150 行。它比同构建、同 launcher 的 `(32 16 1)` 慢约 **7.42%**（以 `(32 16 1)` 时间为分母）；因此，**在这两个严格匹配的新结果中，`(32 16 1)` 最快**。新 `(16 8 4)` 的 Cd(150) 与旧结果接近，但约 0.2736 低于先前采用的约 0.28–0.29 参考区间，不能只根据技术运行成功就认定科学正确性；需检查完整 Cd／残差轨迹。历史 `(16 8 4)` PgoUse 3.1909 与历史 `(32 16 1)` PgoUse 3.0079 均不可代入 stock Opt 对照。`(8 8 8)` 缺 at-run binary hash，三 XYZ 图可显示其历史参考点，但不得称三点均为严格同构建实验。

**新结果证据**：ASPIRE2A scratch `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/hier1684-opt-4n-v1-25906053/`，其中 `evidence/logs/50_simpleFoam_A0.log` 给出 150 步与 3.291327721919464 s/step，`case/postProcessing/forceCoeffsAll/0/coefficient.dat` 给出新鲜的 150 行及 Cd(150) 0.27356125421800065。PBS `qstat -x -f` 为 `Exit_status = 0`；`evidence/exit-status.txt` 为 `script_exit_rc=0`。实验记录见 [`experiments/aspire2a-hier1684-opt-4n/README.md`](../experiments/aspire2a-hier1684-opt-4n/README.md)。

**建议画面**：三点横向 dot plot，实心标出两组新 stock Opt 结果，`(8 8 8)` 用空心历史参考点；图注写明其二进制 provenance 限制，并在 `(16 8 4)` 旁标注 Cd 需复核。

## 5. Basic decomposition 主对照

在上述 AOCC/Open MPI stock Opt、4 节点 512 ranks、150 步、无显式绑核条件下：

| 分区 | s/step | Cd(150) | Job | 备注 |
|---|---:|---:|---|---|
| hierarchical `(32 16 1)` | 3.0640 | 0.290022 | 25826705 | 同构建新对照 |
| plain Scotch | 2.9124 | 0.284051 | 20064271 | Basic |
| weighted Scotch | **2.9052** | 0.288551 | 20072244 | Basic 提交配置；`domains (4 8 16)`，`domainWeights (1 1 0.01)` |

Weighted 比 `(32 16 1)` 低约 5.18%；比 plain Scotch 低约 0.25%。后一差异来自单次运行，且 plain 与 weighted 的 `domains` 和 `domainWeights` 均有变化，**不能声称权重单独带来了稳定收益**。称“当前观察到的最快 Basic 配置”即可。新 `(16 8 4)` 为 3.291328 s/step，未改变以 `(32 16 1)` 作为较快 hierarchical 对照的选择。

**建议画面**：点图或短条图，纵轴显示 2.85–3.12 s/step 并明确标注截断轴；每点标数值，另用小型 Cd 表验证。不把 Bonus KaHIP 混在 Basic 排名中。

## 6. Final Basic 运行与 scaling

| Nodes | Ranks | Steps | Weighted Scotch s/step | Cd(final) | Job |
|---:|---:|---:|---:|---:|---|
| 1 | 128 | 40 | 13.3451 | 0.434536 | 19730482 |
| 2 | 256 | 80 | 6.3961 | 0.340263 | 20030920 |
| 4 | 512 | 150 | **2.9052** | **0.288551** | 20072244 |

1/2/4 节点要求的步数不同，Cd 也处于不同收敛阶段。因此这张图展示任务规定运行点的时间趋势，不把比值当作严格同长度 strong scaling 或宣称超线性加速。正式计分只引用 4 节点无 profiler 日志。

**建议画面**：三根柱／点与节点、步数原生表格并列；每组标注 step count。

## 7. PMPI 机制诊断：同一方法、三种分区

新三路 150 步 PMPI 作业 25826770 在相同 stock Opt 与 4 节点 512 ranks 条件下全部完成，均保留新鲜 Cd：

| 分区 | Profiler 内 s/step | Mean rank time in MPI | Compute share |
|---|---:|---:|---:|
| hierarchical `(32 16 1)` | 3.0650 | 27.29% | 72.71% |
| plain Scotch | 2.9635 | 19.68% | 80.32% |
| weighted Scotch | 2.9212 | 19.03% | 80.97% |

PMPI 显示 hierarchical 的 MPI 占比更高，与分区改善通信/同步成本的解释相符。它是**选出快配置之后的诊断**，不是“先 profile 才选出 Scotch”的时间线；PMPI 的插桩计时不替代无 profiler 的正式成绩。旧 mpiP 与 PMPI 的范围、方法不一致，不能直接放在同一量化图比较。

**建议画面**：三根 100% stacked bar（MPI / non-MPI）及右侧两句结论。若使用 cut-face 结构指标，需要说明“推算跨节点界面”依赖 rank-block node mapping 假设，不是实测网络流量。

## 8. Bonus and build explorations（独立支线）

- KaHIP `fast/0.01` stock Opt：2.8759 s/step、Cd 0.280044，job 20030922；属于 Bonus，不能称 Basic best。相对 weighted Scotch 快约 1.01%，仍为单次点。
- GCC `-march=znver3` 与 stock Opt 的 KaHIP 单次对照 2.8827 vs 2.8805 s/step，未见可靠收益。
- AOCC PGO + KaHIP + 绑核 2.86785；匹配 Opt + KaHIP + 绑核 2.86926，约 0.05% 差，不能宣称已证实 PGO 收益。PGO 经 PgoGen 训练再 PgoUse 构建，不能混入 Basic 主线。
- 绑核影响依赖分区：既有 weighted Scotch 2.905 → 2.949 s/step（变慢），KaHIP 2.876 → 2.869（变快）；单次结果仅作探索。

**建议画面**：独立的探索页，明确 Basic / Bonus 标签；PGO 与 flag 用小型对照表，不给微小差异画夸张纵轴。

## 9. Final claim and evidence limits

最终 Basic 提交配置：AOCC 5.0 + Open MPI 5.0.10 stock Opt，4 nodes × 128 ranks，weighted Scotch，150 steps，无显式绑核。正式平均每步 2.9052 s，Cd(150) 0.288551。报告“已观察到的最快 Basic”，而非“证明 weighted 稳定优于 plain”或“证明 AOCC/PGO 最优”。

需在讲稿或备份页明确：`(16 8 4)` 的新 Cd(150) 约 0.2736，完整轨迹仍需复核；`(8 8 8)` 缺 at-run binary hash 且 Cd 轨迹需复核；plain/weighted 已做三轮重复但计时波动大，不能据此宣称 weighted 稳定更快；编译栈和 PGO 的细小差异仍缺匹配重复；PMPI 是一致的机制证据而非因果证明。

## 10. Scotch A/B/C 后续：先解释波动，再决定是否补跑

三轮 4 节点、512 ranks、150 步无 profiler 作业已完成。A 为 plain Scotch；B 为相同 `domains (4 8 16)` 的均匀权重 `(1 1 1)`；C 为相同 domains 的当前权重 `(1 1 0.01)`。每轮在同一节点分配上按不同顺序完成 A/B/C；三轮使用相同的 AOCC stock Opt `simpleFoam` SHA-256、每组各自相同的有效输入哈希，且九个 solver 日志均正常走完 150 步。以下是**诊断重复结果，不替换已有提交成绩**：

| Block / PBS | 顺序 | A plain | B uniform | C weighted | 单位 |
|---|---|---:|---:|---:|---|
| 1 / `25909583` | A–B–C | 2.929377 | 3.030054 | 3.201184 | s/step |
| 2 / `25909584` | B–C–A | 3.166639 | 2.912308 | 3.086675 | s/step |
| 3 / `25909585` | C–A–B | 5.565019 | 4.918194 | 4.113459 | s/step |

三组 Cd(150) 在各轮分别重复为 A **0.284051**、B **0.274010**、C **0.288551**；B 的 40/80/120/150 步 Cd 轨迹也跨轮一致，但最终低于目前采用的约 0.28–0.29 参考带，不能作为合格优化候选。每轮最快者依次是 A、B、C；C 相对 A 的差值依次为慢 9.28%、快 2.53%、快 26.08%。第三轮整体明显变慢，且三轮使用不同的物理节点组合；第三轮末的 `ClockTime` 与 `ExecutionTime` 差距也扩大。这提示应调查等待或节点环境，但尚未证明原因。**不得对九个点简单取最小值或整体均值来证明权重收益。** 保留原 2.9052 s/step、Cd 0.288551 为已提交的 C 单次正式记录，同时把“C 比 A 快约 0.25%”标为当时单次观察，而非可复现结论。

补充顺序（以下均为建议，尚未授权新作业）：

1. **零 SU 证据审计**：核对九条 Cd／残差轨迹、各阶段时间、分区 cell/interface 分布、跨节点界面估算及 rank→node/core 映射；对照三轮节点位置和 PBS 输出。先确认 B 的科学有效性问题，以及第三轮为何整体变慢。不要把“跨机柜”直接写成已证实原因。
2. **仅在找出并控制波动来源后，补 A 与 C**：沿用固定 AOCC/Open MPI stock Opt、同一 65M 输入、4×128 ranks、150 步、无 profiler、无显式绑核；在同一节点分配内做顺序平衡的配对重复，完整保存节点、亲和性、输入/二进制哈希、时间轨迹和新鲜 Cd。已有三轮不能直接当作稳定收益证据，也不应原样盲目加跑更多轮。2026-10-25 用户确认直连认证恢复后，`qstat -x` 和 `tracejob -n 7` 仍都查不到这三个已结束作业的历史事件；已从保留文件确定第三轮约 10 月 23 日 07:17–08:56（新加坡时间）的节点与时间窗口，供站点支持核对。详见[节点事件跟进](../progress/2026-10-25-aspire2a-scotch-abc-site-event-followup.md)。
3. **只有 A/C 的正确性和稳定差异成立，才测新权重**：先根据切面与拓扑提出 1–2 个比例，每次只改变 `domainWeights`。B 当前是用来拆分变量的诊断组，不是胜出候选。
4. **PGO 与绑核是可选 Basic 扩展，而非尚未开展的工作**：已有 PGO 对照在 KaHIP＋绑核支线，约 2.86926→2.86785 s/step；weighted Scotch 的单次绑核对照为 2.90519→2.94881 s/step。若后来要主张它们改进 Basic Scotch，须分别在选定的 Scotch 分区上做同分配、同输入的 Opt/PgoUse 或 unbound/bound 配对；不要把 KaHIP 的结果移植到 Scotch。当前优先级低于 A/C 波动与 B 正确性审计。

详细作业路径、退出状态和原始记录位置见 [本次核查](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md)。

## 幻灯片建议顺序

1. Cover；2. Team；3. OpenFOAM section；4. Workload & evaluation；5. Strategy and controls；6. Stack survey；7. Hierarchical XYZ；8. Basic decomposition；9. Selected Basic configuration；10. Basic scaling and Cd；11. PMPI method；12. Three-way MPI share；13. Bonus KaHIP；14. Architecture flag；15. PGO；16. Rank binding；17. Final results；18. Evidence limits；19. Next step；20. Thank you。

每页只讲一个问题。Slides 内为英文短句、原生可编辑图表和表格；本文保留中文解释与证据限制。

## 11. 学长的图论解释与我们能主张的范围（2026-10-25 核对）

把 mesh 看成图：cell 是顶点，相邻 cell 之间的内部 face 是边；分给不同 MPI rank 的相邻 cell 形成 processor interface，求解时通常需要交换场值。分区同时希望各 rank 工作量接近，并减少昂贵的跨分区边。几何 hierarchical 主要按坐标逐层切割；Scotch/METIS/KaHIP 会利用连接图考虑切边与平衡。因此图方法**可能**更快，不能当成所有网格和机器上的定理，也不能把切面数直接写成网络字节数或 MPI 时间。本项目现有 4 节点数据支持“较快的 graph-based 分区通常比 hierarchical 有更少界面和 MPI 等待”的机制解释；具体到 weighted 与 plain Scotch，结论尚未稳定。

学长所说的是 **multi-level Scotch**，不是“module-level”。OpenFOAM v2512 的 `scotch` 支持通过 `coeffs { domains ...; domainWeights ...; }` 表示多层通信权重。学长图里是 `domains (4 56)`、`domainWeights (1 0.01)`；我们 ASPIRE2A 的 C 是 `domains (4 8 16)`、`domainWeights (1 1 0.01)`，所以属于同一类机制，但**不是同一配置或同一实验**。我们的 A 是 plain Scotch，B 是相同 `domains` 且均匀权重 `(1 1 1)`，C 是当前加权配置。这些 ASPIRE2A 结果不可说成在 Gadi 上做的。此处的“层”是分区模型；是否精确对应实际 node/socket/core，需要结合 rank→node/core 映射验证。

现有 A/B/C 三轮中，C 分别是最慢、居中和最快；第三轮全部明显变慢。B 的 Cd(150) **0.274010** 低于当前约 0.28–0.29 参考带，但规则没有写成硬阈值，应标作正确性待评估。第一轮的总 processor-interface faces 为 A **2,927,022**、B **2,958,587**、C **3,033,594**：C 的**总切面更多**，不能借用学长的话宣称“C 通过减少总通信边胜出”。2026-10-25 的[零 SU 核查](../progress/2026-10-25-aspire2a-scotch-abc-zero-su-audit.md)读取了三轮实际 rank→host 映射，验证了跨节点 faces：A **337,324**、B **279,728**、C **271,614**；这提示权重可能转移了切面位置，但不等于实测网络流量。三轮每个配置的完整 Cd 文件逐字节相同，而第三轮出现多个几十秒的 wall-clock 跳变；未识别其根因，不能据此排名 A/C。

### Profiling 的“按时间”和“按次数”

我们已有 ASPIRE2A 的 4 节点 40 步 **mpiP** call-type 汇总：plain Scotch 按累计 MPI 时间前三为 `MPI_Allreduce` **11,650.9 rank-s**、`MPI_Waitall` **6,856.2 rank-s**、`MPI_Isend` **1,053.4 rank-s**；按调用次数前三是 `MPI_Isend` **305.68M**、`MPI_Irecv` **305.68M**、`MPI_Test` **304.25M**（其次 `MPI_Allreduce` **32.32M**）。所以我们的“前三次数”**不等于**学长图里的 `Isend/Irecv/Allreduce`。累计 rank-s 不是 solver wall-clock 秒，也不表示纯网络传输。旧 mpiP 40 步的 coefficient 文件继承自模板，不能用来验证该 profile 的新鲜 Cd。已完成的三分区 **PMPI 150 步**提供相同工具下的总 MPI 占比（hierarchical 27.29%、plain 19.68%、weighted 19.03%），可作 Basic 机制主图；若要画 PMPI 的 call-type 时间/次数图，应先从**这组三个 PMPI 原始报告**一致地提取，不要把旧 mpiP 与 PMPI 数值混画。Gadi 也做过 Scotch PMPI rank/peer 分析，但架构、rank 数、MPI 环境均不同，应另列背景而非并入 ASPIRE2A 对照。

### METIS 已测试，保留在 Bonus 支线

队友的 ASPIRE2A 记录中，最早 ICX/Intel MPI 的 1 节点 METIS 作业因缺实际 `libmetisDecomp` 而失败；后续独立 METIS 构建有成功记录：AOCC/Open MPI stock Opt、1 节点 40 步约 **13.390 s/step**（job `25246701`），4 节点 150 步、**core binding** 约 **2.934 s/step**、Cd 约 **0.2927**（job `25252675`）。其 4 节点点位不能与无显式绑核的 plain/weighted Scotch 当成单变量 A/B；METIS 与 KaHIP 均留作 Bonus 探索。当前不需要为了讲 Basic Scotch 再跑 METIS。

### 执行顺序

1. **已完成只读、零 SU 核查**：九个运行的时间序列、Cd／残差、rank→node/允许 CPU mask、总界面与跨节点界面已整理在[审计记录](../progress/2026-10-25-aspire2a-scotch-abc-zero-su-audit.md)。第三轮明显变慢由离散的长 wall-clock 跳变推动，但原因尚未识别；B 的 Cd 科学可接受性仍待与官方参考轨迹核对。**没有提交新作业**。
2. 识别并控制波动来源后，才考虑同一构建、输入、4 节点资源与顺序平衡的 A/C 配对补跑；无需原样重复 A/B/C。
3. PGO 和绑核留作可选的 Scotch 扩展。现有 PGO 在 KaHIP、weighted Scotch 绑核仅单次探索；若要在 Basic 主线声称收益，必须在选定 Scotch 分区上做匹配对照。新权重比例等 A/C 差异可复现后再测。

来源：[OpenFOAM v2512 `scotchDecomp.H` 多层配置说明](https://api.openfoam.com/2512/scotchDecomp_8H_source.html)；[`mpiP` 40 步汇总](evidence/aspire2a-mpip-4n512-2026-09-23/mpip-call-type-summary.csv)、[`mpiP` 正确性限制](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md)、[4 节点分区分析](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md)、[A/B/C 核查](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md)、队友 [`metrics.csv`](../references/teammate/OpenFoam-HPCAI-26/results/metrics.csv)。
