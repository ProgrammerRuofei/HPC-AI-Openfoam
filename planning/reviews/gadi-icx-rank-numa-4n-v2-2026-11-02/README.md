# Four-node rank/NUMA v2 topology-receipt repair

User approved one retry after the v1 receipt failure. This review records the narrowly scoped implementation before remote use. Original v1 scripts and evidence remain unchanged.

Changes: new v2 PBS/arm paths and PASS markers; node-side helper writes lscpu receipt itself with hostname, nonempty and CPU-model checks; arm logs topology begin/validated and error line/return status; expected-script manifest updated. No compiler, MPI, rank-placement algorithm, scientific input, decomposition, acceptance threshold or resource changes.

Same ICX2025.3.2/privateOpenMPI5.0.10/OpenFOAMv2512/Scotch,4 SPR nodes ×104 ranks,control then candidate each150steps,both core-bound,21 ranks moved within original node/socket.416CPU/760GB RAM/400GB JOBFS/1h,max832SU;expected465–500SU,not guaranteed. Prior v1 cost35.13SU is separate. New job scratch estimate<=25GiB/<6000inodes; master mesh remains shared/read-only with SHA checks. No extra persistent raw-grid copy.

Full diff: proposed-scripts.patch. Local tests must prove valid receipt, empty/wrong-model/wrong-host rejection and no overwrite, shell syntax and embedded Python parsing; stage-script hashes checked. These checks do not prove cluster execution or speedup. Single retry only; no automatic retry on a new failure. Finish with all original acceptance checks and immutable job-keyed archival.
