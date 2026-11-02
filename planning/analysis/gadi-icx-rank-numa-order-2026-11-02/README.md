# Analysis: ICX Scotch rank-to-NUMA ordering

## 1. Concise summary

2026-11-02，Asia/Singapore。本次只做本地分析，消耗 **0 SU**，没有连接集群、安装运行脚本或提交 PBS。

用户确认按“rank 排列／NUMA 局部性 → 有依据的 MPI collective 参数 → 编译 flags”推进。当前只落实第一项。最新 collective 配对没有观察到禁用 HCOLL 加速，且因 Cd 轨迹一致性门槛未通过；不改变它的失败记录，也不将 no-HCOLL 作为新默认。

已有 Scotch 排列的局部性并不差。在保留每个 rank 的节点和 socket、每个 NUMA 域13 ranks、每个 socket 的最大 NUMA 单元负载不增加的约束下，找到只移动21个 rank 的候选：节点内部跨 NUMA 接口面减少 **2.2368%**。这是几何指标改善，**不是实测时间改善或网络字节减少**。

## 2. Scope and evaluation criteria

- 工具链目标：ICX2025.3.2、私有 Open MPI5.0.10、OpenFOAM v2512，Scotch，固定65,334,765单元输入；不变更 MPI、collective、物理设置或分区。
- 原始图：[182830268 default/10_decomposePar.log](../../evidence/gadi-pbs-script-snapshot/logs/182830268.gadi-pbs/default/10_decomposePar.log)。逐边核对 GCC PMPI181908113 的派生邻接表，2307条无向边完全相同；每条边双向面数、每 rank 接口面合计也一致。
- 核心／NUMA模板：P0 182588070 的104份 core 收据与 Linux topology.csv；独立以182637290的四节点 Open MPI placement.bindings.txt确认 `rank % 104` 对应逻辑核心编号。均核对本地归档 SHA256。
- **历史模板不是新节点实测。** 新分配必须重新验证拓扑、hwloc逻辑核心编号、MPI_Init前后CPU mask，不使用假定 Linux CPU编号直接写rankfile。
- 正式对照若获批，两臂都明确 core-bound。采用 core binding 是为了固定放置条件，不代表它已经比默认绑定快；不拿历史默认绑定时间直接当新对照。
- 每个 rank 留在原节点和 socket，只改变 socket 内4个NUMA域之间的排列；总接口面、跨节点接口面、跨socket接口面保持不变。无 NUMA内存策略改变。

## 3. Data and analysis

| 指标（接口面去重） | 历史模板上的对照 | 候选 |
|---|---:|---:|
| 全部 processor faces | 2,690,403 | 2,690,403 |
| 跨节点 faces | 300,065 | 300,065 |
| 节点内部跨 socket faces | 164,284 | 164,284 |
| 同 socket 内跨 NUMA faces | 552,095 | 536,071（−2.9024%） |
| 节点内部全部跨 NUMA faces | 716,379 | 700,355（−2.2368%） |
| 每 NUMA ranks | 13 | 13 |
| 最大 NUMA 单元数 | 2,054,052 | 2,054,052 |
| NUMA 单元数 CV | 0.32465% | 0.32090% |

仅21个 rank 改变核心与NUMA域：4个节点块分别移动3、6、10、2个。其他395个 rank 保留原核心槽位。每节点104个核心槽位一一对应，每socket52 ranks。

算法：固定起点的确定性最佳交换下降，再做最多6轮交换序列的前缀搜索；只有净减少接口面的前缀才提交。每一步维持13-rank容量及原socket最大NUMA单元负载上限。没有使用性能时间挑选候选，没有随机多起点或全局最优保证。交换轨迹完整保留在[swaps.json](swaps.json)。

复算：[analyze.py](analyze.py)；结果：[summary.json](summary.json)；映射分析表：[candidate-analysis-only.csv](candidate-analysis-only.csv)；单元负载：[numa-loads.csv](numa-loads.csv)。CSV是分析表，不是可执行rankfile，不应直接上传运行。

本地验证：脚本重跑输出完全一致；独立从CSV与边表重新计数得到相同跨NUMA面数；图、双向邻接、容量、socket归属、最大负载约束均通过。

## 4. Insights gained

收益空间在这项保守候选中较小，不能从减少2.24%接口面推导提升2.24%速度。它只改变16,024个接口面的NUMA类别，占全部接口面约0.60%；实际时间还受消息次数／大小、缓存、共享内存协议、内存页分布、负载与同步影响。

现有 Waitall 相关性支持检验放置假设，但不是因果证据。本分析不测量 MPI等待、内存带宽或页驻留。即使效果为零，也不能排除更大范围的socket／跨节点排列；它们应作为独立后续变量，不能混入本次。

182830268 的2199份小文件尚未完成本地归档。这里使用的分解日志、host map均已完整SHA验证；本候选不依赖缺失收据来声称当前求解器实际核心或内存位置。

## 5. Suggested next section

先申请一次 **单节点104核、10分钟上限、34.67 SU** 的MPI-only预检，资源16GB RAM/20GB JOBFS，不运行OpenFOAM、不读写大网格。

同一个节点依次测试：现有核心绑定映射、等价rankfile控制、4个节点块各自的候选排列。共6次104-rank短启动，每次45秒超时；所有通信保持原默认策略，记录 MPI_Init 前后 CPU mask、rank/host、Allreduce sum=5356、环形Sendrecv正确性和探针实际UCP路径／版本。

候选rankfile从本次分配的baseline `--report-bindings` 逻辑核心编号生成。要求控制rankfile与baseline完全一致、104独立物理核心、13 ranks/NUMA、每个候选socket不变，实际变更rank数分别为3/6/10/2；任何不符停止，不做overload回退或自动重试。

预检只能证明启动、映射和小通信正确；不能证明四节点性能、实际求解器内存位置或所有节点一致。通过后再决定是否值得一组四节点150步的无插桩配对：当前模型信号不大，不能自动升级。正式配对资源可参考已成功流程416CPU/760GB/400GBJOBFS/1小时，上限832SU，历史实际约465–500SU（不是承诺）。四节点执行前仍要核对每个节点拓扑和图身份。

[完整预检 diff 与审批范围](../../reviews/gadi-icx-rank-numa-preflight-2026-11-02/README.md)。当前没有远端访问、同步或提交授权动作发生。

## 6. Provenance

输入逐文件路径与SHA：[input-provenance.json](input-provenance.json)。原始SHA核验适用于日志与P0收据；GCC边表是派生交叉核对，不代替ICX原始分解日志。现有结果：[collective结果记录](../../../results/gadi-icx20253-collective-policy/README.md)、[四节点binding结果](../../../results/gadi-icx20253-binding-numa/four-node-v2-182637290.md)。

实现语法参考：[Open MPI5.0.10 mpirun rankfile文档](https://docs.open-mpi.org/en/v5.0.10/man-openmpi/man1/mpirun.1.html)。rankfile使用逻辑核心索引；文档不能代替本站版本实测。
