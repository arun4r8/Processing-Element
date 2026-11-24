# PE PPA challenge

## Setup

Write your PE in `0-inputs/rtl/pe.sv`. The module must be named `pe` and have the ports that `0-inputs/tb/pe_smoke_tb.sv` connects to. You can use the blocks in `0-inputs/rtl/fxp.sv`.

## Flow

RTL to signoff on SKY130 hd with Cadence tools. Each stage is a folder with one run script. Run the stages in order on the UT ECE lab hosts:

```bash
./0-inputs/run-sim.sh
./1-syn/run-syn.sh
./2-floorplan/run-floorplan.sh
./3-place/run-place.sh
./4-cts/run-cts.sh
./5-route/run-route.sh
./6-sta/run-sta.sh
./7-emir/run-emir.sh
./8-gds/run-gds.sh
```

Or run them all in order with:

```bash
./rtl2gds.sh
```

It stops if a run script exits with an error. A tool can hit an error in its script and still exit cleanly, so check each stage's logs and reports too.

| Stage | Tool | Reads | Writes to `outputs/` |
|---|---|---|---|
| `0-inputs` | Xcelium | `rtl/`, `tb/`, `pe.sdc` | `pe.vcd` (switching activity) |
| `1-syn` | Genus | `0-inputs` | `pe.v`, `pe.sdc` |
| `2-floorplan` | Innovus | `1-syn` | `pe.floorplan.db` |
| `3-place` | Innovus | `2-floorplan` | `pe.place.db` |
| `4-cts` | Innovus | `3-place` | `pe.cts.db` |
| `5-route` | Innovus | `4-cts` | `pe.route.db`, `pe.v`, `pe.spef` |
| `6-sta` | Tempus | `5-route` | — (signoff timing) |
| `7-emir` | Voltus | `5-route`, `0-inputs` | — (signoff power, IR drop, EM) |
| `8-gds` | Innovus | `5-route` | `pe.gds` (layout with the standard cells merged in) |

Each stage has a `README.md` that explains what it does, what you fill in, and each block of its script. Each stage also has the same layout:

```
<stage>/
  run-<stage>.sh   run script
  <stage>.tcl      the tool script; edit this
  logs/            tool logs and scratch
  outputs/         what the next stage reads
  reports/         what you read
```

A run script deletes its stage's `logs/`, `outputs/` and `reports/` before it starts, so a rerun replaces the last run. If you change a stage, rerun every stage after it.

`0-inputs` also holds the shared setup: `pe.sdc` (constraints), `filelist.f`, `ppa.tcl` (scoring) and `mmmc.tcl`, the timing setup that place and route and signoff use. Every stage times at one corner, tt, the same library synthesis uses. `pdk/sky130` links to the PDK. `refs/` has the Genus, Innovus, Tempus and Voltus manuals and links to the SKY130 documentation. `7-emir/em.models` holds the EM limits from the SKY130 tech LEF.

## The scripts

The scripts are plain on purpose. They run each step with the tool defaults and do no optimization. With the reference PE, the routed design fails setup in `6-sta`. Read the reports, find out why, and change the scripts to fix it.

## Scoring

Synthesis writes the PPA report to `1-syn/reports/pe_ppa.rpt`. After signoff, `8-gds` scores the finished design the same way, with timing from `6-sta` and power from `7-emir`, in `8-gds/reports/pe_ppa_final.rpt`.

```
FOM = perf³ / (√power × area)
```

- perf is the clock frequency in MHz
- power is total power in mW, as reported by Genus
- area is cell area in µm²

Your FOM is 0 if timing fails (any negative slack) or if cell area is over 30,000 µm².

## Rules

Change the flow to get the highest FOM you can. You can change anything except these files:

- `0-inputs/run-sim.sh` and `0-inputs/tb/pe_activity_tb.sv` (activity generation)
- `0-inputs/tb/pe_smoke_tb.sv` (smoke test)
- `0-inputs/ppa.tcl` (scoring)

Your design has to pass the smoke test (`0-inputs/logs/smoke.log`).
