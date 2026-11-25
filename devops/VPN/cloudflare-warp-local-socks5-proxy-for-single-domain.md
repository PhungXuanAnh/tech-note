# Cloudflare WARP (Local SOCKS5 Proxy) + ZeroOmega chỉ áp dụng cho 1 domain trên Chrome

- [1. Bài toán & kiến trúc giải pháp](#1-bài-toán--kiến-trúc-giải-pháp)
- [2. Cài đặt Cloudflare WARP chạy SOCKS5 proxy cục bộ trên Ubuntu](#2-cài-đặt-cloudflare-warp-chạy-socks5-proxy-cục-bộ-trên-ubuntu)
  - [2.1. Cách 1: Chạy hàm tự động trong `new-os-install-Ubuntu.sh`](#21-cách-1-chạy-hàm-tự-động-trong-new-os-install-ubuntush)
  - [2.2. Cách 2: Cài đặt thủ công từng bước](#22-cách-2-cài-đặt-thủ-công-từng-bước)
  - [2.3. Kiểm chứng proxy cục bộ](#23-kiểm-chứng-proxy-cục-bộ)
- [3. Cấu hình tiện ích ZeroOmega trên Chrome cho riêng 1 domain](#3-cấu-hình-tiện-ích-zeroomega-trên-chrome-cho-riêng-1-domain)
- [4. Lệnh quản lý & xử lý sự cố nhanh](#4-lệnh-quản-lý--xử-lý-sự-cố-nhanh)

---

## 1. Bài toán & kiến trúc giải pháp

Một số nhà mạng tại Việt Nam (ví dụ VNPT) chặn truy cập web của một số trang (như `www.linkedin.com` báo `ERR_CONNECTION_CLOSED`) bằng **bộ lọc gói tin sâu theo chỉ báo tên máy chủ trong bắt tay TLS (TLS SNI / DPI filtering)**. Khi đó:

- Đổi máy chủ phân giải tên miền (DNS) như `1.1.1.1` / `8.8.8.8` hoặc bật DNS qua HTTPS (DoH) không giải quyết được nếu trang web không bật mã hóa gói chào kết nối (ECH).
- Bật mạng riêng ảo (VPN) toàn máy lại làm đổi IP và định tuyến toàn bộ lưu lượng của hệ thống (ảnh hưởng SSH, Docker, Tailscale, hoặc các dịch vụ nội bộ).

**Giải pháp gọn nhất (miễn phí, không giới hạn dung lượng, không ảnh hưởng hệ thống)**:

1. **Cloudflare WARP chạy ở chế độ máy chủ ủy quyền cục bộ (`WarpProxy`)** tại `127.0.0.1:40000`:
   - `Packet Tunnel: false` — không đụng vào bảng định tuyến (routing table) của hệ điều hành.
   - Dịch vụ `warp-svc` tự khởi động cùng Ubuntu và tự duy trì kết nối `127.0.0.1:40000`.
2. **Tiện ích mở rộng ZeroOmega trên Chrome (`Proxy SwitchyOmega 3 (ZeroOmega)`)**:
   - Bật chế độ **`auto switch`** để chỉ định tuyến riêng domain cần mở (ví dụ `*.linkedin.com`) qua `SOCKS5 127.0.0.1:40000`.
   - Mọi tab khác trong Chrome, terminal, SSH, Docker, Tailscale vẫn đi thẳng mạng gốc 100%.

---

## 2. Cài đặt Cloudflare WARP chạy SOCKS5 proxy cục bộ trên Ubuntu

### 2.1. Cách 1: Chạy hàm tự động trong `new-os-install-Ubuntu.sh`

Dùng khi cài máy Ubuntu mới hoặc muốn cài lại/khôi phục cấu hình (chạy lại nhiều lần an toàn):

```bash
source ~/Dropbox/Work/Other/conf.d/alias/new-os-install-Ubuntu.sh
install_cloudflare_warp_proxy
```

Hàm này tự động thêm kho APT chính thức của Cloudflare, cài `cloudflare-warp`, bật `warp-svc` tự khởi động cùng hệ thống, đăng ký tài khoản miễn phí nếu chưa có, chuyển sang chế độ `proxy` trên cổng `40000` và kết nối.

### 2.2. Cách 2: Cài đặt thủ công từng bước

```bash
# 1. Thêm khóa GPG và kho APT chính thức của Cloudflare
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg \
  | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ ${CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/cloudflare-client.list > /dev/null

# 2. Cài gói và bật dịch vụ tự khởi động khi boot
sudo apt-get update
sudo apt-get install -y cloudflare-warp
sudo systemctl enable --now warp-svc

# 3. Đăng ký miễn phí, chuyển sang chế độ SOCKS5 proxy cục bộ cổng 40000 và kết nối
warp-cli --accept-tos registration new
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect
```

*(Nếu cài xong có cửa sổ GUI `Cloudflare One Client` bật lên, có thể đóng lại bình thường; dịch vụ nền `warp-svc` đã được cấu hình qua `warp-cli`.)*

Đảm bảo proxy hệ thống của GNOME đang tắt để các ứng dụng khác không bị đi qua proxy:

```bash
gsettings set org.gnome.system.proxy mode 'none'
```

### 2.3. Kiểm chứng proxy cục bộ

```bash
# Kiểm tra trạng thái WARP (phải là Connected)
warp-cli --accept-tos status

# Lưu lượng đi qua SOCKS5 127.0.0.1:40000 -> phải thấy warp=on
curl -s --socks5-hostname 127.0.0.1:40000 https://www.cloudflare.com/cdn-cgi/trace | grep -E '^(warp|ip|loc|colo)='

# Lưu lượng trực tiếp từ terminal -> phải thấy warp=off
curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -E '^(warp|ip|loc|colo)='
```

---

## 3. Cấu hình tiện ích ZeroOmega trên Chrome cho riêng 1 domain

1. **Cài tiện ích mở rộng**:
   - Mở Chrome Web Store: [Proxy SwitchyOmega 3 (ZeroOmega)](https://chromewebstore.google.com/detail/proxy-switchyomega-3-zero/pfnededegaaopdmhkdmcofjmoldfiped) (bản Manifest V3 kế nhiệm SwitchyOmega).
   - Bấm **Add to Chrome**.
2. **Tạo hoặc sửa hồ sơ proxy trỏ vào WARP**:
   - Mở trang **Options** của ZeroOmega, chọn hồ sơ **`proxy`** ở cột bên trái (hoặc bấm **New profile...** → đặt tên `WARP`, chọn **Proxy Profile**).
   - Nhập cấu hình:
     - **Protocol**: `SOCKS5`
     - **Server**: `127.0.0.1`
     - **Port**: `40000`
   - Bấm **Apply changes** (nút xanh ở góc dưới bên trái).
3. **Cấu hình quy tắc chỉ áp dụng cho 1 domain (`auto switch`)**:
   - Chọn mục **`auto switch`** ở cột bên trái.
   - Bấm **Add a condition** và điền:
     - **Condition Type**: `Host wildcard`
     - **Condition Details**: `*.linkedin.com` *(trong ZeroOmega, mẫu `*.example.com` khớp cả tên miền gốc `example.com` lẫn mọi tên miền phụ như `www.example.com`, `vn.example.com`)*
     - **Profile**: chọn **`proxy`** (hoặc `WARP`)
   - Ở dòng **Default** phía dưới, giữ **`[Direct]`** để mọi trang web khác đi thẳng mạng gốc.
   - Bấm **Apply changes**.
   - *(Khi cần mở thêm domain bị chặn khác, chỉ cần bấm **Add a condition** thêm 1 dòng tương tự rồi bấm **Apply changes**.)*
4. **Kích hoạt & kiểm chứng**:
   - Bấm biểu tượng **ZeroOmega** trên thanh công cụ Chrome → chọn **`auto switch`**.
   - Mở `https://www.linkedin.com/` → truy cập bình thường.
   - Mở `https://www.cloudflare.com/cdn-cgi/trace` trên tab khác → kiểm tra thấy **`warp=off`** (xác nhận các trang khác không đi qua WARP).

---

## 4. Lệnh quản lý & xử lý sự cố nhanh

```bash
# Xem trạng thái & cấu hình hiện tại (xác nhận Mode: WarpProxy on port 40000, Always On: true)
warp-cli --accept-tos status
warp-cli --accept-tos settings list
systemctl is-enabled warp-svc

# Tắt / bật lại WARP tạm thời (các tab khác vẫn vào bình thường, chỉ domain trong auto switch bị ảnh hưởng)
warp-cli --accept-tos disconnect
warp-cli --accept-tos connect

# Đăng ký lại từ đầu nếu tài khoản thiết bị lỗi hoặc đổi mạng làm treo phiên
warp-cli --accept-tos registration delete
warp-cli --accept-tos registration new
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect
```

### Cách kiểm chứng nhanh xem một domain có bị nhà mạng chặn theo SNI hay không

```bash
# 1. Thử truy cập trực tiếp -> nếu TCP connect được nhưng treo ở Client hello / 0 bytes received
curl -vI --max-time 6 https://www.linkedin.com/

# 2. Kiểm tra cùng IP của domain đó với SNI khác (vd 104.18.41.41) -> nếu trả HTTP/2 200 tức là bị chặn theo SNI
curl -vI --max-time 6 --connect-to www.cloudflare.com:443:104.18.41.41 https://www.cloudflare.com/

# 3. Thử lại qua WARP SOCKS5 -> nếu nhận được phản hồi từ server tức là WARP xử lý được
curl -vI --max-time 10 --socks5-hostname 127.0.0.1:40000 https://www.linkedin.com/
```
