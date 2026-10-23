#!/usr/bin/env python3
"""Fetch only the Intel oneAPI RPM dependency closure into a user scratch cache."""
import argparse
import gzip
import hashlib
import os
from pathlib import Path
import re
import urllib.request
import xml.etree.ElementTree as ET

REPO = "https://yum.repos.intel.com/oneapi/"
EXPECTED_PRIMARY_SHA256 = "f992bcd2a7ecdd2ed7a6b1b718faad925bcf9f37c906625f51b54b73742c9700"
REPOMD_NS = {"r": "http://linux.duke.edu/metadata/repo"}
PKG_NS = {
    "c": "http://linux.duke.edu/metadata/common",
    "r": "http://linux.duke.edu/metadata/rpm",
}
ROOTS = (
    "intel-oneapi-compiler-dpcpp-cpp-2026.2",
    "intel-oneapi-mpi-devel-2021.19",
)


def get(url):
    with urllib.request.urlopen(url, timeout=120) as response:
        return response.read()


def numbers(version):
    return tuple(map(int, re.findall(r"\d+", version)))


def file_sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        while data := source.read(4 * 1024 * 1024):
            digest.update(data)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dest", required=True, type=Path)
    parser.add_argument("--plan-only", action="store_true")
    args = parser.parse_args()
    repomd = ET.fromstring(get(REPO + "repodata/repomd.xml"))
    primary = next(x for x in repomd.findall("r:data", REPOMD_NS) if x.attrib["type"] == "primary")
    href = primary.find("r:location", REPOMD_NS).attrib["href"]
    expected = primary.find("r:checksum", REPOMD_NS).text
    assert primary.find("r:checksum", REPOMD_NS).attrib["type"] == "sha256"
    if expected != EXPECTED_PRIMARY_SHA256:
        raise ValueError("Intel repository metadata changed; review before downloading")
    assert href.startswith("repodata/") and ".." not in href
    compressed = get(REPO + href)
    assert hashlib.sha256(compressed).hexdigest() == expected, "repo metadata checksum mismatch"
    index = {}
    for package in ET.fromstring(gzip.decompress(compressed)).findall("c:package", PKG_NS):
        name = package.findtext("c:name", namespaces=PKG_NS)
        if not name.startswith("intel-oneapi-"):
            continue
        version = package.find("c:version", PKG_NS).attrib["ver"]
        checksum = package.find("c:checksum", PKG_NS)
        assert checksum.attrib["type"] == "sha256"
        filename = package.find("c:location", PKG_NS).attrib["href"]
        if not re.fullmatch(r"intel-oneapi-[A-Za-z0-9_.+-]+\.rpm", filename):
            raise ValueError(f"unexpected RPM path: {filename}")
        requires = [entry.attrib for entry in package.findall("c:format/r:requires/r:entry", PKG_NS)
                    if entry.attrib.get("name", "").startswith("intel-oneapi-")]
        record = (name, version, package.find("c:size", PKG_NS).attrib["package"], checksum.text, filename, requires)
        index.setdefault(name, []).append(record)

    selected = {}
    pending = list(ROOTS)
    while pending:
        name = pending.pop()
        if name in selected:
            continue
        candidates = index.get(name, [])
        if not candidates:
            raise ValueError(f"unresolved Intel package: {name}")
        chosen = max(candidates, key=lambda row: numbers(row[1]))
        if name.endswith("-2026.2") and not chosen[1].startswith("2026.2"):
            raise ValueError(f"wrong compiler release: {chosen}")
        if name.endswith("-2021.19") and not chosen[1].startswith("2021.19"):
            raise ValueError(f"wrong MPI release: {chosen}")
        selected[name] = chosen
        for requirement in chosen[5]:
            dep = requirement["name"]
            if requirement.get("flags") in ("GE", "GT") and dep in index:
                newest = max(index[dep], key=lambda row: numbers(row[1]))
                if numbers(newest[1]) < numbers(requirement.get("ver", "0")):
                    raise ValueError(f"dependency version unavailable: {requirement}")
            pending.append(dep)

    total = sum(int(row[2]) for row in selected.values())
    if args.plan_only:
        for name, version, size, _, _, _ in sorted(selected.values()):
            print(f"{name}\t{version}\t{size}")
        print(f"INTEL_RPM_PLAN packages={len(selected)} bytes={total}")
        return
    args.dest.mkdir(parents=True, exist_ok=True)
    manifest = args.dest / "manifest.tsv"
    lines = []
    for name, version, size, digest, filename, _ in sorted(selected.values()):
        target = args.dest / filename
        if target.exists() and file_sha256(target) != digest:
            raise ValueError(f"existing RPM checksum mismatch: {target}")
        if not target.exists():
            print(f"downloading {name} {version} {size} bytes", flush=True)
            temporary = target.with_suffix(".rpm.part")
            with urllib.request.urlopen(REPO + filename, timeout=120) as source, temporary.open("wb") as output:
                while data := source.read(4 * 1024 * 1024):
                    output.write(data)
            if file_sha256(temporary) != digest:
                raise ValueError(f"downloaded RPM checksum mismatch: {filename}")
            os.replace(temporary, target)
        if target.stat().st_size != int(size):
            raise ValueError(f"RPM size mismatch: {filename}")
        lines.append("\t".join((name, version, size, digest, filename)))
    temporary = manifest.with_suffix(".tsv.part")
    temporary.write_text("\n".join(lines) + "\n")
    os.replace(temporary, manifest)
    print(f"INTEL_RPM_CACHE_PASS packages={len(lines)} bytes={total} manifest={manifest}")


if __name__ == "__main__":
    main()
