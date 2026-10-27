# 2026 APAC HPC-AI 演示文稿内容方案

状态：供团队核对的内容稿，2026-10-08。主讲顺序为 **OpenFOAM → Qwen → 共同结论**。本文件是讲稿和证据清单；幻灯片只显示标题、关键数字和必要图表，不放来源路径、制作说明或小字脚注。

## 1. 演示范围与时间

- 一套演示文稿覆盖两项任务。官方安排为 15–20 分钟陈述及 10 分钟问答。建议 OpenFOAM 约 8 分钟、Qwen 约 7 分钟、开场与收尾约 2 分钟。
- 主讲约 15 页；原始日志、脚本、字典、完整 benchmark sweep 和失败案例放提交包或备用页。主讲页不展示无法在投影屏幕上读清的密集表格。
- OpenFOAM 的正式 Basic 结果、Bonus 结果和诊断 profiling 分开标注；Qwen 的最终 Basic 脚本、Bonus sticky router 和已淘汰实验分开标注。
- 颜色沿用先前 NTU/HPC-AI 参考稿。正文优先白底、深蓝大标题。每页最多一条主结论与一张主要图，图中文字应足够大。

### 建议主讲页序

| 页 | 板块 | 标题 | 主要呈现 |
| ---: | --- | --- | --- |
| 1 | 开场 | 2026 APAC HPC-AI | 队名、学校 |
| 2 | 开场 | Outline | OpenFOAM、Qwen、结论 |
| 3 | OpenFOAM | Workload and Evaluation | 固定算例、计分指标、运行约束 |
| 4 | OpenFOAM | Optimization Search | 实验方向与筛选逻辑 |
| 5 | OpenFOAM | Compiler and Flags | 已测编译栈、`-march=znver3`、PGO 状态 |
| 6 | OpenFOAM | Decomposition | Hierarchical、Basic Scotch、Bonus KaHIP |
| 7 | OpenFOAM | Basic Scaling and Cd | 1/2/4 节点时间与 Cd |
| 8 | OpenFOAM | Profiling | 分区界面、MPI 调用与瓶颈解释 |
| 9 | OpenFOAM | OpenFOAM Takeaways | 最终 Basic、Bonus 和限制 |
| 10 | Qwen | Workload and Deployment | 模型、硬件、PD 与 SLA |
| 11 | Qwen | Routing Bottleneck and Fix | 0.5→13 req/s 的定位与双组方案 |
| 12 | Qwen | Tuning and Bottleneck | 性能阶梯、prefill 上限、负结果 |
| 13 | Qwen | Declared Basic Result | N=60 的正式指标与选点理由 |
| 14 | Qwen | Bonus and Reproducibility | Sticky router、提交脚本、待验证项 |
| 15 | 收尾 | Conclusions | 两项任务各一项结果与方法总结 |

## 2. OpenFOAM 逐页内容

### 第 3 页：Workload and Evaluation

**页上只放：** `OpenFOAM v2512`、`occDrivAerStaticMesh`、约 65M cells、`simpleFoam`；ASPIRE2A AMD EPYC 7713；“4 节点 Average wall-clock time per time step”。用一条简明流程表示 `decomposePar → restore0Dir → renumberMesh → potentialFoam → applyBoundaryLayer → simpleFoam`。

**讲述要点：** 科学工作负载固定，不改变 mesh、solver、`fvSchemes`、`fvSolution`。官方 1/2/4 节点分别要求 40/80/150 步，4 节点是计分点。运行链必须保留 `decomposePar -constant`、`restore0Dir -processor`、`renumberMesh -constant -overwrite -parallel`、`potentialFoam -initialiseUBCs -parallel`、`applyBoundaryLayer -ybl 0.0450244 -parallel`、`simpleFoam -parallel`。计分数字来自 solver 的平均每步 wall-clock 行，不能用 PBS 总 walltime 或 `ExecutionTime/150` 代替。

**提交包对应材料：** v2512 构建方式、1/2/4 节点 PBS 脚本、实际输入字典、各阶段日志、4 节点 solver log 与 `coefficient.dat`。幻灯片不塞完整命令和路径；评委应能在文本提交包中读到。

### 第 4 页：Optimization Search

**页上只放：** 四个方向及状态：编译器/MPI、flags、分区、rank/placement。可用四列短词表示“测量 → 比较 → 保留或淘汰”。

**讲述要点：** 团队并非只跑了 Scotch。现有证据包含 AOCC、GCC、ICX 构建与运行，GCC `znver3` 实验，Hierarchical/Scotch/weighted Scotch/KaHIP 分区，部分 rank 与绑定配置，及 mpiP 分析。讲述顺序应该先指出较大的分区差异，再说明较小的编译器、flag、绑定差异为何没有升级为最终收益主张。探索覆盖面放在这一页，细节留给后续结果页。

