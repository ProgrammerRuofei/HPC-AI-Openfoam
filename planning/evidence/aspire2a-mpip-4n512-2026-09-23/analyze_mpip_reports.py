#!/usr/bin/env python3
"""Parse retained mpiP 3.5 reports without modifying the raw evidence."""

from __future__ import annotations

import csv
import re
import statistics
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parent
REPORTS = {
    "kahip": ROOT / "kahip" / "simpleFoam.512.3360713.1.mpiP",
    "scotch": ROOT / "scotch" / "simpleFoam.512.1914981.1.mpiP",
    "hierarchical": ROOT / "hierarchical" / "simpleFoam.512.2051974.1.mpiP",
}
DECOMPOSE_LOGS = {method: ROOT / method / "10_decomposePar.log" for method in REPORTS}

COLLECTIVES = {
    "Allgather", "Allgatherv", "Allreduce", "Alltoall", "Alltoallv",
    "Barrier", "Bcast", "Gather", "Gatherv", "Reduce", "Reduce_scatter",
    "Scatter", "Scatterv",
}
WAIT_TEST = {"Test", "Testall", "Testany", "Testsome", "Wait", "Waitall", "Waitany", "Waitsome"}
POINT_TO_POINT = {"Bsend", "Ibsend", "Irecv", "Irsend", "Isend", "Issend", "Recv", "Rsend", "Send", "Sendrecv", "Ssend"}


def percentile(values: list[float], fraction: float) -> float:
    values = sorted(values)
    pos = (len(values) - 1) * fraction
    lo = int(pos)
    hi = min(lo + 1, len(values) - 1)
    weight = pos - lo
    return values[lo] * (1 - weight) + values[hi] * weight


def category(name: str) -> str:
    if name in COLLECTIVES:
        return "collective"
    if name in WAIT_TEST:
        return "wait_test"
    if name in POINT_TO_POINT:
        return "point_to_point"
    return "other"


def rankdata(values: list[float]) -> list[float]:
    order = sorted(range(len(values)), key=values.__getitem__)
    ranks = [0.0] * len(values)
    start = 0
    while start < len(order):
        end = start + 1
        while end < len(order) and values[order[end]] == values[order[start]]:
            end += 1
        average_rank = (start + end - 1) / 2.0
        for index in order[start:end]:
            ranks[index] = average_rank
        start = end
    return ranks


def pearson(left: list[float], right: list[float]) -> float:
    left_mean = statistics.mean(left)
    right_mean = statistics.mean(right)
    numerator = sum((x - left_mean) * (y - right_mean) for x, y in zip(left, right))
    denominator = (
        sum((x - left_mean) ** 2 for x in left)
        * sum((y - right_mean) ** 2 for y in right)
    ) ** 0.5
    return numerator / denominator if denominator else float("nan")


def spearman(left: list[float], right: list[float]) -> float:
    return pearson(rankdata(left), rankdata(right))


def parse_decompose(path: Path, assignments: dict[int, str]):
    metrics = {
        rank: {"cells": 0, "interface_faces": 0, "neighbors": 0, "cross_node_faces": 0}
        for rank in range(512)
    }
    current = None
    seen_pairs: set[tuple[int, int]] = set()
    with path.open(errors="replace") as stream:
        for raw in stream:
            line = raw.strip()
            match = re.fullmatch(r"Processor (\d+)", line)
            if match:
                current = int(match.group(1))
                continue
            if current is None:
                continue
            match = re.fullmatch(r"Number of cells = (\d+)", line)
            if match:
                if metrics[current]["cells"] == 0:
                    metrics[current]["cells"] = int(match.group(1))
                continue
            match = re.fullmatch(r"Number of faces shared with processor (\d+) = (\d+)", line)
            if match:
                peer, faces = int(match.group(1)), int(match.group(2))
                pair = tuple(sorted((current, peer)))
                if pair not in seen_pairs:
                    seen_pairs.add(pair)
                    metrics[current]["neighbors"] += 1
                    metrics[peer]["neighbors"] += 1
                    if assignments[current] != assignments[peer]:
                        metrics[current]["cross_node_faces"] += faces
                        metrics[peer]["cross_node_faces"] += faces
                continue
            match = re.fullmatch(r"Number of processor faces = (\d+)", line)
            if match:
                if metrics[current]["interface_faces"] == 0:
                    metrics[current]["interface_faces"] = int(match.group(1))
    if len(seen_pairs) == 0 or any(row["cells"] == 0 for row in metrics.values()):
        raise ValueError(f"{path}: incomplete decomposition metrics")
    return metrics


