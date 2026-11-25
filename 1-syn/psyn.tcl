# ── Synthesis ────────────────────────────────────────────────────────────────

# ── Paths ────────────────────────────────────────────────────────────────────
set stage_dir /misc/scratch/ar76269/pe-apprentice/1-syn
set sc        $stage_dir/../pdk/sky130/sky130A/libs.ref/sky130_fd_sc_hd
set in_dir    $stage_dir/../0-inputs
set out_dir   $stage_dir/outputs
set rpt_dir   $stage_dir/reports

set_db max_cpus_per_server 2

# No LEC mapping files (fv/)
set_db write_verification_files false

# ── Libraries ────────────────────────────────────────────────────────────────
set_db library     $sc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set_db lef_library [list $sc/techlef/sky130_fd_sc_hd__nom.tlef $sc/lef/sky130_fd_sc_hd.lef]
set_db qrc_tech_file $stage_dir/../pdk/sky130/qrc/qrcTechFile

# ── RTL ──────────────────────────────────────────────────────────────────────
read_hdl -sv [list $in_dir/rtl/fxp.sv $in_dir/rtl/pe.sv]
elaborate pe
check_design -unresolved
read_sdc $in_dir/pe.sdc
read_def $stage_dir/../2-floorplan/outputs/pe.floorplan.def

# ── Activity ─────────────────────────────────────────────────────────────────
read_vcd -static -vcd_scope pe_activity_tb.dut $in_dir/outputs/pe.vcd
# Label for the PPA report
set ppa_activity "VCD 0-inputs/outputs/pe.vcd"

# ── Optimizations ────────────────────────────────────────────────────────────
# Add your optimizations here

# ── Synthesis ────────────────────────────────────────────────────────────────

set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

set_db lp_insert_clock_gating true
set_db design:pe .retime true
set_db use_scan_seqs_for_non_dft false
syn_generic -physical
syn_map     -physical
syn_opt
# ── Reports ──────────────────────────────────────────────────────────────────
report_timing > $rpt_dir/pe_timing.rpt
report_area   > $rpt_dir/pe_area.rpt
report_gates  > $rpt_dir/pe_gates.rpt
report_power  > $rpt_dir/pe_power.rpt
report_qor    > $rpt_dir/pe_qor.rpt
report_clock_gating > $rpt_dir/pe_clock_gating.rpt
# ── PPA ──────────────────────────────────────────────────────────────────────
source $in_dir/ppa.tcl
ppa_report $rpt_dir/pe_qor.rpt $rpt_dir/pe_power.rpt $rpt_dir/pe_ppa.rpt

# ── Outputs ──────────────────────────────────────────────────────────────────
write_hdl > $out_dir/pe.v
write_sdc > $out_dir/pe.sdc

exit