**边界：** 不把不同 MPI 的 ICX 与 AOCC 直接称作“纯编译器 A/B”；不把只运行一次、差距不足 1% 的实验称作稳定提升。`KaHIP` 属于 Bonus，不能代替 Basic 提交。

### 第 5 页：Compiler and Flags

**页上建议内容：**

| 项目 | 可展示的结论 |
| --- | --- |
| 最终 Basic 构建 | AOCC 5.0 + Open MPI 5.0.10，官方 v2512，stock `Opt`，`-O3` |
| GCC CPU 定向 flag | stock KaHIP 约 2.8805；`-O3 -march=znver3` 约 2.8827 s/step，单次结果未见收益 |
| PGO | 尝试过训练/构建流程，但未形成可核验的最终 4 节点 PGO 性能结果 |

**讲述要点：** 先说明 `-O3` 是已采用的优化等级，不应把它讲成后来独立发现的加速。GCC `znver3` 与 stock GCC 的差值约 0.074%，小于一次运行足以支持的结论；只表达“本次测量没有支持采用该 flag”。AOCC `OptZnver3` 没有完成比赛账户的可用构建，不能放进有效性能排名。AOCC、GCC、ICX 的代表运行可以放备用页；ICX 同时使用 Intel MPI，解释时保留这个混杂因素。没有实际比赛二进制的机器码检查，不能说已经证明某种 SIMD 指令出现或缺失。

**图的选择：** 若要图，只画 GCC stock 与 `znver3` 两点，并写清同为 4 节点 KaHIP；否则一张三行文字表比细小柱形差距更清楚。

### 第 6 页：Decomposition

**页上主图：** 4 节点、512 ranks、150 步平均时间：Hierarchical `(8 8 8)` **3.355476**、Basic Scotch **2.912440**、Bonus KaHIP `fast`, imbalance `0.01` **2.875901 s/step**。图例明确区分 Basic/Bonus。可在图侧写“Scotch 相对 Hierarchical：单次观测约快 13.2%；KaHIP 相对 Scotch：差约 1.3%”。

**讲述要点：** 这三个点使用同一 AOCC/Open MPI 栈与 4×128 ranks，前述三次运行没有显式的 bind 选项。分区改变 processor interfaces 和跨节点通信。已分析的拓扑数据中，KaHIP、Scotch、Hierarchical 的跨节点界面分别约 **213,435 / 337,324 / 2,048,418**；排序与运行时间、诊断 mpiP 总量方向一致。不要将拓扑关联写成独立证明的因果机制，也不要把 bound KaHIP 2.869257 与 unbound Scotch 2.912440 当作纯分区比较。

**正确性与统计边界：** 三者最后一步 Cd 约为 0.2800、0.2841、0.2984；Hierarchical 的 0.2984 高于官方约 0.28–0.29 的参考区间，不能将其写为“完全等价且通过严格容差”的基线。每种配置仅一次正式测量，约 1.3% 的 KaHIP 差距需要重复实验才可称稳健。KaHIP 是规则中的 Bonus 方法，Basic 仍为 Scotch。

### 第 7 页：Basic Scaling and Cd

**页上主图和小表：** Scotch 的正式 1/2/4 节点结果。只画平均每步时间；Cd、步数和 ranks 放三行表。

| 节点 | MPI ranks | 步数 | 平均 wall-clock / step | 最后一步 Cd | Job ID |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 128 | 40 | **13.352080 s** | **0.435988** | `19730481` |
| 2 | 256 | 80 | **6.378504 s** | **0.327139** | `20047559` |
| 4 | 512 | 150 | **2.912440 s** | **0.284051** | `20064271` |

**讲述要点：** 由官方指标计算的观测 speedup 为 2 节点 **2.0933×**、4 节点 **4.5845×**。这些超过理想线性值的数字只能称为现有运行的观测值，不能在单次运行和不同步数下宣称已经证明超线性扩展。三个原始 solver log 正常结束、达到要求终止步数；相应 `coefficient.dat` 含 40/80/150 行。2 节点 Cd 0.3271 低于规则中的约 0.34 参考，规则没有给 Basic 硬性百分比阈值，应完整披露而非标绿色“严格通过”。

**可选图：** 若取到本届原始 coefficient files，可画本届 Cd 轨迹。不要使用 seniors 的 2000 步流场图片代替本届数据。

### 第 8 页：Profiling

**页上只放：** 一张“分区 → 跨节点界面 → MPI 等待/collective”的证据图。建议突出 `MPI_Allreduce` 与 `MPI_Waitall`，不要塞完整 512-rank 分布表。

