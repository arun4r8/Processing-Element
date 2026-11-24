# 6-sta

Signoff static timing analysis with Tempus. Times the routed design at tt with the real wire parasitics. This is the timing result that counts. Tempus only checks the design; to fix a failure, change an earlier stage and rerun from there.

```bash
./6-sta/run-sta.sh
```

## What you fill in

Nothing. Read the reports, and fix any failures in earlier stages.

## sta.tcl

### Design import

- `read_mmmc` loads the timing setup from `0-inputs/mmmc.tcl`, with the SDC from `5-route`, where the clock arrives through the real clock tree.
- `read_netlist` and `init_design` load the final netlist from `5-route`.
- `read_spef` loads the routed parasitics, so the delays come from the real wires.
- `timing_analysis_type ocv` and `timing_analysis_cppr both` are the same as in place and route.
- `delaycal_enable_si true` turns on crosstalk: a switching neighbor wire can speed up or slow down a signal through the coupling capacitance in the SPEF.

### Reports

| Report | What it shows |
|---|---|
| `setup.rpt` | The 10 worst setup paths. Setup fails when data arrives too late for the next clock edge. |
| `hold.rpt` | The 10 worst hold paths. Hold fails when data changes too soon after the clock edge. |
| `summary.rpt` | WNS, TNS and the number of failing setup and hold paths, split by path type: input to register, register to register, register to output, input to output. |
| `all_violators.rpt` | Every failing path and design rule (max transition, max capacitance). |

A path passes when its slack is 0 or more.
