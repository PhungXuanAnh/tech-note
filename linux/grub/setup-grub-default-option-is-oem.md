# Setup GRUB Default Boot Option to OEM Kernel

This guide explains how to configure Ubuntu's GRUB bootloader to automatically boot the OEM kernel as the first/default option.

## Overview

By default, Ubuntu's GRUB bootloader uses the generic kernel as the first boot option. This setup creates a custom entry that:

1. **Adds "Ubuntu (OEM Kernel)" as the first menu option**
2. **Automatically detects the latest installed OEM kernel**
3. **Auto-updates when OEM kernel is upgraded** (after running `update-grub`)

## Final GRUB Menu Structure

| # | Option | Description |
|---|--------|-------------|
| 0 | `Ubuntu (OEM Kernel)` | Latest OEM kernel ← **Default** |
| 1 | `Ubuntu` | Latest generic kernel |
| 2 | `Advanced options for Ubuntu` | All kernels submenu |
| 3 | `Windows Boot Manager` | Windows (if dual-boot) |
| 4 | `UEFI Firmware Settings` | BIOS/UEFI settings |

## Prerequisites

- Ubuntu with OEM kernel installed (`linux-image-*-oem`)
- Root/sudo access

## Installation Steps

### Step 1: Create the Custom GRUB Script

Create `/etc/grub.d/07_custom` with the following content:

```bash
sudo tee /etc/grub.d/07_custom << 'EOFSCRIPT'
#!/bin/bash
# Custom Ubuntu entry to boot the latest OEM kernel as first option
# This script dynamically finds the newest OEM kernel

set -e

# Find the latest OEM kernel
OEM_KERNEL=$(ls -v /boot/vmlinuz-*-oem 2>/dev/null | tail -1)

if [ -z "$OEM_KERNEL" ]; then
    # No OEM kernel found, exit silently
    exit 0
fi

# Extract kernel version from path
OEM_VERSION=$(basename "$OEM_KERNEL" | sed 's/vmlinuz-//')

# Check if corresponding initrd exists
OEM_INITRD="/boot/initrd.img-${OEM_VERSION}"
if [ ! -f "$OEM_INITRD" ]; then
    echo "Warning: initrd for $OEM_VERSION not found" >&2
    exit 0
fi

# Get root UUID
ROOT_UUID=$(grep -oP 'UUID=\K[^ ]+' /etc/fstab | head -1)
if [ -z "$ROOT_UUID" ]; then
    ROOT_UUID=$(findmnt -no UUID /)
fi

# Get kernel parameters from /etc/default/grub
. /etc/default/grub
CMDLINE="${GRUB_CMDLINE_LINUX_DEFAULT} ${GRUB_CMDLINE_LINUX}"

cat << EOF
menuentry 'Ubuntu (OEM Kernel)' --class ubuntu --class gnu-linux --class gnu --class os {
    recordfail
    load_video
    gfxmode \$linux_gfx_mode
    insmod gzio
    if [ x\$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
    insmod part_gpt
    insmod ext2
    search --no-floppy --fs-uuid --set=root ${ROOT_UUID}
    echo 'Loading Linux ${OEM_VERSION} ...'
    linux /boot/vmlinuz-${OEM_VERSION} root=UUID=${ROOT_UUID} ro ${CMDLINE} \$vt_handoff
    echo 'Loading initial ramdisk ...'
    initrd /boot/initrd.img-${OEM_VERSION}
}
EOF
EOFSCRIPT
```

### Step 2: Make the Script Executable

```bash
sudo chmod +x /etc/grub.d/07_custom
```

### Step 3: Configure GRUB Default

Edit `/etc/default/grub` to set the first entry as default:

```bash
# Change GRUB_DEFAULT to 0
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub

# Comment out GRUB_SAVEDEFAULT if present
sudo sed -i 's/^GRUB_SAVEDEFAULT=.*/#GRUB_SAVEDEFAULT=true/' /etc/default/grub
```

Or manually edit `/etc/default/grub`:

```
GRUB_DEFAULT=0
#GRUB_SAVEDEFAULT=true
GRUB_TIMEOUT=10
```

### Step 4: Update GRUB

```bash
sudo update-grub
```

### Step 5: Verify Configuration

```bash
# Check the first menu entry
sudo grep -A 5 "menuentry 'Ubuntu (OEM Kernel)'" /boot/grub/grub.cfg

# List all main menu entries
sudo awk '/^menuentry|^submenu/ {print NR": "$0}' /boot/grub/grub.cfg | head -6
```

## How Auto-Update Works

The script in `/etc/grub.d/07_custom` runs every time `update-grub` is executed. It:

1. Searches for all OEM kernels: `ls -v /boot/vmlinuz-*-oem`
2. Selects the latest one (last in sorted list)
3. Generates the GRUB menu entry with the current OEM kernel version

**When is `update-grub` run automatically?**
- When installing/removing kernel packages (`apt install/remove linux-image-*`)
- When running `sudo update-grub` manually

**Note:** After upgrading OEM kernel, you should run:
```bash
sudo update-grub
```

## Troubleshooting

### GRUB menu not showing
Hold **Shift** (BIOS) or **Esc** (UEFI) during boot to force GRUB menu.

### Boot fails with OEM kernel
1. At GRUB menu, select "Ubuntu" (generic kernel) or use "Advanced options"
2. Once booted, check OEM kernel files:
   ```bash
   ls -la /boot/vmlinuz-*oem* /boot/initrd.img-*oem*
   ```
3. Regenerate initrd if missing:
   ```bash
   sudo update-initramfs -u -k <oem-kernel-version>
   ```

### Check NVIDIA drivers for OEM kernel
```bash
ls -la /lib/modules/$(ls /boot/vmlinuz-*-oem | tail -1 | sed 's/.*vmlinuz-//')/updates/dkms/
```

### Remove this configuration
```bash
sudo rm /etc/grub.d/07_custom
sudo update-grub
```

## Files Modified

| File | Purpose |
|------|---------|
| `/etc/grub.d/07_custom` | Custom script to generate OEM kernel entry |
| `/etc/default/grub` | GRUB configuration (GRUB_DEFAULT=0) |
| `/boot/grub/grub.cfg` | Generated GRUB config (auto-generated, don't edit) |

## Why 07_custom?

GRUB scripts in `/etc/grub.d/` are executed in numerical order:
- `00_header` - GRUB defaults
- `05_debian_theme` - Theme/appearance
- **`07_custom`** - Our custom OEM entry (runs before 10_linux)
- `10_linux` - Standard Ubuntu kernel entries
- `30_os-prober` - Windows/other OS detection
- `40_custom` - User custom entries (after other entries)

By using `07_custom`, our OEM entry appears **before** the auto-generated Ubuntu entries.
