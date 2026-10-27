# APAC HPC-AI submission staging — 2026-10-09

Current step: assemble the text evidence package for the existing ASPIRE2A
OpenFOAM Basic runs. No optimization decision, experiment, build or job was
made.

## Completed

- Read the numbered workflow files, AGENTS.md, APPLICATION.md and the latest
  prior progress report; checked the local Git state. Pre-existing modified
  and untracked files were preserved.
- Confirmed the existing ASPIRE2A SSH master. Read-only inspection located
  weighted Scotch Basic cases for jobs 19730482, 20030920 and 20072244.
  Checked their original solver metric lines, final Cd rows, input-file and
  log presence, and SHA256 for the main evidence files. Exact commands and
  findings are in `submission/REMOTE_COMMANDS.txt` and
  `submission/2026-apac-hpc-ai/REMOTE_EVIDENCE.txt`.
- Confirmed the teammate checkout and its GitHub remote both point to
  `cc5861fdbc0ab6330c5cd122701bb73c7260d75d`; no new commit to pull.
- Created `submission/2026-apac-hpc-ai/` and copied existing Basic PBS scripts,
  shared runner, AOCC/Open MPI build scripts, PBS stdout/stderr and a three-row
  metrics extract without changing their contents. Added a scaling table,
  provenance notes and a 27-file remote copy list.
- After the user explicitly directed us to disregard the local transfer-form
  rule, used non-interactive `scp -p` through `aspire2a-comp` to copy the 27
  Basic text files. Verified 40/80/150 steps, official solver metric, final
  Cd, `End`, all preparation-stage endings, PBS DRIVAER_OK, and 15 core
  files against remote SHA256. Copied fixed `fvSchemes`, `fvSolution`, and
  `forceCoeffsAll`; their hashes were identical across the three Basic cases.
- Separately assembled KaHIP Opt 1/2/4 evidence and the 4-node AOCC PgoUse
  + binding candidate under `openfoam/bonus/`. Copied 36 case text files,
  scripts and PBS evidence, PGO build/training scripts and two added wmake
  rules. Verified step counts, metrics, Cd, stage endings and 20 remote core
  hashes. The PGO + binding candidate is marked as requiring a distinct F2/F3
  proof review before being claimed as a fully proved Bonus result.
- Preserved the current 19-slide OpenFOAM-only PPTX under
  `submission/working/`. It is not the required combined team presentation.
- Validated staged shell-script syntax, text formats and CSV mappings.

## Blockers and exact next action

The project's `workflow/00-General-SSH-Rules.md` still marks its SCP/rsync
adapter field `TBD`; the user explicitly overrode that rule for this task.
The actual read-only transfer used `scp -p -o BatchMode=yes -o
ConnectTimeout=15 aspire2a-comp:<source> <local-destination>`. The full
source/destination list is `submission/REMOTE_TRANSFER_COMMANDS.txt`.

The final combined Qwen + OpenFOAM deck and Qwen submission materials are also
not present in this staging tree. KaHIP/PGO Bonus is kept separate pending F2/F3
proof review. Confirm organizer delivery channel and deadline time zone.

No remote state changed. No `qsub`, `qdel`, build, run, Git commit, push or
pull occurred.
