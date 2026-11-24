#!/bin/bash
# ── Simulation on the chamber ────────────────────────────────────────────────
# Same two xrun commands as run-sim.sh (which may not be edited), minus the LRC
# module lines that don't exist on the chamber. source setup.sh first.
cd "$(dirname "$0")"
rm -rf logs outputs
mkdir -p logs outputs
cd logs
[ -n "${GSCLIB:-}" ] || { echo "source ~/pe-apprentice/setup.sh first" >&2; exit 1; }

period=$(awk '$1 == "set" && $2 == "clock_period" { print $3 }' ../pe.sdc)

xrun -64bit -sv +define+NO_SHM -top pe_smoke_tb \
    -F ../filelist.f ../tb/pe_smoke_tb.sv -l smoke.log
xrun -64bit -sv -access +r -top pe_activity_tb \
    +define+CLK_PERIOD=$period +define+VCD_FILE=\"../outputs/pe.vcd\" \
    -F ../filelist.f ../tb/pe_activity_tb.sv -l activity.log
grep -H "SMOKE TEST" smoke.log
