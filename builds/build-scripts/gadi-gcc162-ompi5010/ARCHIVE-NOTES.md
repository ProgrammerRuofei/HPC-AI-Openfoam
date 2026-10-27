# Historical GCC16/Open MPI build files: archive boundary

Archived unchanged during the 2026-10-28 untracked-file review. The six
pre-existing files, including README, retain their original hashes in the
[classification manifest](../../../planning/repository-audit/2026-10-28-untracked-files.csv).

The README describes the early build/relocation stage, not today's PBS state.
Later completed GCC16/Open MPI/OpenFOAM runs are recorded in the
[Gadi guide](../../../planning/gadi-guide.md) and
[run registry](../../../results/gadi-gcc162-ompi5010-scotch/run-registry.md).
The directory is a partial historical build record, not a self-contained
end-to-end recipe: downstream OpenFOAM and benchmark scripts from the other
worktree are not all present here.

Reviewed file roles:

- `build_gcc162.pbs` calls the same-directory build shell through a fixed
  repository-relative path; `build_gcc162.sh` pins the source hash and uses
  fresh PBS_JOBFS/evidence/archive paths.
- `smoke_gcc162_relocation.pbs` validates a pinned GCC archive in a fresh job.
- `build_ompi5010.pbs` calls `build_ompi5010.sh`; that script pins its inputs,
  expects site modules/PBS libraries and creates job-keyed output.

All five scripts passed local `bash -n`. They were not executed or edited.
Their site paths, module versions, resource requests and archive hashes are
historical inputs, not a newly chosen strategy. Syntax success does not prove
the current cluster environment or compilation will work. Source archives,
runtime archives and mesh data are not supplied by this Git archive.

Any future execution needs the applicable diff review, remote scope, verified
adapter and user authorization. Do not submit a build merely because its file
has now been committed.
