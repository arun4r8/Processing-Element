#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Nov 25 11:13:56 2026                
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
#@ source $in_dir/ppa.tcl
#@ Begin verbose source /misc/scratch/ar76269/pe-apprentice/8-gds/../0-inputs/ppa.tcl (pre)
set ppa_area_cap_um2 30000.0
set ppa_alpha 3.0
set ppa_beta  0.5
set ppa_base_f_mhz 125.0
set ppa_base_p_mw  1.28690
set ppa_base_a_um2 8386.794
set ppa_base_desc  "reference pe.sv, pe.sdc 8 ns, hd"
if {![info exists ppa_activity]} {...}
proc ppa_read {path} {
  set fh [open $path]
  set txt [read $fh]
  close $fh
  return $txt
}
proc ppa_report {qor_rpt power_rpt out_rpt {macs 1}} {
  global ppa_area_cap_um2 ppa_activity ppa_alpha ppa_beta
  global ppa_base_f_mhz ppa_base_p_mw ppa_base_a_um2 ppa_base_desc
  set alpha $ppa_alpha
  set beta  $ppa_beta
  set base_fom [expr {pow($ppa_base_f_mhz, $alpha) / (pow($ppa_base_p_mw, $beta) * $ppa_base_a_um2)}]
  set qor [ppa_read $qor_rpt]
  set pwr [ppa_read $power_rpt]

  # ââ Parse ââ
  if {![regexp {Clock Period\s*\n-+\s*\n\S+\s+([0-9.]+)\s*\n} $qor -> period_ps]} {
    error "ppa: clock period not found in $qor_rpt"
  }
  if {![regexp {\nclk\s+(-?[0-9.]+)\s+(-?[0-9.]+)\s+([0-9]+)} $qor -> wns tns nvio]} {
    error "ppa: clk cost group not found in $qor_rpt"
  }
  if {![regexp {Total Cell Area \(Cell\+Physical\)\s+([0-9.]+)} $qor -> area_um2]} {
    error "ppa: cell area not found in $qor_rpt"
  }
  if {![regexp {Subtotal\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $pwr -> leak_w int_w sw_w tot_w]} {
    error "ppa: power subtotal not found in $power_rpt"
  }

  # ââ Score ââ
  set f_mhz    [expr {1.0e6 / $period_ps}]
  set perf     [expr {$f_mhz * $macs}]
  set p_mw     [expr {$tot_w * 1.0e3}]
  set t_pass   [expr {$wns >= 0 && $nvio == 0}]
  set a_pass   [expr {$area_um2 <= $ppa_area_cap_um2}]
  set fom      [expr {($t_pass && $a_pass) ? pow($perf, $alpha) / (pow($p_mw, $beta) * $area_um2) : 0.0}]

  # ââ Write ââ
  set fh [open $out_rpt w]
  puts $fh "PPA report"
  puts $fh [string repeat - 56]
  puts $fh [format "%-22s %14.1f ps" "Clock period"    $period_ps]
  puts $fh [format "%-22s %14.2f MHz" "Frequency"      $f_mhz]
  puts $fh [format "%-22s %14d" "MACs per cycle"       $macs]
  puts $fh [format "%-22s %14.2f MMAC/s" "Performance" $perf]
  puts $fh [format "%-22s %14.1f ps" "WNS"             $wns]
  puts $fh [format "%-22s %14.1f ps" "TNS"             $tns]
  puts $fh [format "%-22s %14d" "Violating paths"      $nvio]
  puts $fh [format "%-22s %14.3f um^2" "Cell area"     $area_um2]
  puts $fh [format "%-22s %14.3f um^2" "Area limit"    $ppa_area_cap_um2]
  puts $fh [format "%-22s %14.4f mW" "Power total"     $p_mw]
  puts $fh [format "%-22s %14.4f mW" "  internal"      [expr {$int_w * 1.0e3}]]
  puts $fh [format "%-22s %14.4f mW" "  switching"     [expr {$sw_w * 1.0e3}]]
  puts $fh [format "%-22s %14.4f uW" "  leakage"       [expr {$leak_w * 1.0e6}]]
  puts $fh [format "%-22s %s" "Power activity"         $ppa_activity]
  puts $fh [string repeat - 56]
  puts $fh [format "%-22s %14s" "Timing gate"          [expr {$t_pass ? "PASS" : "FAIL"}]]
  puts $fh [format "%-22s %14s" "Area gate"            [expr {$a_pass ? "PASS" : "FAIL"}]]
  puts $fh [format "%-22s %14.2f" "Perf exponent"      $alpha]
  puts $fh [format "%-22s %14.2f" "Power exponent"     $beta]
  puts $fh [format "%-22s %14.6g" "FOM"                $fom]
  puts $fh [format "%-22s %14.6g" "Baseline FOM"       $base_fom]
  puts $fh [format "%-22s %14.3f" "FOM / baseline"     [expr {$fom / $base_fom}]]
  puts $fh [format "%-22s %s" "Baseline"               $ppa_base_desc]
  puts $fh ""
  puts $fh "FOM = perf_MMACs^$alpha / (power_mW^$beta * cell_area_um2)"
  puts $fh "FOM is 0 if timing fails or cell area exceeds the limit"
  close $fh
  return $fom
}
#@ End verbose source /misc/scratch/ar76269/pe-apprentice/8-gds/../0-inputs/ppa.tcl
ppa_report $rpt_dir/final_qor.rpt $rpt_dir/final_power.rpt $rpt_dir/pe_ppa_final.rpt
exit
