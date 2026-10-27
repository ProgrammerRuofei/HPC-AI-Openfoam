#!/usr/bin/env python3
"""Reconstruct the Step 2 A/A repeatability evidence from retained files."""

from __future__ import annotations

import csv
import hashlib
import json
import re
from pathlib import Path
from statistics import mean


ROOT = Path(__file__).resolve().parent
EVIDENCE = ROOT / "evidence"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def parse_solver(path: Path) -> dict:
    time_re = re.compile(r"^Time = (\d+)$")
    timing_re = re.compile(
        r"^ExecutionTime = ([0-9.]+) s\s+ClockTime = ([0-9.]+) s$"
    )
    solve_re = re.compile(
        r"Solving for (Ux|Uy|Uz|p), Initial residual = ([^,]+), "
        r"Final residual = ([^,]+), No Iterations (\d+)"
    )
    continuity_re = re.compile(
        r"time step continuity errors : sum local = ([^,]+), global = ([^,]+), "
        r"cumulative = (\S+)"
    )
    average_re = re.compile(r"Average wall-clock time per time step = ([0-9.]+)")

    current_time = None
    cumulative = {}
    solvers = {}
    continuity = {}
    built_in_average = None
    for raw in path.read_text(errors="replace").splitlines():
        line = raw.strip()
        match = time_re.match(line)
        if match:
            current_time = int(match.group(1))
            solvers.setdefault(current_time, {})
            continue
        match = timing_re.match(line)
        if match and current_time is not None:
            cumulative[current_time] = {
                "execution": float(match.group(1)),
                "clock": float(match.group(2)),
            }
            continue
        match = solve_re.search(line)
        if match and current_time is not None:
            solvers[current_time][match.group(1)] = {
                "initial": float(match.group(2)),
                "final": float(match.group(3)),
                "iterations": int(match.group(4)),
            }
            continue
        match = continuity_re.search(line)
        if match and current_time is not None:
            continuity[current_time] = {
                "local": float(match.group(1)),
                "global": float(match.group(2)),
                "cumulative": float(match.group(3)),
            }
            continue
        match = average_re.search(line)
        if match:
            built_in_average = float(match.group(1))

    increments = {}
    for step in sorted(cumulative):
        if step - 1 in cumulative:
            increments[step] = {
                key: cumulative[step][key] - cumulative[step - 1][key]
                for key in ("execution", "clock")
            }

    window = [step for step in range(20, 41) if step in increments]
    return {
        "path": str(path.relative_to(ROOT)),
        "steps": sorted(cumulative),
        "built_in_average_s_per_step": built_in_average,
        "steps_20_40_execution_mean_s": mean(
            increments[step]["execution"] for step in window
        ),
        "steps_20_40_clock_mean_s": mean(
            increments[step]["clock"] for step in window
        ),
        "steps_20_40_count": len(window),
        "cumulative": cumulative,
        "increments": increments,
        "solvers": solvers,
        "continuity": continuity,
    }


def parse_coefficients(path: Path) -> dict:
    rows = []
    with path.open() as handle:
        for raw in handle:
            if raw.startswith("#") or not raw.strip():
                continue
            values = raw.split()
            rows.append((int(float(values[0])), float(values[1])))
    return {
        "path": str(path.relative_to(ROOT)),
        "rows": len(rows),
        "first_step": rows[0][0],
        "last_step": rows[-1][0],
        "cd_40": dict(rows)[40],
        "sha256": sha256(path),
    }


def parse_affinity(path: Path) -> dict:
    records = []
    with path.open(newline="") as handle:
        for row in csv.reader(handle):
            # CPU masks can contain commas (for example 0,128). The first
            # three and last three fields remain fixed.
            rank = int(row[0])
            local_rank = int(row[1])
            host = row[2]
            mask = ",".join(row[3:-3])
            cpu = int(row[-3])
            socket = int(row[-2])
            node, core = row[-1].split(":", 1)
            records.append(
                {
                    "rank": rank,
                    "local_rank": local_rank,
                    "host": host,
                    "mask": mask,
                    "cpu": cpu,
                    "socket": socket,
                    "numa": int(node),
                    "core": int(core),
                }
            )

    hosts = sorted({record["host"] for record in records})
    per_host = {}
    for host in hosts:
        subset = [record for record in records if record["host"] == host]
        per_host[host] = {
            "ranks": len(subset),
            "local_rank_min": min(record["local_rank"] for record in subset),
            "local_rank_max": max(record["local_rank"] for record in subset),
            "unique_masks": len({record["mask"] for record in subset}),
            "unique_physical_cores": len(
                {(record["socket"], record["core"]) for record in subset}
            ),
            "numa_nodes": sorted({record["numa"] for record in subset}),
            "logical_cpus_per_mask": sorted(
                {len(record["mask"].split(",")) for record in subset}
            ),
        }
    return {
        "path": str(path.relative_to(ROOT)),
        "rows": len(records),
        "rank_min": min(record["rank"] for record in records),
        "rank_max": max(record["rank"] for record in records),
        "unique_ranks": len({record["rank"] for record in records}),
        "hosts": per_host,
    }


