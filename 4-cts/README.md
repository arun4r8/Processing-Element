# 4-cts

Clock tree synthesis with Innovus. Until now the clock reached every flop at the same instant (an ideal clock). CTS builds a real tree of clock buffers from the `clk` pin to every flop, aiming for the clock to arrive at about the same time everywhere.

```bash
./4-cts/run-cts.sh
```

## What you fill in

- The `...` blanks in the `NDR` block.
- Optional: the two optimization blocks.

## cts.tcl

`read_db` loads the placed database from `3-place`.

### Optimizations

Empty. Settings here apply before the clock tree is built.

### NDR

A non-default rule (NDR) routes the clock nets with wider wires and more spacing than signal nets. Wider wires have less resistance, and more spacing means less coupling to nearby signals, so clock delay is lower and more predictable.

The clock tree has two parts:
- trunk: from the clock root down to the last level of buffers;
- leaf: from those buffers to the flops.

For each part:
- `create_route_rule` sets the NDR:
  - `-width_multiplier {met1:met5 N}` makes wires N times the minimum width on met1 to met5;
  - `-spacing_multiplier` does the same for spacing.
  - Both values must be greater than 1. For a part that should use normal wires, leave `-route_rule` off its route type.
- `create_route_type` pairs the rule with the layers to route on, from `-bottom_preferred_layer` to `-top_preferred_layer`.

`cts_route_type_trunk` and `cts_route_type_leaf` tell CTS which route type to use for each part.

### CTS

- `cts_buffer_cells` and `cts_inverter_cells` limit the clock tree to the clock buffers and inverters, which have equal rise and fall delays.
- `ccopt_design` builds the clock tree. It also optimizes the datapath while it does (CCOpt is clock concurrent optimization), so logic cells can be resized or added.

### Post-CTS optimization (optional)

Empty. With the real clock in place, hold timing can be checked for the first time, so this is where to fix timing problems that show up after CTS.

### Outputs

`pe.cts.db`, the database with the clock tree. Route reads it.
