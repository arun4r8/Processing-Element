#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Nov 25 10:58:00 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.18-s099_1 (64bit) 07/18/2023 13:03 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.18-s099_1 NR230707-1955/21_18-UB (database version 18.20.605) {superthreading v2.17}
#@(#)CDS: AAE 21.18-s017 (64bit) 07/18/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.18-s022_1 () Jul 11 2023 23:10:24 ( )
#@(#)CDS: SYNTECH 21.18-s010_1 () Jul  5 2023 06:32:03 ( )
#@(#)CDS: CPE v21.18-s053
#@(#)CDS: IQuantus/TQuantus 21.1.1-s966 (64bit) Wed Mar 8 10:22:20 PST 2023 (Linux 3.10.0-693.el7.x86_64)

#@ source ../cts.tcl
#@ Begin verbose source (pre): source ../cts.tcl
set stage_dir /misc/scratch/ar76269/pe-apprentice/4-cts
set place_out $stage_dir/../3-place/outputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_db $place_out/pe.place.db
set_db opt_time_design_compress_reports false
create_route_rule -name ndr_trunk -width_multiplier {met1:met5 2} -spacing_multiplier {met1:met5 2}
create_route_type -name trunk_route -route_rule ndr_trunk -bottom_preferred_layer met2 -top_preferred_layer met4
create_route_rule -name ndr_leaf -width_multiplier {met1:met5 2} -spacing_multiplier {met1:met5 2}
create_route_type -name leaf_route -route_rule ndr_leaf -bottom_preferred_layer met1 -top_preferred_layer met3
set_db cts_route_type_trunk trunk_route
set_db cts_route_type_leaf  leaf_route
set_db cts_buffer_cells   {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4
                           sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_16}
set_db cts_inverter_cells {sky130_fd_sc_hd__clkinv_1 sky130_fd_sc_hd__clkinv_2 sky130_fd_sc_hd__clkinv_4
                           sky130_fd_sc_hd__clkinv_8 sky130_fd_sc_hd__clkinv_16}
ccopt_design
opt_design -post_cts
time_design -post_cts       -report_dir $rpt_dir/timing -report_prefix cts_setup
time_design -post_cts -hold -report_dir $rpt_dir/timing -report_prefix cts_hold
report_clock_trees -out_file $rpt_dir/clock_trees.rpt
report_skew_groups -out_file $rpt_dir/skew_groups.rpt
report_area  -out_file $rpt_dir/area.rpt
report_power -out_file $rpt_dir/power.rpt
write_db $out_dir/pe.cts.db
exit
