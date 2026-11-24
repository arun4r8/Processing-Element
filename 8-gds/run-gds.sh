#!/bin/bash
# ── GDS run ──────────────────────────────────────────────────────────────────
cd "$(dirname "$0")"
rm -rf logs outputs reports
mkdir -p logs outputs reports
cd logs
. /home/projects/Modules/init/bash
module load cadence
innovus -stylus -batch -no_gui -files ../gds.tcl -log gds
