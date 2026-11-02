# Proposed rank/NUMA placement preflight — approved for one preflight

2026-11-02。本地审阅提案，不是已安装或运行脚本。

[完整diff](proposed-scripts.patch)拟新增 `experiments/gadi-icx20253-rank-numa/` 下4个文件：

- `preflight_rank_numa_1n_v1.pbs`：104CPU、16GB、20GBJOBFS、10分钟，pm78/normalsr，**34.67SU申请上限**；预检短于申请时间时按实际收费。沿用已验证GCC runtime/OpenMPI归档和ICX2025.3.2模块。无OpenFOAM构建、分解或求解。
- `rank_numa_probe.c`：仅编译小MPI探针，采集MPI_Init前后CPU mask、104-rank Allreduce及ring Sendrecv、实际UCP路径/版本。私有MPI链接核验。探针不是求解器。
- `rank_numa_preflight.py`：验证拓扑与104唯一核心；从本次baseline绑定输出提取hwloc逻辑核心编号；生成等价控制rankfile及四个节点块候选rankfile；核验实际mask及socket/NUMA关系。不会硬编码历史Linux CPU号。
- `candidate-map-v1.csv`：审阅后固定哈希的映射数据，源自[0SU分析](../../analysis/gadi-icx-rank-numa-order-2026-11-02/README.md)。21个rank更换核心/NUMA，395个保持原槽位；节点/socket归属不变。

启动差异：

```diff
- mpirun --map-by ppr:104:node --bind-to core ... placement_probe
+ mpirun --map-by rankfile:file=control.rankfile --bind-to core ... placement_probe
+ mpirun --map-by rankfile:file=candidate-nodeN.rankfile --bind-to core ... placement_probe
```

baseline、control、四个candidate均104ranks、同一节点、同一核心集合。每次45秒有界超时，失败中断后续启动；无overload/oversubscribe回退。每NUMA13rank；目标changed masks分别3/6/10/2。`MPI_Init`前后mask必须一致。探针全局sum5356与逐rank环形收发必须通过。

新唯一stdout：
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_rank_numa_1n_v1.pbs.out`

新job-keyed evidence：
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/<job>/evidence/`

不复制原始大网格。预计新增scratch证据小于20MiB、少于800inodes；这里只是规划值，提交前只读核对实际配额、路径与连接。GCC/MPI解包位于20GB JOBFS，沿用已通过的P0资源配置。保留源码、rankfile、拓扑、624份收据、完整stdout、PBS/SU和SHA；可生成已批准作业内的压缩证据归档方案另行审阅，当前diff未包含压缩。

验收：PBSExit0＋完整PASS＋所有rank正确/不共享核心＋预期映射生效＋probe私有MPI/UCP证据。无网格/Cd/性能得分；无跨节点通信覆盖。MPI_Init hang、拓扑不符或rankfile不支持都保存证据并停止，不自动新作业重试。

本地验证：[validation.txt](validation.txt)，包括bash语法、Python AST、合成104-rank正例、错误mask/重复核心反例、离线结果重算。C未编译、Open MPI rankfile未远端验证，明确由预检解决。

## Approval requested

请批准只执行这一次预检，包括按已展示diff制作文件、仅提交相关文件到隔离分支、推送 `git@github.com:ProgrammerRuofei/HPC-AI-Openfoam.git` 的 `codex/gadi-gcc162-build` 及既有Gadi transport、ff-only/SHA核对、一次qsub、只读状态检查、SCP取回并归档原始证据（含内部路径）与结果记录。保留main、其他未提交修改、原始日志；监视器保持关闭。

**不包含四节点求解、NUMA内存策略变更、MPI算法变更、重新构建OpenFOAM或额外重试。** 四节点性能试验仍需展示独立diff和预算。

审批依据：[AGENTS.md](../../../AGENTS.md)：“Before every future remote-affecting change, show the user the relevant local diff and wait for approval.” 当前对研究顺序的认可用于本地分析与提案；尚未把它扩大为这份具体新PBS作业的提交批准。

## Approval received — 2026-11-02

User explicitly approved this exact diff and one preflight, including isolated branch sync, submission and evidence archival. Runtime files installed without changes to the approved hashes. No four-node job or retry authorized.
