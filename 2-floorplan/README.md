# 2-floorplan

Floorplan with Innovus. Sets the size of the chip, places the I/O pins on its edges, adds the well tap and end cap cells, and builds the power grid. No logic cells are placed yet.

```bash
./2-floorplan/run-floorplan.sh
```

Check `reports/pg_connectivity.rpt`. It should report no problems, or the power grid is not connected.

## What you fill in

In `floorplan.tcl`:
- `create_floorplan -core_size`: the core width and height, then the margin from core to die on each side.
- `edit_pin`: the `-start` and `-spacing` of each pin group, so the pins fit your die.
- `XMinCore`, `XMaxCore`, `YMinCore`, `YMaxCore` and `power_metal_width`.
- `add_rings` and `add_stripes`.

In `SetPinGroup.tcl`:
- `WeightIn`, `InputIn`, `WeightOut`, `InputOut` and `CtrlOut`.

## floorplan.tcl

### Design import

- `read_mmmc` loads the timing setup from `0-inputs/mmmc.tcl`.
- `read_physical -lef` loads the technology LEF (metal layers, vias, design rules) and the cell LEF (the size and pin shapes of each cell).
- `read_netlist` loads the netlist from synthesis.
- `init_power_nets` and `init_ground_nets` name the supply nets `VDD` and `VSS`.
- `init_design` builds the design from all of the above.
- `timing_analysis_type ocv` turns on on-chip variation: launch and capture paths can be timed with different derates. Post-route timing needs it. `timing_analysis_cppr both` removes the pessimism this adds on the part of the clock path that launch and capture share. Both settings are saved in the database for later stages.

### Global nets

Connects the supply pins of every cell to `VDD` and `VSS`. Each SKY130 cell has four supply pins:
- `VPWR` and `VGND` are the power and ground rails.
- `VPB` and `VNB` are the body (well) pins: the PMOS n-well and the NMOS p-substrate.

The rules are saved in the database, and Innovus applies them to every cell it adds in later stages.

### Core

`create_floorplan -site unithd -core_size w h left bottom right top`:
- `unithd` is the row site of the hd library; every cell is a multiple of it.
- `w` and `h` are the core size in µm, the area where cells go. Your cell area from synthesis divided by the core area is the utilization.
- `left bottom right top` are the margins between core and die. The power ring goes there.

### Pins

- `SetPinGroup.tcl` sets the list of pins in each group.
- `assign_pins_edit_in_batch true` makes Innovus place all the pins in one pass.
- `edit_pin` places one group:
  - `-side left` or `-side right` picks the die edge.
  - `-layer met3` puts the pins on met3, which runs horizontal, so it can reach the left and right edges.
  - `-spread_type start -start {x y}` starts the group at `y` µm. On the left and right edges only `y` is used.
  - `-spacing` is the distance between pins. Pins snap to the nearest met3 track, so the spacing you get may differ a little.
  - `-spread_direction clockwise` runs up the left edge and down the right edge.
  - `-fixed_pin 1` stops later stages from moving them.

### Well taps and end caps

- End caps (`decap_3`) go at both ends of every cell row, so the row edges meet the layout rules.
- Well taps (`tapvpwrvgnd_1`) tie the n-well to `VDD` and the substrate to `VSS`. Without them a cell's well can float and latch up. `-cell_interval 26` with `-checker_board` puts one every 26 µm per row, offset between rows.

### Power Grid

- `XMinCore` to `YMaxCore` are the core edges in µm. They must match your `create_floorplan`.
- `power_metal_*` are the start, stop and width for the stripes, 2 µm inside the core.
- `add_rings` puts a `VDD` and `VSS` ring around the core, in the margin.
- `route_special -connect core_pin` draws the met1 followpins: the `VPWR` and `VGND` rails along each cell row, connected to the ring.
- `add_stripes` adds straps across the core that carry current from the ring to the rails.

SKY130 metal goes up to met5. Even layers (met2, met4) run vertical and odd layers (met1, met3, met5) horizontal. met4 needs at least 0.3 µm width and spacing, met5 1.6 µm. Below that the vias between layers fail and the grid comes out disconnected.

### Outputs

`pe.floorplan.db` is an Innovus database: a folder that holds the whole design state, including the netlist, the floorplan, the pins, the power grid, the corners and the settings. Place reads it with `read_db`, so each stage continues where the previous one stopped.

## SetPinGroup.tcl

### Pin groups

`bus` makes the list of pins for a bus: `bus pe_psum_in 16` returns `pe_psum_in[0]` to `pe_psum_in[15]`.

### Inputs and Outputs

Each line sets one group for an `edit_pin` in `floorplan.tcl`. The control pins are listed by name; the 16-bit buses use `bus`.
