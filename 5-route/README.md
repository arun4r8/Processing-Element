# 5-route

Routing with Innovus. Fills the gaps between cells, draws every signal wire in metal, then extracts the resistance and capacitance of those wires. It writes the files that signoff (`6-sta`, `7-emir`) and `8-gds` read.

```bash
./5-route/run-route.sh
```

Check `reports/drc.rpt` and `reports/connectivity.rpt`. Both should be clean.

## What you fill in

Nothing is required. The two optimization blocks are where your routing settings and post-route fixes go.

## route.tcl

`read_db` loads the CTS database from `4-cts`.

### Optimizations

Empty. Settings here apply before routing, so they change how the nets are routed.

### Fillers

`add_fillers` fills every empty site in the cell rows with `fill` cells, from 8 sites wide down to 1. Fillers keep the wells and the power rails continuous along each row; gaps would break the layout rules. They go in before routing, so the router works around them.

### Route

- `route_design` routes every signal net. Global routing picks a rough path for each net, then detailed routing draws the exact wires and vias on the metal tracks.
- `extract_rc_engine post_route` makes timing use the resistance and capacitance of the real wires from here on, not the estimates used before routing.

### Post-route optimization (optional)

Empty. Timing is now based on the real wires. This is where to fix timing problems that show up after routing.

### Outputs

- `pe.route.db`: the routed database. `7-emir` and `8-gds` read it.
- `pe.v`: the final netlist. Compared with the synthesis netlist, it also has the clock buffers, tie cells and any cells that optimization added. `6-sta` reads it.
- `pe.sdc`: the constraints as Innovus has them now. The clock is set as propagated: it arrives through the real clock tree, not ideally as in synthesis. `6-sta` reads it.
- `pe.spef`: the parasitics. SPEF (Standard Parasitic Exchange Format) lists the resistance and capacitance of every routed net, extracted from the wire shapes with the QRC tech file. It also has the coupling capacitance between neighboring wires, which STA uses for crosstalk. It is written for `rc_nom`, the one RC corner in `mmmc.tcl`. `6-sta` and `7-emir` read it, so their delays come from the real wires.
