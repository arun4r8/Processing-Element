# 3-place

Placement with Innovus. Puts every standard cell from the netlist into a legal spot in the cell rows, and adds tie cells.

```bash
./3-place/run-place.sh
```

## What you fill in

Nothing is required. The two optimization blocks are where your placement settings and post-place fixes go. See `refs/innovus_stylus_user_guide.pdf`.

## place.tcl

`read_db` loads the floorplan database from `2-floorplan`.

### Optimizations

Empty. Settings here apply before placement, so they change how the cells are placed.

### Place

- `place_design` places the cells. It spreads them out to keep wires short and avoid crowded areas, then legalizes them: every cell on a row site, with no overlaps.
- `add_tieoffs` adds `conb_1` tie cells. An input tied to a constant 0 or 1 must connect to a tie cell, not straight to `VDD` or `VSS`.

### Post-place optimization (optional)

Empty. Commands here run on the placed design. This is where to fix timing problems that show up after placement.

### Outputs

`pe.place.db`, the database with the cells placed. CTS reads it.
