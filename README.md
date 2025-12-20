# TWIST2: Scalable, Portable, and Holistic Humanoid Data Collection System

By Yanjie Ze, Siheng Zhao, Weizhuo Wang, Angjoo Kanazawa†, Rocky Duan†, Pieter Abbeel†, Guanya Shi†, Jiajun Wu†, C. Karen Liu†, 2025  
(† Equal Advising)

> **Note (ETHRC):**  
> This README and the documentation structure in this fork have been prepared by the team at [**ETH Robotics Club (ETHRC)**](https://www.ethrobotics.ch/) to make TWIST2 easier to install, integrate and operate in our internal environment.  
> All credit for the TWIST2 system itself goes to the original authors listed above.

---

## Project Links

- 🌐 **Website:** <https://yanjieze.com/TWIST2>  
- 📄 **Paper (arXiv):** <https://arxiv.org/abs/2511.02832>  
- 🎥 **Video:** <https://youtu.be/lTtEvI0kUfo>  

> 🔗 **Full Documentation (ETHRC version):**  
> <https://\<your-org-or-user\>.github.io/TWIST2/>  
> (Update this link to match your GitHub Pages URL.)

---

## What is TWIST2?

**TWIST2** is a scalable, portable, and holistic humanoid data collection system that combines:

- Whole-body motion tracking via VR headsets, controllers, and body trackers  
- Teleoperation of humanoid robots (e.g. Unitree G1 / H1 / H1_2)  
- RL-based low-level controllers trained in simulation (Isaac Gym + Legged Gym + RSL-RL)  
- A modular pipeline for **sim-to-sim** and **sim-to-real** deployment  

In this ETHRC-maintained fork, we focus on:

- Making installation reproducible on our standard Ubuntu + conda stacks  
- Documenting the teleop and data-collection workflows  
- Clarifying how to integrate TWIST2 into internal projects and experiments

---

## Getting Started

For complete instructions, **do not follow this README alone**.  
Use the full docs site instead:

**Start here:**  
- [Installation Guide](https://\<your-org-or-user\>.github.io/TWIST2/GettingStarted/Installation/)  
- [Training & Deployment Overview](https://\<your-org-or-user\>.github.io/TWIST2/UserGuide/TrainingAndDeployment/)  
- [Teleop Pipeline](https://\<your-org-or-user\>.github.io/TWIST2/UserGuide/TeleopPipeline/)  
- [Sim2Real with Unitree](https://\<your-org-or-user\>.github.io/TWIST2/UserGuide/Sim2Real_Unitree_en/)

### Ultra-short summary

- TWIST2 uses **two conda envs**:
  - `twist2` (Python 3.8) – training, low-level controller, sim2sim/sim2real, teleop data collection  
  - `gmr` (Python 3.10+) – online motion retargeting (GMR) + PICO streaming  
- Uses **Redis** as the communication layer between high-level (teleop / motion server) and low-level (RL policy).  
- Comes with:
  - A trained ONNX controller at `assets/ckpts/twist2_1017_20k.onnx`  
  - Example motions in `assets/example_motions`  
  - Optional full TWIST2 dataset for training your own controller

---

## Minimal Quickstart (for testing the provided policy)

> ⚠️ This is only a sketch. For robust setup, follow the full docs.

1. Create and activate the `twist2` environment, install Isaac Gym and TWIST2 deps.  
2. Make sure **Redis** is installed and running.  
3. Use the provided ONNX ckpt:

```bash
# train.sh is only needed if you want to train your own policy
# For direct deployment, you can use the provided ONNX checkpoint.

# Example: run sim2sim verification
bash run_motion_server.sh   # terminal 1 (high-level motion streaming)
bash sim2sim.sh             # terminal 2 (low-level controller)
```

4. For teleop with PICO + XRoboToolkit, set up the `gmr` env and PICO SDK, then follow the **Teleop Pipeline** in the docs.

---

## Citations

If you use TWIST2 in your work, please cite:

```bibtex
@article{ze2025twist2,
  title   = {TWIST2: Scalable, Portable, and Holistic Humanoid Data Collection System},
  author  = {Yanjie Ze and Siheng Zhao and Weizhuo Wang and Angjoo Kanazawa and
             Rocky Duan and Pieter Abbeel and Guanya Shi and Jiajun Wu and
             C. Karen Liu},
  year    = {2025},
  journal = {arXiv preprint arXiv:2511.02832}
}
```

Related works:

```bibtex
@article{ze2025twist,
  title   = {TWIST: Teleoperated Whole-Body Imitation System},
  author  = {Yanjie Ze and Zixuan Chen and Jo{\~a}o Pedro Ara{\'u}jo and Zi-ang Cao and
             Xue Bin Peng and Jiajun Wu and C. Karen Liu},
  year    = {2025},
  journal = {arXiv preprint arXiv:2505.02833}
}

@article{joao2025gmr,
  title   = {Retargeting Matters: General Motion Retargeting for Humanoid Motion Tracking},
  author  = {Joao Pedro Araujo and Yanjie Ze and Pei Xu and Jiajun Wu and C. Karen Liu},
  year    = {2025},
  journal = {arXiv preprint arXiv:2510.02252}
}
```

---

## Contact

* For questions about the **original TWIST2 project**, contact:
  [`yanjieze@stanford.edu`](mailto:yanjieze@stanford.edu)
* For questions about the **ETHRC pipeline/integration**, contact:
[`rzendehdel@ethz.ch`](mailto:rzendehdel@ethz.ch)
