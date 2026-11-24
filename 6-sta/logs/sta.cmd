#######################################################
#                                                     
#  Tempus Timing Solution Command Logging File                     
#  Created on Wed Nov 11 11:05:24 2026                
#                                                     
#######################################################

#@(#)CDS: Tempus Timing Solution v22.12-s082_1 (64bit) 05/04/2023 21:55 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 22.12-s082_1 NR230417-0429/22_12-UB (database version 18.20.608) {superthreading v2.20}
#@(#)CDS: AAE 22.12-s030 (64bit) 05/04/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 22.12-s024_1 () Apr 27 2023 13:39:51 ( )
#@(#)CDS: SYNTECH 22.12-s012_1 () Apr 26 2023 10:17:02 ( )
#@(#)CDS: CPE v22.12-s078

#@ Begin verbose source ../sta.tcl (pre)
set stage_dir [file dirname [file normalize [info script]]]
set sc        $stage_dir/../pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
set qrc       $stage_dir/../pdk/sky130/qrc/qrcTechFile
set in_dir    $stage_dir/../0-inputs
set route_out $stage_dir/../5-route/outputs
set sdc       $route_out/pe.sdc
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_mmmc $in_dir/mmmc.tcl
#@ Begin verbose source /misc/scratch/ar76269/pe-apprentice/6-sta/../0-inputs/mmmc.tcl (pre)
create_library_set -name lib_tt -timing $sc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
create_timing_condition -name tc_tt -library_sets lib_tt
create_rc_corner -name rc_nom -qrc_tech $qrc
create_delay_corner -name dc_tt -timing_condition tc_tt -rc_corner rc_nom
create_constraint_mode -name func -sdc_files $sdc
create_analysis_view -name view_tt -constraint_mode func -delay_corner dc_tt
set_analysis_view -setup view_tt -hold view_tt
#@ End verbose source /misc/scratch/ar76269/pe-apprentice/6-sta/../0-inputs/mmmc.tcl
read_netlist $route_out/pe.v
init_design
read_spef -rc_corner rc_nom $route_out/pe.spef
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both
set_db delaycal_enable_si true
report_timing -max_paths 10 -path_type full_clock > $rpt_dir/setup.rpt
report_timing -early -max_paths 10 -path_type full_clock > $rpt_dir/hold.rpt
report_analysis_summary > $rpt_dir/summary.rpt
report_constraint -all_violators > $rpt_dir/all_violators.rpt
exit
