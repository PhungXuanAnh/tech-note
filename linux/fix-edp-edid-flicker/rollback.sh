#!/bin/bash
# Go bo hoan toan co che CustomEDID, tra may ve trang thai truoc khi cai.
set -uo pipefail
[ "$(id -u)" = 0 ] || { echo "Can chay bang sudo"; exit 1; }
BK=/etc/X11/edp-edid-fix-backup

echo "== Go cau hinh Xorg =="
rm -fv /etc/X11/xorg.conf.d/10-edp-customedid.conf
echo "== Tat service =="
systemctl disable --now edp-edid-cache.service 2>/dev/null
rm -fv /etc/systemd/system/edp-edid-cache.service
systemctl daemon-reload
echo "== Go script va EDID =="
rm -fv /usr/local/sbin/edp-edid-cache.py /etc/X11/edid-edp.bin

echo "== Khoi phuc file da sao luu (neu co) =="
if [ -d "$BK" ] && [ -n "$(ls -A $BK 2>/dev/null)" ]; then
    cp -av $BK/. /etc/X11/ 2>/dev/null
else
    echo "  khong co gi de khoi phuc (truoc khi cai may chua co cac file nay)"
fi

rm -fv /usr/local/sbin/edp-edid-fix-rollback
echo
echo "Da go xong. Dang xuat/dang nhap lai de X tro ve mac dinh."
