# 8-gds

Writes the final layout as a GDS file with Innovus. GDS is the format that layout checks (DRC, LVS) and the fab read. It also scores the finished design with `ppa.tcl`, so run it after `6-sta` and `7-emir`.

```bash
./8-gds/run-gds.sh
```

Read `reports/pe_ppa_final.rpt` for your final FOM.

## What you fill in

Nothing.

## gds.tcl

`read_db` loads the routed database from `5-route`.

### Stream out

`write_stream` writes the layout:
- `-map_file` gives the GDS layer and datatype number for each LEF layer, for example met1 → 68/20. The map is the one that comes with the PDK.
- `-merge` copies in the layout of each standard cell. The Innovus database only has each cell's outline and pins, not the transistors inside.
- `-unit 1000` writes coordinates in nm (1000 per µm).
- `-mode all` writes everything: cells, signal wires, the power grid and pins.

### Final PPA

Scores the finished design with the same formula as synthesis, using numbers from signoff:
- timing: WNS, TNS and the number of failing paths for setup at the tt view, from the Standard group in `6-sta/reports/summary.rpt`. The Async group (recovery and removal checks on the reset) is not scored, as in synthesis;
- power: total, internal, switching and leakage power from `7-emir/reports/power/power.rpt`;
- area: the area of the logic cells in the routed design. Fillers, well taps and end caps are left out, so the number compares with the synthesis cell area and the area limit;
- frequency: the clock period of the design.

`ppa_report` in `ppa.tcl` reads Genus report text, so the script first writes these numbers in that format, to `reports/final_qor.rpt` and `reports/final_power.rpt`. `ppa_report` then writes `reports/pe_ppa_final.rpt`.

The final FOM is usually lower than the synthesis one: place and route add clock buffers and other cells, and power and timing now include the real wires.

### Outputs

`pe.gds` is the complete layout: your routed design, with the full layout of every standard cell inside it. Open it in Virtuoso or KLayout to view it.
