# Màn hình built-in nháy và không lên hình (Legion 83DF + NVIDIA)

**Ngày:** 2026-09-10
**Máy:** Lenovo Legion 83DF, i9-14900HX, RTX 4070 Laptop, BIOS N0CN35WW
**Hệ:** Ubuntu 22.04.5, kernel 6.5.0-1027-oem, X11, `nvidia-driver-595-open` 595.91.07
**Panel:** BOE **NE160QDM-NZB**, 16" 2560x1600 240Hz (`BOE / 0x0c8b / 0x00000068`)

## Triệu chứng

1. Màn hình laptop nháy liên tục, không nhìn thấy gì.
2. Mở Display Settings thì thấy layout 3 màn bị đặt sai vị trí.
3. Thỉnh thoảng mới bị. **Reboot là hết.**

Hai triệu chứng này **cùng một nguyên nhân**.

## Nguyên nhân gốc

Driver NVIDIA **đọc EDID của panel qua kênh eDP AUX thất bại lúc boot**, rồi tự bịa ra một EDID giả chỉ có duy nhất mode 640x480. Panel 2560x1600 không khoá được tín hiệu 640x480 → nháy và tối đen.

### Bằng chứng

So sánh Xorg log giữa boot tốt và boot lỗi:

| | Boot tốt | Boot lỗi |
|---|---|---|
| Nhận diện | `BOE Technology Group Co., Ltd (DFP-5): connected` | `NVIDIA (DFP-5): connected` |
| EDID | đọc được | `(WW) NVIDIA(0): NVIDIA (DFP-5) does not have an EDID` |
| Mode | `DP-4 @2560x1600 +0+0` | `DP-4 640x480+0+0`, `0mm x 0mm` |

EDID giả trong `/sys/class/drm/card0-eDP-1/edid`:

```
00000000  00 ff ff ff ff ff ff 00  3a c4 00 00 00 00 00 00
00000010  00 00 01 04 95 00 00 78  ee 91 a3 54 4c 99 26 0f
00000020  50 54 00 20 00 00 01 01  01 01 01 01 01 01 01 01
00000030  01 01 01 01 01 01 00 00  00 00 00 00 00 00 00 00
*                                  ^^^ toàn bộ detailed timing = 0
```

`3a c4` giải mã ra **"NVD"** = NVIDIA, không phải BOE. Không có detailed timing descriptor nào → chỉ còn established timing 640x480.

### Vì sao layout bị sai

GNOME/mutter khớp cấu hình đã lưu bằng bộ ba `vendor + product + serial`:

| | `monitors.xml` | Mutter thấy lúc lỗi |
|---|---|---|
| DP-4 | `BOE / 0x0c8b / 0x00000068` | `NVD / 0x0000 / 0x00000000` |

Không khớp → mutter vứt layout đã lưu, rơi về layout mặc định xếp ngang tuần tự. Layout sai **là hệ quả**, không phải lỗi riêng.

### Vì sao ngẫu nhiên, và vì sao reboot mới hết

Đây là **race condition** lúc khởi động:

```
GPU cấp nguồn panel (VDD)
   ↓  panel TCON khởi động — thời gian dao động theo nhiệt độ,
   ↓  thời gian máy tắt trước đó, trạng thái tụ nguồn
TCON sẵn sàng → kéo HPD
   ↓
Driver đọc EDID qua AUX
   ↓  TCON chưa sẵn sàng → AUX_DEFER
Driver retry có giới hạn → hết lượt → bịa EDID giả
```

Yếu tố làm cửa sổ đua hẹp trên máy này:

- `nvidia-drm.modeset=1` khiến modeset chạy **rất sớm, giây thứ ~5.5**, sát lúc panel vừa có điện.
- Driver là **open kernel module**, khởi tạo display chạy bất đồng bộ trên firmware GSP.
- Boot lỗi nạp `nvidia-modeset` ở **5.530s — chậm nhất trong 8 boot** (boot tốt: 5.438–5.518s).

