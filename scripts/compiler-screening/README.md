# Legacy generic compiler-screening harness

The three existing scripts were reviewed and archived unchanged on
2026-10-28. This is preservation, not a new compiler experiment or execution
approval. Their original hashes are in the
[classification manifest](../../planning/repository-audit/2026-10-28-untracked-files.csv).

- `stage_candidate_runtime_node.sh`: checksum-gated runtime extraction per
  allocated node; verifies the candidate executable and metadata.
- `smoke_candidate.pbs`: five-rank tutorial smoke on Gadi `normal`, requiring
  caller-supplied archive, compiler and binary settings.
- `benchmark_candidate_4n.pbs`: legacy 192-rank Cascade Lake screening case,
  not the current 416-rank Sapphire Rapids configuration.

All three passed `bash -n`; none was executed, edited, parameterized or
submitted. Runtime paths, modules, input identity, output freshness and
scientific validity require a new task-specific review before reuse. The
smoke-script comment says six supplied variables, but its actual guard names
seven; the implementation remains unchanged. The benchmark also depends on
the external fixed case and its `Allrun.gadi`, so it is not self-contained.

For current measured results use the [Gadi guide](../../planning/gadi-guide.md),
not the existence of these scripts as proof of a completed benchmark.
