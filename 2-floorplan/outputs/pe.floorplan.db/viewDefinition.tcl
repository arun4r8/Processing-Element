if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name lib_tt\
   -timing\
    [list ${::IMEX::libVar}/mmmc/sky130_fd_sc_hd__tt_025C_1v80.lib]
create_timing_condition -name tc_tt\
   -library_sets [list lib_tt]
create_rc_corner -name rc_nom\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -qrc_tech ${::IMEX::libVar}/mmmc/rc_nom/qrcTechFile
create_delay_corner -name dc_tt\
   -timing_condition {tc_tt}\
   -rc_corner rc_nom
create_constraint_mode -name func\
   -sdc_files\
    [list ${::IMEX::libVar}/mmmc/pe.sdc]
create_analysis_view -name view_tt -constraint_mode func -delay_corner dc_tt
set_analysis_view -setup [list view_tt] -hold [list view_tt]
