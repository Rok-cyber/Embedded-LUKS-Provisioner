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
