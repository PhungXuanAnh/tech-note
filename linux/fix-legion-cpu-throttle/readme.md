# Fix Legion CPU throttle (Legion Pro 5 16IRX9 / 83DF)

Sửa/giám sát lỗi CPU **i9-14900HX bị EC bóp xung**: turbo sập, CPU kẹt ở xung nền
(~2.0–2.2GHz) hoặc idle tụt 800MHz, quạt kẹt thấp.

- Chi tiết chẩn đoán & bằng chứng: xem [fix-cpu-issue-conclusion.md](fix-cpu-issue-conclusion.md).
- Máy: Lenovo Legion Pro 5 16IRX9, type **83DF**, i9-14900HX, RTX 4070.
- Firmware lúc chẩn đoán: BIOS **N0CN32WW** (2025-06-16), EC **1.27**.

---

## TL;DR — gốc rễ & cách sửa

Gốc rễ là **lỗi firmware EC/BIOS**: EC ép **MMIO RAPL PL1 xuống thấp** làm turbo sập.
dmesg gắn nhãn `ACPI BIOS Error (bug)` (DPTF `IETM._OSC` fail do DSDT thiếu
`\_TZ.ETMD`; handler EC `_Q44` crash thiếu `WM00`).

> **✅ Cập nhật 2026-07 — CÓ FIX PHẦN MỀM BỀN VỮNG (đính chính kết luận cũ).**
> Kết luận trước đây ("không cách phần mềm nào giữ được turbo, chỉ drain EC") **KHÔNG
> còn đúng** trên boot OEM 6.5 hiện tại: **ghi PL1 vào MMIO constraint thì GIỮ ĐƯỢC**,
> EC **không** ghi đè — kể cả khi tải 32 nhân. Đây là fix phần mềm thật sự.

> **🔥 Cập nhật 2026-07 (lần 2) — ĐÍNH CHÍNH LỚN:** thủ phạm kẹp công suất trên boot
> hiện tại là **`thermald --adaptive`** (nghe theo bảng DPTF firmware), KHÔNG phải EC.
> Sau khi chỉnh thermald đã **unlock 140W / 5107MHz** — vượt xa mức 55W. Chi tiết ở
> mục 🔥 bên dưới. Fix static 55W ở đây giờ bị thermald (đã chỉnh) đặt 140W đè lên.

**Cách sửa (đã tích hợp vào `cpupower.service`, tự chạy mỗi lần boot):**

```bash
# 1) governor  2) platform_profile  3) ghi PL1 (cần root)
sudo cpupower frequency-set -g performance
sudo powerprofilesctl set performance
echo 55000000 | sudo tee /sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw
```

**Drain EC** (tắt máy, rút sạc + mọi thiết bị, giữ nút nguồn 30s) nay chỉ còn là
**phương án dự phòng** khi EC kẹt cứng tới mức ghi PL1 cũng bị đè (hiếm).

---

## 🔥 Cập nhật 2026-07 (lần 2) — thủ phạm thật là **thermald `--adaptive`**, đã unlock 5.1GHz / 140W

Chẩn đoán lại sâu hơn cho thấy trên boot hiện tại (OEM 6.5), thứ **đang kẹp PL1 xuống
10W** ở nhiệt vừa (~77°C) **không phải EC** mà là **`thermald` chạy cờ `--adaptive`** —
nó nghe theo **bảng DPTF firmware** (INT3400) và ghì RAPL rất gắt. Vì vậy dù
`cpupower.service` đã ghi 55W lúc boot, thermald vẫn **đè lại** lúc chạy (kẹp 10W, hoặc
nâng 140W tuỳ nhiệt) → static 55W thành vô nghĩa khi thermald active.

**Bằng chứng (đo trực tiếp):**

| Trạng thái | PL1 @nhiệt | Boost 1 nhân | Ghi chú |
|---|---|---|---|
| thermald `--adaptive` (mặc định) | **kẹt 10W** @77°C | ~2.2GHz | firmware DPTF kẹp |
| dừng thermald + ghi 55W | 55W giữ | 5.0GHz @97°C/4s | xác nhận thermald là thủ phạm |
| **bỏ `--adaptive` + config trip 95°C** | **140W** @73°C | **5107MHz** @97°C | ✅ fix Option B |

