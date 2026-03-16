#!/usr/bin/env bash
# fix-wifi.sh — Recovery script for Intel AX211 WiFi firmware crashes
# Usage: sudo fix-wifi
set -euo pipefail

IFACE="wlp0s20f3"

echo "=== WiFi Recovery ==="

# Step 1: Check if WiFi interface exists
if ! ip link show "$IFACE" &>/dev/null; then
    echo "[FIX] WiFi interface $IFACE not found — reloading driver..."
    modprobe -r iwlmvm iwlwifi 2>/dev/null || true
    sleep 1
    modprobe iwlwifi
    sleep 2
    if ip link show "$IFACE" &>/dev/null; then
        echo "[OK] WiFi interface restored"
    else
        echo "[FAIL] WiFi interface still missing after driver reload"
        exit 1
    fi
else
    echo "[OK] WiFi interface $IFACE exists"
fi

# Step 2: Restart NetworkManager
echo "[FIX] Restarting NetworkManager..."
systemctl restart NetworkManager
sleep 2

if systemctl is-active --quiet NetworkManager; then
    echo "[OK] NetworkManager running"
else
    echo "[FAIL] NetworkManager failed to start"
    exit 1
fi

# Step 3: Disable WiFi power save
iwconfig "$IFACE" power off 2>/dev/null || true
PM=$(iwconfig "$IFACE" 2>/dev/null | grep -oP 'Power Management:\K\S+')
echo "[OK] Power Management: $PM"

# Step 4: Verify WiFi is connected (wait up to 10s)
echo -n "[WAIT] Waiting for WiFi connection"
for i in $(seq 1 10); do
    if nmcli -t -f STATE general 2>/dev/null | grep -q "connected"; then
        echo ""
        SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        echo "[OK] Connected to: $SSID"
        exit 0
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "[WARN] WiFi not connected after 10s. Try: nmcli device wifi connect <SSID>"
exit 0
