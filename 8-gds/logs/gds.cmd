#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Nov 11 11:28:30 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.18-s099_1 (64bit) 07/18/2023 13:03 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.18-s099_1 NR230707-1955/21_18-UB (database version 18.20.605) {superthreading v2.17}
#@(#)CDS: AAE 21.18-s017 (64bit) 07/18/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.18-s022_1 () Jul 11 2023 23:10:24 ( )
#@(#)CDS: SYNTECH 21.18-s010_1 () Jul  5 2023 06:32:03 ( )
#@(#)CDS: CPE v21.18-s053
#@(#)CDS: IQuantus/TQuantus 21.1.1-s966 (64bit) Wed Mar 8 10:22:20 PST 2023 (Linux 3.10.0-693.el7.x86_64)

#@ source ../gds.tcl
#@ Begin verbose source (pre): source ../gds.tcl
set stage_dir [file dirname [file normalize [info script]]]
set sc        $stage_dir/../pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
set map       $stage_dir/../pdk/sky130/sky130A/libs.tech/klayout/tech/sky130A.map
set in_dir    $stage_dir/../0-inputs
set route_out $stage_dir/../5-route/outputs
set sta_rpt   $stage_dir/../6-sta/reports
set emir_rpt  $stage_dir/../7-emir/reports
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports
set_multi_cpu_usage -local_cpu 2
read_db $route_out/pe.route.db
write_stream $out_dir/pe.gds -map_file $map -merge $sc/gds/sky130_fd_sc_hd.gds -unit 1000 -mode all
set fh [open $sta_rpt/setup.rpt]
set setup [read $fh]
close $fh
regexp {Path 1: \S+ \((-?[0-9.]+) ns\)} $setup -> wns
set fh [open $sta_rpt/summary.rpt]
set sta [read $fh]
close $fh
set tns  0
set nvio 0
regexp {View:view_tt\) \(EL:Setup\).*?GroupType:Standard.*?\n\s*(-?[0-9.]+):(-?[0-9.]+):([0-9]+)\s} $sta -> sum_wns tns nvio
set fh [open $emir_rpt/power/power.rpt]
set pwr [read $fh]
close $fh
regexp {Total Internal Power:\s+(\S+)}  $pwr -> int_mw
regexp {Total Switching Power:\s+(\S+)} $pwr -> sw_mw
regexp {Total Leakage Power:\s+(\S+)}   $pwr -> leak_mw
regexp {Total Power:\s+(\S+)}           $pwr -> tot_mw
set area 0
foreach inst [get_db insts] {
    if {![regexp {__(fill|decap|tapvpwrvgnd)_} [get_db $inst .base_cell.name]]} {
        set area [expr {$area + [get_db $inst .area]}]
    }
}
set period_ps [expr {[lindex [get_db clocks .period] 0] * 1000}]
set fh [open $rpt_dir/final_qor.rpt w]
puts $fh "Clock Period\n------------\nclk $period_ps\n"
puts $fh "clk [expr {$wns * 1000}] [expr {$tns * 1000}] $nvio"
puts $fh "Total Cell Area (Cell+Physical) $area"
close $fh
set fh [open $rpt_dir/final_power.rpt w]
puts $fh "Subtotal [expr {$leak_mw / 1000.0}] [expr {$int_mw / 1000.0}] [expr {$sw_mw / 1000.0}] [expr {$tot_mw / 1000.0}]"
close $fh
set ppa_activity "VCD 0-inputs/outputs/pe.vcd, Voltus at tt"
source $in_dir/ppa.tcl
ppa_report $rpt_dir/final_qor.rpt $rpt_dir/final_power.rpt $rpt_dir/pe_ppa_final.rpt
exit
