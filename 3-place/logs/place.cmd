#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Nov 25 10:55:53 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.18-s099_1 (64bit) 07/18/2023 13:03 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.18-s099_1 NR230707-1955/21_18-UB (database version 18.20.605) {superthreading v2.17}
#@(#)CDS: AAE 21.18-s017 (64bit) 07/18/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.18-s022_1 () Jul 11 2023 23:10:24 ( )
#@(#)CDS: SYNTECH 21.18-s010_1 () Jul  5 2023 06:32:03 ( )
#@(#)CDS: CPE v21.18-s053
#@(#)CDS: IQuantus/TQuantus 21.1.1-s966 (64bit) Wed Mar 8 10:22:20 PST 2023 (Linux 3.10.0-693.el7.x86_64)

#@ source ../place.tcl
#@ Begin verbose source (pre): source ../place.tcl
set stage_dir /misc/scratch/ar76269/pe-apprentice/3-place
set fp_out    $stage_dir/../2-floorplan/outputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_db $fp_out/pe.floorplan.db
set_db opt_time_design_compress_reports false
place_design
set_db add_tieoffs_cells sky130_fd_sc_hd__conb_1
add_tieoffs
opt_design -pre_cts
time_design -pre_cts -report_dir $rpt_dir/timing -report_prefix place
report_area  -out_file $rpt_dir/area.rpt
report_power -out_file $rpt_dir/power.rpt
check_place $rpt_dir/check_place.rpt
write_db $out_dir/pe.place.db
exit
