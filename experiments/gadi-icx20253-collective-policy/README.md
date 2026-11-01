# ICX 2025 collective-policy compatibility smoke

User approved reviewed diff on 2026-11-01. One normalsr job, 5 CPU/ranks,
16 GB RAM, 20 GB JOBFS, 10 min, approximately 1.67 SU maximum.
Existing ICX 2025.3.2, private Open MPI 5.0.10, OpenFOAM v2512 archives.
Same fresh 20-step Scotch tutorial for default and no-HCOLL policies.
No scored 65M workload, no compiler rebuild, no four-node authorization.

[Reviewed diff and checks](../../planning/reviews/gadi-icx20253-collective-policy-2026-11-01/README.md).
Both solver runs include collective verbose and binding receipts. The MPI
probe records its own loaded UCP path/version and checks Allreduce sum=10.
Probe observations do not establish the solver's loaded-library identity.
Component Enabled does not identify every operation's algorithm.

Require PBS Exit0, final/arm PASS, five rank receipts per arm, Time1..20,
End/finalization, identical input hashes and no-HCOLL exclusion evidence.
Preserve all original evidence; no automatic retry or monitor.
No job submitted yet. Results pending.

Submitted exactly once: **182829851.gadi-pbs**, script commit485ab33. [Submission record](../../progress/2026-11-01-gadi-collective-policy-review.md). Results pending; no automatic retry.

Smoke182829851:Exit0/PASS,0.16SU,58sec,rawarchivecomplete. User authorized next controlledpair without anotherapprovalpause; full diff shown and validated. [Four-node review](../../planning/reviews/gadi-icx20253-collective-4n-2026-11-01/README.md),832SUceiling,noextrasubmissions.

Four-node pair submitted once as `182830268.gadi-pbs` from reviewed commit `d3bbdef`. Results pending; never resubmit. Monitor remains off.
