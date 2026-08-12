#!/usr/bin/env bash
# legion-throttle-monitor.sh
# -----------------------------------------------------------------------------
# Phát hiện tình trạng EC của Legion "bóp" CPU: CPU đang có tải nhưng bị kẹt ở
# xung nền (~2.2GHz) và/hoặc PL1 (MMIO RAPL) tụt thấp. Khi phát hiện, gửi thông
# báo desktop nhắc DRAIN EC.
#
# Đây CHỈ là công cụ CẢNH BÁO — nó không tự sửa được (EC ghi đè mọi thay đổi
# phần mềm). Mục đích: báo sớm để bạn biết cần drain thay vì tự đoán.
#
# Cấu hình bằng biến môi trường (đặt trong file .service nếu muốn đổi):
#   FREQ_BASE_MHZ    ngưỡng xung "kẹt nền" (mặc định 2400; khỏe thì >3000 khi tải)
#   LOAD_BUSY_PCT    chỉ cảnh báo khi NHÂN BẬN NHẤT >= mức này (mặc định 70%).
#                    Dùng % nhân bận nhất (không phải % tổng) vì i9 có 32 luồng:
#                    tải vài nhân (Chrome, build...) vẫn phải turbo được.
#   PL1_WARN_W       PL1 dưới mức này lúc đang tải = đáng ngờ (mặc định 30W)
#   NOTIFY_COOLDOWN_S  giãn cách tối thiểu giữa 2 lần báo (mặc định 300s)
# -----------------------------------------------------------------------------
set -u

FREQ_BASE_MHZ="${FREQ_BASE_MHZ:-2400}"
LOAD_BUSY_PCT="${LOAD_BUSY_PCT:-70}"
PL1_WARN_W="${PL1_WARN_W:-30}"
NOTIFY_COOLDOWN_S="${NOTIFY_COOLDOWN_S:-300}"
STATE_FILE="${STATE_FILE:-/run/user/$(id -u)/legion-throttle-monitor.state}"
LOG_FILE="${LOG_FILE:-$HOME/.local/state/legion-throttle-monitor.log}"

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

# --- 1) PL1 (MMIO RAPL) theo watt ---------------------------------------------
pl1_path=""
for p in /sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw \
         /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw; do
    [ -r "$p" ] && { pl1_path="$p"; break; }
done
pl1_w=-1
[ -n "$pl1_path" ] && pl1_w=$(( $(cat "$pl1_path") / 1000000 ))

# --- 2) % của NHÂN BẬN NHẤT, lấy mẫu trong 1 giây -----------------------------
# Đọc từng dòng cpuN trong /proc/stat -> "core busy idle" (busy = mọi cột trừ idle/iowait)
percore() { awk '/^cpu[0-9]/{print $1, $2+$3+$4+$7+$8+$9, $5+$6}' /proc/stat; }
declare -A A_B A_I
while read -r c b i; do A_B[$c]=$b; A_I[$c]=$i; done < <(percore)
sleep 1
top_core_busy=0
while read -r c b i; do
    db=$(( b - ${A_B[$c]:-0} )); di=$(( i - ${A_I[$c]:-0} )); dt=$(( db + di ))
    [ "$dt" -le 0 ] && continue
    p=$(( db * 100 / dt ))
    [ "$p" -gt "$top_core_busy" ] && top_core_busy=$p
done < <(percore)

# --- 3) Xung nhân cao nhất hiện tại --------------------------------------------
max_mhz=$(awk -F: '/MHz/{v=$2+0; if(v>m)m=v} END{printf "%d", m}' /proc/cpuinfo)

# --- 4) Quyết định: có nhân đòi chạy NHƯNG kẹt ở xung nền = bị throttle --------
throttled=0
if [ "$top_core_busy" -ge "$LOAD_BUSY_PCT" ] && [ "$max_mhz" -le "$FREQ_BASE_MHZ" ]; then
    throttled=1
fi

ts=$(date '+%F %T')
echo "$ts topcore=${top_core_busy}% maxMHz=${max_mhz} PL1=${pl1_w}W throttled=${throttled}" >> "$LOG_FILE"

if [ "$throttled" -eq 1 ]; then
    now=$(date +%s); last=0
    [ -r "$STATE_FILE" ] && last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
    if [ $(( now - last )) -ge "$NOTIFY_COOLDOWN_S" ]; then
        echo "$now" > "$STATE_FILE"
        notify-send -u critical -i dialog-warning \
            "Legion EC dang throttle CPU" \
            "Nhan ban nhat ${top_core_busy}% nhung ket o ${max_mhz} MHz (PL1=${pl1_w}W).
Can DRAIN EC: tat may, rut sac + moi thiet bi, giu nut nguon 30s." 2>/dev/null || true
    fi
fi

exit 0
