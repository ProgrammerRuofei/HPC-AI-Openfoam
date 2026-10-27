# OpenFOAM 展示故事线与后续实验计划

更新：2026-10-22。本文用于重排演示文稿；所有时间为 `simpleFoam` 日志中的平均每步 wall-clock 秒数，越低越好。新 `(16 8 4)` stock Opt 结果尚未取得，相关单元格故意留空。

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
| `(16 8 4)` | **新 stock Opt 对照，job 25906053** | **待结果** | **待结果** | 与 `(32 16 1)` 匹配；旧 PgoUse 数字不代填 |
| `(32 16 1)` | stock Opt，无 profiler；job 25826705 | 3.0640 | 0.290022 | 目前可验证的较快 hierarchical 候选 |

历史 `(16 8 4)` PgoUse 为 3.1909、Cd 0.273561；历史 `(32 16 1)` PgoUse 为 3.0079。两者不能直接进入上述 stock Opt 排名。等新 `(16 8 4)` 结果出来，再确定三 XYZ 的最终排名；当前图可给它留空。

**建议画面**：三点横向 dot plot；新 `(16 8 4)` 用空心点和 “pending” 标签，图注写明 `(8 8 8)` 的二进制 provenance 限制。不画未测数字。

## 5. Basic decomposition 主对照

在上述 AOCC/Open MPI stock Opt、4 节点 512 ranks、150 步、无显式绑核条件下：

| 分区 | s/step | Cd(150) | Job | 备注 |
|---|---:|---:|---|---|
| hierarchical `(32 16 1)` | 3.0640 | 0.290022 | 25826705 | 同构建新对照 |
| plain Scotch | 2.9124 | 0.284051 | 20064271 | Basic |
| weighted Scotch | **2.9052** | 0.288551 | 20072244 | Basic 提交配置；`domains (4 8 16)`，`domainWeights (1 1 0.01)` |

Weighted 比 `(32 16 1)` 低约 5.18%；比 plain Scotch 低约 0.25%。后一差异来自单次运行，且 plain 与 weighted 的 `domains` 和 `domainWeights` 均有变化，**不能声称权重单独带来了稳定收益**。称“当前观察到的最快 Basic 配置”即可。`(16 8 4)` 完成后需检查它是否改变 hierarchical 参照。

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

需在讲稿或备份页明确：`(16 8 4)` 新结果仍待完成；`(8 8 8)` 缺 at-run binary hash 且 Cd 轨迹需复核；plain/weighted、编译栈和 PGO 细小差异尚无重复运行；PMPI 是一致的机制证据而非因果证明。

## 10. Next step：把 0.25% 的差异变成可检验结论

1. 首先在相同条件下交错重复 plain 和当前 weighted Scotch（同 build、输入、4 节点、512 ranks、150 步、launcher），记录 rank→node/core 映射与运行波动。
2. 分离当前混在一起的两个因素：A 为 plain Scotch；B 固定 `domains (4 8 16)` 且采用均匀权重（先确认 OpenFOAM 字典语义）；C 为同一 domains 加当前 `domainWeights (1 1 0.01)`。每次只变一个因素。
3. 若 C 的收益超过波动，再基于明确的拓扑假设选 1–2 个权重比；每次只改 `domainWeights`，同时看总 cut、跨节点 cut（标注估算假设）、最差 rank 界面、负载均衡、150 步时间以及 Cd/残差。
4. 仅在性能增益可重复、并且正确性一致时，把“当前最快”升级为“稳定改进”；否则保留 plain 与 weighted 性能接近的结论。

这组新实验是**后续计划**，不是当前已完成或已获授权的作业。

## 幻灯片建议顺序

1. Cover；2. Team；3. OpenFOAM section；4. Workload & evaluation；5. Strategy and controls；6. Stack survey；7. Hierarchical XYZ；8. Basic decomposition；9. Selected Basic configuration；10. Basic scaling and Cd；11. PMPI method；12. Three-way MPI share；13. Bonus KaHIP；14. Architecture flag；15. PGO；16. Rank binding；17. Final results；18. Evidence limits；19. Next step；20. Thank you。

每页只讲一个问题。Slides 内为英文短句、原生可编辑图表和表格；本文保留中文解释与证据限制。
