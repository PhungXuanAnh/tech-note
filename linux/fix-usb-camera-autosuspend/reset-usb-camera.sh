#!/usr/bin/env bash
# Reset USB camera (DV20) - full software power cycle
# Equivalent to physical unplug/replug
# Fixes "video track is paused" in browsers
#
# Install: sudo cp reset-usb-camera.sh /usr/local/bin/reset-usb-camera
# Usage:   reset-usb-camera
set -euo pipefail

VENDOR="4c4a"
PRODUCT="4a55"

# Find the camera's sysfs device path and USB port
find_camera() {
    for d in /sys/bus/usb/devices/*/idVendor; do
        local dir
        dir=$(dirname "$d")
        local v p
        v=$(cat "$d" 2>/dev/null) || continue
        p=$(cat "$dir/idProduct" 2>/dev/null) || continue
        if [ "$v" = "$VENDOR" ] && [ "$p" = "$PRODUCT" ]; then
            basename "$dir"
            return 0
        fi
    done
    return 1
}

get_bus_and_port() {
    local dev_name="$1"
    local bus="${dev_name%%-*}"
    local port="${dev_name#*-}"
    port="${port%%.*}"
    echo "$bus $port"
}

DEV=$(find_camera) || { echo "ERROR: Camera (${VENDOR}:${PRODUCT}) not found. Is it plugged in?"; exit 1; }
echo "Found camera at USB device: $DEV"

read -r BUS PORT <<< "$(get_bus_and_port "$DEV")"
echo "USB Bus: $BUS, Port: $PORT"

# Find the hub device file
HUB_DEV="/dev/bus/usb/$(printf "%03d" "$BUS")/001"
if [ ! -c "$HUB_DEV" ]; then
    echo "ERROR: Could not find root hub device at $HUB_DEV"
    exit 1
fi
echo "Root hub: $HUB_DEV"

# Step 1: Power cycle the USB port using hub port power control
echo ""
echo "Step 1/2: Power cycling USB port $PORT..."
sudo python3 -c "
import fcntl, struct, os, time
USBDEVFS_CONTROL = 0xc0185500
PORT_POWER = 8
fd = os.open('$HUB_DEV', os.O_RDWR)

# Clear PORT_POWER (power off)
buf = struct.pack('BBHHHIq', 0x23, 0x01, PORT_POWER, $PORT, 0, 5000, 0)
fcntl.ioctl(fd, USBDEVFS_CONTROL, buf)
print('  Port power OFF')

time.sleep(3)

# Set PORT_POWER (power on)
buf = struct.pack('BBHHHIq', 0x23, 0x03, PORT_POWER, $PORT, 0, 5000, 0)
fcntl.ioctl(fd, USBDEVFS_CONTROL, buf)
print('  Port power ON')

os.close(fd)
"

echo "  Waiting for device to re-enumerate..."
sleep 3

# Step 2: Ensure autosuspend is disabled
echo "Step 2/2: Disabling autosuspend..."
sudo udevadm trigger --subsystem-match=usb
sleep 1

# Verify
DEV2=$(find_camera) || { echo "ERROR: Camera did not come back after power cycle!"; exit 1; }
SYSFS2="/sys/bus/usb/devices/$DEV2"
if [ -f "$SYSFS2/product" ]; then
    PRODUCT_NAME=$(cat "$SYSFS2/product")
    POWER=$(cat "$SYSFS2/power/control" 2>/dev/null || echo "unknown")
    echo ""
    echo "Camera reset successful: $PRODUCT_NAME"
    echo "  Autosuspend: $POWER"
    echo "  Device: $DEV2"
    echo ""
    echo "Refresh your browser tab to use the camera."
else
    echo "ERROR: Camera did not re-enumerate properly"
    exit 1
fi
