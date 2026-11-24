# ── Signoff STA ──────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir [file dirname [file normalize [info script]]]
set sc        $stage_dir/../pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
set qrc       $stage_dir/../pdk/sky130/qrc/qrcTechFile
set in_dir    $stage_dir/../0-inputs
set route_out $stage_dir/../5-route/outputs
set sdc       $route_out/pe.sdc
set rpt_dir   $stage_dir/reports

set_multi_cpu_usage -local_cpu 2

# ── Design import ────────────────────────────────────────────────────────────
read_mmmc $in_dir/mmmc.tcl
read_netlist $route_out/pe.v
init_design
read_spef -rc_corner rc_nom $route_out/pe.spef

set_db timing_analysis_type ocv
set_db timing_analysis_cppr both
set_db delaycal_enable_si true

# ── Reports ──────────────────────────────────────────────────────────────────
report_timing -max_paths 10 -path_type full_clock > $rpt_dir/setup.rpt
report_timing -early -max_paths 10 -path_type full_clock > $rpt_dir/hold.rpt
report_analysis_summary > $rpt_dir/summary.rpt
report_constraint -all_violators > $rpt_dir/all_violators.rpt
exit