→ **Đính chính kết luận cũ "không nâng được quá 55W / EC kẹp thực 55W": SAI.** Với
thermald được chỉnh, phần mềm **đạt 140W và 5.1GHz** — EC/PECI **không** kẹp cứng 55W
như suy đoán trước. Nút thắt runtime thật là **thermald `--adaptive`**, không phải EC.

### Cách sửa (Option B — đã tích hợp `new-os-install-Ubuntu.sh`)

Bỏ `--adaptive` + cấp config PERFORMANCE để thermald **chỉ ghì RAPL khi CPU chạm 95°C**:

```bash
# 1) Config: passive trip 95°C trên x86_pkg_temp -> rapl_controller
sudo tee /etc/thermald/thermal-conf.xml >/dev/null <<'XML'
<?xml version="1.0"?>
<ThermalConfiguration><Platform>
  <Name>Legion Pro 5 16IRX9 - performance override</Name>
  <ProductName>*</ProductName>
  <Preference>PERFORMANCE</Preference>
  <ThermalZones><ThermalZone>
    <Type>x86_pkg_temp</Type>
    <TripPoints><TripPoint>
      <SensorType>x86_pkg_temp</SensorType>
      <Temperature>95000</Temperature>
      <type>passive</type>
      <ControlType>SEQUENTIAL</ControlType>
      <CoolingDevice><index>1</index><type>rapl_controller</type><influence>100</influence></CoolingDevice>
    </TripPoint></TripPoints>
  </ThermalZone></ThermalZones>
</Platform></ThermalConfiguration>
XML

# 2) Bỏ --adaptive khỏi thermald
sudo mkdir -p /etc/systemd/system/thermald.service.d
sudo tee /etc/systemd/system/thermald.service.d/override.conf >/dev/null <<'OVR'
[Service]
ExecStart=
ExecStart=/usr/sbin/thermald --systemd --dbus-enable
OVR

sudo systemctl daemon-reload && sudo systemctl restart thermald
```

**Khôi phục:** `sudo rm /etc/systemd/system/thermald.service.d/override.conf /etc/thermald/thermal-conf.xml && sudo systemctl daemon-reload && sudo systemctl restart thermald`

> **Đánh đổi (trung thực):** dưới 95°C CPU kéo hết công suất (tới 140W) nên **tải nặng
> all-core sẽ nóng nhanh, chạy quanh 92–97°C**. PROCHOT phần cứng vẫn chặn ~100°C (không
> hại chip). Fan vẫn ~2900–3600 RPM (ép cao hơn không được), nên **giới hạn thật giờ là
> TẢN NHIỆT, không phải PL nữa**: tác vụ bursty / 1-vài nhân boost thoải mái tới ~5GHz;
> all-core bền vững thì bị nhiệt ghì (vẫn hơn hẳn mức kẹt 2.2GHz cũ). Muốn mát/êm hơn:
> hạ trip (vd `90000`).

Hàm cài tự động: **`setup_thermald_performance_in_Legion_laptop()`** trong
`new-os-install-Ubuntu.sh` (guard `hostname==Legion`).

---

## Vì sao vẫn tái phát? — 2 tầng trigger

| Tầng | Triệu chứng | Vì sao | Cách xử lý (service làm sẵn) |
|---|---|---|---|
| **A. platform_profile** | boot xong tự về `balanced` | `power-profiles-daemon` reset khi khởi động | `powerprofilesctl set performance` |
| **B. EC bóp PL1** | PL1 tụt ~10–33W, turbo sập | firmware EC ép RAPL qua PECI | ghi `55000000` vào `constraint_0_power_limit_uw` |

> Bằng chứng service **không** phải thủ phạm: đo lúc boot thấy PL1=19.25W **trước**
> khi service chạy, 20.75W **sau** → service chỉ nâng nhẹ PL1, không gây lỗi. Đã loại
> trừ sạc/pin (ADP0 online, BAT0 Not charging).

---

