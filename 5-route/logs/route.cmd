#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sun Nov 22 11:13:26 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.18-s099_1 (64bit) 07/18/2023 13:03 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.18-s099_1 NR230707-1955/21_18-UB (database version 18.20.605) {superthreading v2.17}
#@(#)CDS: AAE 21.18-s017 (64bit) 07/18/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.18-s022_1 () Jul 11 2023 23:10:24 ( )
#@(#)CDS: SYNTECH 21.18-s010_1 () Jul  5 2023 06:32:03 ( )
#@(#)CDS: CPE v21.18-s053
#@(#)CDS: IQuantus/TQuantus 21.1.1-s966 (64bit) Wed Mar 8 10:22:20 PST 2023 (Linux 3.10.0-693.el7.x86_64)

#@ source ../route.tcl
#@ Begin verbose source (pre): source ../route.tcl
set stage_dir /misc/scratch/ar76269/pe-apprentice/5-route
set cts_out   $stage_dir/../4-cts/outputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_db $cts_out/pe.cts.db
set_db opt_time_design_compress_reports false
set_db add_fillers_cells {sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4
                          sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1}
add_fillers -prefix FILLER
set_db route_design_with_timing_driven 1
route_design
set_db extract_rc_engine post_route
opt_design -post_route -setup -hold
set_db opt_setup_target_slack 0.02
opt_design -post_route -setup -hold
time_design -post_route       -report_dir $rpt_dir/timing -report_prefix route_setup
time_design -post_route -hold -report_dir $rpt_dir/timing -report_prefix route_hold
report_area  -out_file $rpt_dir/area.rpt
report_power -out_file $rpt_dir/power.rpt
check_drc -out_file $rpt_dir/drc.rpt
check_connectivity -type all -ignore_soft_pg_connects -out_file $rpt_dir/connectivity.rpt
write_db $out_dir/pe.route.db
write_netlist $out_dir/pe.v
write_parasitics -spef_file $out_dir/pe.spef -rc_corner rc_nom
write_sdc $out_dir/pe.sdc
exit
