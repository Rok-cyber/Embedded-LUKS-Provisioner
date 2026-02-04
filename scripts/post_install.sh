#!/bin/bash
# =================================================================
# Project: SecurePi-AutoDeploy (Phase 2)
# Description: Post-reboot environment setup and system verification.
# =================================================================

sleep 10
echo "--- Finalizing Environment (Phase 2) ---"

# Move to the secure python directory
# (Path adjusted for portfolio generality)
cd /home/dsi/secure_vault/py

# Install dependencies
echo "📦 Installing Python dependencies..."
sudo apt update && sudo apt install -y python3-pip
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt --break-system-packages
fi

# Mark installation as complete
touch /home/dsi/INSTALLATION_DONE
echo "------------------------------------------------------------"
echo "🎉 ALL Python libraries are installed. System is ready."
echo "------------------------------------------------------------"

# Diagnostic checks
echo "📊 Running system health checks..."
df -h
sudo systemctl status mariadb --no-pager

# Self-destruct: Remove post-install service and script for security
echo "🧹 Cleaning up post-install artifacts..."
sudo systemctl disable post-install.service
sudo rm -f /etc/systemd/system/post-install.service
# The script deletes itself
sudo rm -f "$0"
