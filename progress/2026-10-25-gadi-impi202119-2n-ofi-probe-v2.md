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

Local validation, synchronization, submission, PBS ID, detailed result
and actual SU are pending.