EDID giả bị **cache ở tầng kernel** và **không có cơ chế đọc lại**. Đã kiểm chứng: `xrandr --output DP-4 --off` rồi `--auto` không làm driver dò lại (`bl_power` vẫn `0` kể cả khi `dpms=Off` → panel chưa từng mất nguồn). `xrandr --addmode` cũng bị **BadMatch** vì driver từ chối mọi mode không được EDID xác nhận. Đăng xuất/khởi động lại X cũng vô ích vì cache nằm dưới tầng kernel. **Chỉ reboot mới xoá được.**

### Không phải hỏng phần cứng

Quét log 4 phiên gần nhất: **không có một lỗi hiển thị nào giữa phiên** — không `Xid`, không lỗi link training, không GPU fallen off the bus. Cáp eDP mòn ở bản lề sẽ gây nhiễu cả lúc đang dùng, nhất là khi gập mở màn. Triệu chứng khu trú hoàn toàn ở thời điểm khởi tạo → lỗi thời điểm, không phải lỗi vật lý.

Đèn nền cũng bình thường: `bl_power=0`, `brightness=51/100`.

## Cách khắc phục

Cấp sẵn EDID cho driver bằng `Option "CustomEDID"` → driver không cần hỏi panel nữa → race condition mất tác dụng.

Vấn đề: cần EDID thật, mà lúc đang lỗi thì không đọc được từ panel. **Giải pháp: lấy từ registry Windows** (máy dual-boot), rồi để service tự nâng cấp lên bản đầy đủ ở boot tốt kế tiếp.

### Cơ chế

```
Mỗi lần boot:
  edp-edid-cache.service  ──chạy trước gdm──►  đọc /sys/.../card0-eDP-1/edid
        │
        ├─ EDID thật (BOE 0x0c8b, checksum mọi block đúng) ──► ghi đè /etc/X11/edid-edp.bin
        └─ EDID giả  (NVD 0x0000)                          ──► GIỮ NGUYÊN cache cũ
                                                                      │
  Xorg đọc Option "CustomEDID" ◄──────────────────────────────────────┘
```

Vì EDID chứa đúng `BOE / 0x0c8b / 0x00000068`, mutter luôn khớp `monitors.xml` → layout không còn bị đặt sai.

### Cài đặt

```bash
sudo ./install.sh          # cài, KHÔNG khởi động lại X
# rồi đăng xuất và đăng nhập lại (không cần reboot)
```

Gỡ bỏ bất cứ lúc nào:

```bash
sudo edp-edid-fix-rollback
```

Đừng dùng `systemctl restart gdm` — nó giết luôn terminal đang chạy. Nếu X không lên: `Ctrl+Alt+F3` → đăng nhập → chạy lệnh gỡ ở trên.

### Kết quả đã kiểm chứng

Ngay trong phiên bị lỗi, chỉ đăng xuất/đăng nhập lại, **không reboot**:

```
Xorg.1.log:
  (**) NVIDIA(0): Option "CustomEDID" "DFP-5:/etc/X11/edid-edp.bin"
  (--) NVIDIA(GPU-0): BOE Technology Group Co., Ltd (DFP-5): connected
  → cảnh báo "does not have an EDID" đã biến mất

xrandr:
  DP-4 connected primary 2560x1600+651+1080  345mm x 215mm

mutter:
  DP-4  vendor=BOE  product=0x0c8b  serial=0x00000068
  → layout khớp đúng monitors.xml, tự khôi phục
```

Đáng chú ý: **kernel vẫn giữ EDID giả `NVD`** (boot đó thực sự lỗi), nhưng X đã chạy `BOE` 2560x1600 vì `CustomEDID` ghi đè lên. Đúng như thiết kế.

## Giới hạn cần biết

| Thời điểm | EDID dùng | Refresh |
|---|---|---|
| Ngay sau khi cài | seed 128B từ Windows | 2560x1600 **@60Hz** |
| Sau boot tốt đầu tiên | EDID thật từ panel | 2560x1600 **@240Hz** |

