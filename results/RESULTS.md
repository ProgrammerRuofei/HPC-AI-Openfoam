# Results Report

## Phase 0 Gadi four-node controlled repeats

`metrics.csv` records R1–R4 for the frozen OpenFOAM v2512, GCC 8.5.0, Open
MPI 4.1.7, 4-node/192-rank configuration.  All runs reached Time 150 and
exited zero.  R4 is valid with a documented missing expected PBS-stdout
artifact; its provenance and solver logs remain available, and no repair was
performed.

| Attempt | ClockTime (s) | ExecutionTime (s) | Mean timestep (s) | PBS walltime | Status |
| --- | ---: | ---: | ---: | ---: | --- |
| r1 | 802 | 781.85 | 5.136668 | 17m54s | Valid controlled repeat |
| r2 | 1045 | 1025.47 | 6.842763 | 21m52s | Valid controlled repeat; anomalous performance retained |
| r3 | 793 | 773.28 | 5.152651 | 17m48s | Valid controlled repeat |
| r4 | 790 | 770.84 | 5.129230 | 17m40s | Valid with documented artifact anomaly |

The reportable representative metric is the all-valid-repeat ClockTime median,
797.5 s.  This report does not select the fastest run or attribute the R2
slowdown to a particular system cause.  See `phase0/README.md` for evidence,
validity classification, and repeatability statistics.
