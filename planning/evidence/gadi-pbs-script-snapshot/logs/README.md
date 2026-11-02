# Gadi raw log index — binding batch

|Job|Raw local logs|Outcome|
|---|---|---|
|182588070|[444 originals and scheduler receipt, SHA256 verified](182588070.gadi-pbs/README.md)|Preflight Exit0/PASS;1.33SU|

The primary checkout retains the earlier job index; this branch adds only this batch evidence.

## Binding AB archive — 2026-10-30

| Job | Raw local logs | Outcome |
|---|---|---|
|182588604|[AB:465 original files + qstat,SHA verified](182588604.gadi-pbs/README.md)|Exit0/PASS;default8.252224/core8.248215s/step;79.50SU|

## Binding BA archive — 2026-10-30

| Job | Raw local logs | Outcome |
|---|---|---|
|182589631|[BA:465 original files + qstat,SHA verified](182589631.gadi-pbs/README.md)|Exit0/PASS;core8.260328/default8.274169s/step;78.69SU|

## Four-node binding182590339

[Raw local logs: partial,1256/1300 originals,SHA verified;44rank receipts pending](182590339.gadi-pbs/README.md).PBSExit271/JOBFS;default150steps1.985561463s/step,Cd0.291876174;core did not solve.241.97SU.

182590339 Raw local logs: **complete** (1300originals+qstat,SHAverified). Prior44missingfilesresolved;historicalgapreceiptsretained.

## Collective smoke 182829851

[Raw local logs: complete,39 originals+qstat,SHA verified](182829851.gadi-pbs/README.md). Exit0/PASS,58sec,0.16SU;5ranktutorial20stepsperpolicy;HCOLLcontrastobserved.

- [182926714.gadi-pbs](182926714.gadi-pbs/README.md): Raw local logs **complete for all produced evidence** (14 original files + qstat, SHA verified). MPI-only preflight F/Exit137,16GB memory exceeded,28sec/1.62SU; baseline receipts and candidate outputs were never produced.

- [182929980.gadi-pbs](182929980.gadi-pbs/README.md): Raw local logs **complete**,655 verified originals+qstat; independent624-rankreceipt validation PASS,F/Exit0,48sec,2.77SU. One-node MPI-only placement compatibility; not performance.

## 182932939.gadi-pbs — rank/NUMA pair v1 failure

[Raw local logs](182932939.gadi-pbs/README.md): **complete for produced evidence**, 24 original files plus qstat, all SHA verified. F/Exit1,152s,35.13SU. Empty lscpu topology receipt before MPI mapping/decomposition/solver; no150step result or Cd. Candidate not started. No retry submitted.

## ICX/GCC PMPI comparison — 2026-11-02

- [182940799](182940799.gadi-pbs/README.md): Raw local logs **complete for retained evidence**,40originals+qstatSHAverified;Exit0/PASS,150steps,416full+416bucketreports;1.984600097s/step,Cd0.2918761744,244.98SU.
- [181908113](181908113.gadi-pbs/README.md): Raw local logs **now complete for retained evidence**,40originals+freshqstatcapture;oldpartialarchiveexpandedwithoutoverwriting. HistoricalPBSstdoutExit0/246.83SU;freshqstatexpired,notfailure.
- [Paired analysis](../../../analysis/gadi-icx-gcc-pmpi-2026-11-02/README.md): WaitalllowerinICX,Allreducenotimproved;runtime/node/bindinguncertaintyretained.

## 182939454.gadi-pbs — rank/NUMA paired v2

[Raw local logs](182939454.gadi-pbs/README.md): **complete**,3447originals+qstatSHAverified,3328rankJSON;F/Exit0/2051s/474.01SU. Control1.984055638/candidate1.984123310s/step,Cd0.291876174identical. Singlepair,no usefulspeedup;probeUCP1.21.0/HCOLL selectionnotblanketsolverproof.