Registry Windows chỉ lưu **base block 128 byte**; timing 240Hz nằm trong DisplayID extension không được lưu. Service tự nâng cấp ở boot tốt kế tiếp rồi giữ vĩnh viễn.

EDID thật đọc từ panel (384 byte) đã được xác nhận chứa đủ:

```
Block 0  base       checksum hợp lệ   DTD0: 2560x1600 @ 60.00Hz
Block 1  CTA-861    checksum hợp lệ
Block 2  DisplayID  checksum hợp lệ   [0x22] Type VII: 2560x1600 @ 240.00Hz
                                              pclk 1175.040 MHz
```

### 60Hz hay 240Hz — số đo thực tế

EDID khai **60Hz là preferred** (DTD0 trong base block), 240Hz chỉ là mode phụ trong DisplayID. Nên mọi thứ chọn "mode ưu tiên" theo chuẩn đều lấy 60Hz — đó là lý do mặc định là 60, không phải ai cấu hình sai.

Đo trên desktop nhàn rỗi, PowerMizer ở chế độ adaptive, lấy mẫu 20 giây mỗi 0.5s:

|  | 60Hz | 240Hz | chênh |
|---|---|---|---|
| Power trung bình | 7.84 W | 8.42 W | +0.58 W |
| **Power sàn** | 4.49 W | 6.27 W | **+1.78 W** |
| **Mem clock sàn** | 405 MHz | 810 MHz | **+405 MHz** |
| Nhiệt độ đỉnh | 41 °C | 41 °C | 0 |

Con số đáng tin là **giá trị sàn**, không phải trung bình — trung bình bị nhiễu bởi hoạt động desktop ngẫu nhiên (thấy rõ ở chỗ GPU clock trung bình lại giảm, điều vô nghĩa về mặt vật lý). Sàn mang tính cấu trúc: ở 240Hz clock bộ nhớ không tụt xuống 405 MHz được nữa vì display engine cần thêm băng thông, kéo theo sàn điện năng tăng.

**Nhiệt độ không đổi.** Và không liên quan gì tới lỗi throttle trong `fix-legion-cpu-throttle`: đo lúc chạy 240Hz vẫn thấy `PL1=140W, PL2=190W`, governor `performance`, core cao nhất `5660MHz` — không có dấu vết kẹp công suất.

Khuyến nghị: cắm sạc thì dùng 240Hz, chạy pin thì về 60Hz.

## Bẫy gặp phải khi làm

**1. EDID lấy từ registry không nguyên vẹn.** Byte 126 khai "có 2 extension" nhưng registry chỉ lưu 128 byte base. Đọc 384 byte thì 256 byte sau là rác registry (thấy rõ chuỗi ASCII `Orig...` ở offset `0x00ac`), checksum sai. Phải cắt còn 128 byte, đặt byte 126 = 0 và **tính lại checksum** byte 127.

**2. Script cache phải kiểm checksum TỪNG extension block.** Nếu chỉ kiểm base block, blob 384 byte kiểu trên sẽ lọt qua và bị cache lại như "EDID thật". Đã bổ sung vòng lặp kiểm mọi block.

**3. Backup không được chứa chính file mình cài.** `/etc/X11/edid-edp.bin` và `10-edp-customedid.conf` là tên do bộ này đặt ra, không phần mềm nào khác tạo. Nếu chạy `install.sh` lần hai mà vẫn backup chúng thì `rollback` sẽ xoá rồi khôi phục lại đúng chúng → gỡ không bao giờ sạch. Đã chặn bằng marker `.backup-done`.

**4. Rollback không được để trong `/tmp`.** Ubuntu xoá `/tmp` khi boot, mà đó đúng là lúc cần nó nhất (X chết, phải vào TTY). Đã cài vào `/usr/local/sbin/edp-edid-fix-rollback`.

**5. `ConditionPathExists` làm service bị skip vĩnh viễn.** Bản đầu dùng `ConditionPathExists=/sys/class/drm/card0-eDP-1/edid`. Mốc thời gian boot thực tế:

