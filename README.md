# Processing Element — RTL-to-GDS on SKY130

A 16-bit fixed-point multiply-accumulate processing element (one cell of a
systolic array) taken from RTL through a full Cadence physical-design flow and
signed off on the SkyWater 130 nm HD library.

**Result (signoff):** 322 MHz (3.1 ns), 11,650 µm² cell area, 6.64 mW,
setup/hold clean in Tempus, DRC/connectivity/antenna clean, GDS written.
FOM 5.4× the course baseline.

## What's here

| Stage | Tool | What I did |
|---|---|---|
| `0-inputs` | Xcelium | 2-stage pipelined PE RTL (`rtl/pe.sv`), weight double-buffering, smoke + activity testbenches |
| `1-syn` | Genus | Retiming across the multiplier, clock-gating, over-constrained synthesis so post-route timing survives real wires |
| `2-floorplan` | Innovus | 135×135 µm core, pin planning, met4/met5 power mesh (rings + 4×4 strap grid), well taps, endcaps |
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

- **Retiming vs. real wires.** Genus balances retimed stages to ~0 ps of
  slack against its wire-load model; routed wires then cost ~150 ps and the
  design fails. Pinning the output register just moved the failure to the
  input side. The fix that worked: synthesize with 0.30 ns of extra clock
  uncertainty so the balance has headroom, then let the real constraint
  apply in P&R.
- **Scan flops by default.** Genus mapped ~7 % of registers to scan-mux
  flops with no DFT in the design; Innovus choked on the missing scan chain.
  `use_scan_seqs_for_non_dft false` — smaller, faster, and the warning
  disappears.
- **Each P&R stage gets its own `opt_design`.** Placement exposes wire
  length, CTS exposes skew, routing exposes parasitics; each one gets an
  optimization pass with the new information. The final 8 ps was closed with
  targeted `eco_update_cell` resizes on the critical path's weakest cells.
- **GUI vs. batch.** Innovus 21.18 in GUI mode corrupts internal state on
  `check_place`/`write_db` (Tcl `true` where an int is expected). All flow
  commands run `-no_gui`; the GUI is a viewer only.

## Current iteration

A 4×4 met4/met5 power mesh replaced the original single-direction straps to
improve IR drop. The re-routed design closes reg2reg timing but is 22 ps short
on the register-to-output paths; closure is in progress (the `5-route` reports
reflect this run, the `6-sta`/`7-emir`/`8-gds` reports are from the signed-off
run above). Next: move the clock pin to the flop centroid and physical-aware
synthesis (`syn_opt -physical`) to remove the uncertainty margin hack.

## Running it

Requires Cadence Genus/Innovus/Tempus/Voltus/Xcelium and the SKY130 PDK
(`pdk/sky130` is expected to point at it). `./rtl2gds.sh` runs all nine stages.
