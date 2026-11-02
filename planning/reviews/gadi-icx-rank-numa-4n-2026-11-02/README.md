# ICX Scotch rank/NUMA four-node paired screening — review only

用户已同意进入四节点；本文件首次展示具体差异，尚未安装运行脚本、同步或提交。AGENTS要求具体diff审批。本次提议**一个PBS作业，两个150步完整链**，不是两次独立排队作业。

## Experiment and isolated variable

- 同一4个Gadi normalsr Sapphire Rapids8470Q节点，104ranks/node，共416；ICX2025.3.2、私有OpenMPI5.0.10、OpenFOAMv2512、固定65,334,765单元、Scotch、原科学设置和二进制SHA。
- 顺序：control原排列 → candidate候选排列。两臂均`--bind-to core`、用rankfile明确全部416rank位置；每rank节点/socket不变，每NUMA13rank，仅21rank核心改变。两臂都不强制UCX预加载、不排除HCOLL、不改collective算法或NUMA内存策略。
- 新分配先测每节点CPU拓扑与OpenMPI逻辑core编号，禁止将历史LinuxCPU编号当rankfile索引。匹配单节点已验证的3/6/10/2变化。
- 仅比较同一分配内control/candidate秒步比值；不拿旧默认绑定时间充当配对control。单次顺序配对有顺序效应，不能宣称稳定获益或因果性，也不自动追加反向重复。

## Full local diff and files

[完整520行diff](proposed-scripts.patch)新增5文件，均只存在于审阅patch：

| Proposed file | Role |
|---|---|
|run_rank_numa_pair_4n_v1.pbs|同一分配顺序启动两臂、JOBFS余量/时间门槛、配对验收|
|run_rank_numa_arm_4n_v1.sh|基于成功binding4n v2完整链，改为control/candidate rankfile|
|rank_numa_4n.py|416rank实测拓扑→rankfile；放置、MPI收据验收|
|rank_numa_probe_4n.c|沿用已通过预检，仅world size104→416、sum5356→86320；独立预求解探针|
|jobfs_receipt_4n.sh|每节点写非空配额余量收据，避免旧bash-c收据歧义|

复用已固定SHA的candidate-map-v1.csv、runtime/processor staging helpers。新增源码只编译小MPI探针，**不重编OpenFOAM**。探针在求解计时外运行；solver不加载采样器/PMPI。

关键启动差异：
```diff
- mpirun --map-by ppr:104:node [default/core binding] --mca pml ucx -np416 ...
+ mpirun --map-by rankfile:file=control.rankfile --bind-to core --mca pml ucx -np416 ...
+ mpirun --map-by rankfile:file=candidate.rankfile --bind-to core --mca pml ucx -np416 ...
```

每臂含单独416rank MPI_Init前后affinity/Allreduce/ring/UCP探针及collective verbose日志；它能说明探针选择，不能直接证明simpleFoam每次collective选择。求解前exec收据也不证明求解过程内存页位置。

## Budget and storage

申请416CPU/760GBRAM/400GBJOBFS/1h，**832SU上限**。已有同规模binding/collective配对实际464.76/469.16SU；本次规划约465–500SU，额外检查及机器波动可能增加，以PBS回执为准。任一臂失败停止，剩余不足25min不启动第二臂。

2026-11-02只读nci_account/lquota：6.05KSU可用；scratch661.74GiB/1TiB，179761/202000inode。

原始网格五个文件合计7,455,806,605字节（约6.94GiB），保留原有唯一主副本；每臂只在JOBFS产生独立可写case，共享case的constant链接回主副本，前后验SHA。无新永久原始网格副本。根据旧182637290的8个processor tar的stat，两臂归档共17,978,613,760字节（约16.74GiB）；它们是实验分区，不是原始网格备份。规划新增scratch<=25GiB、<=6000inode（约3328rank收据、832processor链接、其他日志/字典等）；为估计非硬保证，提交前重查quota。JOBFS100GiB/node，两臂独立目录保留到作业结束，下一臂前需至少50GiB余量；不删除历史证据。

## Evidence and acceptance

1. PBSExit0、两臂及pair PASS、四SPR主机各104rank；脚本/源码/归档/simpleFoam SHA一致。
2. control和candidate的基准映射、节点/socket归属、可用CPU及内存允许范围可对照；每节点104独立物理核心、每NUMA13rank；候选只改3/6/10/2rank位置。
3. 416rank独立MPI探针sum86320/ring与前后mask正确；记录UCP真实路径/版本、链接和collective日志；两臂实际UCP需相同。
4. decomposePar的归一化分区几何SHA必须匹配候选设计原图182830268：6c3d197ff7f601a68ed937fe736b99f9e2c280392cd802a3895a250b46c724b5。两臂分区及输入hash相同。科学输入和solver源码不变。
5. 完整decompose/renumberMesh/potentialFoam/applyBoundaryLayer日志End；simpleFoam Time1..150/End/正常finalisation；有限正coded平均秒步，完整Cd轨迹。保留现有诊断Cd0.27–0.30及配对max绝对差<=1e-8；这些**不是官方硬阈值**。超出时保留全部结果并人工检查，不自动放宽、不把结果提升为赢家。
6. 归档原始PBS stdout、run.log、solver及准备日志、Cd、rankfile、拓扑和MPI/affinity收据、SHA与实际SU；job-keyed local logs及results/progress。若异常保留首错，不自动重投。

新stdout：/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_rank_numa_pair_4n_v1.pbs.out
新根：/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-pair-4n-v1/<job>/

## Validation and remaining uncertainty

Shell bash-n、Python及3个嵌入Python AST通过；合成416rank四主机测试通过rankfile生成、control映射、21rank变换和MPI收据校验，错误host/初始化后CPU变动反例被拒绝；源/归档/binary SHA及科学命令与成功脚本一致。四节点探针C未编译/远端未运行，其仅规模和sum更改，实际四节点兼容性由作业内预检验收。所有模拟测试不是集群性能证据。

下一步请求确认这份具体diff和预算，才安装运行文件、提交同步并只qsub一次。监控可跟进这一次作业，失败不自动追加作业。

## Approval received

2026-11-02 user approved this specific diff, one four-node control/candidate pair, isolated GitHub/Gadi sync, archival and five-minute monitoring. Five runtime files installed exactly matching reviewed SHA256. No automatic retry or additional four-node job.
