# Sim2Real with Unitree (EN)

Run the TWIST2 ONNX controller on a Unitree G1/H1/H1_2. This page follows the practical flow from the Unitree deployment guide—network prep, robot bring-up, and pairing with TWIST2 teleop or scripted motions.

---

## Network & robot prep

- **Example IPs (Unitree defaults):**
  - Robot: `192.168.123.164`
  - LiDAR (if present): `192.168.123.120`
  - Workstation (set static): e.g., `192.168.123.222` / `255.255.255.0`
- **Cable:** Wired Ethernet from workstation to robot.
- **Interface name:** Find with `ifconfig`/`ip a` (e.g., `enp3s0`, `eno1`); you will set this in `sim2real.sh`.
- **Mode:** Start robot hoisted; wait for **zero torque mode**. Enter **debugging mode** with `L2+R2` on the Unitree remote (joints become damped).
- **Zero pose:** Keep the robot in the hoist until default pose is confirmed.

---

## Prerequisites (software)

- `twist2` env (Python 3.8): ONNX Runtime (GPU), Mujoco/Isaac deps, Redis client.
- `gmr` env (Python 3.10+): GMR + XRoboToolkit + PICO SDK (for teleop).
- Redis running and reachable (default localhost).
- ONNX checkpoint ready (default `assets/ckpts/twist2_1017_20k.onnx`).

---

## Bring-up & launch (teleop → real robot)

1) **Connect and set NIC**  
   - Configure workstation IP (e.g., `192.168.123.222/24`) on the NIC plugged into the robot.  
   - Record NIC name (e.g., `enp3s0`).

2) **Start low-level controller (terminal A, `twist2`)**
   ```bash
   conda activate twist2
   ./sim2real.sh   # edit net/ckpt inside; --use_hand if hands are powered
   ```
   - Reads `action_*` from Redis, builds TWIST2 obs, runs ONNX, sends PD targets, publishes `state_*`.

3) **Start teleop publisher (terminal B, `gmr`)**
   ```bash
   conda activate gmr
   ./teleop.sh     # set redis_ip/height/target_fps if needed
   ```
   - Streams PICO/XRoboToolkit poses, retargets via GMR, writes `action_body/hand/neck` to Redis.

4) **Robot side sequence**
   - **Zero torque:** initial state after controller starts—joints feel loose.
   - **Default position:** press **Start** on the Unitree remote; robot moves to default pose (keep hoisted, then lower gently).
   - **Motion control:** press **A** to step; use sticks for velocity (left stick: x/y, right stick: yaw).
   - **Exit/damping:** press **Select** to exit and drop to damping; or `Ctrl+C` in terminal.

5) *(Optional)* **Recording (terminal C, `twist2`)**
   ```bash
   conda activate twist2
   python deploy_real/server_data_record.py --task_name sim2real_run --data_folder ./logs
   ```

---

## Alternative: scripted motion → robot

- Terminal A (`twist2`): `./sim2real.sh`
- Terminal B (`twist2`): scripted motions instead of teleop
  ```bash
  conda activate twist2
  ./run_motion_server.sh   # streams example motions as action_* to Redis
  ```

---

## Key Redis channels (Unitree naming)

- **Actions (consumed by robot controller):**  
  `action_body_unitree_g1_with_hands` (35-D), `action_hand_left_*`, `action_hand_right_*`, `action_neck_*`, `t_action`
- **State (published by robot controller):**  
  `state_body_unitree_g1_with_hands`, `state_hand_left_*`, `state_hand_right_*`, `state_neck_*`, `t_state`
- **Motion server gating (optional):**  
  `motion_start_signal`, `motion_exit_signal`

Swap the suffix if you use a different robot alias.

---

## Safety checklist

- E-stop in reach; start hoisted; only lower after default pose is stable.
- Use wired LAN; avoid Wi-Fi for control.
- Keep `--use_hand` off if hands are unpowered.
- Check Redis connectivity before torque: `redis-cli ping` and `get action_body_unitree_g1_with_hands`.

---

## Troubleshooting

- **Robot not moving:** NIC/IP wrong in `sim2real.sh`; actions zero; ONNX path invalid.
- **Jitter/lag:** Enable `--smooth_body`; ensure GPU headroom; clean the LAN.
- **Hands/neck idle:** Verify `--use_hand`; check `action_neck_*` updates; ensure hand controllers are powered.
- **Runtime/ONNX errors:** Re-export with `to_onnx.sh`; confirm `onnxruntime-gpu` in `twist2`.
- **Connection drops:** Inspect cable/switch; restart `sim2real.sh` after link is stable.

---

## Next steps

- Validate in sim first: [Sim2Sim Verification](Sim2Sim.md)  
- Teleop details: [Teleop Pipeline](TeleopPipeline.md)  
- Training/export flow: [Training & Deployment Overview](TrainingAndDeployment.md)  
