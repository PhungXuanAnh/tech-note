#!/bin/bash
# Mount Windows read-only, trich EDID that cua panel, unmount.
set -e
S="$(dirname "$(readlink -f "$0")")"
MNT=/mnt/win-edid
echo "== Mount Windows (chi doc) =="
mkdir -p $MNT
mount -t ntfs-3g -o ro,ignore_hiberfile /dev/nvme0n1p3 $MNT
trap 'umount $MNT 2>/dev/null; rmdir $MNT 2>/dev/null' EXIT

HIVE=$MNT/Windows/System32/config/SYSTEM
[ -f "$HIVE" ] || { echo "Khong thay $HIVE"; exit 1; }

echo "== Quet registry hive tim EDID =="
python3 "$S/extract-edid.py" "$HIVE" "$S/edid-edp-boe.bin"

chown $SUDO_UID:$SUDO_GID "$S/edid-edp-boe.bin" 2>/dev/null || true
echo
echo "== Xong. File: $S/edid-edp-boe.bin =="
