# ── PDK selection ─────────────────────────────────────────────────────────────
# Sourced by every tool script. Sets every PDK-specific name in one place so the
# stage scripts stay identical between sky130 (LRC) and gsclib045 (chamber).
# $PE_PDK comes from 0-inputs/env.sh.

set root_dir [file normalize [file join [file dirname [info script]] ..]]
set pdk      [expr {[info exists ::env(PE_PDK)] ? $::env(PE_PDK) : "sky130"}]
set cpus     [expr {[info exists ::env(PE_CPUS)] ? $::env(PE_CPUS) : 2}]

switch -- $pdk {
  sky130 {
    set sc        $root_dir/pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
    set lib_setup $sc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
    set lib_hold  $lib_setup
    set lefs      [list $sc/techlef/sky130_fd_sc_hd__nom.tlef $sc/lef/sky130_fd_sc_hd.lef]
    set qrc       $root_dir/pdk/sky130/qrc/qrcTechFile
    set stream_map $root_dir/pdk/sky130/sky130A/libs.tech/klayout/tech/sky130A.map
    set cell_gds  $sc/gds/sky130_fd_sc_hd.gds
    set stream_unit 1000
    set vdd       1.8
    set site      unithd
    set process_node 130
    # pg pins: {global_net pin_name} pairs
    set pg_pins   {VDD VPWR VSS VGND VDD VPB VSS VNB}
    set drv_cell  sky130_fd_sc_hd__buf_2
    set tie_cells sky130_fd_sc_hd__conb_1
    set endcap    sky130_fd_sc_hd__decap_3
    set welltap   sky130_fd_sc_hd__tapvpwrvgnd_1
    set welltap_interval 26.0
    set fillers   {sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1}
    set cts_bufs  {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_16}
    set cts_invs  {sky130_fd_sc_hd__clkinv_1 sky130_fd_sc_hd__clkinv_2 sky130_fd_sc_hd__clkinv_4 sky130_fd_sc_hd__clkinv_8 sky130_fd_sc_hd__clkinv_16}
    set hold_bufs {sky130_fd_sc_hd__dlygate4sd1_1 sky130_fd_sc_hd__dlygate4sd2_1 sky130_fd_sc_hd__buf_2}
    set phys_cell_regex {__(fill|decap|tapvpwrvgnd)_}
    # layers (odd horizontal, even vertical)
    set m1 met1; set pin_h met3; set pin_v met2
    set ring_h met5; set ring_v met4; set stripe_layer met4
    set ring_width 1.6;  set ring_spacing 1.6;  set ring_offset 1.6
    set stripe_width 1.0; set stripe_spacing 1.0; set stripe_pitch 30.0
    set top_route met5;  set cts_bottom met2; set cts_top met4
    set ndr_layers met1:met5
    set em_models $root_dir/7-emir/em.models
    set pad_via   via4
  }
  gsclib045 {
    foreach v {LIB_SS LIB_FF LEF_TECH LEF_MACRO} {
      if {![info exists ::env($v)]} { error "pdk.tcl: \$$v not set; source setup.sh" }
    }
    set lib_setup $::env(LIB_SS)                     ;# slow corner for setup
    set lib_hold  $::env(LIB_FF)                     ;# fast corner for hold
    set lefs      [list $::env(LEF_TECH) $::env(LEF_MACRO)]
    set qrc       [expr {[info exists ::env(PE_QRC_TECH)] ? $::env(PE_QRC_TECH) : ""}]
    set stream_map [expr {[info exists ::env(STREAM_MAP)] ? $::env(STREAM_MAP) : ""}]
    set cell_gds  [expr {[info exists ::env(STDCELLS_GDS)] ? $::env(STDCELLS_GDS) : ""}]
    set stream_unit 2000
    set vdd       1.0
    set site      CoreSite
    set process_node 45
    set pg_pins   {VDD VDD VSS VSS}
    set drv_cell  BUFX4
    set tie_cells {TIEHI TIELO}
    set endcap    ""                                  ;# gsclib045 rows need no end caps
    set welltap   ""                                  ;# taps are inside every cell
    set welltap_interval 0
    set fillers   {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1}
    set cts_bufs  {CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16}
    set cts_invs  {CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX8 CLKINVX12 CLKINVX16}
    set hold_bufs {DLY1X1 DLY2X1 DLY3X1 DLY4X1 BUFX2 BUFX3}
    set phys_cell_regex {^FILL[0-9]+$}
    set m1 Metal1; set pin_h [expr {[info exists ::env(PIN_LAYER_H)] ? $::env(PIN_LAYER_H) : "Metal3"}]
    set pin_v [expr {[info exists ::env(PIN_LAYER_V)] ? $::env(PIN_LAYER_V) : "Metal2"}]
    set ring_h Metal5; set ring_v Metal6; set stripe_layer Metal6
    set ring_width 1.0;  set ring_spacing 0.5;  set ring_offset 0.5
    set stripe_width 0.8; set stripe_spacing 0.5; set stripe_pitch 20.0
    set top_route Metal6; set cts_bottom Metal3; set cts_top Metal6
    set ndr_layers Metal1:Metal6
    set em_models ""                                  ;# no EM limits known for gpdk045 yet
    set pad_via   Via5
  }
  default { error "pdk.tcl: unknown PE_PDK '$pdk'" }
}

# Keep only the cells the loaded library really has (call after init_design / library load).
proc existing_cells {l} {
  set o {}
  foreach c $l { if {$c ne "" && [llength [get_db base_cells $c]]} { lappend o $c } }
  return $o
}
puts "pdk.tcl: PE_PDK=$pdk site=$site vdd=$vdd cpus=$cpus"
