#!/bin/bash

# ---- Ensure we're in a conda env and show libpython ----
if [ -z "${CONDA_PREFIX:-}" ]; then
    echo "[ERROR] CONDA_PREFIX is not set. Please 'conda activate twist2' before running this script."
    exit 1
fi

echo "[INFO] Using conda environment at: $CONDA_PREFIX"
echo "[INFO] Checking for libpython3.8 in: $CONDA_PREFIX/lib"
ls "$CONDA_PREFIX"/lib/libpython3.8* 2>/dev/null || echo "[WARN] No libpython3.8* found in $CONDA_PREFIX/lib"

# Add the conda env's lib dir to LD_LIBRARY_PATH so Isaac Gym can find libpython3.8.so.1.0
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:${LD_LIBRARY_PATH:-}"
echo "[INFO] LD_LIBRARY_PATH set to: $LD_LIBRARY_PATH"

# ---- Original script starts here ----

script_dir=$(dirname "$(realpath "$0")")
# motion_file="${script_dir}/assets/example_motions/0807_yanjie_walk_005.pkl"
motion_file="${script_dir}/assets/example_motions/0807_yanjie_walk_001.pkl"

# Change to deploy_real directory
cd "${script_dir}/deploy_real" || exit 1

# by default we use our own laptop as the redis server
redis_ip="localhost"
# this is my unitree g1's ip in wifi
# redis_ip="192.168.110.24"

# Run the motion server
python server_motion_lib.py \
    --motion_file "${motion_file}" \
    --robot unitree_g1_with_hands \
    --vis \
    --redis_ip "${redis_ip}"
    # --send_start_frame_as_end_frame \
    # --use_remote_control \
