# ── Signoff power, IR drop and EM ────────────────────────────────────────────
# Static analysis at the tt view.

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir [file dirname [file normalize [info script]]]
set qrc       $stage_dir/../pdk/sky130/qrc/qrcTechFile
set in_dir    $stage_dir/../0-inputs
set route_out $stage_dir/../5-route/outputs
set pgv_dir   $stage_dir/logs/pgv
set rpt_dir   $stage_dir/reports

set_multi_cpu_usage -local_cpu 2

read_db $route_out/pe.route.db
read_spef -rc_corner rc_nom $route_out/pe.spef

# ── Power ────────────────────────────────────────────────────────────────────
# Writes the per-instance currents that rail analysis reads
set_db power_method static
set_db power_view view_tt
set_db power_write_static_currents true
read_activity_file -format VCD -scope pe_activity_tb.dut $in_dir/outputs/pe.vcd
report_power -out_dir $rpt_dir/power

# ── Power grid library ───────────────────────────────────────────────────────
# Tech only: wire and via resistance from the QRC file, no cell models
set_pg_library_mode -cell_type techonly -default_power_voltage 1.8 -extraction_tech_file $qrc
write_pg_library -out_dir $pgv_dir

# ── Rail analysis ────────────────────────────────────────────────────────────
# 5% drop limit; supply enters at every via4 on the grid
set_pg_nets -net VDD -voltage 1.8 -threshold 1.71
set_pg_nets -net VSS -voltage 0.0 -threshold 0.09
set_rail_analysis_domain -domain_name core -power_nets VDD -ground_nets VSS
set_power_pads -net VDD -auto_voltage_source_creation true -layer via4
set_power_pads -net VSS -auto_voltage_source_creation true -layer via4
set_power_data -format current [list $rpt_dir/power/static_VDD.ptiavg $rpt_dir/power/static_VSS.ptiavg]

# EM limits are in em.models; the QRC file has none
set_rail_analysis_config -method static -accuracy hd -analysis_view view_tt \
    -power_grid_libraries $pgv_dir/techonly.cl -extraction_tech_file $qrc \
    -em_models $stage_dir/em.models -ignore_shorts true
report_rail -type domain -output_dir $rpt_dir/rail core
exit
