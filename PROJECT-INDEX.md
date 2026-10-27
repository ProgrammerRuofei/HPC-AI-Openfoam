# OpenFOAM 记录导航

**先选集群，再找证据。** 本页是导航，不替代原始日志或运行登记。整理于 2026-10-28；最近实验状态来自本地 2026-10-26 记录，本次没有连接集群。

| 集群 | 快速入口 | 当前可查的主结果 |
| --- | --- | --- |
| [ASPIRE2A](planning/aspire2a-guide.md) | Basic 证据包、分区分析、PMPI、A/B/C、PGO × binding、展示主线 | weighted Scotch 的 1/2/4 节点留存证据；后续对照受 timing stalls 影响，尚不能稳定排名 |
| [Gadi](planning/gadi-guide.md) | 新旧栈、Scotch 对照、scaling、profile、ICX、展示主线 | GCC 16.2/Open MPI 5.0.10 + Scotch 的 1/2/4 节点与 4 节点重复 |

## 按问题找

| 想找什么 | 入口 |
| --- | --- |
| 留存的原始日志、Cd、输入 | [ASPIRE2A Basic staging 包](submission/2026-apac-hpc-ai/openfoam/README.txt)；Gadi 见 [运行登记及远端证据路径](results/gadi-gcc162-ompi5010-scotch/run-registry.md) |
| 1/2/4 节点结果 | [ASPIRE2A scaling.csv](submission/2026-apac-hpc-ai/openfoam/scaling/scaling.csv)；[Gadi scaling 记录](results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.md) |
| 分区与性能分析 | [ASPIRE2A 展示证据草稿](planning/2026-10-22-openfoam-evidence-storyline-draft.md)；[Gadi 同栈运行登记](results/gadi-gcc162-ompi5010-scotch/run-registry.md) |
| MPI / CPU profiling | [ASPIRE2A 三分区 PMPI 分析入口](planning/aspire2a-guide.md#profiling-与后续实验)；[Gadi PMPI rank 分析](results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md) |
| 计划与 slide storyline | [ASPIRE2A 导航](planning/aspire2a-guide.md#计划与-storyline)；[Gadi 导航](planning/gadi-guide.md#计划与-storyline) |
| 按日期追溯做了什么 | [progress/](progress/README.md)；旧实验总索引见 [experiment-index.md](results/experiment-index.md) |
| 当前性能结论为什么要保留限制 | [Scotch A/B/C 核查](progress/2026-10-25-aspire2a-scotch-abc-evidence.md)、[PGO × binding stall audit](progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md) |
| 本次整理范围、未纳入的本地文件 | [仓库整理记录](progress/2026-10-28-repository-review-and-organization.md)、[evidence 保存规则](planning/evidence/README.md)、[参考材料边界](references/README.md) |
| 剩余 119 文件哪些归档、ignore 或保留本地 | [分类决定](planning/2026-10-28-untracked-file-classification.md)、[逐文件大小/SHA256/原因](planning/repository-audit/2026-10-28-untracked-files.csv)、[本轮交接](progress/2026-10-28-untracked-file-classification.md) |

## 读数规则

- **不要跨集群排性能名次。** ASPIRE2A 与 Gadi 的 CPU、rank/node、构建和运行环境不同。
- 计时图优先引用 `simpleFoam` 的 **Average wall-clock time per time step**；Cd 需要同时看对应步数和轨迹，不能把不同步数的最后一行当成收敛值。
- `results/experiment-index.md`、根目录 README 的详细旧叙述及 `planning/PLANS.md` 保留历史原貌；其中“ASPIRE2A blocked”“Gadi 旧站点栈是当前 baseline”等状态已过期。查近期结果请从本页进入各集群记录。
- staging 包存在不等于已正式上传或获评。本地较早的 staging checklist 与后续“submitted”表述不完全一致，最终投递和成绩仍需独立凭据确认。
- 本次只整理本地文档、归档与 Git commits；没有提交作业或连接集群，原始日志和脚本路径保持不变。
