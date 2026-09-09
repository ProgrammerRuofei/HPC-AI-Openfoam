# Repository organisation pass and Git remote state

**Date:** 2026-09-09
**Scope:** documentation only. No file was moved, no script was changed, no job
was submitted, nothing on Gadi was touched, and nothing was committed or pushed.

## 1. What this pass did

Rewrote the navigation layer so the repository can be understood from GitHub
without reading the full history:

- [`README.md`](../README.md) — rebuilt as the control center.
- [`results/experiment-index.md`](../results/experiment-index.md) — new master
  index of every run with status labels and provenance.
- [`results/hpc-lessons.md`](../results/hpc-lessons.md) — new failure/lesson
  register (L1–L10).
- [`experiments/aspire2a-diagnosis/README.md`](../experiments/aspire2a-diagnosis/README.md) — new; the directory had none.
- Stale placeholder READMEs refreshed (`builds/`, `experiments/`, `planning/`,
  `progress/`, `results/`, `scripts/`) — several still claimed that no
  experiment or script existed.
- [`APPLICATION.md`](../APPLICATION.md) — the "current scored reference" table
  was stale.

Deliberately **not** touched, to keep the pending Git divergence easy to
resolve: `builds/build-scripts/c1-icc2021-openmpi417/README.md`,
`build_c1_*.pbs`, `build_c1_*.sh`, and
`builds/build-scripts/common/build_openfoam_v2512_openmpi.sh` — these are
exactly the four files the Gadi-side commits modified.

## 2. Why no directories were moved

Scripts resolve other scripts by repository-relative path. A `git mv` would
break jobs that then fail deep inside a paid allocation:

| File | Coupling |
| --- | --- |
| `builds/build-scripts/*/build_*.pbs` | `exec bash builds/build-scripts/<id>/build_<id>.sh` after `cd $PBS_O_WORKDIR` |
| `builds/build-scripts/*/build_*.sh` | `$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh` |
| `official-gadi-spr/validate_official_baselines.sh` | hard-codes the three `official-gadi-spr/official_baseline_*.pbs` paths |
| `scripts/compiler-screening/*.pbs` | `bash scripts/compiler-screening/stage_candidate_runtime_node.sh` |
| `builds/.../benchmark_c1_65m_4n.pbs` | asserts `PBS_O_WORKDIR` == `/scratch/pm78/kj7183/openfoam_cpu/control-repo` and builds an absolute path to `stage_c1_runtime_node.sh` |
| `builds/.../a1-.../build_a1_*.sh` | `${PROJECT_ROOT}/builds/build-scripts/${STACK_ID}` |

Absolute Gadi paths (`/scratch/...`, `/apps/...`) are cluster locations and are
independent of repository layout.

## 3. Git remote state as of this pass

Three clones exist. All three are on branch `main`.

| Clone | Where | `main` points to |
| --- | --- | --- |
| Mac (this working copy) | `/Users/sofia/Projects/openfoam-aspire2a` | `1765c86` |
| GitHub `origin` | `git@github.com:ProgrammerRuofei/HPC-AI-Openfoam.git` | `49dc0c9` |
| Gadi `gadi` | `gadi-comp:/scratch/pm78/kj7183/openfoam_cpu/control-repo` | `cfc6c95` |

```
* cfc6c95 (gadi/main)        Work around ICC CircularBuffer const bug
* 421908e                    Repair ICC aligned allocation build compatibility
| * 1765c86 (HEAD -> main)   Work around ICC CircularBuffer const bug
| * 49dc0c9 (origin/main)    Repair ICC aligned allocation build compatibility
| * bfcfa34                  Record official Sapphire Rapids scaling results
|/
* bc45f06                    Build wmake's own tools before src: the real C1 blocker
```

### How the split happened

The same two ICC build fixes were committed **twice, independently**: once on
the Mac (`49dc0c9`, `1765c86`) and once directly in the Gadi clone
(`421908e`, `cfc6c95`, author *Koompa Junchan*, 2026-09-04). Git treats them as
different commits because they have different parents and timestamps, even
though the resulting files are identical.

Editing directly in the Gadi clone is what caused this. Per
[`workflow/01-Git-Sync-Policy.md`](../workflow/01-Git-Sync-Policy.md), the
cluster clone should only ever `git pull --ff-only`.

