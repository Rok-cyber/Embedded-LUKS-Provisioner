
🛡️ SecurePi-AutoDeploy
Automated, Hardware-Bound Secure Deployment System for Raspberry Pi

<p align="center"><img src="https://img.shields.io/badge/OS-Raspberry%20Pi-C51A4A?style=for-the-badge&logo=Raspberry-Pi"><img src="https://img.shields.io/badge/Security-LUKS-blue?style=for-the-badge&logo=linux"><img src="https://img.shields.io/badge/Language-C%20%2F%20Bash-00599C?style=for-the-badge&logo=c"></p>

📖 <font size="6">Overview</font>
This project provides a robust, two-stage automated installation process. It focuses on hardware-level data security through LUKS encryption and zero-touch deployment using orchestrated systemd services.

🎯 <font size="5">Problem & Solution</font>
Problem: Unauthorized disk cloning and data theft of embedded devices.
Solution: Binding the encrypted storage to unique hardware identifiers (CPU Serial/SD CID) to ensure data stays on the designated hardware.

🚀 <font size="6">Key Features</font>
🔐 HW-Bound KeyDerives unique encryption keys from CPU Serial and SD CID.
🤖 Zero-TouchTwo-stage orchestration handles everything from partitioning to reboot setup.
🛡️ Self-CleaningAutomatically removes installation scripts post-setup to prevent reverse engineering.
🗄️ Service IntegrityEnsures encrypted vault is ready before services like MariaDB start.
📁 <font size="6">Project Structure</font>
├── 📂 src/
│   ├── 📄 keygen.c        # Hardware-bound key derivation logic
│   └── 📄 unlocker.c      # Boot-time LUKS auto-unlock utility
├── 📂 scripts/
│   ├── 📄 deploy.sh       # Main orchestrator (Phase 1)
│   └── 📄 post_install.sh # Post-reboot environment setup (Phase 2)
├── 📂 configs/
│   └── 📄 secure-deploy.service # systemd unit template
└── 📄 README.md

🛠️ <font size="6">Deployment Workflow</font>
Phase 1:
Initial SetupVerify system environment and dependencies.
Generate hardware-specific key via keygen.c.
Format and mount LUKS partition.Migrate sensitive data and purge original files.

Phase 2: Post-Reboot FinalizationAutomatic vault unlock via unlocker.c.
Python dependency installation via pip.
Self-Destruct: All installation scripts are purged for security hygiene.

🔒 <font size="6">Security Hardening</font>[!IMPORTANT]No Logs, No Trace: For maximum security, the system is designed to run without leaving installation logs or temporary setup files.
Stack Protection: Binaries compiled with -fstack-protector-strong.
DB Security: MariaDB override allows access to encrypted mount paths while maintaining ProtectSystem=full.


🤝 <font size="6">Contact</font> Seongrok Lee - @Rok-cyber - rokbnoc@gmail.com
