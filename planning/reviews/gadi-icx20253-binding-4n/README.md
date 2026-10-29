# One four-node default/core binding pair

User explicitly approved writing and submitting this target-scale experiment after
review of the single-node AB/BA results. One PBS allocation, default then core,
each 416 MPI ranks, four SPR8470Q hosts with104 ranks each,150 steps. ICX2025.3.2,
private OpenMPI5.0.10,OpenFOAMv2512,Scotch,65,334,765 cells. One-hour/832SU ceiling;
estimate450–500SU for both complete preparation/solver chains. No automatic repeat.

[Full diff](proposed-scripts.patch) compares the arm with the validated scored
script and shows the new pair wrapper and affinity helper. Only treatment is
--bind-to core; unchanged map-by ppr:104:node and pml ucx. No UCX preload or
collective override. Module UCX1.18.1/UCC1.4.4 does not establish loaded solver
versions/collectives; historical uncertainty remains. No CPU/PMPI sampling.

Before solving: bounded180s placement probes,416 ranks/four hosts,unique core
assignments within default masks, unchanged rank-to-host mapping. Fail stops pair.
Each arm needs input/archive/binarySHA,complete preparation End,Time1..150/End,
positive coded seconds/step,Cd plausibility. Final paired gates compare all
partition geometry,scientific input,Cd trajectory (1e-8 diagnostic consistency,
not an official competition threshold),and416 affinity receipts per arm.
Masks are pre-exec evidence,not actual post-MPI-init or memory-page residency.

Storage checked before submission:573.83GiB/1TiB,166.15K/202Kinodes;7.53KSU
available,624SU reserved. Prior four-node staging8.4GiB;pair stages~16.8GiB,
allow20GiB/<5000 permanent inodes.100GB node-localJOBFS request,760GB memory.
Original master mesh is referenced from shared case;mutable processor meshes
are independent JOBFS copies. Master and actual-use mesh hashes recorded and
master checked unchanged after each arm. No prior evidence removed or overwritten.

Local validation: bash -n,embedded Python AST,synthetic416-rank/four-host receipts
made from actual BA masks;wrong-host/duplicate-core rejection;real182564679
150-step log paired parser and missing-step rejection;embedded scriptSHAchecks.
First arm must fully pass before second;do not begin second with<25min remaining.

One AB order tests target-scale behavior but does not alone eliminate order or
run-to-run noise. Compare paired ratio;do not declare benefit from one tiny delta.
Raw logs go to planning/evidence/gadi-pbs-script-snapshot/logs/<job-id>/,
with separate default/core evidence,original names/bytes,SHA256,sources andPBS/SU.

## Script SHA256

- `run_binding_arm_4n_v1.sh`: `d9c6abd2ac2fabb89ec90de8fd4e3e8504e9502c5f52b397a9f715232807dcc2`
- `run_binding_pair_4n_v1.pbs`: `b862283593e33c9b667ec08dbe73bcd5332b681b2204447ebb82ccc211712106`
- `affinity_receipt_4n.py`: `76dc544c5d43f767a01d9651e6055e69f1e9ef1e451095f0ea3450a139d658d4`
