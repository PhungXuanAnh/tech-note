# Fix USB Camera Not Working After Long Uptime

## Problem

USB camera stops working after long laptop uptime (commonly affects cheap cameras like Jieli Technology DV20, `4c4a:4a55`):
- Browser shows **"video track is paused"** on webcam test sites
- Camera appears in `lsusb` and `/dev/video*` but cannot stream
- **Physically unplugging and replugging the camera fixes it**

## Root Cause

Linux kernel USB **autosuspend** suspends idle USB devices after 2 seconds by default. Many USB cameras (especially cheap ones like Jieli-based models) don't wake properly from autosuspend — their firmware enters a corrupted state where the device appears present but cannot deliver video frames.

## Solution

### Quick Setup (Automated)

```bash
sudo ./setup.sh
```

The setup script is idempotent — safe to run multiple times. It will:
1. Install/update the udev rule for all USB cameras
2. Install/update the `reset-usb-camera` script
3. Reload udev rules and verify

### Manual Setup

#### 1. Disable USB Autosuspend for All USB Cameras (Prevents the Problem)

Create a udev rule that matches **all USB cameras** (any device with USB Video Class `0x0e` interface):

```bash
sudo tee /etc/udev/rules.d/99-usb-camera-no-autosuspend.rules << 'EOF'
# Disable USB autosuspend for all USB cameras (UVC class 0x0e)
# Matches video interfaces and sets power/control on the parent USB device
ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="0e", RUN+="/bin/sh -c 'echo on > /sys%p/../power/control'"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb
```

> **Why `ATTR{bInterfaceClass}=="0e"` instead of `DRIVERS=="uvcvideo"`?**
> The `uvcvideo` driver binds at the USB **interface** level (e.g., `1-4:1.0`), but `power/control` exists only on the parent USB **device** (e.g., `1-4`). Using `DRIVERS=="uvcvideo"` with `ATTR{power/control}="on"` silently fails because the matched interface doesn't have that attribute. Instead, we match on `bInterfaceClass=="0e"` (USB Video class) and use `RUN` to write to the parent's `power/control` via `../power/control`.

Verify:

```bash
# Check autosuspend status for all USB video devices
for iface in /sys/bus/usb/devices/*:*/bInterfaceClass; do
  [ "$(cat "$iface" 2>/dev/null)" = "0e" ] || continue
  dev_path=$(dirname "$iface")/..
  dev=$(basename "$(readlink -f "$dev_path")")
  echo "$dev: power/control=$(cat "$dev_path/power/control" 2>/dev/null)"
done | sort -u
# Should show: power/control=on for each camera
```

#### 2. Reset Script (Fixes Already-Stuck Camera — No Physical Replug Needed)

Install the reset script:

```bash
sudo cp reset-usb-camera.sh /usr/local/bin/reset-usb-camera
sudo chmod +x /usr/local/bin/reset-usb-camera
```

Usage:

```bash
reset-usb-camera
```

The script performs a **full USB port power cycle** via hub port power control ioctls:
1. Sends `ClearPortFeature(PORT_POWER)` to the root hub — cuts VBUS power to the port (equivalent to physical unplug)
2. Waits 3 seconds
3. Sends `SetPortFeature(PORT_POWER)` — restores power (equivalent to physical replug)
4. Re-applies udev rules to disable autosuspend
5. Verifies camera re-enumeration

This is equivalent to physically unplugging and replugging the camera. After running, refresh your browser tab.

> **Note:** The xHCI root hub may report "No power switching" but still honor per-port power control requests via `ClearPortFeature`/`SetPortFeature` ioctls. This was verified to work on Intel xHCI (device 7a60).

## How to Identify Your Camera

```bash
# List USB cameras
lsusb | grep -i camera

# Find video devices
for v in /dev/video*; do
  echo -n "$v: "
  v4l2-ctl -d "$v" --info 2>&1 | grep "Card type" || echo "(no info)"
done

# Check autosuspend status
cat /sys/bus/usb/devices/1-4/power/control      # "on" = good, "auto" = bad
cat /sys/bus/usb/devices/1-4/power/runtime_status # "active" = good, "suspended" = bad
```

## Technical Details

### Why Software Reset Sometimes Fails

| Reset Method | Cuts VBUS Power? | Resets Firmware? |
|---|---|---|
| Physical unplug/replug | Yes | Yes |
| **Hub port power cycle** (our script) | **Yes** | **Yes** |
| `uhubctl` (if supported) | Yes | Yes |
| `usbreset` (USBDEVFS_RESET) | No | Sometimes |
| `authorized` toggle (0→1) | No | No |
| `modprobe -r uvcvideo` | No | No |

Many cheap USB cameras' internal microcontrollers need a full VBUS power cycle to reset their firmware state. Our script achieves this by sending USB hub port power control commands directly to the xHCI root hub, which is equivalent to a physical unplug/replug.

### Key Kernel Messages

```
usb 1-4: 3:1: cannot get freq at ep 0x82    # Normal for Jieli cameras (audio quirk)
uvcvideo 1-4:1.1: Failed to resubmit video URB (-1)  # Camera is stuck
```

### Adapting for Other Cameras

The udev rule uses `ATTR{bInterfaceClass}=="0e"` which automatically covers all USB cameras — no changes needed.

For the reset script, if your camera has a different vendor/product ID, update the `VENDOR` and `PRODUCT` variables:

```bash
lsusb | grep -i camera
# Bus 001 Device 003: ID <vendor>:<product> ...
```

Then edit `/usr/local/bin/reset-usb-camera` and change the `VENDOR` and `PRODUCT` variables.
