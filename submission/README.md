# 2026 APAC HPC-AI submission staging

This directory is a **working submission package**, not yet ready to upload as
the complete team package. The OpenFOAM Basic evidence is assembled under
`2026-apac-hpc-ai/openfoam/`.

## Release gates

- [x] Copy the original 1/2/4-node weighted Scotch solver logs, stage logs,
      coefficient files, and exact input dictionaries from ASPIRE2A.
- [x] Recheck the copied core files against remote SHA256 and confirm the
      4-node solver log and coefficient file belong to job 20072244.
- [ ] Add the final **combined Qwen + OpenFOAM** interview presentation at
      `2026-apac-hpc-ai/presentation/team_presentation.pptx`.
- [ ] Decide whether to include the separately assembled KaHIP Bonus evidence.
      The AOCC Opt method comparison and the PGO + binding candidate have
      different proof requirements; see `openfoam/bonus/README.txt`.
- [ ] Verify the Qwen submission files with that task's owner.
- [ ] Confirm the organizer's delivery channel and deadline time zone.

The OpenFOAM scripts and PBS stdout/stderr were copied from the team repo
from the team's local Git checkout at commit
`cc5861fdbc0ab6330c5cd122701bb73c7260d75d`. One Unicode ellipsis in
a comment of the shared runner was converted to ASCII `...` for the text
submission; executable commands are unchanged. No remote file was changed.
`openfoam/analysis/basic_metrics_from_teammate.csv` is a three-row extract
from that checkout's `results/metrics.csv`; the copied raw solver logs are the
authoritative score evidence. The original remote files were read, not edited.
The KaHIP Bonus text evidence is also assembled under `openfoam/bonus/`, with
its method-only comparison and separately marked PGO + binding candidate.

Do not submit the whole repository, source tree, mesh, `processor*` directories,
or built executables.
