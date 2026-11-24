#!/bin/bash
# ── STA run ──────────────────────────────────────────────────────────────────
cd "$(dirname "$0")"
rm -rf logs outputs reports
mkdir -p logs outputs reports
cd logs
. /home/projects/Modules/init/bash
module load cadence
tempus -stylus -no_gui -files ../sta.tcl -log sta