def parse_decomposition(path: Path) -> dict:
    text = path.read_text(errors="replace")
    cells = [int(value) for value in re.findall(r"Number of cells = (\d+)", text)]
    processor_faces = [
        int(value) for value in re.findall(r"Number of processor faces = (\d+)", text)
    ]
    # The log has one per-rank value followed by a final distinct-face total.
    rank_processor_faces = processor_faces[: len(cells)]
    reported_distinct_faces = processor_faces[len(cells)]
    return {
        "path": str(path.relative_to(ROOT)),
        "ranks": len(cells),
        "cells_sum": sum(cells),
        "cells_mean": mean(cells),
        "cells_max": max(cells),
        "cells_max_over_mean": max(cells) / mean(cells),
        "processor_faces_sum_double_counted": sum(rank_processor_faces),
        "distinct_processor_faces": sum(rank_processor_faces) // 2,
        "reported_distinct_processor_faces": reported_distinct_faces,
        "face_count_internal_check": sum(rank_processor_faces) // 2
        == reported_distinct_faces,
        "max_processor_faces_on_rank": max(rank_processor_faces),
        "kahip_fast_imbalance_001": "kahipDecomp : config=fast imbalance=0.01"
        in text,
    }


def main() -> None:
    arms = {
        label: parse_solver(EVIDENCE / "logs" / f"50_simpleFoam_{label}.log")
        for label in ("A0", "A1")
    }
    coefficients = {
        label: parse_coefficients(EVIDENCE / f"coefficient-{label}.dat")
        for label in ("A0", "A1")
    }
    pair_mean = mean(
        arms[label]["steps_20_40_execution_mean_s"] for label in ("A0", "A1")
    )
    pair_difference = abs(
        arms["A1"]["steps_20_40_execution_mean_s"]
        - arms["A0"]["steps_20_40_execution_mean_s"]
    )
    summary = {
        "job": "25523028.pbs101",
        "exit_status": 0,
        "arms": arms,
        "coefficients": coefficients,
        "coefficients_byte_identical": (EVIDENCE / "coefficient-A0.dat").read_bytes()
        == (EVIDENCE / "coefficient-A1.dat").read_bytes(),
        "steps_20_40_execution_pair_mean_s": pair_mean,
        "steps_20_40_execution_absolute_difference_s": pair_difference,
        "steps_20_40_execution_relative_difference_percent": 100
        * pair_difference
        / pair_mean,
        "solver_iterations_identical": {
            field: all(
                arms["A0"]["solvers"][step][field]["iterations"]
                == arms["A1"]["solvers"][step][field]["iterations"]
                for step in range(1, 41)
            )
            for field in ("Ux", "Uy", "Uz", "p")
        },
        "solver_residual_records_identical": arms["A0"]["solvers"]
        == arms["A1"]["solvers"],
        "continuity_records_identical": arms["A0"]["continuity"]
        == arms["A1"]["continuity"],
        "affinity": parse_affinity(EVIDENCE / "rank-affinity.csv"),
        "decomposition": parse_decomposition(EVIDENCE / "logs" / "10_decomposePar.log"),
    }
    (ROOT / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")

    compact = {
        "job": summary["job"],
        "exit_status": summary["exit_status"],
        "A0_builtin_s_per_step": arms["A0"]["built_in_average_s_per_step"],
        "A1_builtin_s_per_step": arms["A1"]["built_in_average_s_per_step"],
        "A0_steps20_40_execution_s": arms["A0"]["steps_20_40_execution_mean_s"],
        "A1_steps20_40_execution_s": arms["A1"]["steps_20_40_execution_mean_s"],
        "steps20_40_relative_difference_percent": summary[
            "steps_20_40_execution_relative_difference_percent"
        ],
        "coefficients_byte_identical": summary["coefficients_byte_identical"],
        "cd_40": coefficients["A0"]["cd_40"],
        "affinity_rows": summary["affinity"]["rows"],
        "hosts": len(summary["affinity"]["hosts"]),
        "cells_sum": summary["decomposition"]["cells_sum"],
        "distinct_processor_faces": summary["decomposition"][
            "distinct_processor_faces"
        ],
    }
    (ROOT / "summary-compact.json").write_text(
        json.dumps(compact, indent=2, sort_keys=True) + "\n"
    )
    print(json.dumps(compact, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
