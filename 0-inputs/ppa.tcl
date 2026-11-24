# ── PPA report ──────────────────────────────────────────────────────
# FOM = perf^alpha / (power^beta * area)

# Area limit, um^2
set ppa_area_cap_um2 30000.0

# FOM exponents
set ppa_alpha 3.0
set ppa_beta  0.5

# Baseline
set ppa_base_f_mhz 125.0
set ppa_base_p_mw  1.28690
set ppa_base_a_um2 8386.794
set ppa_base_desc  "reference pe.sv, pe.sdc 8 ns, hd"

# Power activity source
if {![info exists ppa_activity]} { set ppa_activity "vectorless (Genus default)" }

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

  # ── Parse ──
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

  # ── Score ──
  set f_mhz    [expr {1.0e6 / $period_ps}]
  set perf     [expr {$f_mhz * $macs}]
  set p_mw     [expr {$tot_w * 1.0e3}]
  set t_pass   [expr {$wns >= 0 && $nvio == 0}]
  set a_pass   [expr {$area_um2 <= $ppa_area_cap_um2}]
  set fom      [expr {($t_pass && $a_pass) ? pow($perf, $alpha) / (pow($p_mw, $beta) * $area_um2) : 0.0}]

  # ── Write ──
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
