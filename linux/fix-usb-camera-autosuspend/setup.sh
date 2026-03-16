#!/usr/bin/env bash
# Setup script for USB camera autosuspend fix
# Safe to run multiple times (idempotent)
#
# What it does:
#   1. Installs udev rule to disable USB autosuspend for all USB cameras
#   2. Installs reset-usb-camera script for fixing stuck cameras
#   3. Reloads udev rules and applies to currently connected cameras
#
# Usage: sudo ./setup.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UDEV_RULE="/etc/udev/rules.d/99-usb-camera-no-autosuspend.rules"
RESET_SCRIPT="/usr/local/bin/reset-usb-camera"

# --- Check root ---
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root (sudo ./setup.sh)"
    exit 1
fi

echo "=== USB Camera Fix Setup ==="
echo ""

# --- Step 1: Install udev rule ---
UDEV_CONTENT_FILE=$(mktemp)
cat > "$UDEV_CONTENT_FILE" << 'RULEEOF'
# Disable USB autosuspend for all USB cameras (UVC class 0x0e)
# Matches video interfaces and sets power/control on the parent USB device
ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="0e", RUN+="/bin/sh -c 'echo on > /sys%p/../power/control'"
RULEEOF

if [ -f "$UDEV_RULE" ] && cmp -s "$UDEV_CONTENT_FILE" "$UDEV_RULE"; then
    echo "[OK] udev rule already installed and up-to-date: $UDEV_RULE"
else
    if [ -f "$UDEV_RULE" ]; then
        echo "[UPDATE] Updating udev rule: $UDEV_RULE"
    else
        echo "[INSTALL] Installing udev rule: $UDEV_RULE"
    fi
    cp "$UDEV_CONTENT_FILE" "$UDEV_RULE"
fi
rm -f "$UDEV_CONTENT_FILE"

# --- Step 2: Install reset script ---
if [ -f "$SCRIPT_DIR/reset-usb-camera.sh" ]; then
    if [ -f "$RESET_SCRIPT" ] && cmp -s "$SCRIPT_DIR/reset-usb-camera.sh" "$RESET_SCRIPT"; then
        echo "[OK] Reset script already installed and up-to-date: $RESET_SCRIPT"
    else
        echo "[INSTALL] Installing reset script: $RESET_SCRIPT"
        cp "$SCRIPT_DIR/reset-usb-camera.sh" "$RESET_SCRIPT"
        chmod +x "$RESET_SCRIPT"
    fi
else
    echo "[SKIP] reset-usb-camera.sh not found in $SCRIPT_DIR, skipping reset script install"
fi

# --- Step 3: Reload udev rules ---
echo ""
echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger --subsystem-match=usb
sleep 1

# --- Step 4: Verify ---
echo ""
echo "=== Verification ==="
FOUND=0
seen_devs=""
for iface in /sys/bus/usb/devices/*:*/bInterfaceClass; do
    [ "$(cat "$iface" 2>/dev/null)" = "0e" ] || continue
    dev_path="$(dirname "$iface")/.."
    dev=$(basename "$(readlink -f "$dev_path")")
    power=$(cat "$dev_path/power/control" 2>/dev/null || echo "unknown")
    product=$(cat "$dev_path/product" 2>/dev/null || echo "Unknown USB Camera")

    # Deduplicate (each camera has multiple video interfaces)
    if [[ "$seen_devs" != *"$dev"* ]]; then
        seen_devs="$seen_devs $dev"
        FOUND=$((FOUND + 1))
        if [ "$power" = "on" ]; then
            echo "  [OK] $dev ($product): autosuspend disabled"
        else
            echo "  [WARN] $dev ($product): power/control=$power (expected 'on')"
        fi
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "  No USB cameras detected. The rule will apply when a camera is plugged in."
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "The udev rule will automatically apply to any USB camera plugged in."
echo "If a camera gets stuck, run: reset-usb-camera"