**讲述要点：** 已归档的 4 节点诊断 mpiP 报告显示，这两类调用是 MPI 总时间的主要贡献；KaHIP/Scotch/Hierarchical 的重构聚合 MPI 时间约 **18,836 / 22,499 / 28,901 rank-seconds**，需明确这是跨 rank 累加的诊断量，不是 4 节点 solver walltime。另一轮 2026-10-07 的清洁 mpiP v2 完成了 40 步 A0/P0/A1，对应新鲜系数文件相同，控制组时间相差约 0.335%；profile 估算开销约 10.1%。诊断结果不能替换 150 步正式成绩。旧 profiling 目录中继承的 150 步 Cd 曾被误认作 40 步输出，不得拿它证明旧 profile 的 40 步正确性。

**结论的力度：** “通信和同步值得继续优化”有证据；“某一项 MPI 调参已带来稳定加速”目前没有证据。

### 第 9 页：OpenFOAM Takeaways

**页上三行：**

1. **Basic:** AOCC/Open MPI/Scotch，4 节点 **2.912 s/step**，有 1/2/4 节点结果。
2. **Bonus:** KaHIP `fast/0.01`，4 节点 **2.876 s/step**，与同样未显式绑定的 Scotch 单次差约 1.3%。
3. **理解与限制:** 分区拓扑与 MPI 时间方向一致；小幅收益仍受单次运行和机器噪声限制。

**口头补充：** 结果以原始 solver log 和 `coefficient.dat` 为准。提交包还须完成源/构建身份、实际字典与日志的归档核对；这一项不能靠幻灯片代替。

## 3. Qwen 逐页内容：将队友的 21 页压缩为 5 页

来源为队友当前的 `/Users/sofia/Downloads/HPCAI.pdf`。这是一份现有演示稿；下列数字按 PDF 记录整理，**尚未独立核验队友的原始 `results/metrics.csv` 和 AIPerf JSON**。待她确认最终稿和提交脚本是否仍为这些版本。

### 第 10 页：Workload and Deployment

**页上只放：** 官方 `Qwen3-235B-A22B-Instruct-2507-FP8`，Firmus 2×HGX H200 / 16 GPUs，PD 分离，4000 输入 + 200 输出 token；SLA `TTFT ≤ 3000 ms`、平均 `ITL ≤ 20 ms`、`good_request_fraction ≥ 0.90`。

**讲述要点：** 队友 PDF 声明采用 SGLang 0.5.17、sglang-router 0.3.2、NIXL 1.3.2、AIPerf 0.12.0。官方 benchmark 从单一 gateway 的 `/v1/chat/completions` 进入，closed-loop，60/120/30 秒且使用固定 seed。可用一个大架构图展示 AIPerf → gateway → 两个独立 PD group；每组一个 TP=4 prefill 和一个 TP=4 decode，用完 16 GPU。具体软件版本与拓扑在交稿前请 Qwen 负责人再确认。

### 第 11 页：Routing Bottleneck and Fix

**页上主图：** 左侧旧结构“一个 PD router、4 prefill + 2 decode”，右侧新结构“一个 gateway、两个独立的 1 prefill + 1 decode group”。主数字 **0.5 → 13 requests/s，约 26×**。

**讲述要点：** 旧结构的一个 router 让多个 prefill/decode 组合配对，只有一条配对完成 bootstrap，其他请求停在队列直至超时；decode 侧没有拿到工作。先前短 benchmark 窗口只统计已经完成的请求，会把故障部署的好请求比例看得过高。队友用一个 8-GPU、1:1 的诊断运行排除模型和单个节点故障，再通过两个隔离 group 修复配对。8-GPU 运行仅为诊断，不是正式提交配置。

**重要修正：** 队友后来证明“必须严格 1:1”说得过宽；真正与卡住现象对应的是 **每个 PD router 只拥有一个 decode**。两个 prefill + 一个 decode 可以运行，但进一步测试的 TP=2 prefill 方案性能较差。正文只讲最终可支持的机制，不重复旧的过宽断言。

### 第 12 页：Tuning and Bottleneck

**页上主图：** 从首个通过门槛的 **68.0** 到最终样本 **2,668.7 good output tok/s**，约 **39×**。旁边一句：较大一段来自 routing 修复，其后是并发和配置调优。**不要把 0.5→13 req/s 与 68→2,668.7 tok/s 画成同一种指标。**

**讲述要点：** 队友分析认为最终配置主要受 prefill 约束：两个 TP=4 prefill worker 各约 26,500 input tok/s，总计约 13.3 req/s 的容量，与最终约 13.5 req/s 接近；decode 还有容量。更大的 chunk size 增加 TTFT 并使分数下降；FP8 KV、FlashInfer decode attention、DeepGEMM、CUDA graph 列表、KV page size 等尝试中，没有一项满足队友预设的 **超过 N=60 中位数 2%** 的晋级标准。正式脚本保留 BF16 KV、FA3 attention、默认 page size。完整负结果表放附录。

