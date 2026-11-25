#!/bin/bash
# ── Physical Synthesis run ────────────────────────────────────────────────────────────
cd "$(dirname "$0")"
rm -rf logs outputs reports
mkdir -p logs outputs reports
cd logs
. /home/projects/Modules/init/bash
module load cadence
genus -batch -files ../psyn.tcl -log syn
