# 182590339.gadi-pbs — four-node binding pair failed

Raw local logs: PARTIAL — 1256/1300 originals SHA verified;44 rank receipts
pending after SSH failure. See [missing files](missing-files.tsv). Core result
files were never produced,as distinct from retained but untransferred rank files.
See [sources](sources.tsv),[SHA256](SHA256SUMS),[PBS stdout](run_binding_pair_4n_v1.pbs.out),[default solver](default/evidence/simpleFoam.log),[default Cd](default/evidence/coefficient.dat),[core staging log](core/evidence/run.log).

Remote root: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-4n-v1/182590339.gadi-pbs/
Script commit:c24cc93192fe7be5a98b49a4c344af3405af78e2;submission record7b93073.
PBS SHA:b862283593e33c9b667ec08dbe73bcd5332b681b2204447ebb82ccc211712106.

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
