# System Overview

This page gives a high-level view of the TWIST2 stack: what runs where, how the pieces talk, and which scripts to pair for common workflows.

---

## Core roles

- **Motion source (high level):**
  - *Teleop:* PICO + XRoboToolkit + GMR retargeting (`deploy_real/xrobot_teleop_to_robot_w_hand.py`, launched via `teleop.sh`, env: `gmr`).
  - *Scripted motion:* Motion playback (`deploy_real/server_motion_lib.py`, launched via `run_motion_server.sh`, env: `twist2`).
- **Message bus:** Redis (actions + state shared across processes/machines).
- **Policy/controller (low level):**
  - *Simulation:* ONNX policy in MuJoCo (`deploy_real/server_low_level_g1_sim.py`, launched via `sim2sim.sh`, env: `twist2`).
  - *Real robot:* ONNX policy on hardware (`deploy_real/server_low_level_g1_real.py`, launched via `sim2real.sh`, env: `twist2`).
- **Robot/simulator:** Unitree G1/H1/H1_2 or MuJoCo model; receives PD targets from the low-level controller.
- **Optional data capture:** Episode recorder + stereo vision (`deploy_real/server_data_record.py`, env: `twist2`).
- **Optional GUI:** One-stop launcher (`gui.sh`, env: `twist2`).

---

## Data flow (typical teleop-to-robot)

```
PICO + XRoboToolkit  --(body+hand tracking)-->  GMR teleop script
     |                                           (retarget, state machine)
     |                   Redis: action_* keys (mimic obs + hands + neck)
     v
Low-level controller (sim or real)  --(PD targets)--> Robot or MuJoCo
     |
     |  Redis: state_* keys (proprio, hands, neck) + controller signals
     v
Recorder / Visualization
```

- Teleop publishes *actions*; controllers publish *state*. Both share Redis so motion sources and sinks can be swapped (teleop vs. motion lib; sim vs. real).
- Neck module is an optional action/state pair (`action_neck_*`, `state_neck_*`).

---

## Environments & prerequisites

- **Conda envs:** `twist2` (Python 3.8, Isaac Gym/MuJoCo, policy deployment) and `gmr` (Python 3.10+, retargeting/teleop). See [Environments](../Getting%20Started/Environments.md) and [Installation](../Getting%20Started/Installation.md).
- **Redis:** must be running and reachable by all processes (same host or LAN IP).
- **GPU drivers/CUDA:** required for Isaac Gym, ONNX GPU, and GMR acceleration.
- **PICO/XRoboToolkit:** needed only for teleop; ensure services run before launching.

---

## Common launch combinations

- **Teleop → Real robot**
  1. `conda activate twist2 && ./sim2real.sh` (low-level controller to robot)
  2. `conda activate gmr && ./teleop.sh` (teleop publisher)

- **Teleop → Simulation**
  1. `conda activate twist2 && ./sim2sim.sh` (policy in MuJoCo)
  2. `conda activate gmr && ./teleop.sh`

- **Motion playback → Real robot**
  1. `conda activate twist2 && ./sim2real.sh`
  2. `conda activate twist2 && ./run_motion_server.sh`

- **Motion playback → Simulation**
  1. `conda activate twist2 && ./sim2sim.sh`
  2. `conda activate twist2 && ./run_motion_server.sh`

- **Optional recording:** add `conda activate twist2 && python deploy_real/server_data_record.py --task_name <name>` alongside any of the above.

---

## Safety & troubleshooting

- Keep an emergency stop reachable (hardware E-stop, or left-controller axis click in teleop script).
- If Redis keys are missing, verify Redis is running and IP/port match across scripts.
- If teleop is slow, check network latency and GMR FPS; lower `target_fps` in `teleop.sh` if needed.
- For Isaac Gym/MuJoCo import errors, re-check that the active env is `twist2` and `LD_LIBRARY_PATH` includes your conda `lib` (see `run_motion_server.sh`).

---

## What to read next

- Pipeline details: [Teleop Pipeline](../UserGuide/TeleopPipeline.md)
- Deployment: [Sim2Real with Unitree (EN)](../UserGuide/Sim2Real_Unitree_en.md)
- Neck module: [Neck Module](NeckModule.md)
