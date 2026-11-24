# ── GDS ──────────────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
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

# ── Stream out ───────────────────────────────────────────────────────────────
# The map gives the GDS layer and datatype for each LEF layer.
# The route db only has cell outlines; -merge copies in the cell layouts.
write_stream $out_dir/pe.gds -map_file $map -merge $sc/gds/sky130_fd_sc_hd.gds -unit 1000 -mode all

# ── Final PPA ────────────────────────────────────────────────────────────────
# Scores the finished design with ppa.tcl: setup timing at tt from 6-sta, power from 7-emir,
# and the area of the logic cells (fillers, taps and end caps left out).
# ppa_report reads Genus report text, so the numbers are first written in that format.

# Worst setup slack in ns: the first path in 6-sta's setup report
set fh [open $sta_rpt/setup.rpt]
set setup [read $fh]
close $fh
regexp {Path 1: \S+ \((-?[0-9.]+) ns\)} $setup -> wns

# TNS in ns and failing paths: the Standard group of the tt setup section in the summary.
# The summary only lists failing paths, so when setup passes there is no line and both stay 0.
# The Async group (reset recovery and removal) is left out, as in synthesis.
set fh [open $sta_rpt/summary.rpt]
set sta [read $fh]
close $fh
set tns  0
set nvio 0
regexp {View:view_tt\) \(EL:Setup\).*?GroupType:Standard.*?\n\s*(-?[0-9.]+):(-?[0-9.]+):([0-9]+)\s} $sta -> sum_wns tns nvio

# Power in mW
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
