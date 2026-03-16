# Fix WiFi Crashes and Hangs (Intel AX211)

## Problem

- Computer periodically **hangs** (can move between windows but commands/apps freeze)
- WiFi disappears from Settings: **"Oops, something has gone wrong. Please contact your software vendor. NetworkManager needs to be running"**
- WiFi intermittently disconnects and doesn't reconnect

## Root Cause

**Intel AX211 WiFi firmware crashes** (`NMI_INTERRUPT_UMAC_FATAL` + `ADVANCED_SYSASSERT`).

The firmware's power save mode triggers assertion failures in the UMAC microcontroller. When this happens:
1. The `iwlwifi` driver dumps firmware state (~1s, blocks all network I/O)
2. Any process waiting for network I/O hangs during the dump
3. If the driver can't restart the firmware cleanly, the WiFi interface disappears
4. NetworkManager loses the device → Settings shows "NM needs to be running"

### Identifying the Issue

Check `dmesg` for:
```
iwlwifi 0000:00:14.3: Microcode SW error detected. Restarting 0x0.
iwlwifi 0000:00:14.3: 0x00000071 | NMI_INTERRUPT_UMAC_FATAL
iwlwifi 0000:00:14.3: 0x20101A27 | ADVANCED_SYSASSERT
```

## Solution

### Quick Setup

```bash
sudo ./setup.sh
```

### Manual Setup

#### 1. Disable WiFi Power Save in NetworkManager (immediate, no reboot)

```bash
sudo tee /etc/NetworkManager/conf.d/wifi-powersave-off.conf << 'EOF'
[connection]
wifi.powersave = 2
EOF

sudo systemctl restart NetworkManager
```

> `wifi.powersave = 2` means disabled. Values: 1=default, 2=disabled, 3=enabled.

Verify:
```bash
iwconfig wlp0s20f3 | grep Power
# Should show: Power Management:off
```

#### 2. Disable iwlwifi Hardware Power Saving (requires reboot)

```bash
sudo tee /etc/modprobe.d/iwlwifi-power.conf << 'EOF'
# Disable iwlwifi power saving to prevent NMI_INTERRUPT_UMAC_FATAL firmware crashes
# on Intel AX211 (known issue with firmware 83 on kernel 6.5)
options iwlwifi power_save=0
options iwlmvm power_scheme=1
EOF
```

Then reboot, or reload the module:
```bash
sudo modprobe -r iwlmvm iwlwifi && sudo modprobe iwlwifi
```

Verify:
```bash
cat /sys/module/iwlwifi/parameters/power_save
# Should show: 0 (was: Y)
cat /sys/module/iwlmvm/parameters/power_scheme
# Should show: 1 (was: 2)
```

#### 3. Recovery Script (when WiFi crashes despite fixes)

Install:
```bash
sudo cp fix-wifi.sh /usr/local/bin/fix-wifi
sudo chmod +x /usr/local/bin/fix-wifi
```

Usage:
```bash
sudo fix-wifi
```

This script:
1. Checks if WiFi interface exists; if not, reloads the iwlwifi driver
2. Restarts NetworkManager
3. Disables WiFi power save
4. Verifies WiFi is back

## Technical Details

### System Info

| Component | Value |
|---|---|
| WiFi Card | Intel Wi-Fi 6E AX211 160MHz |
| PCI ID | 7a70/0094, rev=0x430 |
| Firmware | `83.e8f84e98.0 so-a0-gf-a0-83.ucode` |
| Kernel | 6.5.0-1027-oem (Ubuntu 22.04) |
| Driver | iwlwifi + iwlmvm |

### Why This Happens

The Intel AX211's firmware has a bug in its power management state machine. When the WiFi driver transitions the radio between power states (active ↔ sleep), the firmware's UMAC microcontroller can hit an assertion failure (`NMI_INTERRUPT_UMAC_FATAL`). This is especially common:
- After screen lock/unlock (DPMS triggers WiFi power save)
- During periods of low WiFi activity followed by sudden traffic
- When multiple WiFi-dependent services (VPN, Docker, etc.) are active

### Firmware Versions Available

```
/lib/firmware/iwlwifi-so-a0-gf-a0-64.ucode  (oldest)
/lib/firmware/iwlwifi-so-a0-gf-a0-83.ucode  ← currently loaded
/lib/firmware/iwlwifi-so-a0-gf-a0-89.ucode  (newest, but kernel 6.5 may not support it)
```

The driver selects the highest compatible firmware. Kernel 6.5's iwlwifi driver supports up to firmware 83. Upgrading the kernel could enable firmware 89 which has more crash fixes. However, kernel upgrades on OEM systems require caution.

### Key dmesg Entries Explained

| Message | Meaning |
|---|---|
| `TB bug workaround: copied N bytes` | Known Intel silicon errata — harmless |
| `NMI_INTERRUPT_UMAC_FATAL` | WiFi firmware crash in power management |
| `ADVANCED_SYSASSERT` | Firmware assertion failure (crash dump follows) |
| `PHY ctxt cmd error. ret=-5` | PHY context change failed (WiFi radio hung) |
| `Failed to send MAC_CONFIG_CMD` | Driver can't communicate with crashed firmware |
| `WRT: Collecting data` | Driver collecting crash dump (causes brief hang) |
| `RFIm is deactivated, reason = 5` | RF Interference Mitigation off — normal |
