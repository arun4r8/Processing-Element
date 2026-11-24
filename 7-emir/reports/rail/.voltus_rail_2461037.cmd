# Voltus_rail Command File

#Result directory
setvar output_directory_name /misc/scratch/ar76269/pe-apprentice/7-emir/reports/rail

#Distributed processing setting
setvar max_cpu 2
setvar nga_enabled true
nga_dp_hosts max_cpu=2 mode=local time_out=3600

#Layout Files
layout_file /tmp/ssv_tmpdir_2461037_oha9hq/eps_out_2461037.def.gz

#Cell Library
cell_library /misc/scratch/ar76269/pe-apprentice/7-emir/logs/pgv/techonly.cl
setvar tesla_accuracy_mode hd
use_cell_view type standard fast
use_cell_view type macro accurate
use_cell_view type io accurate
setvar power_up_fast_mode true
setvar report_msmv_format true
setvar compress_powergrid_database false
# EPS signoff mode with ignoring shorts utilizes voltus early mode with DFM effects
setvar operation_mode early_verification
setvar enable_dfmeffects_in_early true
setvar hierarchy_char /
setvar use_cell_id true
nga_setvar nga_enable_new_transient_analysis true
setvar enable_smx true
setvar ignore_shorts true
setvar enable_manufacturing_effects true
setvar enable_dfmeffects_in_early true
setvar cluster_via_size 4
setvar cluster_via1_ports true
setvar ignore_fillers true
setvar ignore_decaps true
setvar em_model_file /misc/scratch/ar76269/pe-apprentice/7-emir/em.models
include /misc/scratch/ar76269/pe-apprentice/7-emir/em.models
setvar gif_resolution_option low
setvar gif_zoom_topcell_diearea false
setvar tech_file /misc/scratch/ar76269/pe-apprentice/7-emir/../pdk/sky130/qrc/qrcTechFile
setvar keep_log false
setvar enable_report_db true
setvar eiv_report_auto true
nga_setvar nga_current_redistribution true
setvar mge_load_static_pti false
net_voltage VDD 1.8 1.71
power_pin_supply_tolerance 1.26 2.34 net=VDD
net_voltage VSS 0 0.09
power_pin_supply_tolerance 0 0.3 net=VSS
power_domain core pwrnet="VDD" gndnet="VSS"
current_data_file /misc/scratch/ar76269/pe-apprentice/7-emir/reports/power/static_VDD.ptiavg
current_data_file /misc/scratch/ar76269/pe-apprentice/7-emir/reports/power/static_VSS.ptiavg
power_pin VSS auto_vsrc_creation=true layer=via4
power_pin VDD auto_vsrc_creation=true layer=via4
nga_setvar nga_enable_rc_avg_report true
analyze core 1.8 avg 0.10 ir tc rc iv rv vc pv pi rj
