#!/bin/bash
# Cai co che chong loi doc EDID panel eDP tren Legion + NVIDIA.
# KHONG khoi dong lai X - tu dang xuat/dang nhap lai sau khi cai.
set -euo pipefail
S="$(dirname "$(readlink -f "$0")")"
BK=/etc/X11/edp-edid-fix-backup
[ "$(id -u)" = 0 ] || { echo "Can chay bang sudo"; exit 1; }

# Hai duong dan duoi day la ten do bo cong cu nay dat ra - khong co phan mem
# nao khac tao chung. Vi vay neu chung ton tai thi chac chan la do lan cai truoc
# cua chinh bo nay, KHONG phai file goc cua he thong, va tuyet doi khong duoc
# dua vao backup (neu khong rollback se "khoi phuc" lai chinh chung).
echo "== 0. Sao luu (chi lam MOT LAN) =="
if [ -f "$BK/.backup-done" ]; then
    echo "  da sao luu tu truoc, bo qua"
else
    mkdir -p $BK
    for f in /etc/X11/edid-edp.bin /etc/X11/xorg.conf.d/10-edp-customedid.conf; do
        [ -e "$f" ] && echo "  $f co san -> do lan cai truoc cua bo nay, KHONG backup"
    done
    touch "$BK/.backup-done"
    echo "  backup goc: $BK (rong = truoc khi cai may chua co file nao, dung nhu mong doi)"
fi

echo "== 1. Cai EDID mo dau (trich tu registry Windows) =="
if [ -f /etc/X11/edid-edp.bin ]; then
    echo "  da co /etc/X11/edid-edp.bin, giu nguyen"
else
    install -m 644 "$S/edid-seed-128.bin" /etc/X11/edid-edp.bin
    echo "  da ghi /etc/X11/edid-edp.bin (128 byte, 2560x1600@60Hz)"
fi

echo "== 2. Cai script cache =="
install -m 755 "$S/edp-edid-cache.py" /usr/local/sbin/edp-edid-cache.py
echo "  -> /usr/local/sbin/edp-edid-cache.py"

echo "== 3. Cai lenh go bo vao PATH cua root =="
install -m 755 "$S/rollback.sh" /usr/local/sbin/edp-edid-fix-rollback
echo "  -> go bo bat cu luc nao bang:  sudo edp-edid-fix-rollback"

echo "== 4. Cai va bat systemd service =="
install -m 644 "$S/edp-edid-cache.service" /etc/systemd/system/edp-edid-cache.service
systemctl daemon-reload
systemctl enable edp-edid-cache.service
echo "  -> se chay truoc display-manager moi lan boot"

echo "== 5. Chay thu script cache ngay bay gio =="
/usr/local/sbin/edp-edid-cache.py || true

echo "== 6. Cai cau hinh Xorg =="
install -m 644 "$S/10-edp-customedid.conf" /etc/X11/xorg.conf.d/10-edp-customedid.conf
echo "  -> /etc/X11/xorg.conf.d/10-edp-customedid.conf"

echo
echo "==================== DA CAI XONG ===================="
/usr/bin/python3 - <<'PY'
e=open('/etc/X11/edid-edp.bin','rb').read()
v=(e[8]<<8)|e[9]
print(f"EDID dang dung: vendor={''.join(chr(((v>>s)&0x1F)+64) for s in (10,5,0))} "
      f"product=0x{(e[11]<<8)|e[10]:04x} serial=0x{int.from_bytes(e[12:16],'little'):08x} "
      f"({len(e)}B, {e[126]} ext)")
d=e[54:72]; px=((d[1]<<8)|d[0])*10000
h=d[2]|((d[4]&0xF0)<<4); hb=d[3]|((d[4]&0x0F)<<8)
vt=d[5]|((d[7]&0xF0)<<4); vb=d[6]|((d[7]&0x0F)<<8)
print(f"                timing {h}x{vt} @ {px/((h+hb)*(vt+vb)):.0f}Hz")
PY
echo
echo "BUOC TIEP THEO: dang xuat roi dang nhap lai (khong can reboot)."
echo
echo "NEU X KHONG LEN:  Ctrl+Alt+F3 -> dang nhap -> sudo edp-edid-fix-rollback"
