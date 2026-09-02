# OpenFOAM ASPIRE2A Optimisation Control Repository

This is the local control repository for the fixed OpenFOAM
`occDrivAerStaticMesh` workload. The repository follows the workflow pack in
[`workflow/README.md`](workflow/README.md).

Remote access and optimisation work are not configured or authorised yet.
Read [`AGENTS.md`](AGENTS.md) and [`APPLICATION.md`](APPLICATION.md) before
workflow action.

## Repository layout

- `builds/`: source, build-script, and approved-extra-package placeholders.
- `experiments/`: one directory per authorised run; `_template/` is a blank
  structure only.
- `planning/`: authorised optimisation plans and analysis.
- `results/`: structured, extracted result records.
- `progress/`: dated session handoffs.
- `scripts/`: reusable local workflow and read-only probe scripts.
- `workflow/`: reusable HPC workflow rules.
