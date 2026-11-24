# 1-syn

Synthesis with Genus. Turns your RTL into a gate-level netlist of SKY130 standard cells that meets the clock in `pe.sdc`, then scores it with the PPA report.

```bash
./1-syn/run-syn.sh
```

Read `reports/pe_ppa.rpt` for your FOM.

## What you fill in

Nothing is required; the script runs as is. To improve your FOM, put your synthesis settings in the `Optimizations` block.

## syn.tcl

### Libraries

- `library` is the Liberty (.lib) file for the tt corner: the timing, power and function of every standard cell. Synthesis maps to these cells.
- `lef_library` is the technology LEF and the cell LEF: the metal layers and the size of each cell. Genus uses them to estimate area and wire load.

### RTL

- `read_hdl -sv` reads the SystemVerilog files.
- `elaborate pe` builds the design hierarchy with `pe` as the top module.
- `check_design -unresolved` reports any module that was used but not found.
- `read_sdc` applies the clock and I/O constraints.

### Activity

`read_vcd -static` reads the toggle rates from `0-inputs/outputs/pe.vcd` for power estimation. `-vcd_scope` is the PE instance inside the testbench. `ppa_activity` is only a label for the PPA report.

### Optimizations

Empty. Settings placed here apply before synthesis runs, so they shape how Genus builds the netlist. See `refs/genus_user_guide.pdf`.

### Synthesis

- `syn_generic` turns the RTL into generic logic and does technology-independent optimization.
- `syn_map` maps that logic onto SKY130 cells.
- `syn_opt` optimizes the mapped netlist for timing, area and power.

### PPA

`ppa.tcl` reads the QoR and power reports and writes `reports/pe_ppa.rpt` with the frequency, area, power and FOM. Do not change it.

### Outputs

- `pe.v` is the gate-level netlist: your design as instances of SKY130 cells and the wires between them. Floorplan reads it.
- `pe.sdc` is the constraints as Genus wrote them for the netlist. Place and route and STA use this file.
