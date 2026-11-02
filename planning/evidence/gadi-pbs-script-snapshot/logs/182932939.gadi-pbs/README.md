# 182932939.gadi-pbs — failed before MPI placement and solver

PBS F / Exit 1; walltime 00:02:32; actual 35.13 SU. Start 2026-11-02 16:14:51 Asia/Singapore, PBS completion 16:17:37 (scheduler 19:17:37 AEDT). Four SPR hosts 0201–0204, 104 requested CPUs/ranks per node, 416 total. ICX 2025.3.2 / private Open MPI 5.0.10 / OpenFOAM v2512 / Scotch; intended control then candidate, 150 steps each, both core-bound. Allocation 760 GB RAM / 400 GB JOBFS / 1 hour (832 SU ceiling); actual memory 31.91 GB. No scientific performance result.

## Original files and provenance

All 24 produced original files (23 job-root files and independent PBS stdout) were retrieved read-only, with original filenames, directory structure and bytes preserved. See `sources.tsv` for every source path and hash, `SHA256SUMS` for each original and the captured `qstat-xf.txt`, and `remote-sha256.txt` for the remote hash output. No originals excluded. qstat is a fresh scheduler capture rather than an original job-produced file.

## Independent validation and first failure

- Submitted PBS SHA: 78b5926b750bb2b5532538e3ad92cf50f2e89792ca52c42ecd148361eff1446d; all submitted script/helper hash checks printed OK.
- Fixed source dictionary hashes, GCC/MPI/OpenFOAM archive hashes and simpleFoam binary hash passed in control/run.log. Four STAGE_4N_RUNTIME_PASS receipts exist; simpleFoam links private libmpi.so.40.
- `control/evidence/lscpu-0.txt` is empty (SHA e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855). Independent stdout contains complete SPR8470Q lscpu output after staging. The arm script line 106 redirects the launching pbsdsh stdout, followed at line 107 by a mandatory grep of that empty receipt. This is the first identified failed evidence gate; there is no shell ERR trace to prove the exact command return status.
- Both arm and pair exit receipts report 1. No baseline directory or MPI placement receipts were produced; candidate never started. Hardware output shows the expected model, so this is not evidence of wrong CPU hardware.
- `ldd` includes /usr/lib64/libucp.so.0, UCC and HCOLL, but actual MPI_Init UCP version and collective selection are unknown because the probe never ran.

## Missing / not reached

No baseline/placement/solver-affinity/mpi-runtime rank reports, partition hash, decomposePar/renumberMesh/potentialFoam/applyBoundaryLayer/simpleFoam logs, coefficient.dat, pair-summary or success markers. Planned 150 steps were not executed. Timing and Cd are unavailable, not zero. Source mesh verification after MPI placement was not reached; no claim of complete scientific-input validation.

## Next action and limits

Preserve failure; do not automatically resubmit. Proposed workflow repair: collect per-node lscpu through a small node-side helper that writes its own receipt, validate nonempty output and model, and add explicit stage/error reporting. Test the helper locally before presenting a complete v2 diff with new output paths, script hashes and unchanged science/resources. A new four-node retry needs approval after that diff; there is currently no retry authorization. No run scripts changed during this investigation.
