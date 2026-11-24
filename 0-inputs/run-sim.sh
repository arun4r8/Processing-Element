#!/bin/bash
# ── Simulation: smoke test and activity VCD ──────────────────────────────────
cd "$(dirname "$0")"
rm -rf logs outputs
mkdir -p logs outputs
cd logs
. /home/projects/Modules/init/bash
module load cadence

# Activity runs at the clock period in pe.sdc
period=$(awk '$1 == "set" && $2 == "clock_period" { print $3 }' ../pe.sdc)

xrun -64bit -sv +define+NO_SHM -top pe_smoke_tb \
    -F ../filelist.f ../tb/pe_smoke_tb.sv -l smoke.log
xrun -64bit -sv -access +r -top pe_activity_tb \
    +define+CLK_PERIOD=$period +define+VCD_FILE=\"../outputs/pe.vcd\" \
    -F ../filelist.f ../tb/pe_activity_tb.sv -l activity.log
