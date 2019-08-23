# Tìm hiểu Nagios

# Mục lục
- [1. Tổng quan về Nagios](#1)
- [2. Tính năng và đặc điểm của Nagios](#2)
- [3. Thành phần của Nagios](#3)
	- [3.1. Nagios Core](#31)
	- [3.2. Nagios plugin](#32)
- [4. Cơ chế hoạt động](#4)
	- [4.1. Giám sát trực tiếp](#41)
	- [4.2. Kiểm tra qua NRPE](#42)
- [5. Tài liệu tham khảo](#5)


---------------------------------------------

Tài liệu sẽ được cập nhật thêm...

<a name="1"></a>
## 1. Tổng quan về Nagios:
- Là 1 công cụ giám sát nguồn mở mạnh mẽ giúp giám sát hạ tầng CNTT (máy chủ, thiết bị mạng, thiết bị phần cứng...)
- Ra mắt vào năm 1999, được bảo trợ bởi Nagios Enterprises
- Nagios có thể đưa ra cảnh báo tới người dùng khi hệ thống gặp sự cố
- Được thiết kế với khả năng mở rộng và tính linh hoạt cao
- Một số sản phẩm của Nagios như: Nagios XI, Nagios log server, Nagios Network Analyzer, Nagios Fusion


<a name="2"></a>
## 2. Tính năng của Nagios
- Giám sát các dịch vụ mạng(SMTP, POP3, HTTP, PING...)
- Giám sát các host (CPU, Disk, RAM,...)
- Các plugin đơn giản, dễ dàng phát triển và kiểm tra dịch vụ
- Phát hiện và phân biệt các host bị down và host không thể truy cập được
- Thông báo khi có sự cố xảy ra và khi sự cố được khắc phục (qua mail, tin nhắn,...)
- Tự động xoay vòng log file
- Hỗ trợ giám sát dự phòng
- Có giao diện web để view
- Hoạt động dựa trên cơ chê plugin, Nagios nhận thông tin từ plugin và xử lý các thông tin đó
- Thiết lập plugin đơn giản, người dùng có thể tự phát triển plugin của mình qua Shell script, C/C++, Python, Ruby...
- Cung cấp lịch sử ghi lại các cảnh báo, thông báo, sự cố...
- Thư viện add-on plugin phong phú

<a name="3"></a>
## 3. Thành phần của Nagios
Nagios gồm 2 thành phần chính là Nagios Core và Nagios plugin

<a name="31"></a>
#### 3.1. Nagios Core
- Là thành phần chính của Nagios, là công cụ giám sát và cảnh báo 
- Nagios core xử lý các sự kiện, quản lý các thông báo của các thành phần được theo dõi
- Nagios Core khắc họa 1 số API được sử dụng để mở rộng khả năng của mình, thực hiện các nhiệm vụ bổ sung

<a name="32"></a>
#### 3.2. Nagios plugin
- Nagios plugin là thành phần mở rộng giúp Nagios Core theo dõi các thông tin. Plugin là các ứng dụng độc lập nhưng thường được thực thi, điều khiển bởi Nagios Core
- Plugin thực hiện kiểm tra, sau đó trả kết quả về cho Nagios Core. Plugin có thể viết bằng C/C++..., hoặc là các bản thực thi (Perl, PHP...)

<a name="4"></a>
## 4. Cơ chế hoạt động
Một số cơ chế hoạt động của Nagios Core như: giám sát trực tiếp, check qua NRPE...

<a name="41"></a>
#### 4.1. Giám sát trực tiếp
- Giám sát trực tiếp, các plugin được đặt ngay trên server Nagios
- Giám sát trực tiếp để kiểm tra các giao thức giao tiếp qua mạng như SMPT, HTTP, FTP...
- Một số plugin như: check_ping, check_http, check_snmp...
- Nguyên tắc của giám sát trực tiếp là client không cần cài gì cả

<a name="42"></a>
#### 4.2 Kiểm tra của NRPE
- NRPE (Nagios Remote Plugin Executor), hay còn gọi là bộ thực thi giám sát từ xa, được cài đặt trên các thiết bị giám sát
- Sử dụng để giám sát các thông số của host như check RAM, CPU, Disk... Hoặc để giám sát mail, database, web
- Các plugin cục bộ trên host sẽ thu thập dữ liệu sau đó dịch vụ như nrpe_daemon sẽ trả kết quả cho nrpe_plugin trên Nagios server

<a name="5"></a>
## 5. Tài liệu tham khảo
-(1) https://www.nagios.org/documentation/













