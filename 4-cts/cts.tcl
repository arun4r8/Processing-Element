# ── Clock tree ───────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir /misc/scratch/ar76269/pe-apprentice/4-cts
set place_out $stage_dir/../3-place/outputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports

set_multi_cpu_usage -local_cpu 2

read_db $place_out/pe.place.db

# Timing reports as plain text, not .gz
set_db opt_time_design_compress_reports false

# ── Optimizations ────────────────────────────────────────────────────────────
# Add your optimizations here

# ── NDR ──────────────────────────────────────────────────────────────────────
# Clock nets get wider wires and more spacing than signal nets.
# Trunk: from the clock root down to the last buffers. Leaf: from those buffers to the flops.
create_route_rule -name ndr_trunk -width_multiplier {met1:met5 2} -spacing_multiplier {met1:met5 2}
create_route_type -name trunk_route -route_rule ndr_trunk -bottom_preferred_layer met2 -top_preferred_layer met4

create_route_rule -name ndr_leaf -width_multiplier {met1:met5 2} -spacing_multiplier {met1:met5 2}
create_route_type -name leaf_route -route_rule ndr_leaf -bottom_preferred_layer met1 -top_preferred_layer met3

set_db cts_route_type_trunk trunk_route
set_db cts_route_type_leaf  leaf_route

# ── CTS ──────────────────────────────────────────────────────────────────────
set_db cts_buffer_cells   {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4
                           sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_16}
set_db cts_inverter_cells {sky130_fd_sc_hd__clkinv_1 sky130_fd_sc_hd__clkinv_2 sky130_fd_sc_hd__clkinv_4
                           sky130_fd_sc_hd__clkinv_8 sky130_fd_sc_hd__clkinv_16}
ccopt_design

# ── Post-CTS optimization (optional) ─────────────────────────────────────────
# Optional add your post-CTS optimization here
opt_design -post_cts
# ── Reports ──────────────────────────────────────────────────────────────────
time_design -post_cts       -report_dir $rpt_dir/timing -report_prefix cts_setup
time_design -post_cts -hold -report_dir $rpt_dir/timing -report_prefix cts_hold
report_clock_trees -out_file $rpt_dir/clock_trees.rpt
report_skew_groups -out_file $rpt_dir/skew_groups.rpt
report_area  -out_file $rpt_dir/area.rpt
report_power -out_file $rpt_dir/power.rpt

# ── Outputs ──────────────────────────────────────────────────────────────────
write_db $out_dir/pe.cts.db
exit
