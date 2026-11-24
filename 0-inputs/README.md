# 0-inputs

The design and the setup every later stage shares: the RTL, the testbenches, the clock and I/O constraints, the timing setup and the scoring script. `run-sim.sh` runs two simulations. One checks that your PE works. The other records how often each signal switches, which synthesis and power analysis use to estimate power.

```bash
./0-inputs/run-sim.sh
```

## What you fill in

- `rtl/pe.sv`: your PE. The module must be named `pe` and have the ports that `tb/pe_smoke_tb.sv` connects to. You can use the blocks in `rtl/fxp.sv`.
- `pe.sdc`: change `clock_period` to set the frequency you are aiming for.
- `filelist.f`: add any new RTL files. Synthesis reads its files from `1-syn/syn.tcl`, so add them there too.

Do not change `run-sim.sh`, `tb/` or `ppa.tcl`.

## run-sim.sh

### Simulation: smoke test and activity VCD

- Reads `clock_period` from `pe.sdc`, so the activity simulation runs at the same clock period as the design.
- The first `xrun` runs `pe_smoke_tb`, which drives known values into the PE and checks the outputs. It passes if `logs/smoke.log` says `SMOKE TEST PASSED`.
- The second `xrun` runs `pe_activity_tb`, which drives random data and records every signal change in `outputs/pe.vcd`.

### Output: pe.vcd

A VCD (value change dump) is a list of every time each signal in the PE changes value. Genus and Voltus read it to get a toggle rate for each net. Power depends on how often nets switch, so this gives a more realistic power number than a guessed default rate.

## pe.sdc

The Synopsys Design Constraints file: the timing the design has to meet.

### Clock

- `create_clock` defines `clk` with a period of `clock_period` in ns. 8.0 ns is 125 MHz.
- `set_clock_uncertainty` takes 5% of the period off the timing budget, for clock jitter and skew that the tools cannot see.

### I/O

- `set_input_delay` and `set_output_delay` assume 20% of the period is used outside the PE, so inputs arrive late and outputs must leave early.
- `set_driving_cell` treats each input as driven by a `buf_2` cell.
- `set_load` puts a 0.01 pF load on every output.

## mmmc.tcl

Multi-mode multi-corner (MMMC) setup: which library, parasitics and constraints to time with. Floorplan reads it, and the setup is saved in the database for place, CTS and route. STA reads it again.

A real chip is timed at several process corners, for example slow transistors for setup and fast ones for hold. This flow uses one, tt (typical transistors, 25 °C, 1.80 V), the same library synthesis uses.

### Corners

- `create_library_set` names the standard cell library.
- `create_timing_condition` wraps the library set.
- `create_rc_corner` points to the QRC tech file, which gives the resistance and capacitance of the metal layers.
- `create_delay_corner` pairs the timing condition with the RC corner.
- `create_constraint_mode` points to the SDC.
- `create_analysis_view` combines the delay corner with the constraints into a view the tools can time.
- `set_analysis_view` checks both setup and hold in that view.
