# OpenFOAM record navigation

English companion to [PROJECT-INDEX.md](PROJECT-INDEX.md), prepared 2026-10-28.
Choose the cluster first, then follow the evidence. This index does not replace
raw logs or run registries. Latest experiment status here comes from local
2026-10-26 records; no cluster connection was made for this organization pass.
New teammates can start with [TEAM-GUIDE.md](TEAM-GUIDE.md).

| Cluster | Quick entry | Main retained results |
| --- | --- | --- |
| [ASPIRE2A](planning/aspire2a-guide.en.md) | Basic evidence package, partition analysis, PMPI, A/B/C, PGO x binding and storyline | Weighted Scotch 1/2/4-node evidence; later comparisons suffer timing stalls and do not establish a stable ranking. |
| [Gadi](planning/gadi-guide.en.md) | Old/new stacks, Scotch comparisons, scaling, profiling, ICX and storyline | GCC 16.2/Open MPI 5.0.10 + Scotch 1/2/4-node records and a 4-node repeat. |

## Find evidence by question

| Question | Entry |
| --- | --- |
| Raw logs, Cd and inputs | [ASPIRE2A Basic staging](submission/2026-apac-hpc-ai/openfoam/README.txt); [Gadi registry and remote evidence pointers](results/gadi-gcc162-ompi5010-scotch/run-registry.md) |
| 1/2/4-node measurements | [ASPIRE2A scaling CSV](submission/2026-apac-hpc-ai/openfoam/scaling/scaling.csv); [Gadi scaling record](results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.md) |
| Partition/performance analysis | [ASPIRE2A storyline evidence draft](planning/2026-10-22-openfoam-evidence-storyline-draft.en.md); [Gadi same-stack registry](results/gadi-gcc162-ompi5010-scotch/run-registry.md) |
| MPI / CPU profiling | [ASPIRE2A profiling entry](planning/aspire2a-guide.en.md#profiling-and-later-experiments); [Gadi PMPI rank analysis](results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md) |
| Plans and slide storyline | [ASPIRE2A guide](planning/aspire2a-guide.en.md#plans-and-storyline); [Gadi guide](planning/gadi-guide.en.md#plans-and-storyline) |
| Chronological work | [Progress](progress/README.md); [older experiment index](results/experiment-index.md) |
| Why performance claims need caveats | [Scotch A/B/C review](progress/2026-10-25-aspire2a-scotch-abc-evidence.md); [PGO x binding stall audit](progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md) |
| Organization scope and local-only files | [Repository review](progress/2026-10-28-repository-review-and-organization.md), [evidence retention](planning/evidence/README.md), [reference boundaries](references/README.md) |
| Classification of the remaining 119 files | [English decision record](planning/2026-10-28-untracked-file-classification.en.md), [per-file sizes/SHA256/reasons](planning/repository-audit/2026-10-28-untracked-files.csv), [handoff](progress/2026-10-28-untracked-file-classification.md) |

## Reading rules

- Do not rank clusters by performance: CPU, ranks/node, builds and runtime
  environments differ between ASPIRE2A and Gadi.
- Prefer `simpleFoam`'s `Average wall-clock time per time step` in timing plots.
  Review Cd at the corresponding step count and its trajectory; final rows at
  different iteration counts are not interchangeable converged values.
- `results/experiment-index.md`, the root README's detailed narrative and
  `planning/PLANS.md` retain historical snapshots. Their ASPIRE2A "blocked"
  and old Gadi "current baseline" labels are obsolete. Use cluster guides
  for more recent evidence.
- A staging package is not proof of upload or scoring. Earlier checklists and
  later "submitted" wording conflict; independent delivery/score evidence is
  still required.
- This organization work was local documentation, archival and Git work only:
  no jobs or cluster connections; original log/script paths were preserved.
