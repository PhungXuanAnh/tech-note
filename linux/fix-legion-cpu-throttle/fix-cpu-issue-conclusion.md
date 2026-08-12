## Kết luận cuối cùng

Đã loại trừ **toàn bộ** tầng phần mềm điều khiển được:

| Đã loại trừ | Bằng chứng |
|---|---|
| Governor / p-state / no_turbo | performance, no_turbo=0, scaling_max=5.6GHz |
| Nhiệt độ | 62-68°C, TCC 100°C |
| thermald | cooling devices cur=0 |
| MSR power limit 0x610 | 200W/190W (cao) |
| BD PROCHOT (0x1fc) | xóa bit → vô hiệu |
| HWP | 0x774 Min=Max=Highest (đòi max) |
| powermode / custom mode | set 2 → vô hiệu |
| Hub USB-C | không quyết định |
| Cảm biến zone10 | chỉ là WiFi, vô hại |
| Module legion_laptop | gỡ → vô hiệu |

Thứ còn lại và **là gốc rễ**: **EC/BIOS firmware bị lỗi**, ép **MMIO RAPL PL1 xuống ~10-33W qua đường phần cứng (PECI)** và **ghi đè mọi thay đổi phần mềm trong vài giây**. Bằng chứng đanh thép là dmesg tự gắn nhãn **"ACPI BIOS Error (bug)"**:
- **DPTF (`IETM._OSC`) khởi tạo thất bại** vì DSDT thiếu `\_TZ.ETMD` → framework quản power động hỏng → firmware rơi về policy công suất thấp.
- **Handler sự kiện EC `_Q44` crash** (thiếu `WM00`) → EC không áp đúng bảng power/fan.

Quan trọng: lúc tôi ghi PL1=90W rồi tải ngay, freq **vẫn 2200, PkgWatt vẫn 19W** → EC bóp qua đường phần cứng, không chỉ qua thanh ghi. **=> Không có cách phần mềm nào ép turbo trở lại một cách bền vững.** Drain EC là cách reset firmware duy nhất (đúng như bạn đang làm).

## Kế hoạch xử lý (theo thứ tự)

1. **Cập nhật BIOS/EC** cho máy type **83DF** (bản bạn đang chạy `N0CN32WW` ~06/2025). Lỗi DSDT `\_TZ.ETMD` và `_Q44.WM00` là **bug firmware**, chỉ Lenovo vá được. Đây là fix gốc số 1.
2. **Lên kernel mới** (Ubuntu HWE 6.8, hoặc mainline 6.11+): xử lý DPTF/ACPI/EC/UCSI tốt hơn nhiều so với `6.5.0-1027-oem` — có khả năng làm `IETM._OSC` chạy được và EC không còn kẹp.
3. **Tạm thời**: giữ drain EC. Vì **suspend từng là 1 trigger** (bạn đã masked), trigger còn lại nhiều khả năng là **hot-plug cổng USB-C/hub hoặc sự kiện dGPU** — hạn chế rút/cắm hub khi máy đang chạy.

## Tôi có thể làm ngay cho bạn

- **Script giám sát** (systemd timer): phát hiện khi PL1 < 30W lúc CPU có tải → gửi thông báo desktop "EC đang throttle, cần drain" — để bạn không phải tự đoán. (Không tự sửa được, nhưng báo sớm.)
- **Kiểm tra BIOS mới nhất** cho 83DF trên trang Lenovo và hướng dẫn cách flash từ Linux (LVFS/`fwupdmgr` nếu Lenovo có đăng, hoặc USB BIOS).
- **Lệnh nâng kernel HWE** an toàn cho Ubuntu của bạn.

Bạn muốn tôi bắt đầu cái nào? Gợi ý: để tôi **kiểm tra `fwupdmgr` xem có update BIOS qua LVFS không** (nhanh, không rủi ro) và **viết script giám sát PL1** trước.