### What actually differs

- `builds/`, `phase0/`, `official-gadi-spr/`, `experiments/`, `scripts/` are
  **byte-identical** between `1765c86` and `cfc6c95`
  (`builds/` tree `4b3675d9c55443c167a3a609439419b59d5a7480` on both sides).
  The C1 build inputs are the same on both lines, so the
  `BUILD_VALIDATION_PASS` provenance is not in question.
- The **only** tree difference is three Markdown files —
  `planning/competition-progress.md`,
  `results/compiler-screening-summary.md`,
  `results/official-gadi-spr/run-registry.md` — which is exactly the Mac-only
  commit `bfcfa34` (the official 1N/2N scaling records). Gadi does not have it.

> The claim "content-equivalent local commit" in
> `results/compiler-screening-summary.md` is true for the **build inputs** but
> not for the repository as a whole. `1765c86` and `cfc6c95` are *not* the same
> tree.

### Status

**Not resolved, deliberately.** Which line becomes authoritative is a decision
for the repository owner, not something to settle automatically.

Ancestry facts, verified:
- `49dc0c9` **is** an ancestor of `1765c86` → pushing Mac `main` to GitHub
  would be a **clean fast-forward**, publishing exactly one commit (`1765c86`).
- `49dc0c9` is **not** an ancestor of `cfc6c95` → the Gadi line has never been
  on GitHub.
- Neither `1765c86` nor `cfc6c95` is an ancestor of the other; their merge base
  is `bc45f06`.

## 4. Content that exists on only one side

Two lessons were found on the Gadi line but missing from the Mac's rewritten
documentation. Both are now preserved permanently in
[`results/hpc-lessons.md`](../results/hpc-lessons.md):

1. **L1** — the walltime / service-unit reservation lesson (38.61 SU actually
   billed against ~768 SU reserved by an 8-hour request, which starved official
   baseline attempt 1). This existed in generalised form in
   `official-gadi-spr/README.md`, but the concrete evidence existed only in the
   Gadi copy of `compiler-screening-summary.md`.
2. **L2** — the `WM_MPLIB=INTELMPI` → `SYSTEMOPENMPI` reset and the resulting
   `mpicc --showme:link` failure. This *is* present on the Mac, but only as an
   **uncommitted working-tree edit** to
   `results/s1-autonomous-debug-summary.md`. It is not in commit `1765c86`, so
   it would be lost by any `git checkout`/`reset` of that file.

Recording them in a tracked lessons file removes the dependence on either the
Gadi line or an uncommitted edit.

## 5. Uncommitted work carried forward

Left uncommitted on purpose, pending review:

- `builds/build-scripts/c1-icc2021-openmpi417/benchmark_c1_65m_4n.pbs` (new)
- `builds/build-scripts/c1-icc2021-openmpi417/stage_c1_runtime_node.sh` (new)
- `builds/build-scripts/c1-icc2021-openmpi417/repair_c1_runtime_archive_v2.pbs` (staged)
- `builds/build-scripts/c1-icc2021-openmpi417/smoke_c1_icc2021_openmpi417.pbs` (staged + modified)
- `results/compiler-screening-summary.md` (staged)
- `results/s1-autonomous-debug-summary.md` (modified — see §4)
- `scripts/compiler-screening/` (untracked)
- `builds/build-scripts/a1-gcc112-craympich-private/` (untracked)
- `progress/2026-09-04-aspire2a-multinode-build-revisit.md` (untracked)
- `references/last-year/` (untracked)

`results/scripts/__pycache__/` is build noise and should be git-ignored rather
than committed.

## 6. Next actions

1. Decide which history is authoritative (see §3). Nothing else should be
   pushed until this is settled.
2. Commit the documentation pass and the C1 65M scripts once reviewed.
3. Push to GitHub; `git pull --ff-only` in the Gadi clone.
4. ~~Recover the two missing C1 PBS job IDs~~ — **done 2026-09-09**:
   runtime-archive repair `178252413.gadi-pbs`, smoke attempt 2
   `178254935.gadi-pbs`. Both are recorded in
   [`results/experiment-index.md`](../results/experiment-index.md). Neither can
   cite a commit, because both scripts were untracked at submission time
   (lesson L11) — committing them closes that gap.
5. Submit the C1 65M screening benchmark and record the result as `SCREENING`.
