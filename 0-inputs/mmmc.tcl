# ── Corners ──────────────────────────────────────────────────────────────────
# One corner: typical (tt, 25 C, 1.80 V), the same library synthesis uses.
# Read by floorplan (saved in the db for place, cts, route) and by sta.
# Expects $sc, $qrc and $sdc from the calling script.

create_library_set -name lib_tt -timing $sc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
create_timing_condition -name tc_tt -library_sets lib_tt
create_rc_corner -name rc_nom -qrc_tech $qrc
create_delay_corner -name dc_tt -timing_condition tc_tt -rc_corner rc_nom
create_constraint_mode -name func -sdc_files $sdc
create_analysis_view -name view_tt -constraint_mode func -delay_corner dc_tt

set_analysis_view -setup view_tt -hold view_tt