def parse_report(path: Path):
    assignments: dict[int, str] = {}
    rank_rows: list[dict[str, float | int | str]] = []
    call_ms: defaultdict[str, float] = defaultdict(float)
    call_count: defaultdict[str, int] = defaultdict(int)
    section = None

    with path.open(errors="replace") as stream:
        for raw in stream:
            line = raw.strip()
            match = re.match(r"@ MPI Task Assignment\s+:\s+(\d+)\s+(\S+)", line)
            if match:
                assignments[int(match.group(1))] = match.group(2)
                continue
            if line.startswith("@--- MPI Time (seconds)"):
                section = "mpi_time"
                continue
            if line.startswith("@--- Callsite Time statistics"):
                section = "call_time"
                continue
            if line.startswith("@--- Callsite Message Sent statistics"):
                section = "message"
                continue
            if line.startswith("@---") and section is not None:
                section = None
                continue

            if section == "mpi_time":
                fields = line.split()
                if len(fields) == 4 and fields[0].isdigit():
                    rank = int(fields[0])
                    rank_rows.append({
                        "rank": rank,
                        "host": assignments.get(rank, "UNKNOWN"),
                        "app_time_s": float(fields[1]),
                        "mpi_time_s": float(fields[2]),
                        "mpi_percent": float(fields[3]),
                    })
                continue

            if section == "call_time":
                fields = line.split()
                # Name Site Rank Count Max Mean Min App% MPI%
                if len(fields) == 9 and fields[1].isdigit() and fields[2].isdigit():
                    name = fields[0]
                    count = int(fields[3])
                    mean_ms = float(fields[5])
                    call_ms[name] += count * mean_ms
                    call_count[name] += count

    if len(assignments) != 512 or len(rank_rows) != 512:
        raise ValueError(f"{path}: expected 512 assignments/rank rows, got {len(assignments)}/{len(rank_rows)}")

    measured_mpi_s = sum(float(row["mpi_time_s"]) for row in rank_rows)
    reconstructed_mpi_s = sum(call_ms.values()) / 1000.0
    return assignments, rank_rows, call_ms, call_count, measured_mpi_s, reconstructed_mpi_s


def main() -> None:
    call_output = ROOT / "mpip-call-type-summary.csv"
    rank_output = ROOT / "mpip-rank-summary.csv"
    overview_output = ROOT / "mpip-overview.csv"
    joined_output = ROOT / "mpip-rank-partition-joined.csv"
    correlation_output = ROOT / "mpip-partition-correlations.csv"

    overview_rows = []
    correlation_rows = []
    with call_output.open("w", newline="") as call_stream, rank_output.open("w", newline="") as rank_stream, joined_output.open("w", newline="") as joined_stream:
        call_writer = csv.writer(call_stream)
        rank_writer = csv.writer(rank_stream)
        call_writer.writerow(["method", "call", "category", "time_s", "share_of_reconstructed_mpi_time_pct", "count"])
        rank_writer.writerow(["method", "rank", "host", "app_time_s", "mpi_time_s", "mpi_percent"])
        joined_writer = csv.writer(joined_stream)
        joined_writer.writerow(["method", "rank", "host", "cells", "interface_faces", "neighbors", "cross_node_faces", "mpi_time_s", "mpi_percent"])

        for method, report in REPORTS.items():
            assignments, rank_rows, call_ms, call_count, measured_s, reconstructed_s = parse_report(report)
            partition = parse_decompose(DECOMPOSE_LOGS[method], assignments)
            for row in rank_rows:
                rank_writer.writerow([
                    method, row["rank"], row["host"], row["app_time_s"], row["mpi_time_s"], row["mpi_percent"]
                ])
                rank = int(row["rank"])
                joined_writer.writerow([
                    method, rank, row["host"], partition[rank]["cells"],
                    partition[rank]["interface_faces"], partition[rank]["neighbors"],
                    partition[rank]["cross_node_faces"], row["mpi_time_s"], row["mpi_percent"],
                ])
            for call, milliseconds in sorted(call_ms.items(), key=lambda item: item[1], reverse=True):
                call_writer.writerow([
                    method,
                    call,
                    category(call),
                    milliseconds / 1000.0,
                    100.0 * milliseconds / (reconstructed_s * 1000.0),
                    call_count[call],
                ])

            mpi_times = [float(row["mpi_time_s"]) for row in rank_rows]
            mpi_percent = [float(row["mpi_percent"]) for row in rank_rows]
            category_s: defaultdict[str, float] = defaultdict(float)
            for call, milliseconds in call_ms.items():
                category_s[category(call)] += milliseconds / 1000.0
            overview_rows.append({
                "method": method,
                "measured_rank_sum_mpi_s": measured_s,
                "reconstructed_call_sum_mpi_s": reconstructed_s,
                "reconstruction_ratio": reconstructed_s / measured_s,
                "rank_mpi_time_min_s": min(mpi_times),
                "rank_mpi_time_median_s": statistics.median(mpi_times),
                "rank_mpi_time_p90_s": percentile(mpi_times, 0.90),
                "rank_mpi_time_p95_s": percentile(mpi_times, 0.95),
                "rank_mpi_time_p99_s": percentile(mpi_times, 0.99),
                "rank_mpi_time_max_s": max(mpi_times),
                "rank_mpi_percent_median": statistics.median(mpi_percent),
                "collective_s": category_s["collective"],
                "wait_test_s": category_s["wait_test"],
                "point_to_point_s": category_s["point_to_point"],
                "other_s": category_s["other"],
                "distinct_interface_faces": sum(row["interface_faces"] for row in partition.values()) / 2,
                "distinct_cross_node_faces": sum(row["cross_node_faces"] for row in partition.values()) / 2,
            })
            mpi_by_rank = [float(row["mpi_time_s"]) for row in sorted(rank_rows, key=lambda row: int(row["rank"]))]
            for metric in ("cells", "interface_faces", "neighbors", "cross_node_faces"):
                values = [float(partition[rank][metric]) for rank in range(512)]
                correlation_rows.append({
                    "method": method,
                    "partition_metric": metric,
                    "spearman_vs_rank_mpi_time": spearman(values, mpi_by_rank),
                    "pearson_vs_rank_mpi_time": pearson(values, mpi_by_rank),
                })

    fields = list(overview_rows[0])
    with overview_output.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(overview_rows)

    with correlation_output.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(correlation_rows[0]))
        writer.writeheader()
        writer.writerows(correlation_rows)


if __name__ == "__main__":
    main()
