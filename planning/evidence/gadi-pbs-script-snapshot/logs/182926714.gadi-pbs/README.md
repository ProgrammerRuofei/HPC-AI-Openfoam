# 182926714.gadi-pbs — rank/NUMA preflight failed

**PBS F / Exit137; no PASS.** ICX2025.3.2 + private Open MPI5.0.10; one normalsr SPR8470Q host `gadi-cpu-spr-0201`,104ranks,16GB RAM,20GB JOBFS,10min request.28sec actual,**1.62SU**. No OpenFOAM run, steps,Cd or solver seconds/step.

The scheduler stdout explicitly states `Job 182926714 has exceeded memory allocation`.104 probe RSS values total16.180843GiB at termination, excluding other processes. Baseline MPI initialization reports `[LOG_CAT_MCAST] Failed to register MR: errno 12`; rank54 killed. Do not infer a unique library root cause beyond the confirmed memory-limit kill.

Archive/library/compiler versions and probe source hashes passed before baseline launch; `probe.ldd` confirms job-local libmpi.so.40. Modules UCX1.18.1/UCC1.4.4 do not establish actual selected runtime versions/collectives.0 baseline rank receipts; candidate launches not reached. No acceptance.json, PASS, UCP self-report or validated rankfile maps. PBS exit alone is not used for acceptance.

All13 produced evidence files plus independent PBS stdout copied byte-for-byte and matched remote SHA256. qstat.txt is the raw read-only scheduler response; its local hash is also listed. Empty baseline directory retained. Expected-but-unproduced624 rankJSON, five rankfiles, logical-core-map.json, acceptance.json and candidate logs are not transfer gaps.

Source evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/`
Stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_rank_numa_1n_v1.pbs.out`
Commands: `ssh -o BatchMode=yes -o ConnectTimeout=10 gadi-comp 'qstat -xf 182926714.gadi-pbs'`; read-only `find . -type f -exec sha256sum {} +` in job evidence and `sha256sum` stdout. Pull via `scp -r -p -o BatchMode=yes` evidence into new temporary directory and `scp -p -o BatchMode=yes` stdout; no remote writes or new PBS operations.

| Local file | Remote source | SHA-256 |
|---|---|---|
|[baseline.bindings.txt](baseline.bindings.txt)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/baseline.bindings.txt`|`f4234e0d22ad71d7bf2eb8177a2cd842dea5d0a14740f39b29c234742b16d6cd`|
|[baseline.stdout](baseline.stdout)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/baseline.stdout`|`e41ad5745f9f95be378533a8efb67fc83d8edf652de45d39ae414cb0b4af4873`|
|[candidate-map-v1.csv](candidate-map-v1.csv)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/candidate-map-v1.csv`|`b82e7f750816a3f0b9fb5951ee7be00f83b2c75ec02e8be6454c4c7a8fda3c91`|
|[exit-status.txt](exit-status.txt)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/exit-status.txt`|`e390ce9fc0ea1d5a401fe56eddaafd556f62b2153124584b928ca302843092ce`|
|[lscpu.txt](lscpu.txt)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/lscpu.txt`|`1cacfe4a903e022085616278eb5bd713376806b8582bcf54dcbbe2cb26196c10`|
|[modules.txt](modules.txt)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/modules.txt`|`937148f9ca65b06937885e23f7981525ae04daac5892766fa391c036ca144423`|
|[preflight_rank_numa_1n_v1.pbs.out](preflight_rank_numa_1n_v1.pbs.out)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_rank_numa_1n_v1.pbs.out`|`8d2cd99429acc50467570473714c34bb2b3c629298e76621d1ad1db655f83886`|
|[probe.ldd](probe.ldd)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/probe.ldd`|`59870de0493a170754735a9029f1884c3f53119b79218d0f4fb1db0772006eca`|
|[provenance.txt](provenance.txt)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/provenance.txt`|`0952320081030f9dbabcbe1c850ed68db58e352bbdcf11f581a06e01bd675ac6`|
|[qstat.txt](qstat.txt)|`qstat -xf 182926714.gadi-pbs`|`058d506d6740140e4b174cfbcff2c2bc1cb23e724b95145a45eb62f2cea388dc`|
|[rank_numa_preflight.py](rank_numa_preflight.py)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/rank_numa_preflight.py`|`0e6cff53301a5c079e7b4824e2eeca25a167e47d1ecc91681d8d7d584945b431`|
|[rank_numa_probe.c](rank_numa_probe.c)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/rank_numa_probe.c`|`693de09cc0d8adeec5cb6badd3c7218ffb1f013122fdbb4c9fb23ef86404f52b`|
|[run.log](run.log)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/run.log`|`2b50843c0ce05144a6c202bb538b0ebdab555571df26cd3977326c11850ebe65`|
|[submitted.pbs](submitted.pbs)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/submitted.pbs`|`455f0a4a0e2dd99ae3ac3be999509cb26e4bcd28d524015eb7b481c60b7d687a`|
|[topology.csv](topology.csv)|`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/topology.csv`|`3f2db65c292d3982da3db0989ffd8f1175f2d0d00e720a6b8ad12e121e612c56`|
