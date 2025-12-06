# GUI Usage

This page explains the CustomTkinter control center (`gui.py`) that launches common TWIST2 services (sim2sim, sim2real, teleop, motion server, recording) and remote G1 utilities. Run it from the `twist2` env using `gui.sh`.

```bash
conda activate twist2
./gui.sh
```

---

## What the GUI controls

- **Remote G1 (via SSH host `g1`):**
  - **G1 Neck Control** – `bash ~/g1-onboard/docker_neck.sh` (cleanup: `pkill -f neck_teleop.py`)
  - **G1 ZED Teleop** – `bash ~/g1-onboard/docker_zed.sh` (cleanup: `pkill -9 OrinVideoSender`)
  - **G1 ZED Policy** – `bash ~/g1-onboard/docker_zed_policy.sh`
  - Quick actions: `kill_port.sh`, `test_zed.sh`, and “Start Neck & ZED Teleop” (launches both)
  - Connection test: SSH check to host alias `g1`
- **Local services:**
  - **Sim2Sim Deploy** – `bash sim2sim.sh`
  - **Sim2Real Deploy** – `bash sim2real.sh` (cleanup: `pkill -f server_low_level_g1_real_future.py`)
  - **Offline Motion** – `bash run_motion_server.sh`
  - **Online Teleop** – `bash teleop.sh`
  - **Visuomotor Policy Deploy** – `bash /home/ANT.AMAZON.COM/yanjieze/lab42/src/Improved-3D-Diffusion-Policy/deploy_policy.sh` (hardcoded path; edit if you use it)
  - **Data Recording** – `bash data_record.sh` (cleanup: `pkill -f server_data_record.py`)
  - One-click local start: Sim2Real Deploy + Teleop + Data Recording
- **Global controls:**
  - Theme selector (multiple dark/light/EVA variants)
  - “Disable Firewall” button (calls `sudo ufw disable`—use only if you intend to)
  - “EMERGENCY STOP” kills all running panel processes

Each panel shows status (OFFLINE/ONLINE/STARTING/ERROR), command text, output logs, and buttons: START, KILL, CLEAR. Remote panels tunnel commands via SSH (`g1`) with `StrictHostKeyChecking=no`.

---

## How to use it

1. **Prereqs:** `customtkinter` installed in `twist2`; SSH alias `g1` configured for your robot PC; required scripts present in expected paths (see above).
2. **Launch:** `./gui.sh` (activates `twist2`, runs `gui.py`).
3. **Start services:** Click START on individual panels, or use the combined buttons:
   - Remote: “🚀 Start Neck & ZED Teleop”
   - Local: “🚀 Start Sim2Real Deploy & Teleop & Record”
4. **Monitor logs:** Each panel streams stdout/stderr into the embedded terminal view.
5. **Stop services:** Use KILL on a panel; EMERGENCY STOP ends all running panels.

---

## Tips & edits

- **SSH host:** If your robot is not reachable as `g1`, update the SSH target in `gui.py` (`_build_ssh_command` and related calls).
- **Paths:** Adjust the visuomotor deploy path, remote docker scripts, and kill commands to match your setup.
- **Sim2Real NIC/ckpt:** Edit `sim2real.sh` for the correct network interface and ONNX path before launching from the GUI.
- **Firewall button:** It hardcodes `sudo ufw disable`; remove or adapt if you do not want the GUI to modify firewall settings.

---

## Troubleshooting

- **SSH errors:** Confirm key/credentials and host alias `g1`; try `ssh g1` manually.
- **Processes keep running after KILL:** Check cleanup commands; some panels use `pkill` patterns—adjust them if your script names differ.
- **No output:** Ensure commands exist in the repo root (GUI runs with `cwd` at repo root for local panels).
- **Wrong colors/theme glitches:** Themes are applied at startup; change in the dropdown requires restart to take full effect.