## Kết quả đo (sau khi áp fix)

Test tải 32 nhân, tự ngắt nếu package temp ≥96°C:

| PL1 (ghi) | all-core MHz | single-core turbo | Package temp | Fan (RPM) | Ghi chú |
|---|---|---|---|---|---|
| **55W** | ~2500 | 5.5–5.6GHz | ~82°C | ~3400 | mát, êm, turbo phục hồi hoàn toàn |
| 90W | ~2500 (**y hệt**) | ~5.5GHz | ~84°C | ~3500 | **không lợi** — EC vẫn kẹp công suất *thực* ~55W |

- Giá trị PL1 ta ghi **giữ nguyên** suốt tải (sysfs không bị đè).
- 2500MHz all-core @55W là **đúng spec Intel** (PBP/PL1=55W), không phải throttle;
  single-core turbo phục hồi hoàn toàn (5.5GHz) — đủ mượt cho tác vụ thường ngày.
- Nhiệt cả hai mức chỉ ~82–84°C, quạt ~3500 RPM → bạn "chưa bao giờ thấy quạt >5500"
  vì máy chưa bao giờ đủ nóng để EC cho quạt chạy mạnh hơn (không phải quạt hỏng).

> **⚠️ Phát hiện quan trọng — không nâng được quá 55W bằng phần mềm.** Ghi PL1=90W
> **không** tăng all-core (vẫn 2500MHz, nhiệt ~84°C y như 55W) → **EC vẫn kẹp công
> suất *thực* xuống ~55W qua PECI**, bất kể giá trị ghi vào MMIO constraint. Phần mềm
> chỉ đưa về **mức spec 55W** (thoát trạng thái bug 10–33W), **không** mở khoá được
> "performance table" đầy đủ của Legion (all-core 3.5GHz+). Muốn hơn cần **EC/BIOS vá
> bảng công suất** (bản N0CN35WW hiện chưa có). → **Giữ 55W; đặt 90W vô ích.**
>
> **🔻 ĐÍNH CHÍNH (2026-07 lần 2):** kết luận "không quá 55W" ở trên **đã SAI** — hoá ra
> `thermald --adaptive` mới là thứ kẹp công suất khi máy đang chạy, không phải EC. Sau
> khi chỉnh thermald đo được **PL1 140W / 5107MHz**. Xem mục 🔥 "thủ phạm thật là
> thermald `--adaptive`" ở trên.

---

## ⚠️ Phát hiện về KERNEL (đính chính)

Lỗi throttle này **độc lập với kernel** — cả OEM 6.5 lẫn generic 6.8 đều bị.
Đo thực tế khi máy đang ở trạng thái throttle:

| Kernel | Idle | Khi CÓ tải | PL1 | Kết luận |
|---|---|---|---|---|
| `6.5.0-1027-oem` | ~2200 (sàn cao) | **kẹt ~2200** | 10–33W trôi | throttle |
| `6.8.0-136-generic` | 800–4199 (turbo idle OK) | **tụt ~2000** | ~25W | **throttle y hệt** |

→ **Chuyển kernel KHÔNG sửa được** (bác bỏ khuyến nghị "lên 6.8 để hết lỗi"). Turbo
vẫn sập khi có tải trên cả hai.

**Vì sao OEM 6.5 "cảm giác mượt hơn":** governor `performance` trên OEM giữ **sàn
xung ~2200MHz**, còn generic 6.8 cho idle tụt về **800MHz** → nhìn như "kẹt 800",
dù throttle-khi-tải là như nhau. Muốn lấy lại cảm giác sàn 2200 trên 6.8 (không
sửa được throttle, chỉ nâng sàn idle):

```bash
sudo cpupower frequency-set -d 2.2GHz     # hoặc: echo 2200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
```

**Lưu ý:** OEM 6.5 đã **EOL (Canonical ngừng vá)**, `linux-oem-22.04` nay cũng trỏ
6.8. Nếu ở lại OEM vì trải nghiệm tốt hơn thì chấp nhận đánh đổi bảo mật/hỗ trợ.

---

## Cách khôi phục khi bị throttle

