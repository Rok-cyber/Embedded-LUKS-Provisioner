# 🛡️ SecurePi-AutoDeploy
> **Automated, Hardware-Bound Secure Deployment System for Raspberry Pi**

<p align="center">
  <img src="https://img.shields.io/badge/OS-Raspberry%20Pi-C51A4A?style=for-the-badge&logo=Raspberry-Pi">
  <img src="https://img.shields.io/badge/Security-LUKS-blue?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/Language-C%20%2F%20Bash-00599C?style=for-the-badge&logo=c">
</p>

---

## 📖 Overview
This project provides a robust, **two-stage automated installation process**. It focuses on hardware-level data security through **LUKS encryption** and zero-touch deployment using orchestrated systemd services.

## 🏗️ System Architecture & Partition Layout
The system is designed to isolate the immutable OS from the encrypted data vault.


- **Partition 1 (SDA1/Boot):** Standard bootloader & kernel config.
- **Partition 2 (SDA2/RootFS):** Optimized 12GB immutable OS layer.
- **Partition 3 (SDA3/Vault):** Hardware-bound LUKS encrypted storage for sensitive data.


## 🛠️ Golden Image Creation Workflow
To ensure rapid mass deployment, a "Golden Image" strategy was implemented:

1. **Shrink & Optimize:** Reduced the live filesystem to a 12GB footprint using `resize2fs`.
2. **Sector-Level Extraction:** Utilized `dd` to capture only the populated sectors, leaving 110MB of trailing free space to ensure compatibility across different 32GB EMMC vendors.
3. **High-Ratio Compression:** Achieved a **97% compression rate** (31GB -> 808MB) for efficient network distribution.

  
### 🎯 Problem & Solution
* **Problem**: Unauthorized disk cloning and data theft of embedded devices.
* **Solution**: Binding the encrypted storage to unique hardware identifiers (CPU Serial/SD CID) to ensure data stays on the designated hardware.

---

## 🚀 Key Features

| Feature | Description |
| :--- | :--- |
| **🔐 HW-Bound Key** | Derives unique encryption keys from CPU Serial and SD CID. |
| **🤖 Zero-Touch** | Two-stage orchestration handles everything from partitioning to reboot setup. |
| **🛡️ Self-Cleaning** | Automatically removes installation scripts post-setup to prevent reverse engineering. |
| **🗄️ Service Integrity** | Ensures encrypted vault is ready before services like MariaDB start. |

---


## 💡 Engineering Challenges & Troubleshooting

### **Issue: Zero-byte file generation during image extraction**
- **Symptoms:** Installation scripts appeared as 0-byte files in the flashed image despite successful copying.
- **Root Cause:** Kernel write cache latency and `sync` command omission before `dd` extraction.
- **Solution:** - Forced filesystem synchronization using `sync`.
  - Implemented automated log rotation/cleanup to prevent disk-full errors during the extraction process.
  - Verified image integrity using loopback devices (`losetup`) before final release.



## 🛠️ Usage
1. Flash the golden image to your Raspberry Pi.
2. The `secure-deploy.service` will trigger `deploy.sh` on first boot.
3. The system will automatically partition, encrypt, and reboot.
4. Post-reboot, the encrypted volume is automatically mounted, and the deployment scripts are securely wiped.

---

## 📁 Project Structure

```text
├── 📂 src/
│   ├── 📄 keygen.c        # Hardware-bound key derivation logic
│   └── 📄 unlocker.c      # Boot-time LUKS auto-unlock utility
├── 📂 scripts/
│   ├── 📄 deploy.sh       # Main orchestrator (Phase 1)
│   └── 📄 post_install.sh # Post-reboot environment setup (Phase 2)
├── 📂 configs/
│   └── 📄 secure-deploy.service # systemd unit template
└── 📄 README.md
