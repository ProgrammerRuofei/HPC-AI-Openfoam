# Gadi pm78 scratch inode cleanup

The user approved archiving and removing only the old
`/scratch/pm78/kj7183/openfoam-build/OpenFOAM-v2512` source tree. The
`pm78` inode allocation is shared across the project; the tree was owned by
`kj7183`, used 47,912 inodes and 949 MB, and was not referenced by current
repository build scripts. `qstat -u kj7183` returned no active jobs before
submission. The baseline data, run logs, `ThirdParty-v2512`, and all other
directories were outside the cleanup scope.

The reviewed script `builds/build-scripts/gadi-gcc162-ompi5010/archive_old_openfoam_source.pbs`
was committed as `c694155` and pushed to the isolated branch on GitHub and
Gadi. The local and Gadi script SHA-256 matched:
`203eb07a47ddab73047de435359cfb8e40d8fc03dc0db0f63b1b8637b1c43405`.
The Gadi control checkout remained on `main`; a submitted copy was
materialized from the verified branch ref under `submit-logs/`.

One PBS job, `182137556.gadi-pbs`, ran in `normalsr` with one CPU, 4 GB RAM,
2 GB JOBFS and a 30-minute limit. It finished `Exit_status=0` in 7:40 and
charged **0.26 SU**. Its stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/archive_old_openfoam_source.pbs.out`.
The log records `SOURCE_ENTRIES=47912`, `ARCHIVE_ENTRIES=47912`,
`ARCHIVE_VALIDATION_PASS`, and `SOURCE_REMOVED_PASS`. GNU tar's comparison
against the source completed before removal. The retained archive is
`/scratch/pm78/kj7183/openfoam-build/OpenFOAM-v2512.precleanup-20261023.tar`
(870 MB), with adjacent `.sha256`; the archive SHA-256 is
`bc8aad936cffe07bb1565a806ecfa948f1fb759a960e766564b30992f523f46e`.
A separate `sha256sum -c` after the job returned `OK`.

Afterward, the source path was absent and `du --inodes -s` for
`/scratch/pm78/kj7183/openfoam-build` was 5,395 (53,305 before).
The live `lfs quota -g pm78 /scratch/pm78` reported 153,412 files. The
`nci_account -P pm78` summary still showed 201.32K used immediately after
completion, so its storage report had not yet caught up. The source tree
remains recoverable from the verified tar archive.
