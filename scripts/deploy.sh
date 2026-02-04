#!/bin/bash

# =================================================================
# Project: SecurePi-AutoDeploy (Main Orchestrator)
# Author: Seongrok Lee (Rok-cyber)
# Description: Automated LUKS encryption, HW-bound key generation, 
#              and secure environment provisioning for Raspberry Pi.
# =================================================================

set -e

# --- [Configuration] ---
TARGET_USER="dsi"
BASE_DIR="/home/$TARGET_USER"
SECURE_VAULT="$BASE_DIR/secure_vault"
TARGET_PARTITION="/dev/mmcblk0p3"
MAPPER_NAME="secure_storage"

echo "--- [Step 1] Initial Preparation & Module Compilation ---"
sudo apt update
sudo apt install -y build-essential libssl-dev cryptsetup dos2unix rsync

# Compile security modules
# [Note] keygen/unlocker source codes are in the src/ directory
gcc ./src/keygen.c -o keygen -lssl -lcrypto
gcc ./src/unlocker.c -o unlocker -lssl -lcrypto -fstack-protector-strong -O2
chmod +x keygen unlocker

echo "--- [Step 2] Hardware-Bound Encryption Setup (LUKS) ---"
sudo mkdir -p "$SECURE_VAULT"

# Generate hardware-bound key using CPU Serial/Machine ID
./keygen
KEY_STR=$(cat ./key.txt | tr -d '\n' | tr -d '\r')

echo "🔐 Formatting and Opening LUKS partition..."
echo -n "$KEY_STR" | sudo cryptsetup luksFormat "$TARGET_PARTITION" --key-file - --batch-mode
echo -n "$KEY_STR" | sudo cryptsetup luksOpen "$TARGET_PARTITION" "$MAPPER_NAME" --key-file -

echo "📂 Mounting Secure Vault..."
sudo mkfs.ext4 "/dev/mapper/$MAPPER_NAME"
sudo mount "/dev/mapper/$MAPPER_NAME" "$SECURE_VAULT"

echo "--- [Step 3] Data Migration & Sanitization ---"
# [Portfolio Note] In production, this migrates application binaries, 
# database assets, and proprietary Python scripts to the encrypted partition.
echo "🚚 Migrating assets to secure storage..."
sudo rsync -av --exclude="$(basename $SECURE_VAULT)" "$BASE_DIR/" "$SECURE_VAULT/"
sync

echo "🧹 Sanitizing base directory (Removing traces)..."
KEEP_LIST=("$(basename $SECURE_VAULT)" "unlocker" "deploy.sh" "src" "scripts" "configs")

for item in "$BASE_DIR"/*; do
    base_item=$(basename "$item")
    should_keep=false
    for keep in "${KEEP_LIST[@]}"; do
        if [[ "$base_item" == "$keep" ]]; then
            should_keep=true
            break
        fi
    done
    if [ "$should_keep" = false ]; then
        sudo rm -rf "$item"
    fi
done

echo "--- [Step 4] System Hardening & Persistence ---"
# Configure MariaDB to allow access to encrypted paths
sudo mkdir -p /etc/systemd/system/mariadb.service.d/
echo -e "[Service]\nProtectHome=false\nProtectSystem=full" | sudo tee /etc/systemd/system/mariadb.service.d/override.conf
sudo systemctl daemon-reload

# Configure Hardware Overlays (CAN, UART, SPI)
CONFIG_FILE="/boot/firmware/config.txt"
OVERLAYS=("dtoverlay=uart10" "dtoverlay=mcp2515,spi1-0,oscillator=16000000,interrupt=23")
for entry in "${OVERLAYS[@]}"; do
    if ! grep -qF "$entry" "$CONFIG_FILE"; then
        echo "$entry" | sudo tee -a "$CONFIG_FILE"
    fi
done

echo "--- [Step 5] Orchestrating Phase 2 (Post-Reboot) ---"
# Move the post-install script to the execution path
# [Note] The script is sourced from the /scripts directory in GitHub
cp ./scripts/post_install.sh "$BASE_DIR/post_install.sh"
chmod +x "$BASE_DIR/post_install.sh"

# Create the temporary systemd service for post-reboot tasks
sudo tee /etc/systemd/system/post-install.service <<EOF
[Unit]
Description=Secure Deploy Post-Install Task
After=network.target mariadb.service
[Service]
Type=simple
ExecStart=/bin/bash $BASE_DIR/post_install.sh
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable post-install.service

echo "--- [Step 6] Self-Destruction & Reboot ---"
# Final self-cleanup of the main installer
sudo rm -f "$BASE_DIR/deploy.sh"

clear
echo "============================================================"
echo "    DEPLOYMENT PHASE 1 COMPLETED: SYSTEM HARDENED"
echo "============================================================"
echo "1. LUKS Partition: Active and Mounted"
echo "2. Security: Installation traces removed"
echo "3. Next: Rebooting in 5 seconds to initiate Phase 2..."

sleep 5
sudo reboot
