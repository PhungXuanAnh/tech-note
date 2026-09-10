#!/usr/bin/python3
"""Luu lai EDID that cua panel eDP moi khi doc duoc.

Chay truoc display-manager. Neu kernel doc duoc EDID hop le cua dung panel BOE
thi ghi de vao cache; neu boot nay bi loi EDID (driver bia ra EDID gia cua
NVIDIA) thi giu nguyen cache cu. Nho vay X luon co EDID that de dung.

LUU Y VE THOI DIEM CHAY
-----------------------
Khong dung ConditionPathExists trong unit file. systemd danh gia dieu kien do
qua som (do ~7.8s) trong khi connector DRM chi duoc tao khi nvidia-drm khoi tao
xong (do ~8.5s) -> unit bi skip VINH VIEN va khong bao gio bat duoc EDID that.
Thay vao do script tu cho, co gioi han thoi gian.

Vi sao cho nhu vay khong lam cham boot khi gap boot loi: luc do driver da bia
ra san EDID gia 128 byte, doc duoc ngay, nen vong cho thoat lap tuc roi script
ket luan "khong dung duoc" va giu cache cu.
"""
import glob
import os
import sys
import time

CACHE   = "/etc/X11/edid-edp.bin"
PATTERN = "/sys/class/drm/card*-eDP-*/edid"   # khong hardcode card0

# ==== HAI HANG SO NAY CHI DUNG CHO MAY NAY ====================================
# Danh tinh panel cua may nay: BOE / 0x0c8b / 0x00000068 (model NE160QDM-NZB).
# Mang script sang laptop khac thi PHAI doi, xem muc "Mang sang may khac" trong
# readme.md de lay gia tri dung.
#
# Viec hardcode la CO Y, khong phai cau tha: chinh phep so sanh nay la thu phan
# biet EDID that voi EDID gia. Neu chap nhan "bat cu EDID nao panel khai" thi
# script se vui ve cache luon cai EDID gia cua NVIDIA (vendor NVD) va vo hieu
# hoa toan bo co che.
VENDOR  = bytes([0x09, 0xE5])                 # PNP ID "BOE", nam o EDID byte 8-9
PROD    = bytes([0x8B, 0x0C])                 # product 0x0c8b, byte 10-11 little-endian
# ==============================================================================
HDR     = bytes([0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00])
TIMEOUT = 20.0
POLL    = 0.25


def log(m):
    print(f"edp-edid-cache: {m}", flush=True)


def wait_for_edid():
    """Cho connector eDP xuat hien va tra ve noi dung EDID (co the la EDID gia)."""
    deadline = time.monotonic() + TIMEOUT
    while True:
        for path in sorted(glob.glob(PATTERN)):
            try:
                data = open(path, "rb").read()
            except OSError:
                continue
            if data:
                return path, data
        if time.monotonic() >= deadline:
            return None, b""
        time.sleep(POLL)


def valid(e):
    if len(e) < 128:        return False, f"chi co {len(e)} byte"
    if e[:8] != HDR:        return False, "sai header"
    if sum(e[:128]) % 256:  return False, "checksum base block sai"
    if e[8:10] != VENDOR:
        v = (e[8] << 8) | e[9]
        name = "".join(chr(((v >> s_) & 0x1F) + 64) for s_ in (10, 5, 0))
        why = "EDID gia cua driver" if name == "NVD" else "panel khac -> xem muc 'Mang sang may khac' trong readme"
        return False, f"vendor la {name} (0x{v:04x}), khong phai BOE: {why}"
    if e[10:12] != PROD:
        return False, (f"product la 0x{(e[11] << 8) | e[10]:04x}, khong phai 0x0c8b "
                       f"-> panel khac, xem muc 'Mang sang may khac' trong readme")

    want = 128 * (1 + e[126])
    if len(e) < want:       return False, f"thieu extension: co {len(e)}B, can {want}B"
    # Kiem tra checksum TUNG extension block. Khong co buoc nay thi mot blob
    # dung header + dung vendor nhung phan duoi la rac (vi du EDID lay tu
    # registry Windows, noi chi luu 128 byte base con byte 126 van khai 2 ext)
    # se lot qua va bi cache lai lam "EDID that".
    for b in range(1, want // 128):
        if sum(e[b * 128:(b + 1) * 128]) % 256:
            return False, f"extension block {b} checksum sai -> blob khong nguyen ven"
    return True, f"{len(e)} byte, {e[126]} extension"


def main():
    t0 = time.monotonic()
    path, edid = wait_for_edid()
    waited = time.monotonic() - t0

    if path is None:
        log(f"khong thay connector eDP nao sau {TIMEOUT:.0f}s -> giu cache cu")
        return 0                                   # tuyet doi khong chan boot
    log(f"doc {path} sau {waited:.2f}s")

    ok, why = valid(edid)
    if not ok:
        log(f"EDID tu panel KHONG dung duoc ({why}) -> giu cache cu")
        return 0

    old = open(CACHE, "rb").read() if os.path.exists(CACHE) else b""
    if edid == old:
        log(f"EDID khop cache san co ({why}), khong can lam gi")
        return 0

    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    tmp = CACHE + ".new"
    with open(tmp, "wb") as f:
        f.write(edid)
    os.replace(tmp, CACHE)                          # thay the nguyen tu
    log(f"DA CAP NHAT cache tu panel: {why} (truoc do {len(old)} byte)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
