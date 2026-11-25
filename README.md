# Processing Element — RTL-to-GDS on SKY130

A 16-bit fixed-point multiply-accumulate processing element (one cell of a
systolic array) taken from RTL through a full Cadence physical-design flow and
signed off on the SkyWater 130 nm HD library.

**Result (signoff):** 317 MHz (3.15 ns), 11,198 µm² cell area, 5.32 mW,
+43 ps setup margin in Tempus with SI, hold clean, DRC/connectivity/antenna
clean, GDS written. FOM 6.0× the course baseline. Fully reproducible from
`./rtl2gds.sh` with no hand ECO.

## What's here

| Stage | Tool | What I did |
|---|---|---|
| `0-inputs` | Xcelium | 2-stage pipelined PE RTL (`rtl/pe.sv`), weight double-buffering, smoke + activity testbenches |
| `1-syn` | Genus | **Physical-aware synthesis** (`psyn.tcl`): reads the floorplan DEF, trial-places and global-routes inside Genus, retimes the multiplier against extracted RC. `syn.tcl` is the wire-load version used to bootstrap the first floorplan |
| `2-floorplan` | Innovus | 135×135 µm core, pin planning, met4/met5 power mesh (rings + 4×4 strap grid), well taps, endcaps; exports the DEF that physical synthesis reads |
| `3-place` | Innovus | Placement + pre-CTS optimization (fixed a 111-fanout reset net) |
| `4-cts` | Innovus | CCOpt clock tree with 2× width/spacing NDRs on trunk and leaf |
| `5-route` | Innovus | Timing-driven detailed routing, post-route opt, hand ECOs on the last violating paths |
| `6-sta` | Tempus | Signoff STA with SI |
| `7-emir` | Voltus | Signoff power and IR drop |
| `8-gds` | Innovus | Stream-out with standard cells merged |

Every stage keeps its `reports/` and `outputs/` so the result can be inspected
without rerunning the tools. `TEMPLATE_README.md` is the original course
template this was built on.

## Things that mattered

- **Retiming vs. real wires — the central problem.** Genus balances retimed
  pipeline stages to ~0 ps of slack against whatever wire model it has. With
  the default wire-load model that estimate is ~150 ps optimistic on this
  design, so every netlist failed post-route by 20–100 ps regardless of clock
  period: relax the clock and retiming just re-balances to zero again. Pinning
  registers, over-constraining synthesis, and hand ECOs all moved the failure
  around without removing it. The fix was physical-aware synthesis: feed Genus
  the floorplan DEF and QRC tech file, run `syn_generic/syn_map -physical`,
  and it retimes against a trial route of the real floorplan. Genus reported
  0 ps; post-route came in at +50 ps. Same area, 20 % less power, and a flow
  that reproduces without intervention.
- **Scan flops by default.** Genus mapped ~7 % of registers to scan-mux
  flops with no DFT in the design; Innovus choked on the missing scan chain.
  `use_scan_seqs_for_non_dft false` — smaller, faster, and the warning
  disappears.
- **Each P&R stage gets its own `opt_design`.** Placement exposes wire
  length, CTS exposes skew, routing exposes parasitics; each one gets an
  optimization pass with the new information. Post-route runs twice with a
  +50 ps target: the optimizer stops early on the first call, and the second
  picks up where it left off.
- **Hand ECOs don't survive on a 65 %-dense design.** Every in-place flop or
  gate upsize I tried pushed neighbours, re-routed their nets, and cost more
  on the I/O paths than it gained on the target. ECO is for a few ps on a
  stable netlist; it is not a substitute for fixing the estimate upstream.
- **GUI vs. batch.** Innovus 21.18 in GUI mode corrupts internal state on
  `check_place`/`write_db` (Tcl `true` where an int is expected). All flow
  commands run `-no_gui`; the GUI is a viewer only.

## Flow order

Physical synthesis needs a floorplan, and the floorplan needs a netlist, so
the first pass bootstraps:

```
1-syn/run-syn.sh  →  2-floorplan  (writes pe.floorplan.def)
1-syn/run-psyn.sh →  2-floorplan  →  3-place  →  4-cts  →  5-route  →  6-sta  →  7-emir  →  8-gds
```

## Running it

Requires Cadence Genus/Innovus/Tempus/Voltus/Xcelium and the SKY130 PDK
(`pdk/sky130` is expected to point at it). `./rtl2gds.sh` runs all nine stages.
