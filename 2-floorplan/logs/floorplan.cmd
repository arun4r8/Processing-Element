#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sun Nov 22 10:50:18 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.18-s099_1 (64bit) 07/18/2023 13:03 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.18-s099_1 NR230707-1955/21_18-UB (database version 18.20.605) {superthreading v2.17}
#@(#)CDS: AAE 21.18-s017 (64bit) 07/18/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.18-s022_1 () Jul 11 2023 23:10:24 ( )
#@(#)CDS: SYNTECH 21.18-s010_1 () Jul  5 2023 06:32:03 ( )
#@(#)CDS: CPE v21.18-s053
#@(#)CDS: IQuantus/TQuantus 21.1.1-s966 (64bit) Wed Mar 8 10:22:20 PST 2023 (Linux 3.10.0-693.el7.x86_64)

#@ source ../floorplan.tcl
#@ Begin verbose source (pre): source ../floorplan.tcl
set stage_dir /misc/scratch/ar76269/pe-apprentice/2-floorplan
set sc        $stage_dir/../pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
set qrc       $stage_dir/../pdk/sky130/qrc/qrcTechFile
set in_dir    $stage_dir/../0-inputs
set syn_out   $stage_dir/../1-syn/outputs
set sdc       $syn_out/pe.sdc
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_mmmc $in_dir/mmmc.tcl
#@ Begin verbose source /misc/scratch/ar76269/pe-apprentice/2-floorplan/../0-inputs/mmmc.tcl (pre)
create_library_set -name lib_tt -timing $sc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
create_timing_condition -name tc_tt -library_sets lib_tt
create_rc_corner -name rc_nom -qrc_tech $qrc
create_delay_corner -name dc_tt -timing_condition tc_tt -rc_corner rc_nom
create_constraint_mode -name func -sdc_files $sdc
create_analysis_view -name view_tt -constraint_mode func -delay_corner dc_tt
set_analysis_view -setup view_tt -hold view_tt
#@ End verbose source /misc/scratch/ar76269/pe-apprentice/2-floorplan/../0-inputs/mmmc.tcl
read_physical -lef [list $sc/techlef/sky130_fd_sc_hd__nom.tlef $sc/lef/sky130_fd_sc_hd.lef]
read_netlist $syn_out/pe.v
set_db init_power_nets  VDD
set_db init_ground_nets VSS
init_design
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both
connect_global_net VDD -type pg_pin -pin_base_name VPWR -all
connect_global_net VSS -type pg_pin -pin_base_name VGND -all
connect_global_net VDD -type pg_pin -pin_base_name VPB  -all
connect_global_net VSS -type pg_pin -pin_base_name VNB  -all
create_floorplan -site unithd -core_size 135 135 10 10 10 10;
#@ source $stage_dir/SetPinGroup.tcl
#@ Begin verbose source /misc/scratch/ar76269/pe-apprentice/2-floorplan/SetPinGroup.tcl (pre)
proc bus {name width} {
    set pins {}
    for {set i 0} {$i < $width} {incr i} { lappend pins "$name\[$i\]" }
    return $pins
}
set CtrlIn   {clk rst pe_accept_w_in pe_valid_in pe_switch_in pe_enabled}
set PsumIn   [bus pe_psum_in    16]
set WeightIn [bus pe_weight_in  16] ;
set InputIn  [bus pe_input_in   16] ;
set CtrlOut   {pe_valid_out pe_switch_out} ;
set PsumOut   [bus pe_psum_out   16]
set WeightOut [bus pe_weight_out 16] ;
set InputOut  [bus pe_input_out  16] ;
#@ End verbose source /misc/scratch/ar76269/pe-apprentice/2-floorplan/SetPinGroup.tcl
set_db assign_pins_edit_in_batch true
edit_pin -pin $CtrlIn   -side left -spread_type start -start {0 20} -spacing 4.08 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $PsumIn   -side left -spread_type start -start {0 50} -spacing 1.36 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $WeightIn -side left -spread_type start -start {0 80} -spacing 1.36 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $InputIn  -side left -spread_type start -start {0 110} -spacing 1.36 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $PsumOut   -side right -spread_type start -start {0 72} -spacing 1.36 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $WeightOut -side right -spread_type start -start {0 102} -spacing 1.36 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $InputOut  -side right -spread_type start -start {0 132} -spacing 1.36 -layer met3 -spread_direction clockwise -fixed_pin 1
edit_pin -pin $CtrlOut   -side right -spread_type start -start {0 24} -spacing 4.08 -layer met3 -spread_direction clockwise -fixed_pin 1
set_db assign_pins_edit_in_batch false
set_db add_endcaps_left_edge  sky130_fd_sc_hd__decap_3
set_db add_endcaps_right_edge sky130_fd_sc_hd__decap_3
add_endcaps -prefix ENDCAP
add_well_taps -cell sky130_fd_sc_hd__tapvpwrvgnd_1 -cell_interval 26.0 -checker_board -prefix WELLTAP
set XMinCore 10 ;
set XMaxCore 145 ;
set YMinCore 10 ;
set YMaxCore 145 ;
set power_metal_start_x [expr $XMinCore + 2]
set power_metal_start_y [expr $YMinCore + 2]
set power_metal_stop_x  [expr $XMaxCore - 2]
set power_metal_stop_y  [expr $YMaxCore - 2]
set power_metal_width   2 ;
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top met5 bottom met5 left met4 right met4} -width $power_metal_width -spacing 1.8 -offset 1.8
route_special -connect core_pin -nets {VDD VSS}
add_stripes -nets {VDD VSS} -layer met4 -direction vertical -width 2.0 -spacing 1.6 -set_to_set_distance 30 -start_from left -start_offset 20 -extend_to design_boundary
add_stripes -nets {VDD VSS} -layer met5 -direction horizontal -width 2.0 -spacing 1.6 -set_to_set_distance 30 -start_from bottom -start_offset 20 -extend_to design_boundary 
check_floorplan -out_file $rpt_dir/check_floorplan.rpt
check_connectivity -type special -nets {VDD VSS} -ignore_soft_pg_connects -out_file $rpt_dir/pg_connectivity.rpt
write_db $out_dir/pe.floorplan.db
exit
