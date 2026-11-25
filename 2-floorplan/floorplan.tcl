# ── Floorplan ────────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir /misc/scratch/ar76269/pe-apprentice/2-floorplan
set sc        $stage_dir/../pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
set qrc       $stage_dir/../pdk/sky130/qrc/qrcTechFile
set in_dir    $stage_dir/../0-inputs
set syn_out   $stage_dir/../1-syn/outputs
set sdc       $syn_out/pe.sdc
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports

set_multi_cpu_usage -local_cpu 2

# ── Design import ────────────────────────────────────────────────────────────
read_mmmc $in_dir/mmmc.tcl
read_physical -lef [list $sc/techlef/sky130_fd_sc_hd__nom.tlef $sc/lef/sky130_fd_sc_hd.lef]
read_netlist $syn_out/pe.v
set_db init_power_nets  VDD
set_db init_ground_nets VSS
init_design

# Needed for post-route timing; saved in the db
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both

# ── Global nets ──────────────────────────────────────────────────────────────
connect_global_net VDD -type pg_pin -pin_base_name VPWR -all
connect_global_net VSS -type pg_pin -pin_base_name VGND -all

# Body (well) pins
connect_global_net VDD -type pg_pin -pin_base_name VPB  -all
connect_global_net VSS -type pg_pin -pin_base_name VNB  -all

# ── Core ──────────────────────────────────────────────────────────────────────
# Core width and height, then core to die on the left, bottom, right and top, in um.

create_floorplan -site unithd -core_size 135 135 10 10 10 10; #you need to set your core area here

# ── Pins ─────────────────────────────────────────────────────────────────────
# Groups are set in SetPinGroup.tcl. Inputs on the left edge, outputs on the right.
# -start {x y} is in um; on the left and right edges only y is used.
# you need to fill in some blanks in SetPinGroup.tcl
# you will need to adjust the spacing for your core area that you choose

source $stage_dir/SetPinGroup.tcl
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

# ── Well taps and end caps ───────────────────────────────────────────────────
set_db add_endcaps_left_edge  sky130_fd_sc_hd__decap_3
set_db add_endcaps_right_edge sky130_fd_sc_hd__decap_3
add_endcaps -prefix ENDCAP
add_well_taps -cell sky130_fd_sc_hd__tapvpwrvgnd_1 -cell_interval 26.0 -checker_board -prefix WELLTAP

# ── Power Grid ───────────────────────────────────────────────────────────────
## Core edges in um; match the -core_size you set in create_floorplan. use at least 10um of margin
set XMinCore 10 ;# left margin
set XMaxCore 145 ;# left margin + core width
set YMinCore 10 ;# bottom margin
set YMaxCore 145 ;# bottom margin + core height

## Adding parameters for power stripes
set power_metal_start_x [expr $XMinCore + 2]
set power_metal_start_y [expr $YMinCore + 2]
set power_metal_stop_x  [expr $XMaxCore - 2]
set power_metal_stop_y  [expr $YMaxCore - 2]
set power_metal_width   2 ;# set your power rail metal width in um

add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top met5 bottom met5 left met4 right met4} -width $power_metal_width -spacing 1.8 -offset 1.8
route_special -connect core_pin -nets {VDD VSS}
add_stripes -nets {VDD VSS} -layer met4 -direction vertical -width 2.0 -spacing 1.6 -set_to_set_distance 30 -start_from left -start_offset 20 -extend_to design_boundary
add_stripes -nets {VDD VSS} -layer met5 -direction horizontal -width 2.0 -spacing 1.6 -set_to_set_distance 30 -start_from bottom -start_offset 20 -extend_to design_boundary 
# ── Reports ──────────────────────────────────────────────────────────────────
check_floorplan -out_file $rpt_dir/check_floorplan.rpt
check_connectivity -type special -nets {VDD VSS} -ignore_soft_pg_connects -out_file $rpt_dir/pg_connectivity.rpt

# ── Outputs ──────────────────────────────────────────────────────────────────
write_def -floorplan -no_std_cells $out_dir/pe.floorplan.def
write_db $out_dir/pe.floorplan.db

exit
