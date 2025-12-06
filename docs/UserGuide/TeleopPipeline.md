# Teleop Pipeline

This guide shows how to run live teleoperation with PICO + XRoboToolkit + GMR, and how it connects to the TWIST2 low-level controller (sim or real). It assumes you have the `gmr` and `twist2` conda envs ready and Redis running. For installation details, see [Installation](../Getting%20Started/Installation.md).

---

## What the pipeline does

- **Headset + controllers + trackers** stream body/hand poses via XRoboToolkit.
- **GMR teleop script** retargets human motion to robot mimic observations and hand poses.
- **Redis** carries actions (`action_*`) to the low-level controller.
- **Low-level controller** (sim or real) runs the ONNX policy and sends PD targets to the robot or MuJoCo.

---

## Requirements

- **Hardware:** PICO 4 Ultra (enterprise mode with VST), body trackers, VR controllers; Unitree G1/H1/H1_2 for real runs; E-stop available.
- **Software/services:**
  - XRoboToolkit PC Service installed and running on the PC.
  - PICO headset with XRoboToolkit app installed (developer mode + adb for install).
  - Redis server reachable by both teleop PC and controller PC.
- **Envs:** `gmr` (Python 3.10+) for teleop; `twist2` (Python 3.8) for low-level controller.
- **Network:** Stable LAN; set `redis_ip` in `teleop.sh` if Redis is remote.

---

## Launch sequences

### A) Teleop → Real robot
1. Terminal A (`twist2`): low-level controller to robot
   ```bash
   conda activate twist2
   ./sim2real.sh      # edit NIC inside if needed
   ```
2. Terminal B (`gmr`): teleop publisher
   ```bash
   conda activate gmr
   ./teleop.sh        # edit redis_ip/height/target_fps if needed
   ```

### B) Teleop → Simulation (MuJoCo)
1. Terminal A (`twist2`): controller in sim
   ```bash
   conda activate twist2
   ./sim2sim.sh
   ```
2. Terminal B (`gmr`): teleop publisher
   ```bash
   conda activate gmr
   ./teleop.sh
   ```

### C) Optional: record while teleoping
Add a third terminal:
```bash
conda activate twist2
python deploy_real/server_data_record.py --task_name teleop_run --data_folder ./logs
```

---

## Teleop controls (state machine)

From `deploy_real/xrobot_teleop_to_robot_w_hand.py`:

- **States:** `idle → teleop → pause → teleop ...`; `exit` ends program.
- **Buttons (PICO controllers):**
  - Right controller `key_one`: cycle states (idle/teleop/pause).
  - Left controller `key_one`: exit.
  - Left controller `axis_click`: emergency stop (kills `sim2real.sh` process).
  - Left joystick: root xy velocity + yaw velocity.
  - Right joystick: fine-tune root xy/yaw velocity.
  - Triggers/grips: hand open/close (stepwise interpolation).
- **Auto-start:** transitions from idle to teleop when motion data is available.

---

## Key Redis channels

- Actions (from teleop or motion server):
  - `action_body_unitree_g1_with_hands` (35-D mimic obs)
  - `action_hand_left_unitree_g1_with_hands`, `action_hand_right_unitree_g1_with_hands`
  - `action_neck_unitree_g1_with_hands` (optional)
  - `t_action`
- State (from low-level controller):
  - `state_body_unitree_g1_with_hands`, `state_hand_left_*`, `state_hand_right_*`, `state_neck_*`
  - `t_state`
- Controller telemetry:
  - `controller_data` (button/axis state mirrored by teleop script)

Swap the suffix if you use a different robot alias.

---

## Tuning tips

- **FPS:** In `teleop.sh`, adjust `--target_fps` to match network/GPU; enable `--measure_fps` for debugging.
- **Height:** `--actual_human_height` improves retargeting scale.
- **Smoothing:** Enable `--smooth` in `teleop.sh` for steadier mimic obs if motion is jittery.
- **Network:** Use wired LAN when possible; ensure Redis IP matches across terminals.
- **Safety:** Keep E-stop reachable; start in a neutral pose; avoid large step inputs.

---

## Troubleshooting

- **No motion / empty keys:** `redis-cli get action_body_unitree_g1_with_hands` to confirm publishing; check Redis IP in scripts.
- **Viewer slow in sim:** Lower `--policy_frequency` in `sim2sim.sh` or disable extra visuals.
- **Teleporting/jerk:** Use smoothing, verify tracker calibration, ensure correct human height.
- **Hand commands ignored:** Confirm `--use_hand` in `sim2real.sh` and that hand controllers are powered/connected.
- **Neck not moving:** Check `action_neck_*` updates; verify neck controller is running (see [Neck Module](../Concepts/NeckModule.md)).

---

## Related docs

- [Installation](../Getting%20Started/Installation.md)
- [Environments (`twist2` & `gmr`)](../Getting%20Started/Environments.md)
- [Training & Deployment Overview](TrainingAndDeployment.md)
- [Sim2Real with Unitree (EN)](Sim2Real_Unitree_en.md)
- [Sim2Sim Verification](Sim2Sim.md)
