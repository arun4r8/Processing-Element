# Running this flow on the chamber (gsclib045) — and still on the LRC (sky130)

Nathan's template, unchanged in shape: same nine stage folders, same run
scripts, same `logs/ outputs/ reports/` per stage, same `ppa.tcl` scoring.
What changed: every PDK-specific name now lives in `0-inputs/pdk.tcl`, picked by
`0-inputs/env.sh` from where you are, and the blanks (`...`) are filled in.

| | LRC (mario) | chamber (sj24) |
|---|---|---|
| detect | `module load cadence` works | `$GSCLIB` set by `setup.sh` |
| library | sky130_fd_sc_hd, tt corner | gsclib045, slow for setup / fast for hold |
| site / supply | `unithd`, 1.8 V, VPWR/VGND/VPB/VNB | `CoreSite`, 1.0 V, VDD/VSS |
| pins | met3 (H) / met2 (V) | Metal3 (H) / Metal2 (V), from `setup.sh` |
| ring / stripes | met5+met4 / met4 | Metal5+Metal6 / Metal6 |
| taps, endcaps | tapvpwrvgnd_1, decap_3 | none needed |
| QRC, EM | provided | none exported yet → 7-emir stops after the power report |
| GDS | sky130A.map | `$STREAM_MAP` + `$STDCELLS_GDS` from `setup.sh` |

Force one with `PE_PDK=sky130 ./rtl2gds.sh` or `PE_PDK=gsclib045 ...`.

## Chamber quickstart

```bash
srun -c 4 --mem=16G --pty bash            # compute node; licenses don't check out on login nodes
source ~/pe-apprentice/setup.sh           # must print GSCLIB <path>, not MISSING
cd ~/pe-apprentice                         # this folder, with your fixed rtl/pe.sv in 0-inputs/rtl/

./check-pdk                                # every cell name should say ok
./0-inputs/run-sim-chamber.sh              # smoke + VCD (run-sim.sh has LRC-only module lines)
./1-syn/run-syn.sh
./2-floorplan/run-floorplan.sh
./3-place/run-place.sh
./4-cts/run-cts.sh
./5-route/run-route.sh
./6-sta/run-sta.sh
./7-emir/run-emir.sh                       # needs a voltus module; skip if `command -v voltus` is empty
./8-gds/run-gds.sh                         # falls back to 5-route power if 7-emir didn't run
```

Or `./rtl2gds.sh` for all of it once each stage has run clean once.

Put the week 5 two-stage `pe.sv` (with the two `pe_enabled` gates) in
`0-inputs/rtl/pe.sv` first — the template ships the one-stage reference PE.

To look at a stage in the GUI: `innovus -stylus` then `read_db 2-floorplan/outputs/pe.floorplan.db`.

## What's filled in, and why

- **Core size** (`2-floorplan`): computed from the synthesized cell area at
  `util 0.60`, snapped to whole rows/sites, square, 10 µm margin. Change `util`.
- **Pins**: by dataflow (west→east: input/valid/switch; north→south: psum/weight)
  so PEs tile into an array. `set pin_style leftright` in `SetPinGroup.tcl`
  gives the template's inputs-left / outputs-right layout.
- **Power grid**: ring in the margin, vertical stripes every 20 µm (30 on sky130),
  M1 followpins. Widths/spacings per PDK in `pdk.tcl`.
- **Place**: `place_opt_design` + `opt_design -pre_cts` instead of bare
  `place_design`, so setup is fixed during placement.
- **CTS NDRs**: trunk 2×W/2×S, leaf 1×W/2×S; propagated clocks after
  `ccopt_design`; post-CTS setup then hold.
- **Route**: timing- and SI-driven; post-route setup+hold opt before fillers.
- **STA**: propagated clocks, two views (setup slow / hold fast on gsclib045).
- **Synthesis**: high effort, flattened. `PE_CLOCK_GATING=1` enables ICG
  insertion once you confirm the lib has a clock-gate cell.

## Clock period

`0-inputs/pe.sdc` ships at 8.0 ns. Week 3 closed 3.0 ns on sky130; on gsclib045
start at 2.0 ns and bracket. `run-sim*.sh` reads the same number for the VCD.

## FOM caveat

`ppa.tcl`'s baseline (FOM 367-ish, 125 MHz, sky130 hd) is a sky130 number. A
gsclib045 FOM will be larger just from the process, so compare against your own
sky130 run, not the baseline, if the scoring is meant to be cross-apprentice.

## Not verified here

These scripts were written without a Cadence install. Structure and Tcl balance
are checked; option spellings for Innovus 21.19 / Tempus / Voltus Stylus are
from the 21.x references in `refs/`. If a `set_db` attribute is rejected the log
names it; `get_db -h <prefix>*` lists the valid ones.
