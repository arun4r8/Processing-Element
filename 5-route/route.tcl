# ── Routing ──────────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir /misc/scratch/ar76269/pe-apprentice/5-route
set cts_out   $stage_dir/../4-cts/outputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports

set_multi_cpu_usage -local_cpu 2

read_db $cts_out/pe.cts.db

# Timing reports as plain text, not .gz
set_db opt_time_design_compress_reports false

# ── Optimizations ────────────────────────────────────────────────────────────
# Add your optimizations here

# ── Fillers ──────────────────────────────────────────────────────────────────
set_db add_fillers_cells {sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4
                          sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1}
add_fillers -prefix FILLER

# ── Route ────────────────────────────────────────────────────────────────────
set_db route_design_with_timing_driven 1
route_design

# ── Post-route optimization (optional) ───────────────────────────────────────
# Optional add your post-route optimization here
set_db extract_rc_engine post_route
opt_design -post_route -setup -hold
set_db opt_setup_target_slack 0.05
opt_design -post_route -setup -hold

# ── Reports ──────────────────────────────────────────────────────────────────
time_design -post_route       -report_dir $rpt_dir/timing -report_prefix route_setup
time_design -post_route -hold -report_dir $rpt_dir/timing -report_prefix route_hold
report_area  -out_file $rpt_dir/area.rpt
report_power -out_file $rpt_dir/power.rpt
check_drc -out_file $rpt_dir/drc.rpt
check_connectivity -type all -ignore_soft_pg_connects -out_file $rpt_dir/connectivity.rpt

# ── Outputs ──────────────────────────────────────────────────────────────────
# db for 7-emir and 8-gds; netlist, SPEF and SDC for 6-sta
write_db $out_dir/pe.route.db
write_netlist $out_dir/pe.v
write_parasitics -spef_file $out_dir/pe.spef -rc_corner rc_nom
write_sdc $out_dir/pe.sdc
exit
