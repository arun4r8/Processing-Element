#######################################################
#                                                     
#  Voltus IC Power Integrity Solution Command Logging File                     
#  Created on Wed Nov 25 11:11:43 2026                
#                                                     
#######################################################

#@(#)CDS: Voltus IC Power Integrity Solution v22.12-s082_1 (64bit) 05/04/2023 21:55 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 22.12-s082_1 NR230417-0429/22_12-UB (database version 18.20.608) {superthreading v2.20}
#@(#)CDS: AAE 22.12-s030 (64bit) 05/04/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 22.12-s024_1 () Apr 27 2023 13:39:51 ( )
#@(#)CDS: SYNTECH 22.12-s012_1 () Apr 26 2023 10:17:02 ( )
#@(#)CDS: CPE v22.12-s078

#@ Begin verbose source ../emir.tcl (pre)
set stage_dir [file dirname [file normalize [info script]]]
set qrc       $stage_dir/../pdk/sky130/qrc/qrcTechFile
set in_dir    $stage_dir/../0-inputs
set route_out $stage_dir/../5-route/outputs
set pgv_dir   $stage_dir/logs/pgv
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_db $route_out/pe.route.db
read_spef -rc_corner rc_nom $route_out/pe.spef
set_db power_method static
set_db power_view view_tt
set_db power_write_static_currents true
read_activity_file -format VCD -scope pe_activity_tb.dut $in_dir/outputs/pe.vcd
report_power -out_dir $rpt_dir/power
set_pg_library_mode -cell_type techonly -default_power_voltage 1.8 -extraction_tech_file $qrc
write_pg_library -out_dir $pgv_dir
set_pg_nets -net VDD -voltage 1.8 -threshold 1.71
set_pg_nets -net VSS -voltage 0.0 -threshold 0.09
set_rail_analysis_domain -domain_name core -power_nets VDD -ground_nets VSS
set_power_pads -net VDD -auto_voltage_source_creation true -layer via4
set_power_pads -net VSS -auto_voltage_source_creation true -layer via4
set_power_data -format current [list $rpt_dir/power/static_VDD.ptiavg $rpt_dir/power/static_VSS.ptiavg]
set_rail_analysis_config -method static -accuracy hd -analysis_view view_tt \
    -power_grid_libraries $pgv_dir/techonly.cl -extraction_tech_file $qrc \
    -em_models $stage_dir/em.models -ignore_shorts true
report_rail -type domain -output_dir $rpt_dir/rail core
exit
