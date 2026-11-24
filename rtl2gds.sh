#!/bin/bash
# ── RTL to GDS ───────────────────────────────────────────────────────────────
# Runs every stage in order. Each stage writes its logs to <stage>/logs.
# Stops if a run script exits with an error. A tool can stop on a script error
# and still exit cleanly, so check each stage's logs and reports as well.
cd "$(dirname "$0")"
set -ex

./0-inputs/run-sim.sh
./1-syn/run-syn.sh
./2-floorplan/run-floorplan.sh
./3-place/run-place.sh
./4-cts/run-cts.sh
./5-route/run-route.sh
./6-sta/run-sta.sh
./7-emir/run-emir.sh
./8-gds/run-gds.sh