1. **Fix phần mềm (ưu tiên):** chạy 3 lệnh ở phần TL;DR, hoặc restart service:
   `sudo systemctl restart cpupower`. Kiểm tra:
   `cat /sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw` phải ra `55000000`.
2. **Drain EC (dự phòng):** nếu ghi PL1 vẫn bị EC đè → tắt máy → rút sạc + HẾT thiết
   bị (USB, hub, màn hình ngoài) → giữ nút nguồn **30s** → cắm lại → bật.
3. Hạn chế trigger: tránh **hot-plug hub USB-C** khi máy đang chạy; **suspend** từng
   gây lỗi (đã mask).

---

## BIOS/EC firmware — bản mới KHÔNG sửa throttle

| | Đang dùng | Mới nhất (Lenovo, 11/06/2026) |
|---|---|---|
| BIOS | N0CN32WW | **N0CN35WW** — chỉ *"security vulnerability LEN-213632"* |
| EC | 1.27 | changelog **N/A** (không đổi) |

→ Update BIOS **không** khắc phục throttle (EC không có mục vá). Lenovo chỉ phát hành
**`.exe` cho Windows**, không có Bootable ISO, không lên LVFS. Vì vậy **fix phần mềm
PL1 ở trên là giải pháp chính**, không phải chờ BIOS.

---

## Công cụ giám sát throttle (systemd user timer)

Báo desktop khi **nhân bận nhất ≥70% nhưng xung kẹt ≤2400MHz** (đúng bản chất
"có nhân đòi boost nhưng bị EC bóp"). **Chỉ cảnh báo, không tự sửa.**

| File | Vai trò |
|---|---|
| [legion-throttle-monitor.sh](legion-throttle-monitor.sh) | Bộ phát hiện (đo % nhân bận nhất + xung + PL1) |
| [legion-throttle-monitor.service](legion-throttle-monitor.service) | Unit oneshot (chạy ở phạm vi user để `notify-send` hoạt động) |
| [legion-throttle-monitor.timer](legion-throttle-monitor.timer) | Chạy mỗi 60s |
| [install.sh](install.sh) | Cài (không cần sudo) |

### Cài đặt

```bash
sudo apt install -y libnotify-bin      # nếu chưa có notify-send
bash install.sh
```

### Dùng

```bash
tail -f ~/.local/state/legion-throttle-monitor.log          # xem log
systemctl --user start legion-throttle-monitor.service      # test 1 lần
systemctl --user disable --now legion-throttle-monitor.timer # gỡ
```

Ngưỡng chỉnh qua env trong file `.service` (`FREQ_BASE_MHZ`, `LOAD_BUSY_PCT`,
`PL1_WARN_W`, `NOTIFY_COOLDOWN_S`).

Ví dụ dòng log khi bị bóp:
```
2026-07-26 17:17:54 topcore=81% maxMHz=2200 PL1=10W throttled=1
```

---

## `install_runs_cpu_at_max_frequency_in_Legion_laptop` (đã sửa để fix throttle)

Function (trong `new-os-install-Ubuntu.sh`) tạo `cpupower.service` chạy **3 việc mỗi
lần boot** → áp luôn fix phần mềm:

```ini
ExecStart=/usr/bin/cpupower frequency-set -g performance
ExecStart=/usr/bin/powerprofilesctl set performance
ExecStart=/bin/sh -c 'echo 55000000 > /sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw'
```

→ governor=performance + platform_profile=performance (tầng A) + ghi PL1=55W (tầng B).
Đổi `55000000` sang mức khác (vd `90000000`=90W) nếu muốn all-core mạnh hơn.

> **Lưu ý (2026-07 lần 2):** dòng ghi PL1=55W ở đây giờ **bị `thermald` (đã chỉnh Option
> B) đặt 140W đè lên** khi nhiệt <95°C → static 55W hầu như vô hiệu, nhưng **vẫn giữ lại**
> vì 2 dòng governor/platform_profile (tầng A) vẫn cần. Phần "nới công suất" thật sự nay
> do **`setup_thermald_performance_in_Legion_laptop()`** đảm nhiệm.
