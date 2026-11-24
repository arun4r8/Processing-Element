# ── Placement ────────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir /misc/scratch/ar76269/pe-apprentice/3-place
set fp_out    $stage_dir/../2-floorplan/outputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports

set_multi_cpu_usage -local_cpu 2

read_db $fp_out/pe.floorplan.db

# Timing reports as plain text, not .gz
set_db opt_time_design_compress_reports false

# ── Optimizations ────────────────────────────────────────────────────────────
# Add your optimizations here

# ── Place ────────────────────────────────────────────────────────────────────
place_design

# Tie cells for constant inputs
set_db add_tieoffs_cells sky130_fd_sc_hd__conb_1
add_tieoffs

# ── Post-place optimization (optional) ───────────────────────────────────────
# Optional add your post-place optimization here
opt_design -pre_cts
# ── Reports ──────────────────────────────────────────────────────────────────
time_design -pre_cts -report_dir $rpt_dir/timing -report_prefix place
report_area  -out_file $rpt_dir/area.rpt
report_power -out_file $rpt_dir/power.rpt
check_place $rpt_dir/check_place.rpt

# ── Outputs ──────────────────────────────────────────────────────────────────
write_db $out_dir/pe.place.db
exit
