# ── Tool environment, shared by every run-*.sh ───────────────────────────────
# Picks the host automatically:
#   chamber : setup.sh already sourced (GSCLIB set) -> gsclib045, Slurm, srun
#   LRC     : UT ECE lab hosts -> module load cadence, sky130
# Override with PE_PDK=sky130|gsclib045.
if [ -z "${PE_PDK:-}" ]; then
  if [ -n "${GSCLIB:-}" ]; then PE_PDK=gsclib045; else PE_PDK=sky130; fi
fi
export PE_PDK
export PE_CPUS="${PE_CPUS:-${SLURM_CPUS_PER_TASK:-2}}"

case "$PE_PDK" in
  gsclib045)
    if [ -z "${GSCLIB:-}" ] || [ ! -f "${LIB_SS:-/nonexistent}" ]; then
      echo "PE_PDK=gsclib045 but \$GSCLIB/\$LIB_SS not set: source ~/pe-apprentice/setup.sh on a compute node first" >&2
      exit 1
    fi
    ;;
  sky130)
    if ! command -v genus >/dev/null 2>&1; then
      . /home/projects/Modules/init/bash
      module load cadence
    fi
    ;;
  *) echo "unknown PE_PDK=$PE_PDK" >&2; exit 1 ;;
esac
echo "env: PE_PDK=$PE_PDK cpus=$PE_CPUS host=$(hostname)"
