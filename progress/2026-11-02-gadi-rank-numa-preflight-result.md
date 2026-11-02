# Rank/NUMA preflight result and proposed memory fix — 2026-11-02

User requested status and next step. Required startup files and main/isolated Git states read; preserved all unrelated changes. Existing master verified; only read-only BatchMode SSH and approved SCP retrieval used. No job submitted or cancelled, runtime scripts unchanged.

182926714.gadi-pbs finished F/Exit137,28sec,1.62SU,SPR0201. Scheduler memory-limit kill at16GB confirmed,104 probe processes total16.180843GiB RSS at snapshot. MR registration errno12 in baseline bindings, no rankJSON/PASS; all later launches absent. Current actual UCP version/collective and candidate mapping remain unknown. No scientific workload or Cd.

14 produced original files + qstat archived to job-keyed logs in main and isolated worktree; every original matched remote SHA256; hashes/sources/README saved. Updated result and experiment records plus raw index and append-only manual error case. Keep prior collective dirty changes out of this result commit.

Next: approve local-only review patch planning/reviews/gadi-icx-rank-numa-preflight-v2-2026-11-02/proposed-scripts.patch. New v2 PBS increases RAM16->64GB only, aside from new attempt names/paths; identical probe/helper/CSV.104CPU/10min/20GBJOBFS unchanged,34.67SU ceiling.64GB gives initialization headroom; not a guarantee MR errors will disappear. No runtime v2 file installed, sync or retry yet. Track2 resource change requires diff approval; previous one-attempt approval did not include retries. No four-node progression until complete preflight validation.

Remote commands: qstat -xf 182926714.gadi-pbs; head/tail stdout and baseline.bindings.txt; cat exit-status.txt; ls/find job evidence; find . -type f -exec sha256sum {} +; sha256sum stdout; scp -r -p -o BatchMode=yes job evidence to new staging and scp -p -o BatchMode=yes stdout. Connection remained valid. No credential access, monitor or remote configuration change.
