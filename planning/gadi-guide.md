# Gadi：结果、分析与展示导航

[返回总入口](../PROJECT-INDEX.md) · 本页只收 Gadi 证据；ASPIRE2A 见 [独立导航](aspire2a-guide.md)。

## 先看结果

| 内容 | 位置 | 读法 |
| --- | --- | --- |
| **GCC 16.2 / Open MPI 5.0.10 / Scotch 运行登记** | [run-registry.md](../results/gadi-gcc162-ompi5010-scotch/run-registry.md) | 4 节点两次完成运行：1.991194389、1.988625920 s/step，均值 1.989910155；同栈 hierarchical `(16 13 2)` 单次 2.058549642 s/step。 |
| **新栈 1/2/4 节点 scaling** | [scaling-1n2n4n.md](../results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.md)、[CSV](../results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.csv) | 1N `182017873`：8.373520290；2N `182022356`：4.137720656；4N 两次均值 1.989910155 s/step。1N/2N 各一次，勿把 >100% 效率解释成已证实的超线性。 |
| **站点旧栈参考** | [official run registry](../results/official-gadi-spr/run-registry.md) | GCC 8.5 / Open MPI 4.1.7 / hierarchical 的 1/2/4 节点；旧站点参考，不是新栈 Scotch 的同条件分区基线。 |
| **1 节点绑核对照** | [binding-1n-40step.md](../results/gadi-gcc162-ompi5010-scotch/binding-1n-40step.md) | 单对差 0.324%；4 节点未验证。 |

Gadi 新栈的运行登记和 scaling 文档于 2026-10-23 从本机 `codex/gadi-gcc162-build` 工作树补入本仓库，保留原文中的 job ID 与远端 evidence 路径。此处是文档副本；若继续在另一工作树更新，需同步新结论，避免两个副本分叉。

2026-10-28 又原样归档了早期 [GCC16/Open MPI build 文件](../builds/build-scripts/gadi-gcc162-ompi5010/ARCHIVE-NOTES.md)
和 [legacy generic screening harness](../scripts/compiler-screening/README.md)。它们不是完整下游复现包或新的执行授权；
[XLSX provenance notes](../results/gadi-successful-4n-workbook-notes.md) 说明派生表中的 runtime 标签限制。

## Profiling 与技术分析

- [PMPI 全 4 节点 rank/partition 分析](../results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md)：区分调用次数、稳态计时与 rank 差异；PMPI 时间包括等待，不能直接解释为网络传输时间。
- [PMPI peer-counter smoke](../results/gadi-gcc162-ompi5010-scotch/pmpi-peer-v2-smoke.md)：方法验证，不是 65M scored result。
- CPU/HPCToolkit 采样结论与 job/evidence 路径收在 [新栈运行登记](../results/gadi-gcc162-ompi5010-scotch/run-registry.md#unscored-diagnostic-profile-attempt)。抽样 CPU share 不等于求解器 walltime share。

## 计划与 storyline

**建议展示顺序：** 固定 case/指标 → 旧站点栈参考 → 固定 hierarchical 比较新旧栈 → 新栈下 hierarchical 与 Scotch → 选定 GCC16/Scotch baseline → 1/2/4 节点 scaling → PMPI 调用量/等待与 CPU profile → 1 节点 binding → ICX 候选与证据限制。

- [ICX 2025.3.2 受控比较计划](gadi-icx20253-controlled-comparison.md)：含单次 4 节点 ICX 结果与重复试验状态。单次小差距不能称稳定胜出。
- [Gadi 4 节点 PMPI 结果](../results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md) 与 [展示资产保存边界](../artifacts/README.md)；[当前 Slides](https://docs.google.com/presentation/d/1jExT8S3abLLzKy8NGVq5GVzljCAmUZfq-c31OjsBnh0/edit)。本地生成的图形、tool dumps 和 deck 版本未在本次证据 commits 中批量收录。
- [早期 `experiment-index.md`](../results/experiment-index.md) 记录旧站点栈与 Phase 0 历史；其中将 ASPIRE2A 写成 blocked 的章节已过期，不能作为全项目实时状态。

**一句话主线：** 先在固定 hierarchical 下观察栈升级，再在同一新栈下选择 Scotch；以 GCC16/Scotch 的完整 scaling 为性能主线，用 profiling 指出下一步应检验的问题，不把等待时间自动归因为网络。
