#!/usr/bin/env bash
# install.sh — cài Legion throttle monitor thành user systemd timer.
# Chạy KHÔNG cần sudo (chạy ở phạm vi user để notify-send hoạt động).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
UNIT="$HOME/.config/systemd/user"

# Chỉ hợp lý trên máy Legion; cảnh báo nhẹ nếu hostname khác.
if [ "$(hostname)" != "Legion" ]; then
    echo "CHU Y: hostname hien tai la '$(hostname)', khong phai 'Legion'. Van tiep tuc cai."
fi

mkdir -p "$BIN" "$UNIT"
install -m 0755 "$SRC/legion-throttle-monitor.sh"       "$BIN/legion-throttle-monitor.sh"
install -m 0644 "$SRC/legion-throttle-monitor.service"  "$UNIT/legion-throttle-monitor.service"
install -m 0644 "$SRC/legion-throttle-monitor.timer"    "$UNIT/legion-throttle-monitor.timer"

if ! command -v notify-send >/dev/null 2>&1; then
    echo "CHU Y: chua co notify-send. Cai bang: sudo apt install -y libnotify-bin"
fi

systemctl --user daemon-reload
systemctl --user enable --now legion-throttle-monitor.timer
systemctl --user status legion-throttle-monitor.timer --no-pager || true

echo
echo "Da cai xong."
echo "  Log:       tail -f ~/.local/state/legion-throttle-monitor.log"
echo "  Test ngay: systemctl --user start legion-throttle-monitor.service && tail -n1 ~/.local/state/legion-throttle-monitor.log"
echo "  Go bo:     systemctl --user disable --now legion-throttle-monitor.timer"
