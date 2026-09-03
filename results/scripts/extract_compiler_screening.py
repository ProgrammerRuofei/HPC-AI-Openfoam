#!/usr/bin/env python3
"""Read-only extraction of solver timing lines; emits JSON and never invents data."""
import json, re, statistics, sys
from pathlib import Path
if len(sys.argv) not in (2, 3): raise SystemExit("usage: extract_compiler_screening.py SOLVER_LOG [metadata.json]")
text = Path(sys.argv[1]).read_text(errors="replace")
matches = re.findall(r"ExecutionTime\s*=\s*([0-9.]+)\s*s\s+ClockTime\s*=\s*([0-9.]+)\s*s", text)
if not matches: raise SystemExit("no ExecutionTime/ClockTime pairs found")
execution, clock = map(float, matches[-1])
official = re.findall(r"Average wall-clock time per time step\s*=\s*([0-9.eE+-]+)", text)
if not official: raise SystemExit("no official Average wall-clock time per time step line found")
steps = [float(x) for x, _ in matches]
deltas = [b-a for a, b in zip(steps, steps[1:])]
out = {"official_metric": "Average wall-clock time per time step", "official_avg_wall_clock_time_per_step_s": float(official[-1]), "clock_time_s": clock, "execution_time_s": execution, "measured_timestep_count": len(deltas)}
if deltas:
    q = statistics.quantiles(deltas, n=4, method="inclusive") if len(deltas) > 1 else [deltas[0]]*3
    out.update(mean_timestep_s=statistics.mean(deltas), timestep_population_stddev_s=statistics.pstdev(deltas), median_timestep_s=statistics.median(deltas), min_timestep_s=min(deltas), q1_timestep_s=q[0], q3_timestep_s=q[2], max_timestep_s=max(deltas))
if len(sys.argv) == 3:
    metadata = json.loads(Path(sys.argv[2]).read_text())
    for key in ("candidate_id", "compiler", "mpi", "build_commit", "binary_sha256", "pbs_job_id", "allocated_nodes", "pbs_walltime_s", "peak_memory_kb"):
        if key in metadata: out[key] = metadata[key]
print(json.dumps(out, sort_keys=True))
