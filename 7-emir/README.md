# 7-emir

Signoff power, IR drop and electromigration (EM) with Voltus, at the tt corner.
- IR drop: the voltage lost across the resistance of the power grid. A cell that gets less than its supply voltage runs slower.
- EM: metal atoms pushed along by current. A wire or via carrying more current than its limit for too long can wear out and open.

```bash
./7-emir/run-emir.sh
```

## What you fill in

Nothing. If IR drop or EM fails, fix the power grid in `2-floorplan`.

## emir.tcl

`read_db` loads the routed database from `5-route`, and `read_spef` loads its parasitics.

### Power

- `power_method static` computes average power, not a waveform over time.
- `power_view view_tt` uses the tt corner.
- `power_write_static_currents true` writes the average current each cell draws, which rail analysis needs.
- `read_activity_file` reads the toggle rates from `0-inputs/outputs/pe.vcd`.
- `report_power` writes `reports/power/power.rpt` and the current files (`static_VDD.ptiavg`, `static_VSS.ptiavg`).

### Power grid library

Rail analysis needs a resistance model of the grid. There are no Voltus cell models for SKY130, so `set_pg_library_mode -cell_type techonly` builds one from the wire and via resistance in the QRC tech file. `write_pg_library` writes it to `logs/pgv`; it is rebuilt every run.

### Rail analysis

- `set_pg_nets` sets each supply net's voltage and limit. `VDD` must stay above 1.71 V and `VSS` below 0.09 V, 5% of 1.8 V.
- `set_rail_analysis_domain` groups `VDD` and `VSS` for analysis.
- `set_power_pads` says where current enters the grid. Here it is every via4 on the grid, as if the block were fed from above.
- `set_power_data` loads the cell currents from the Power block.
- `set_rail_analysis_config` sets up the run:
  - static analysis at the tt view;
  - the grid library from the block above;
  - `em.models` for EM. It has the current limit of each metal and via layer, taken from the SKY130 tech LEF, because the QRC file has none.
- `report_rail` solves the grid for every node voltage and wire current.

### Outputs

The results are under `reports/rail/core_25C_avg_1/Reports/`:

| File | What it shows |
|---|---|
| `VDD/VDD.main.rpt`, `VSS/VSS.main.rpt` | Summary per net: IR drop violations, current density (EM) violations. For VDD the min/avg/max line lists node voltages, not drops. |
| `VDD/VDD.layerbased_ir.rpt` | Worst IR drop on each metal layer. |
| `VDD/VDD.rj.avg.rpt` | Wires and vias near their EM limit, as a fraction of the limit (J/Jmax). |
| `*.gif` | Plots of IR drop and current over the layout. |
