#!/usr/bin/env bash
# setup.sh — Install WiFi crash fixes for Intel AX211
# Idempotent: safe to run multiple times
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== WiFi Crash Fix Setup (Intel AX211) ==="
echo ""

# --- 1. NetworkManager power save config ---
NM_CONF="/etc/NetworkManager/conf.d/wifi-powersave-off.conf"
NM_CONTENT="[connection]
wifi.powersave = 2"

if [[ -f "$NM_CONF" ]] && echo "$NM_CONTENT" | cmp -s "$NM_CONF" -; then
    echo "[OK] NetworkManager power save config already installed"
else
    echo "$NM_CONTENT" | sudo tee "$NM_CONF" > /dev/null
    echo "[INSTALL] NetworkManager power save config → $NM_CONF"
fi

# --- 2. iwlwifi module parameters ---
IWLWIFI_CONF="/etc/modprobe.d/iwlwifi-power.conf"
IWLWIFI_CONTENT="# Disable iwlwifi power saving to prevent NMI_INTERRUPT_UMAC_FATAL firmware crashes
options iwlwifi power_save=0
options iwlmvm power_scheme=1"

if [[ -f "$IWLWIFI_CONF" ]] && echo "$IWLWIFI_CONTENT" | cmp -s "$IWLWIFI_CONF" -; then
    echo "[OK] iwlwifi power save config already installed"
else
    echo "$IWLWIFI_CONTENT" | sudo tee "$IWLWIFI_CONF" > /dev/null
    echo "[INSTALL] iwlwifi power config → $IWLWIFI_CONF"
fi

# --- 3. Recovery script ---
RECOVERY_DEST="/usr/local/bin/fix-wifi"
RECOVERY_SRC="$SCRIPT_DIR/fix-wifi.sh"

if [[ -f "$RECOVERY_DEST" ]] && cmp -s "$RECOVERY_SRC" "$RECOVERY_DEST"; then
    echo "[OK] Recovery script already installed"
else
    sudo cp "$RECOVERY_SRC" "$RECOVERY_DEST"
    sudo chmod +x "$RECOVERY_DEST"
    echo "[INSTALL] Recovery script → $RECOVERY_DEST"
fi

echo ""

# --- Apply changes ---
NEED_RESTART=false

# Check if NM power save is currently wrong
CURRENT_PS=$(iwconfig wlp0s20f3 2>/dev/null | grep -oP 'Power Management:\K\S+' || echo "unknown")
if [[ "$CURRENT_PS" == "on" ]]; then
    NEED_RESTART=true
fi

if $NEED_RESTART; then
    echo "[APPLY] Restarting NetworkManager to apply power save config..."
    sudo systemctl restart NetworkManager
    sleep 2
    sudo iwconfig wlp0s20f3 power off 2>/dev/null || true
fi

# --- Verify ---
echo ""
echo "=== Verification ==="
CURRENT_PS=$(iwconfig wlp0s20f3 2>/dev/null | grep -oP 'Power Management:\K\S+' || echo "unknown")
echo "WiFi Power Management: $CURRENT_PS"

KERNEL_PS=$(cat /sys/module/iwlwifi/parameters/power_save 2>/dev/null || echo "unknown")
echo "iwlwifi power_save: $KERNEL_PS (want: 0 or N; takes effect after reboot)"

KERNEL_SCHEME=$(cat /sys/module/iwlmvm/parameters/power_scheme 2>/dev/null || echo "unknown")
echo "iwlmvm power_scheme: $KERNEL_SCHEME (want: 1; takes effect after reboot)"

echo ""
if [[ "$KERNEL_PS" == "Y" || "$KERNEL_PS" == "1" ]]; then
    echo "⚠  Reboot required for iwlwifi module parameter changes to take effect."
    echo "   After reboot, run this script again to verify."
else
    echo "✓ All fixes applied and active."
fi

echo ""
echo "Recovery: run 'sudo fix-wifi' if WiFi crashes again."
