#!/usr/bin/python3
"""In ra cac hang so can sua khi mang bo fix nay sang mot laptop khac.

Chay tren mot boot MA PANEL DUOC NHAN DIEN DUNG (khong phai boot bi loi EDID),
roi chep ket qua vao edp-edid-cache.py va 10-edp-customedid.conf.

    ./show-panel-identity.py
"""
import glob
import re
import subprocess
import sys


def decode_vendor(e):
    v = (e[8] << 8) | e[9]
    return "".join(chr(((v >> s) & 0x1F) + 64) for s in (10, 5, 0))


def find_edid():
    for path in sorted(glob.glob("/sys/class/drm/card*-eDP-*/edid")):
        try:
            data = open(path, "rb").read()
        except OSError:
            continue
        if len(data) >= 128:
            return path, data
    return None, b""


def find_dfp_name():
    """Tim ten display device ma driver NVIDIA dat cho panel (vi du DFP-5).

    Doc tu Xorg log: dong '(--) NVIDIA(GPU-0): <ten panel> (DFP-N): Internal DisplayPort'
    """
    logs = sorted(glob.glob("/home/*/.local/share/xorg/Xorg.*.log")) + \
           sorted(glob.glob("/var/log/Xorg.*.log"))
    for lg in logs:
        try:
            txt = open(lg, errors="replace").read()
        except OSError:
            continue
        # Panel noi bo la cai duy nhat duoc danh dau '(boot)' va la Internal DisplayPort
        for m in re.finditer(r"\(DFP-(\d+)\): Internal DisplayPort", txt):
            line_start = txt.rfind("\n", 0, m.start()) + 1
            line = txt[line_start:m.end()]
            # Bo qua cac man ngoai (co ten hang nhu 'Asustek', 'Dell'...)
            if "DFP-" in line:
                yield f"DFP-{m.group(1)}", line.strip()


def main():
    path, e = find_edid()
    if not e:
        print("Khong tim thay connector eDP nao. Chay tren may co panel noi bo.")
        return 1

    ven = decode_vendor(e)
    prod = (e[11] << 8) | e[10]
    serial = int.from_bytes(e[12:16], "little")
    model = ""
    for i in range(54, 126, 18):
        d = e[i:i + 18]
        if d[0] == 0 and d[1] == 0 and d[3] == 0xFE:
            t = d[5:18].decode("ascii", "replace").strip()
            if len(t) > len(model):
                model = t

    print(f"Nguon EDID : {path}  ({len(e)} byte)")
    print(f"Panel      : {ven} 0x{prod:04x}  serial 0x{serial:08x}  model {model!r}")
    print()

    if ven == "NVD":
        print("!! Day la EDID GIA do driver bia ra - boot nay dang bi loi doc EDID.")
        print("!! Reboot roi chay lai, phai lay duoc EDID that thi so lieu moi dung.")
        return 1

    print("=== Sua trong edp-edid-cache.py ===")
    print(f"VENDOR  = bytes([0x{e[8]:02X}, 0x{e[9]:02X}])                 # PNP ID \"{ven}\"")
    print(f"PROD    = bytes([0x{e[10]:02X}, 0x{e[11]:02X}])                 # product 0x{prod:04x}")
    print()
    print("=== Sua trong 10-edp-customedid.conf ===")
    names = list(dict.fromkeys(n for n, _ in find_dfp_name()))
    if names:
        print(f"Cac DFP-N la 'Internal DisplayPort' tim thay trong Xorg log: {', '.join(names)}")
        print("Panel noi bo thuong la cai duoc danh dau '(boot)'. Doi chieu bang:")
        print("    grep -E 'DFP-[0-9]+ \\(boot\\)|Internal DisplayPort' ~/.local/share/xorg/Xorg.*.log")
    else:
        print("Khong doc duoc Xorg log. Tim thu cong bang:")
        print("    grep -E 'DFP-[0-9]+' ~/.local/share/xorg/Xorg.*.log | head")
    print('Option "CustomEDID" "<DFP-N>:/etc/X11/edid-edp.bin"')
    return 0


if __name__ == "__main__":
    sys.exit(main())
