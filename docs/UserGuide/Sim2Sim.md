# Sim2Sim Verification

Use this guide to validate your ONNX controller in MuJoCo before going to real hardware. You can drive the controller with either the motion server (scripted motions) or live teleop; both publish the same Redis action keys that the controller consumes.

---

## Prerequisites

- `twist2` conda env activated (Python 3.8) with Mujoco, ONNX Runtime, and TWIST2 deps installed.
- Redis server running and reachable (default: localhost:6379).
- ONNX checkpoint available (default: `assets/ckpts/twist2_1017_20k.onnx`).
- GPU drivers/CUDA for best performance (optional but recommended).

---

## Quick start (default setup)

Terminal 1 — low-level controller in MuJoCo:
```bash
conda activate twist2
./sim2sim.sh
```

Terminal 2 — motion source (pick one):
- **Scripted motion:**  
  ```bash
  conda activate twist2
  ./run_motion_server.sh
  ```
- **Teleop (PICO + GMR):**  
  ```bash
  conda activate gmr
  ./teleop.sh
  ```

You should see the MuJoCo viewer running the policy, driven by the chosen action source.

---

## What sim2sim.sh does

- Launches `deploy_real/server_low_level_g1_sim.py` with:
  - MuJoCo model: `assets/g1/g1_sim2sim_29dof.xml`
  - ONNX policy: `assets/ckpts/twist2_1017_20k.onnx` (override by editing the script)
  - Policy frequency: 100 Hz (decimation inside the script)
  - Redis I/O:
    - Reads actions: `action_body_unitree_g1_with_hands`, `action_hand_left_*`, `action_hand_right_*`, `action_neck_*`
    - Publishes state: `state_body_*`, `state_hand_*` (zeros in sim), `state_neck_*`, `t_state`
- Opens a MuJoCo passive viewer for visualization.

---

## Customizing the run

- **Different ONNX:** Edit `ckpt_path` in `sim2sim.sh`.
- **Headless / no viewer:** Modify `server_low_level_g1_sim.py` to skip `launch_passive` (or run in a virtual display).
- **Policy frequency:** Adjust `--policy_frequency` in `sim2sim.sh` (affects sim decimation).
- **Redis host:** Set `redis_ip` in your action source scripts (teleop/motion server) if Redis is remote.

---

## Tips & troubleshooting

- **No motion:** Check Redis keys: `redis-cli get action_body_unitree_g1_with_hands`; ensure your source script is publishing.
- **Slow viewer:** Lower policy frequency or disable extra visuals; ensure GPU acceleration is available for MuJoCo rendering.
- **Shape errors:** Ensure action sources publish 35-D mimic obs + 7-D hand poses; check for JSON parse errors in the controller log.
- **Stutter/jitter from teleop:** Enable smoothing in `teleop.sh` (`--smooth`) or reduce `--target_fps`.
- **ONNX runtime errors:** Re-export via `to_onnx.sh`; confirm `onnxruntime-gpu` is installed in `twist2`.

---

## Next steps

- Move to real hardware: [Sim2Real with Unitree (EN)](Sim2Real_Unitree_en.md)
- Review teleop details: [Teleop Pipeline](TeleopPipeline.md)
- See full training/export flow: [Training & Deployment Overview](TrainingAndDeployment.md)