| Mốc | Sự kiện |
|---|---|
| `5.530s` | nvidia-drm **bắt đầu** nạp |
| `7.804s` | systemd kiểm tra điều kiện → đường dẫn chưa có → **skip** |
| `8.519s` | `Initialized nvidia-drm` ← connector DRM mới ra đời |
| `9.980s` | gdm khởi động |

Sớm hơn 0.7 giây, và systemd không thử lại. Hậu quả: boot đọc được EDID thật cũng không bắt được. Đã bỏ `Condition`, để chính script chờ có giới hạn 20s.

Kèm theo: `After=systemd-udev-settle.service` cũng vô dụng — unit đó là `static` và không bao giờ được kích hoạt (`Active: inactive (dead)`), nên dòng `After=` không ràng buộc gì cả.

Vòng chờ không làm chậm boot khi gặp boot lỗi: lúc đó driver đã bịa sẵn EDID giả 128 byte, đọc được ngay, nên vòng chờ thoát lập tức rồi kết luận "không dùng được".

**6. Đơn vị pixel clock trong DisplayID 2.0 là kHz, không phải 10 kHz.** Và timing nằm ở data block `0x22` (Type VII Timing), còn `0x20` là Product Identification. Nhầm hai chỗ này thì đọc ra `2400 Hz` thay vì `240 Hz`.

## Mang sang máy khác

### Danh tính `BOE / 0x0c8b / 0x00000068` chỉ đúng cho máy này

Ba giá trị này nằm trong EDID và mô tả **tấm panel cụ thể**, không phải model laptop:

| Thành phần | Nằm ở | Ý nghĩa |
|---|---|---|
| `BOE` | byte 8–9 (`09 E5`) | PNP ID của hãng làm panel (BOE Technology Group) |
| `0x0c8b` | byte 10–11 (little-endian) | mã sản phẩm, ứng với model **NE160QDM-NZB** |
| `0x00000068` | byte 12–15 | trường serial trong EDID |

Ba điểm cần nhớ:

1. **Panel khác model → mã sản phẩm khác.** Kể cả cùng hãng BOE.
2. **Cùng một đời Legion vẫn có thể lắp panel khác nhau tuỳ lô hàng** (BOE, Samsung, CSOT, AUO). Hai máy trông y hệt nhau vẫn có thể ra hai danh tính khác nhau.
3. `0x00000068` **không phải serial riêng của từng máy.** Với panel laptop, trường này thường là hằng số nung sẵn trong firmware panel. Đừng nhầm nó với số seri của máy.

Kết luận: **luôn phải tự lấy lại giá trị trên từng máy.**

### Cách lấy

Chạy trên một boot mà panel được nhận diện đúng (không phải boot đang lỗi):

```bash
./show-panel-identity.py
```

Nó in ra đúng dòng cần dán vào `edp-edid-cache.py`, và liệt kê các `DFP-N` để chọn cho `10-edp-customedid.conf`. Nếu boot đang lỗi EDID, nó sẽ báo `EDID GIA` và bảo bạn reboot — không đưa ra số liệu sai.

### Ba chỗ phải sửa

| File | Sửa gì |
|---|---|
| `edp-edid-cache.py` | `VENDOR` và `PROD` |
| `10-edp-customedid.conf` | tên `DFP-N` của panel nội bộ |
| `extract-edid.py` | `BOE` và `PRODUCT` (chỉ khi trích từ registry Windows) |

Nếu vendor không khớp, script báo lỗi phân biệt rõ hai trường hợp:

```
vendor la NVD (0x3ac4), khong phai BOE: EDID gia cua driver
vendor la SAM (0x4c2d), khong phai BOE: panel khac -> xem muc 'Mang sang may khac'
```

### Vì sao không để script tự nhận panel

Vì phép so sánh vendor/product **chính là thứ phân biệt EDID thật với EDID giả**. Nếu script chấp nhận "bất cứ EDID nào panel khai", nó sẽ vui vẻ cache luôn cái `NVD 0x0000` giả của driver và vô hiệu hoá toàn bộ cơ chế. Hardcode ở đây là tính năng, không phải thiếu sót.

