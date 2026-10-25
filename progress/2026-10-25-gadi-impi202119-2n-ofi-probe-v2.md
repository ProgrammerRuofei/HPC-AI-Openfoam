# Intel MPI 2021.19 two-node OFI preflight v2

The user approved one corrected two-node diagnostic after reviewing the
specific placement diff. The first attempt `182194827.gadi-pbs` cost
5.89 SU and stopped before `MPI_Init`: both `hostname` processes landed
on the first of two PBS nodes. Its evidence remains untouched.

The v2 script keeps the same private ICX 2026.2 / Intel MPI 2021.19
archive, pm78 `normalsr`, two SPR nodes, 208 allocated CPUs, 16 GB memory,
20 GB JOBFS per node, two launched MPI ranks and ten-minute limit
(approximately 69.3 SU request ceiling). It adds
`I_MPI_JOB_RESPECT_PROCESS_PLACEMENT=off` and explicitly names the two
allocated hosts with `-hosts host0,host1`, retaining `-ppn 1` for the
Hydra host check and the default/conditional-tcp MPI peer probes.
It uses new stdout and job-keyed evidence paths. No official case or
OpenFOAM solver will run, and no further automatic retry is authorized.

The v2 file passed local and remote `bash -n` and diff checks. Commit
`c880d02f319525412ee0601e825f0052a29b5c40` was pushed to GitHub,
transferred as a SHA-256-verified Git bundle and fast-forwarded on Gadi's
isolated branch. The staged PBS file SHA-256 is
`11a8fed7f689787945c01ad2af2d64d089d95655cda7717414eeef0cfa1b8000`.
Exactly one `qsub` returned `182218986.gadi-pbs`; initial `qstat -f`
showed Q on `normalsr-exec`, 208 CPUs, 16 GB memory, 20 GB JOBFS and ten
minutes. Independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/probe_impi202119_2n_v2.pbs.out`;
job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/evidence/impi-ofi-2n-v2.182218986.gadi-pbs/`.
Detailed result and actual SU remain pending. Do not submit another
job without separate approval.
