# ASPIRE2A：结果、分析与展示导航

[返回总入口](../PROJECT-INDEX.md) · 本页只收 ASPIRE2A 证据；Gadi 见 [独立导航](gadi-guide.md)。

## 先看结果

| 内容 | 位置 | 读法 |
| --- | --- | --- |
| **Basic staging 的 1/2/4 节点运行** | [证据包说明](../submission/2026-apac-hpc-ai/openfoam/README.txt)、[scaling.csv](../submission/2026-apac-hpc-ai/openfoam/scaling/scaling.csv) | AOCC 5.0 + Open MPI 5.0.10，weighted Scotch；1/2/4 节点分别 13.3451、6.3961、2.9052 s/step，jobs `19730482`、`20030920`、`20072244`。每个节点数一条完成记录；来自 teammate/team，不自动归为本人运行。 |
| 原始 solver 日志与 Cd | [1 节点](../submission/2026-apac-hpc-ai/openfoam/results/1node/simpleFoam.log)、[2 节点](../submission/2026-apac-hpc-ai/openfoam/results/2node/simpleFoam.log)、[4 节点](../submission/2026-apac-hpc-ai/openfoam/results/4node/simpleFoam.log)；同目录 `coefficient.dat` | 图中数字应回到同一 job 的日志和 Cd 文件核验。 |
| 4 节点分区对照 | [2026-10-22 证据与 storyline 草稿 §5](2026-10-22-openfoam-evidence-storyline-draft.md#5-basic-decomposition-主对照) | hierarchical、plain Scotch、weighted Scotch；小差距保持“单次观测”表述。 |
| hierarchical XYZ 对照 | [同一草稿 §4](2026-10-22-openfoam-evidence-storyline-draft.md#4-hierarchical-内部-xyz-筛选)、[新 `(16 8 4)` 实验记录](../experiments/aspire2a-hier1684-opt-4n/README.md) | 旧草稿早于部分新结果；以实验记录的 job/evidence 为核查起点。 |

## 分析与限制

2026-10-28 本地整理：该包保存配置与测量，不单独证明最终投递或成绩。
最近状态取自 2026-10-26 handoff；本次未检查实时 scheduler。

| 问题 | 文档 |
| --- | --- |
| 4 节点 run 有效性与分区可比性 | [4n512 evidence QA](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md) |
| 编译栈与 flags | [compiler/codegen audit](analysis/aspire2a-compiler-codegen-audit-2026-09-17.md) |
| 早期 repeatability | [step2 repeatability](analysis/aspire2a-step2-repeatability-2026-09-24.md) |
| 提交证据核查 | [submission readiness](analysis/aspire2a-submission-readiness-2026-10-07.md) |

## Profiling 与后续实验

- [三分区 PMPI 实验与证据入口](../experiments/aspire2a-decomp-pmpi-3way/README.md)；[早期 mpiP 分析](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md) 与 [干净运行 v1](../results/aspire2a-step3-mpip-v1-25695102.md) 用途、采样范围不同，勿合并百分比。
- [Scotch A/B/C 实验设计](../experiments/aspire2a-scotch-abc/README.md) 与 [2026-10-25 三轮证据核查](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md)：三组 full blocks 均完成；计时波动大，B 的 Cd 低于参考带，不能把 weighted 的单次最快点当成稳定收益。[2026-10-22 进展](../progress/2026-10-22-aspire2a-scotch-abc-preflight-submitted.md)中的“排队”仅为历史状态。
- [Weighted Scotch PGO × binding 已执行设计](../experiments/aspire2a-scotch-pgo-binding/README.md)、[两 block / 八 arm 的 timing audit](../progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md)：均完成，但间歇性长 wall-clock steps 使比较方向反转，不能据此声称稳定 PGO 或 binding 收益。不能用去掉慢步后的 median 替代完整 official mean。
- [Site inquiry 草稿](../progress/2026-10-26-aspire2a-scotch-pgo-binding-site-inquiry-draft.md)尚未发送；stalls 的物理原因未确认。后续诊断或新实验均需另外授权。

## 计划与 storyline

- [ASPIRE2A 展示证据与后续计划](2026-10-22-openfoam-evidence-storyline-draft.md)：讲述顺序、已核验数值及 2026-10-25 A/B/C 更新；PGO 与绑核归入已做的探索，新的 Basic 工作优先处理 Scotch 重复计时和正确性。
- [较早的比赛 PPT 逐页方案](2026-apac-hpc-ai-presentation-plan.md) 与 [2026-10-08 结果整理](2026-10-08-openfoam-results-and-storyline.md)：历史设计参考。
- [OpenFOAM 展示资产及保存边界](../artifacts/README.md)；[演示文稿](https://docs.google.com/presentation/d/1jExT8S3abLLzKy8NGVq5GVzljCAmUZfq-c31OjsBnh0/edit)。部分图形/草稿仅在本地，不随本次 commits 归档。Slides 是展示产物；数值仍以日志和本页链接的记录为准。

**一句话主线：** 固定工作负载和 AOCC/Open MPI 构建 → 比较 hierarchical 与 Scotch → 选出 Basic 配置并展示 1/2/4 节点 → 用 PMPI 解释开销 → 把 flags、PGO、KaHIP、绑核放入独立探索。