## Quan hệ với `fix-monitors-issues-after-unlocking-screen-ubuntu`

Hai bộ fix giải quyết hai lỗi **khác gốc rễ** nhưng cho ra cùng một triệu chứng bề mặt:

|  | fix-edp-edid-flicker | fix-monitors-issues-after-unlocking |
|---|---|---|
| Kích hoạt | Khởi động máy | Mở khoá màn hình, hub USB-C rớt tín hiệu |
| Nguyên nhân | Đọc EDID panel qua eDP AUX thất bại | Driver/mutter mất trạng thái layout khi DPMS thức |
| Ảnh hưởng | Chỉ panel built-in | Chủ yếu màn ngoài |
| Còn xảy ra nếu chỉ 1 màn? | **Có** | Không |

Điểm chung nằm ở tầng dưới: mutter khớp cấu hình đã lưu bằng danh tính `vendor + product + serial`, nên hễ danh tính hoặc việc dò tìm trục trặc là layout bay.

**Bộ fix này giúp luôn cho bộ kia:** trước đây mỗi boot lỗi EDID là danh tính panel đổi thành `NVD/0x0000` khiến mutter không khớp được gì. Nay danh tính cố định vĩnh viễn, một nguồn gây mất layout đã bị loại bỏ.

**Chiều ngược lại từng có xung đột:** `monitor-fix` bỏ rơi refresh rate nên kéo panel 240Hz về 60Hz sau mỗi lần mở khoá. Đã vá — xem `RATE=` trong `layout.env` của bộ đó.

## Nội dung thư mục

| File | Vai trò |
|---|---|
| `install.sh` | Cài đặt (idempotent, chạy lại được) |
| `rollback.sh` | Gỡ bỏ, cài vào PATH thành `edp-edid-fix-rollback` |
| `edp-edid-cache.py` | Service lưu EDID thật khi đọc được |
| `edp-edid-cache.service` | Unit systemd, chạy trước `display-manager` |
| `10-edp-customedid.conf` | Cấu hình Xorg trỏ tới EDID đã lưu |
| `edid-seed-128.bin` | EDID sạch 128B, dùng làm seed |
| `edid-windows-raw-384.bin` | Bản thô từ registry, giữ để đối chiếu |
| `get-edid.sh` | Mount Windows read-only, trích EDID |
| `extract-edid.py` | Quét registry hive tìm block EDID |
| `parse-edid.py` | Đọc và giải mã EDID |
| `show-panel-identity.py` | In hằng số cần sửa khi mang sang máy khác |

## Chẩn đoán nhanh khi nghi tái phát

```bash
# 1. X có nhận đúng panel không
grep -E 'DFP-5.*connected|does not have an EDID' ~/.local/share/xorg/Xorg.1.log

# 2. Kernel đọc EDID được không (NVD = giả, BOE = thật)
python3 -c "e=open('/sys/class/drm/card0-eDP-1/edid','rb').read();v=(e[8]<<8)|e[9];print(''.join(chr(((v>>s)&0x1F)+64) for s in (10,5,0)))"

# 3. Mutter thấy danh tính gì
gdbus call --session --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.GetCurrentState | grep -o "'DP-4'[^)]*"

# 4. Service có chạy không
systemctl status edp-edid-cache.service
```

## Nếu về sau vẫn tái phát

Nếu lỗi xuất hiện **cả khi đang dùng** chứ không chỉ lúc boot, hoặc kèm `Xid` trong dmesg, thì lúc đó mới nghi cáp dẹt eDP ở bản lề. Cơ chế trong tài liệu này chỉ chống được lỗi đọc EDID lúc khởi tạo.

Một phép thử đáng làm: theo dõi xem lỗi có hay xảy ra khi cắm sẵn màn ngoài lúc boot không — khởi tạo song song nhiều output có thể làm eDP bị chậm lượt.
