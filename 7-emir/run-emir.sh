#!/bin/bash
# ── EMIR run ─────────────────────────────────────────────────────────────────
cd "$(dirname "$0")"
rm -rf logs outputs reports
mkdir -p logs outputs reports
cd logs
. /home/projects/Modules/init/bash
module load cadence
voltus -stylus -no_gui -files ../emir.tcl -log emir
