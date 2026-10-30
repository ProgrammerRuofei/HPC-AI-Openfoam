# Gadi ICX2025 four-node binding pair — 2026-10-30

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

Prepared and validated locally;PBS not yet submitted. Latest direct user approval covers writing,synchronizing and submitting this pair once.

## Submitted once — 182590339.gadi-pbs

Reviewed script commit c24cc93192fe7be5a98b49a4c344af3405af78e2 synchronized to GitHub/Gadi. Remote checkout clean and ff-only; local/remote SHA and bash -n matched; independent stdout absent. Submitted exactly once from /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo:
`qsub experiments/gadi-icx20253-binding-numa/run_binding_pair_4n_v1.pbs`
Returned182590339.gadi-pbs; no further scheduler status read yet.

PBS SHA256 b862283593e33c9b667ec08dbe73bcd5332b681b2204447ebb82ccc211712106.
Arm SHA256 d9c6abd2ac2fabb89ec90de8fd4e3e8504e9502c5f52b397a9f715232807dcc2.
Helper SHA256 76dc544c5d43f767a01d9651e6055e69f1e9ef1e451095f0ea3450a139d658d4.

One normalsr allocation,4SPR nodes/416CPUs,760GB,100GBJOBFS,1hour/832SU ceiling. Default then core,each416ranks/150steps;ICX2025.3.2/OpenMPI5.0.10/OpenFOAMv2512/Scotch,fixed65M inputs. No retry.
Stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_4n_v1.pbs.out
Pair root: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-4n-v1/182590339.gadi-pbs/
Raw evidence is in evidence/ and default/evidence/,core/evidence/. Pending results,actualSU,Cd andseconds/step.

Immediately after submission the user requested disabling the monitor. Deleted automation gadi-icx-binding successfully. No job cancellation or new submission; no further automatic polling. Resume evidence retrieval only when requested. Preserve this ID to prevent duplicate submission.

## Result inspected — 182590339.gadi-pbs: incomplete pair, JOBFS limit

PBS F / Exit_status271,SIGTERM,walltime00:17:27 (1047s),posted actual241.97SU
for the entire job. One normalsr allocation,4 Sapphire Rapids8470Q hosts
0514,0515,0516,0526;each104 CPUs/ranks,total416. ICX2025.3.2/private
OpenMPI5.0.10/OpenFOAMv2512/Scotch,unchanged65,334,765-cell occDrivAerStaticMesh.
UCX1.18.1/UCC1.4.4 are declared modules only;actual solver UCP version,
UCC/HCOLL selection remain unmeasured. No UCX preload or collective override.

Default arm completed all four preparation stages and Time1..150/End/finalization.
Coded149-step mean1.985561463114094s/step (first step excluded),Cd at150
0.29187617440389690,ExecutionTime302.06s/ClockTime308s.416rank mapping,
source/actualmesh checks,archive/binary checks and default PASS present.
Pre-exec solver masks allow13physicalcores perrank;not post-MPI affinity or
memory residency. The separate416rank core probe had unique cores within
corresponding default masks. Core arm stopped during runtime staging after
its node0 receipt;no decomposition or solver log,Cd,step-time,corePASS or
pairPASS/summary. Therefore this is not a valid completed binding comparison.
Default completed-arm data are retained as partial-job evidence,not a successful
paired result or a core-binding benefit.

Authoritative PBS stdout: `Job 182590339.gadi-pbs killed due to exceeding jobfs quota. Quota: 25.0GB, Used: 26.53GB, Host: gadi-cpu-spr-0514`.
PBS select gives4nodes eachjobfs26843545600bytes:100GB total is25GB/node.
The first arm's JOBFS files remained while the second unpacked a separate runtime.
The pre-submit capacity estimate failed to budget simultaneous per-node peak;
this is a workflow resource-planning error,not a demonstrated MPI/solver defect.
Retained pair_exit_rc=0 and core script_exit_rc=0 contradict PBS termination and
must never override it. Signal-aware failure reporting needs review separately.

1256 original evidence/stdout files retrieved with remote/local SHA agreement;
44 remaining rank receipts are listed in missing-files.tsv. qstat -xf was
read remotely and showed F/271,but its full raw stdout was not captured locally
before SSH expired;the archived PBS stdout independently records Exit271 andSU.
Original names/bytes and evidence/default/core paths
preserved;README,SHA256SUMS,sources.tsv and remote inventory retained. Missing
expected outputs were never produced:core solve/preparation,core coefficients,
pair-summary and pairPASS. The first bulk SCP pull reached its600-second local transfer bound;1091 verified originals were recovered from preserved staging and a remaining-only pull recovered165 more files before the master connection broke.
Stopped remote operations at SSH failure,no automatic authentication retry.
Full independent affinity validation is deferred until the44 missing receipts arrive.
No archived originals overwritten;no remote file
modified,no repair/retry/newPBS submission ormonitor restart.

Next proposed remedy requires a new reviewed diff and approval:calculate per-node
peak from both arms,then choose adequate per-node JOBFS or reuse the immutable
runtime across arms while preserving independent cases and all evidence;correct
signal status capture. Do not delete existing evidence or reuse this job ID.

## Archive completion after connection recovery

All1300 remote original files now present andSHAverified;fullqstat-xf.txt captured,
confirmingF/Exit271. Earliermissing-files.tsv andpartial-1256 manifests are retained
as historicaltransferreceipts;all44listedfiles are nowresolved. No rawbytesoverwritten.
Runfailure/defaultresult unchanged. No retry ofv1;v2isaseparateauthorizedattempt.
