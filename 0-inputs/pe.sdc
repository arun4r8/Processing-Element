# ── Clock ───────────────────────────────────────────────────────────
set clock_period 3.15
create_clock -name clk -period $clock_period [get_ports clk]
set_clock_uncertainty [expr {$clock_period * 0.05}] [get_clocks clk]

# ── I/O ─────────────────────────────────────────────────────────────
set data_in [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay  [expr {$clock_period * 0.2}] -clock clk $data_in
set_output_delay [expr {$clock_period * 0.2}] -clock clk [all_outputs]
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 $data_in
set_load 0.01 [all_outputs]
