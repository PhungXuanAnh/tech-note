#!/usr/bin/env python3
"""Trich xuat EDID that cua panel eDP tu registry hive cua Windows."""
import sys, os

HDR    = bytes([0x00,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00])
BOE    = bytes([0x09,0xE5])          # PNP ID "BOE"
PRODUCT= bytes([0x8B,0x0C])          # 0x0c8b little-endian

def vendor(e):
    v = (e[8] << 8) | e[9]
    return "".join(chr(((v >> s) & 0x1F) + 64) for s in (10, 5, 0))

def checksum_ok(b):
    return sum(b[:128]) % 256 == 0

def native_mode(e):
    """Doc detailed timing descriptor dau tien -> do phan giai + refresh."""
    d = e[54:72]
    px = ((d[1] << 8) | d[0]) * 10_000                     # pixel clock, Hz
    h  = d[2] | ((d[4] & 0xF0) << 4)
    hb = d[3] | ((d[4] & 0x0F) << 8)
    v  = d[5] | ((d[7] & 0xF0) << 4)
    vb = d[6] | ((d[7] & 0x0F) << 8)
    tot = (h + hb) * (v + vb)
    return h, v, (px / tot if tot else 0)

def main(path):
    data = open(path, "rb").read()
    print(f"Da doc {len(data):,} byte tu {path}\n")

    found, off = [], 0
    while True:
        i = data.find(HDR, off)
        if i < 0:
            break
        off = i + 1
        blk = data[i:i+128]
        if len(blk) < 128 or not checksum_ok(blk):
            continue
        ext = blk[126]
        full = data[i:i + 128 * (1 + ext)]
        found.append((i, full))

    print(f"Tim thay {len(found)} block EDID hop le (checksum dung)\n")
    target = None
    for i, e in found:
        vd, prod = vendor(e), (e[11] << 8) | e[10]
        w, hgt, hz = native_mode(e)
        mark = ""
        if e[8:10] == BOE and e[10:12] == PRODUCT:
            mark, target = "   <<< PANEL eDP CUA BAN", (i, e)
        print(f"  offset 0x{i:08x}  {vd} 0x{prod:04x}  {len(e)}B  {w}x{hgt}@{hz:.0f}Hz{mark}")

    if not target:
        print("\nKHONG tim thay panel BOE 0x0c8b.")
        return 1

    i, e = target
    out = sys.argv[2] if len(sys.argv) > 2 else "/tmp/edid-edp-boe.bin"
    with open(out, "wb") as f:
        f.write(e)
    w, hgt, hz = native_mode(e)
    print(f"\nOK -> ghi {len(e)} byte vao {out}")
    print(f"   Panel: {vendor(e)} 0x{(e[11]<<8)|e[10]:04x}, native {w}x{hgt}@{hz:.0f}Hz")
    print(f"   Kich thuoc: {e[21]}cm x {e[22]}cm")
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