### 第 13 页：Declared Basic Result

**页上醒目数字：** `N=60`；**2,660 good output tok/s**（四次正式时长运行的中位数，四舍五入）；**good_request_fraction = 0.984**；TTFT p50 **837 ms**；平均 ITL **17.6 ms**。

**讲述要点：** 四次 N=60 官方时长样本为 2,657.7 / 2,659.8 / 2,659.9 / 2,668.7 good tok/s，fraction 均为 0.984，吞吐跨度约 0.4%。封装提交脚本无环境覆盖的 job 19927 为 2,659.8，支持复现。N=64 的最高单次样本更高（2,740.1），但四次波动大，fraction 为 0.926–0.983；队友因预先设定“全部样本超过 0.95”的选点规则，选择更稳的 N=60。**0.926 本身仍高于官方 0.90 门槛**，不可写成该次官方门槛失败。TTFT p99 3,726 ms 高于 3,000 ms，并不与整体 fraction 0.984 矛盾：gate 按单个请求判断，少数尾部请求可以失败。

### 第 14 页：Bonus and Reproducibility

**页上左右两栏：** 左侧 Bonus sticky PD router，`N=64`，三个官方时长样本中位数 **2,763.2 good tok/s**、fraction **0.982**；右侧 Basic 重跑材料 `build/setup.sh`、`run/submit.sbatch` 和 packaged no-override job 19927。

**讲述要点：** Sticky router 是队友自写组件，按请求固定 Prefill/Decode 配对；此 Bonus 未进入 Basic 重跑脚本。与 Basic N=60 的 2,660 相比约高 3.9%，但两点的并发数也不同，不能把 3.9% 全归因于路由算法。Bonus 需要证明变更、同等计算、准确性和相对自身 Basic 的收益；队友 PDF 表示 organiser accuracy check 尚未到手。Basic 仍使用官方 FP8 模型、BF16 KV、无 draft model，提交脚本部署后运行未修改的官方 AIPerf 命令。EAGLE3、vLLM、TensorRT-LLM 等分支保留在备用页，不抢主线时间。

## 4. 收尾、备用页与待核对项

### 第 15 页：Conclusions

两栏即可：OpenFOAM 写 Basic Scotch **2.912 s/step** 和“分区/通信是主要研究方向”；Qwen 写 Basic **2,660 good tok/s、fraction 0.984** 和“PD 配对修复 + 稳健并发选点”。口头指出两项任务都保留 Basic 作为 organiser 重跑对象，Bonus 单独呈现。

### 备用页

- OpenFOAM：完整 4 节点配置比较、GCC/ICX/AOCC 表、flags 负结果、Cd 随时间曲线、mpiP 分类、Job IDs、完整 Allrun 与字典核对状态。
- Qwen：完整并发 sweep、正式四次 N=60 样本、N=64 的内部 0.95 标准与官方 0.90 标准、routing 反例修正、负结果表、Bonus 证据及完整部署脚本。
- Seniors 的车身压力与速度切面是旧算例的 ParaView 后处理图。本届没有这项强制要求；只有取得本届场数据并能标清来源时，才考虑加入新的流场图。旧图不能标为本届结果。

### 交稿前需要团队确认

1. Qwen 负责人确认 PDF 中的 Basic 脚本、N=60、四次结果、软件版本及 Bonus 状态仍是最终版本，并提供 `metrics.csv` / AIPerf JSON 核对。
2. OpenFOAM 原始 1/2/4 solver log、`coefficient.dat`、实际 case 字典和构建脚本进入提交包；2 节点 Cd 的偏离按原始证据如实呈现。
3. 所有图中的单位和比较条件写清：`s/step`、`requests/s`、`good output tok/s` 不混用；Basic/Bonus 不混用；profiled 与正式运行不混用。
4. 幻灯片不放路径、哈希、脚注、密集版本表。此类证据保留在文本提交包和本文件中，演示时可口头回答。

## 5. 依据

- [2026 OpenFOAM HPC Task Rules](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md)
- [2026 Qwen3 AI Task Rules](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/1.%20Qwen3%20AI%20Task%20Rules.md)
- [2026 README Addendum](https://github.com/hpcac/2026-APAC-HPC-AI)
- `planning/analysis/aspire2a-submission-readiness-2026-10-07.md`
- `planning/analysis/aspire2a-4n512-evidence-qa-2026-09-18.md`
- `planning/analysis/aspire2a-compiler-codegen-audit-2026-09-17.md`
- `planning/analysis/aspire2a-step1-mpip-evidence-2026-09-23.md`
- 队友提供的 `/Users/sofia/Downloads/HPCAI.pdf`（21 页演示稿，Qwen 数字目前以该稿为来源）。
