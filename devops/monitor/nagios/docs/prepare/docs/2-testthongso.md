# Sử dụng các công cụ để test CPU và check lưu lượng mạng.

## 1. Sử dụng stress để test CPU.

Stress là một công cụ giúp chúng ta có thể :
 <ul>
  <li>Điều chỉnh các hoạt động trên một hệ thống.</li>
  <li>Giám sát các giao diện hạt nhân của hệ điều hành.</li>
  <li>Kiểm tra các thành phần phần cứng Linux của bạn như CPU, bộ nhớ, thiết bị đĩa và nhiều thứ khác để quan sát hiệu suất của chúng trong điều kiện căng thẳng.</li>
  <li>Đo điện năng tiêu thụ khác nhau tải trên một hệ thống.</li>
  <li>Là một công cụ giúp chúng ta kiểm tra các  vấn đề liên quan đến cảnh báo.</li>
 </ul>

Stress có một số các chức năng hữu ích như sau :
 <ul>
  <li>CPU compute</li>
  <li>Drive stress</li>
  <li>I/O syncs</li>
  <li>Pipe I/O</li>
  <li>Cache thrashing</li>
  <li>VM stress</li>
  <li>Socket stressing</li>
  <li>Process creation and termination</li>
  <li>Context switching properties</li>
 </ul>

### 1.1. Cài đặt Stress.

- Trên Ubuntu :

    ```sh
    apt-get update
    apt get install stress -y
    ```

- Trên CentOS 7 :

    ```sh
    yum install epel-release -y
    yum install stress -y 
    ```

### 1.2. Một số option trong Stress.

- Để tạo ra N công việc cho hàm sqrt(), dùng -cpu N.
- Để tạo ra N công việc cho hàm sync(), dùng -io N.
- Để tạo ra N công việc cho hàm malloc()/free(), dùng -vm N.
- Để phân bổ bộ nhớ cho mỗi công việc, dùng –vm-bytes N.
- Thay vì giải phóng và phân bổ lại tài nguyên bộ nhớ, bạn có thể làm lại bộ nhớ bằng cách sử dụng tùy chọn -vm-keep.
- Để đặt thời gian sleep là N giây trước khi giải phóng bộ nhớ, dùng –vm-hang N.
- Để tạo ra N công việc cho hàm write()/unlink(), dùng –hdd N.
- Bạn có thể đặt thời gian chờ sau N giây bằng cách sử dụng tùy chọn timeout N.
- Để đặt khoảng thời gian đợi trước khi bắt đầu công việc theo microseconds, dùng –backoff N.
- Để hiển thị thêm thông tin chi tiết khi chạy stress, hãy sử dụng tùy chọn -v.
- Sử dụng --help để xem trợ giúp sử dụng công cụ này.

### 1.3. Sử dụng stress để  test CPU hệ thống.

- Cài đặt stress :

    ```sh
    yum install epel-release -y
    yum install stress -y 
    ```

- Cài đặt công cụ `sysstat` :

    ```sh
    yum install sysstat -y
    ```
- Đầu tiên ta kiểm tra hệ thống bằng lệnh :

    ```sh
    [root@localhost ~]# uptime
    22:57:25 up  1:40,  3 users,  load average: 0.45, 1.53, 0.91

    # đây là tải trung bình lần lượt trong thời gian 1 phút, 5 phút và 15 phút.
    ```
Kết quả thu được chúng ta ghi lại để có thể so sánh .

- Tiếp theo chúng ta kiểm tra thử CPU của hệ thống  :

    ```sh
    [root@localhost ~]# sar -u 3 10
    Linux 3.10.0-514.el7.x86_64 (localhost.localdomain)     08/01/2017      _x86_64_        (1 CPU)

    10:58:41 PM     CPU     %user     %nice   %system   %iowait    %steal     %idle
    10:58:44 PM     all      0.00      0.00      0.33      0.33      0.00     99.34
    10:58:47 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
    10:58:50 PM     all      0.33      0.00      0.33      0.00      0.00     99.34
    10:58:53 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    10:58:56 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    10:58:59 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
    10:59:02 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    10:59:05 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    10:59:08 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    10:59:11 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
    Average:        all      0.03      0.00      0.23      0.03      0.00     99.70
    ```

Kết quả trên chúng ta thấy được idle đang là gần như 100% , chỉ có 1 chút được sử dụng bởi hệ thống. 

Bây giờ chúng ta tiến hành một phép thử thông qua Stress và kiểm tra lại

- Thực hiện lệnh ;

    ```sh
    [root@localhost ~]# sar -u 3 30
    ```

- Kết quả chúng ta thu được khi check CPU như sau ;


    ```sh
    [root@localhost ~]# sar -u 3 30
    Linux 3.10.0-514.el7.x86_64 (localhost.localdomain)     08/01/2017      _x86_64_        (1 CPU)

    11:03:54 PM     CPU     %user     %nice   %system   %iowait    %steal     %idle
    11:03:57 PM     all     88.89      0.00     11.11      0.00      0.00      0.00
    11:04:00 PM     all     93.00      0.00      7.00      0.00      0.00      0.00
    11:04:03 PM     all     89.04      0.00     10.96      0.00      0.00      0.00
    11:04:06 PM     all     77.01      0.00     22.99      0.00      0.00      0.00
    11:04:09 PM     all     81.33      0.00     18.67      0.00      0.00      0.00
    11:04:12 PM     all     91.63      0.00      8.37      0.00      0.00      0.0
    11:04:15 PM     all     85.79      0.00     14.21      0.00      0.00      0.00
    11:04:18 PM     all     97.76      0.00      2.24      0.00      0.00      0.00
    11:04:21 PM     all     94.55      0.00      5.45      0.00      0.00      0.00
    11:04:24 PM     all     89.64      0.00     10.36      0.00      0.00      0.00
    11:04:27 PM     all     94.35      0.00      5.65      0.00      0.00      0.00
    11:04:30 PM     all     90.80      0.00      9.20      0.00      0.00      0.00
    11:04:33 PM     all     91.02      0.00      8.98      0.00      0.00      0.00
    11:04:37 PM     all     87.30      0.00     12.70      0.00      0.00      0.00
    11:04:40 PM     all     92.54      0.00      7.46      0.00      0.00      0.00
    11:04:43 PM     all     87.26      0.00     12.74      0.00      0.00      0.00
    11:04:46 PM     all     91.88      0.00      8.12      0.00      0.00      0.00
    11:04:49 PM     all     87.67      0.00     12.33      0.00      0.00      0.00
    11:04:52 PM     all      0.00      0.00      9.16      0.00      0.00     90.84
    11:04:55 PM     all      0.33      0.00      0.33      0.00      0.00     99.33
    11:04:58 PM     all      0.00      0.00      1.00      7.36      0.00     91.64
    11:05:01 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
    11:05:04 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    11:05:07 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    11:05:10 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    11:05:13 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    11:05:16 PM     all      0.33      0.00      0.00      0.00      0.00     99.67
    11:05:19 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    11:05:22 PM     all      0.00      0.00      0.33      0.00      0.00     99.67
    11:05:25 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
    Average:        all     49.27      0.00      5.97      0.28      0.00     44.48
    ```

- Kết quả thu được từ công cụ Stress ;

    ```sh
    [root@localhost ~]# uptime
    23:04:56 up  1:47,  3 users,  load average: 9.50, 3.32, 1.61
    ```

=> Thông qua 2 công cụ này  chúng ta có thể dễ dàng kiểm tra được lưu lượng để kiểm tra các cảnh báo và chúng ta thiết lập cho các ứng dụng cảnh báo một cách dễ 
dàng trước khi đưa vào triển khai thực tế.

## 2. Sử dụng Iperf để kiểm tra lưu lượng mạng.

- Iperf là một công cụ hữu hiệu giúp chúng ta tính toán băng thông của mạng.

### 2.1. Cài đặt.

- Trên Ubuntu :

    ```sh
    apt-get update
    apt-get install iperf
    ```

- Trên CentOS 7 :

    ```sh
    yum install epel-release -y
    yum install iperf -y
    ```

### 2.2. Các thông số cơ bản của iperf.

|Tham số|Tác dụng|
|-------|--------|
|-c|chỉ ra địa chỉ IP của server để iperf kết nối đến|
|-f, --format|Chỉ ra định dạng của kết quả hiển thị. 'b' = bps, 'B' = Bps, 'k' = Kbps, 'K' = KBps,...|
|-i, --interval|Thời gian lấy mẫu để hiển thị kết quả tại thời điểm đó ra màn hình|
|-p, --port|Định ra cổng để nghe, mặc định nếu không sử dụng tham số này là cổng 5001|
|-u, --udp|Sử dụng giao thức UDP, mặc định iperf sử dụng TCP|
|-P, --parallel|Chỉ ra số kết nối song song được tạo, nếu là Server mode thì đây là giới hạn số kết nối mà server chấp nhận|
|-b|Định ra băng thông tối ta có thể truyền, chỉ sử dụng với UDP, client mode|
|-t|Tổng thời gian của kết nối, tính bằng giây|
|-M|Max segment size|
|-l|Buffer size|
|-w, --window|Trường Windows size của TCP|

### 2.3. Sử dụng iperf để kiểm tra lưu lượng mạng của hệ thống.

- Cài đặt iperf, cần 2 host. 1 là client và 1 là server. Trên cả 2 host cài iperl :

    ```sh
    yum install epel-release -y
    yum install iperf -y
    ```

- Mở port trên serrver :

    ```sh
    firewall-cmd --permanent --add-port=5001/tcp
    firewall-cmd --reload
    ```

### Thực hiện kiểm tra lưu lượng mạng từ client (10.10.10.130) đến server (10.10.10.129)

- Trên server thực hiện lệnh sau :

    ```sh
    iperf -s
    ```

- Trên client thực hiện lệnh sau :

    ```sh
    iperf -c 10.10.10.129
    ```

- Đợi khoảng 10s chúng ta sẽ thấy được kết quả trả về như sau:

    ```sh
    [root@localhost ~]# iperf -c 10.10.10.129
    ------------------------------------------------------------
    Client connecting to 10.10.10.129, TCP port 5001
    TCP window size:  144 KByte (default)
    ------------------------------------------------------------
    [  3] local 10.10.10.130 port 45758 connected with 10.10.10.129 port 5001
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0-10.0 sec  1.37 GBytes  1.18 Gbits/sec
    ```

- Kết quả mà chúng ta thu được như sau : TCP window size mặc định là 144KByte. Trong thời gian 10s gửi được tổng số dữ liệu là 1,37GB. 
Lưu lượng trung bình là 1.18 Gbits/sec.



### Thực hiện bài test kiểm tra lưu lượng mạng TCP với Buffer size: 16 MB, Window Size: 60 Mbps, Max segment size 5 trong thời gian 5 phút, kết quả hiển thị dưới dạng mbps


Thực hiện lệnh sau trên server :

    ```sh
    iperf -s -P 0 -i 1 -p 5001 -w 60.0m -l 16.0M -f m
    ```

Thực hiện lệnh sau trên client :

    ```sh
    iperf -c 10.10.10.130 -i 1 -p 5001 -w 60.0m -M 1.0K -l 16.0M -f m -t 300

    # trong đó 10.10.10.130 là địa chỉ của server.
    ```

- Kết quả mà ta tìm được là ;

Trên server :

    ```sh
    [root@localhost ~]# iperf -s -P 0 -i 1 -p 5001 -w 60.0m -l 16.0M -f m
    ------------------------------------------------------------
    Server listening on TCP port 5001
    TCP window size: 0.41 MByte (WARNING: requested 60.0 MByte)
    ------------------------------------------------------------
    [  4] local 10.10.10.130 port 5001 connected with 10.10.10.129 port 39748
    [ ID] Interval       Transfer     Bandwidth
    [  4]  0.0- 1.0 sec   141 MBytes  1179 Mbits/sec
    [  4]  1.0- 2.0 sec   150 MBytes  1260 Mbits/sec
    [  4]  2.0- 3.0 sec   145 MBytes  1219 Mbits/sec
    [  4]  3.0- 4.0 sec   162 MBytes  1358 Mbits/sec
    [  4]  4.0- 5.0 sec   170 MBytes  1422 Mbits/sec
    [  4]  5.0- 6.0 sec   208 MBytes  1746 Mbits/sec
    [  4]  6.0- 7.0 sec   208 MBytes  1747 Mbits/sec
    [  4]  7.0- 8.0 sec   191 MBytes  1601 Mbits/sec
    [  4]  8.0- 9.0 sec   198 MBytes  1663 Mbits/sec
    [  4]  9.0-10.0 sec   205 MBytes  1723 Mbits/sec
    [  4] 10.0-11.0 sec   174 MBytes  1459 Mbits/sec
    [  4] 11.0-12.0 sec   192 MBytes  1612 Mbits/sec
    [  4] 12.0-13.0 sec   187 MBytes  1568 Mbits/sec
    [  4] 13.0-14.0 sec   199 MBytes  1666 Mbits/sec
    [  4] 14.0-15.0 sec   237 MBytes  1991 Mbits/sec
    [  4] 15.0-16.0 sec   213 MBytes  1789 Mbits/sec
    [  4] 16.0-17.0 sec   225 MBytes  1885 Mbits/sec
    ```

Trên client :

    ```sh
    [root@localhost ~]# iperf -c 10.10.10.130 -i 1 -p 5001 -w 60.0m -M 1.0K -l 16.0M -f m -t 300
    WARNING: attempt to set TCP maximum segment size to 1024, but got 536
    ------------------------------------------------------------
    Client connecting to 10.10.10.130, TCP port 5001
    TCP window size: 0.41 MByte (WARNING: requested 60.0 MByte)
    ------------------------------------------------------------
    [  3] local 10.10.10.129 port 39748 connected with 10.10.10.130 port 5001
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0- 1.0 sec   144 MBytes  1208 Mbits/sec
    [  3]  1.0- 2.0 sec   160 MBytes  1342 Mbits/sec
    [  3]  2.0- 3.0 sec   144 MBytes  1208 Mbits/sec
    [  3]  3.0- 4.0 sec   160 MBytes  1342 Mbits/sec
    [  3]  4.0- 5.0 sec   160 MBytes  1342 Mbits/sec
    [  3]  5.0- 6.0 sec   208 MBytes  1745 Mbits/sec
    [  3]  6.0- 7.0 sec   208 MBytes  1745 Mbits/sec
    [  3]  7.0- 8.0 sec   192 MBytes  1611 Mbits/sec
    [  3]  8.0- 9.0 sec   208 MBytes  1745 Mbits/sec
    [  3]  9.0-10.0 sec   208 MBytes  1745 Mbits/sec
    [  3] 10.0-11.0 sec   176 MBytes  1476 Mbits/sec
    [  3] 11.0-12.0 sec   192 MBytes  1611 Mbits/sec
    [  3] 12.0-13.0 sec   176 MBytes  1476 Mbits/sec
    [  3] 13.0-14.0 sec   208 MBytes  1745 Mbits/sec
    [  3] 14.0-15.0 sec   224 MBytes  1879 Mbits/sec
    [  3] 15.0-16.0 sec   224 MBytes  1879 Mbits/sec
    [  3] 16.0-17.0 sec   224 MBytes  1879 Mbits/sec
    [  3] 17.0-18.0 sec   128 MBytes  1074 Mbits/sec
    [  3] 18.0-19.0 sec   128 MBytes  1074 Mbits/sec
    [  3] 19.0-20.0 sec   128 MBytes  1074 Mbits/sec
    [  3] 20.0-21.0 sec   160 MBytes  1342 Mbits/sec
    [  3] 21.0-22.0 sec   176 MBytes  1476 Mbits/sec
    [  3] 22.0-23.0 sec   192 MBytes  1611 Mbits/sec
    ```

- Kết quả trên cho chúng ta thấy được cứ mỗi giây sẽ gửi đi một gói tin có lưu lượng trong phần `tranfer` , và kết quả chúng ta sẽ thấy được 
lượng băng thông trung bình ở cột `Bandwidth`.

###  Kiểm tra lưu lượng tối đa trên một card mạng có thể truyển tải được.

- Chúng ta kiểm tra bằng cách gửi liên tục các gói UDP để lấy được thông tin. Bởi vì gói tin UDP ko thực hiện quá trình bắt tay 3 bước như TCP cho 
nên chúng ta có thể dễ dàng kiểm tra được bằng thông tối đa tại một card mạng là bao nhiêu.

Ví dụ : kiểm tra băng thông tối đa của card mạng eth1 trên server 10.10.10.129

- Trên server `10.10.10.129` chúng ta thực hiện như sau :

    ```sh
    iperf -c 10.10.10.129 -u -b 100m -t 100 -i 2
    iperf -c 10.10.10.129 -u -b 500m -t 100 -i 2
    iperf -c 10.10.10.129 -u -b 1g -t 100 -i 2
    iperf -c 10.10.10.129 -u -b 2g -t 100 -i 2
    ```

- Với `iperf -c 10.10.10.129 -u -b 100m -t 100 -i 2` chúng ta thu được kết quả như sau :

    ```sh
    [root@localhost ~]# iperf -c 10.10.10.129 -u -b 100m -t 100 -i 2
    ------------------------------------------------------------
    Client connecting to 10.10.10.129, UDP port 5001
    Sending 1470 byte datagrams, IPG target: 117.60 us (kalman adjust)
    UDP buffer size:  208 KByte (default)
    ------------------------------------------------------------
    [  3] local 10.10.10.129 port 39953 connected with 10.10.10.129 port 5001
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0- 2.0 sec  23.8 MBytes   100 Mbits/sec
    [  3]  2.0- 4.0 sec  23.8 MBytes   100 Mbits/sec
    [  3]  4.0- 6.0 sec  23.8 MBytes   100 Mbits/sec
    [  3]  6.0- 8.0 sec  23.8 MBytes   100 Mbits/sec
    [  3]  8.0-10.0 sec  23.8 MBytes   100 Mbits/sec
    [  3] 10.0-12.0 sec  23.8 MBytes   100 Mbits/sec
    [  3] 12.0-14.0 sec  23.8 MBytes   100 Mbits/sec
    ```

Mỗi 2s kiểm tra 1 lần, và những lần kiểm tra thì lượng dữ liệu gửi đi cũng như Bandwidth không hề thay đổi, có nghĩa là đây chưa phải lưu lượng tối đa 
có thể truyền tải được. Chúng ta tăng lượng lưu lượng cần tryền tải lên rồi tiếp tục kiểm tra.

- Đối với `iperf -c 10.10.10.129 -u -b 500m -t 100 -i 2`

    ```sh
    [root@localhost ~]# iperf -c 10.10.10.129 -u -b 500m -t 100 -i 2
    ------------------------------------------------------------
    Client connecting to 10.10.10.129, UDP port 5001
    Sending 1470 byte datagrams, IPG target: 23.52 us (kalman adjust)
    UDP buffer size:  208 KByte (default)
    ------------------------------------------------------------
    [  3] local 10.10.10.129 port 60022 connected with 10.10.10.129 port 5001
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0- 2.0 sec  82.8 MBytes   347 Mbits/sec
    [  3]  2.0- 4.0 sec  86.5 MBytes   363 Mbits/sec
    [  3]  4.0- 6.0 sec  91.9 MBytes   385 Mbits/sec
    [  3]  6.0- 8.0 sec  90.9 MBytes   381 Mbits/sec
    [  3]  8.0-10.0 sec  84.5 MBytes   354 Mbits/sec
    [  3] 10.0-12.0 sec  92.9 MBytes   390 Mbits/sec
    [  3] 12.0-14.0 sec   127 MBytes   535 Mbits/sec
    [  3] 14.0-16.0 sec   129 MBytes   540 Mbits/sec
    [  3] 16.0-18.0 sec   129 MBytes   541 Mbits/sec
    [  3] 18.0-20.0 sec   130 MBytes   543 Mbits/sec
    [  3] 20.0-22.0 sec   129 MBytes   542 Mbits/sec
    [  3] 22.0-24.0 sec   129 MBytes   540 Mbits/sec
    [  3] 24.0-26.0 sec   129 MBytes   540 Mbits/sec
    [  3] 26.0-28.0 sec   128 MBytes   537 Mbits/sec
    [  3] 28.0-30.0 sec   128 MBytes   535 Mbits/sec
    [  3] 30.0-32.0 sec   126 MBytes   530 Mbits/sec
    [  3] 32.0-34.0 sec   124 MBytes   521 Mbits/sec
    [  3] 34.0-36.0 sec   128 MBytes   535 Mbits/sec
    [  3] 36.0-38.0 sec   128 MBytes   537 Mbits/sec
    [  3] 38.0-40.0 sec   143 MBytes   599 Mbits/sec
    [  3] 40.0-42.0 sec   144 MBytes   606 Mbits/sec
    [  3] 42.0-44.0 sec   139 MBytes   583 Mbits/sec
    [  3] 44.0-46.0 sec   123 MBytes   515 Mbits/sec
    [  3] 46.0-48.0 sec   119 MBytes   500 Mbits/sec
    [  3] 48.0-50.0 sec   119 MBytes   500 Mbits/sec
    ```
Tại trường hợp này lượng băng thông đã thay đổi liên tục với khoảng cách không quá lớn từ 530 đến 600 Mbits/s. chúng ta thực hiện kiểm 
tra với 1 trường hợp khác với lượng lưu lượng cần truyền tải lớn hơn trước khi đưa kết luận.

- Đối với  `iperf -c 10.10.10.129 -u -b 1g -t 100 -i 2`

    ```sh
    [  3] Sent 8058386 datagrams
    [root@localhost ~]# iperf -c 10.10.10.129 -u -b 1g -t 100 -i 2
    ------------------------------------------------------------
    Client connecting to 10.10.10.129, UDP port 5001
    Sending 1470 byte datagrams, IPG target: 11.76 us (kalman adjust)
    UDP buffer size:  208 KByte (default)
    ------------------------------------------------------------
    [  3] local 10.10.10.129 port 50006 connected with 10.10.10.129 port 5001
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0- 2.0 sec  79.2 MBytes   332 Mbits/sec
    [  3]  2.0- 4.0 sec  76.9 MBytes   322 Mbits/sec
    [  3]  4.0- 6.0 sec  90.4 MBytes   379 Mbits/sec
    [  3]  6.0- 8.0 sec   104 MBytes   438 Mbits/sec
    [  3]  8.0-10.0 sec   126 MBytes   527 Mbits/sec
    [  3] 10.0-12.0 sec   126 MBytes   528 Mbits/sec
    [  3] 12.0-14.0 sec   130 MBytes   545 Mbits/sec
    [  3] 14.0-16.0 sec   143 MBytes   600 Mbits/sec
    [  3] 16.0-18.0 sec   143 MBytes   598 Mbits/sec
    [  3] 18.0-20.0 sec   141 MBytes   592 Mbits/sec
    [  3] 20.0-22.0 sec   141 MBytes   593 Mbits/sec
    [  3] 22.0-24.0 sec   143 MBytes   602 Mbits/sec
    [  3] 24.0-26.0 sec   138 MBytes   579 Mbits/sec
    [  3] 26.0-28.0 sec   141 MBytes   590 Mbits/sec
    [  3] 28.0-30.0 sec   174 MBytes   729 Mbits/sec
    [  3] 30.0-32.0 sec   176 MBytes   739 Mbits/sec
    [  3] 32.0-34.0 sec   178 MBytes   747 Mbits/sec
    [  3] 34.0-36.0 sec   176 MBytes   738 Mbits/sec
    ```

Kết quả cho ta thấy lưu lượng tối đa của card mạng này có thể đạt được là 550-600 Mbits/sec

## 3.  Sử dụng sysstat và câu lệnh dd để kiểm tra disk I/O.

- Sử dụng câu lệnh dd để tiến hành chuyển dữ liệu từ ổ `sda` sang ổ `sdb` xem thêm về các thao tác với câu lệnh dd tại [đây](https://github.com/hocchudong/command-linux/blob/master/command-dd.md)

    ```sh
    dd if=/dev/sda of=/dev/sdb conv=noerror,sync
    ```

-Sau đó ta cài đặt công cụ sysstat :

    ```sh
    yum install sysstat -y
    ```

- Dùng lệnh sau để kiểm tra disk I/O.

    ```sh
    iostat -dx 5
    ```

CHúng ta sẽ nhận được hàng loạt các report báo về như sau ;

![disk-1](/docs/prepare/images/disk_1.png)

Ý nghĩa của các thông số như sau :
 <ul>
  <li>r/s và w/s : là số lượng đọc/ghi được yêu cầu </li>
  <li>rsec/s và wsec/s : số sectors đã được đọc/ghi (mỗi sector là 512bytes).</li>
  <li>rkB/s và wkB/s : là số lượng  kilobytes đã được đọc/ghi.</li>
  <li>avgrq-sz : Trung bình sectors của mỗi request (đối với cả đọc và ghi). Được tính như sau : (rsec + wsec) / (r + w)</li>
  <li>avgqu-sz : độ dài trung bình của hàng chờ của thiết bị.</li>
  <li>await : Thời gian phản hồi trung bình của IO request tới thiết bị. Được tính bằng công thức qutim + svctim.</li>
  <li>svctim : Thời gian trung bình mà thiết bị giữ lại request.</li>
  <li>%util : Phần trăm thời gian CPU yêu cầu I/O cấp cho thiết bị (sử dụng băng thông cho thiết bị). Độ bão hòa của thiết bị xẩy ra khi đơn vị này đạt 100%. Nói cách 
  khác đây là số thời gian mà các thiết bị hoàn thiện được công việc.</li>
  <li>rrqm/s : số lượng yêu cầu đọc được merge mỗi giây từ hàng đợi vào ổ cứng.</li>
  <li>wrqm/s : số lượng yêu cầu ghi được merge mỗi giây từ hàng đợi vào ổ cứng.</li>
  <li>Thời gian đáp ứng bao gồm cả thời gian chờ được gọi là qutim</li>
 </ul>

Kết quả khi chúng ta sao chép xong :

    ```sh
    [root@localhost ~]# dd if=/dev/sda of=/dev/sdb conv=noerror,sync
    41943040+0 records in
    41943040+0 records out
    21474836480 bytes (21 GB) copied, 498.459 s, 43.1 MB/s
    [root@localhost ~]#
    ```

## Tìm hiểu về các thông số: IOPS, Latency và Throughput.

Chúng ta cùng miêu tả 3 thông số này qua hoạt động ship hàng từ điểm A đến điểm B như sau :

- IOPS: Số lượng chuyến đi thưc hiện trong một khoảng thời gian

- Throughput: Số hàng chuyển được trong một khoảng thời gian

- Latency: Độ trễ trung bình trong tất cả các chuyến đi trong một khoảng thời gian đã thực hiện

Ba tham số này, đặc biệt là hai tham số IOPS và latency phản ánh chất lượng phục vụ nhưng ko phải lúc nào cũng song hành 
với nhau kiểu một chỉ số tốt thì các chỉ số còn lại cũng tốt theo. Có thể một ngày có nhiều chuyến hàng nhưng có những 
chuyến hàng chuyển nhanh, có chuyến hàng chuyển chậm, IOPS cao nhưng latency trung bình cũng lại cao. Có thể một ngày có 
ít chuyến hàng nhưng mỗi chuyến lại chở full tải thì throughput lại cao dù IOPS thấp vì Throughput = IOPS * IO Average 
size (IO average size cao thì throughput cao). Có thể latency trung bình thấp nhưng số hàng chuyển cũng không vì thế mà 
cao được do ít đơn hàng (application ít request vào storage).


### IOPS.

- Là tốc độ đọc/ghi  ngẫu nhiên.

- Đây có thể nói là các thông số có ý nghĩa thực tế và chúng ta nên để ý. Nó được sử dụng như 1 công cụ benchmark để "tái tạo" 
các tình huống sử dụng thực tế của người dùng. Tốc độ này thường được viết tắt bằng thông số IOPS (ví dụ như bạn sẽ thấy 
trong phần thông số kĩ thuật SSD có ghi 90.000 IOPS). Chúng ta đều biết quá trình sử dụng máy tính, việc phải đọc các tập 
tin có dung lượng nhỏ như các tập tin cache của trình duyệt, cookies, page file, lưu game, tài liệu...diễn ra thường xuyên. 
Các thông số IOPS lớn hơn đồng nghĩa với việc tốc độ đọc các file nhỏ cao hơn. Chúng ta cũng có thể quy đổi thông số IOPS ra 
chuẩn MB/giây theo công thức sau để dễ hình dung hơn: 

    ```sh
    IOPS x 4 / 1024 = tốc độ MB/giây
    ```

- Một số công thức khác :

    ```sh
    Tổng IOPS = IOPS per Disk * Số ổ cứng
    OPS thực = (Tổng IOPS * Write%)/(Raid Penalty) + (Tổng IOPS * Read %)
    Số ổ cứng = ((Read IOPS) + (Write IOPS*Raid Penalty))/ IOPS per Disk
    ```

### Latency.

- Latency là khái niệm về tốc độ xử lý 1 request I/O của hệ thống. Khái niệm này rất quan trọng bởi vì 1 hệ thống lưu trữ 
mặc dù chỉ có capacity 1000 IOPS với thời gian trung bình xử lý latency 10ms, vẫn có thể tốt hơn 1 hệ thống với 5000 IOPS 
nhưng latency là 50ms. Đặc biệt đối với các ứng dụng “nhạy cảm” với latency, chẳng hạn như dịch vụ Database.

## IOPS vs Latency : Yếu tố nào quyết định hiệu năng hệ thống Storage?

- Để so sánh được hiệu quả hệ thống storage, các yếu tố về môi trường platform và ứng dụng cần phải giống nhau – điều này rất khó, vì hệ thống của doanh nghiệp cần phải chạy multi-workload. Trong một vài trường hợp, việc xử lý/transfer 1 lượng lớn data (high throughput) thì được xem là tốt, nhưng khi cần xử lý số lượng lớn các I/O nhỏ thật nhanh (cần IOPS), thì chưa chắc và ngược lại. Lúc này kích cỡ I/O, độ dài của hàng đợi (queu depth) và mức độ xử lý song song… đều có ảnh hưởng đến hiệu năng.

- IOPS – Có lẽ hệ thống sử dụng các ổ cứng HDD hay SSD hiện nay thì đã quá cao rồi, khi đứng riêng lẻ 1 mình, con số này trở nên vô ích. Và vô hình chung nó trở thành 1 thuật ngữ để các nhà sản xuất marketing cho thiết bị của mình, các doanh nghiệp không nên vin vào đó làm thước đo quyết định hiệu năng hệ thống Storage.

- Thay vì đặt câu hỏi: “hệ thống với bao nhiêu IOPS là được?” ta nên hỏi rằng: “Thời gian xử lý ứng dụng là bao nhiêu?” Latency nên được xem là thông số hữu ích nhất, vì nó tác động trực tiếp lên hiệu năng của hệ thống, là yếu tố chính nên dựa vào tính toán ra IOPS và throughput. Nghĩa là việc giảm thiểu latency sẽ giúp cải thiện chung hiệu năng của cả hệ thống

## 4. RAM.

### 4.1. Đẩy lưu lượng RAM lên cao sử dụng stress. 

CHúng ta dùng công cụ tress để đẩy lượng RAM lên cao tùy vào mục đích trong một thời gian ngắn.

- Đầu tiên kiểm tra xem lượng RAM hiện tại đang sử dụng trên máy dùng câu lệnh top :

![ram1](/docs/prepare/images/ram1.png)

- Sau đó dùng stress để đẩy RAM lên cao  :

    ```sh
    [root@localhost ~]# stress -m 1 --vm-bytes 800M -t 10s
    stress: info: [2364] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
    stress: info: [2364] successful run completed in 10s
    ```

- Theo dõi RAM thay đổi qua lênh top chúng ta thấy được RAM đã được đẩy lên trong 1 thời gian ngắn,  việc này giúp chúng ta có 
thể test các cảnh báo .

![ram2](/docs/prepare/images/ram2.png)

### Phân tích qua lệnh free -m.

Trên host sử dụng lệnh `free -m` chúng ta thu được kết quả như sau :

    ```sh
    [root@localhost ~]# free -m
                total        used        free      shared  buff/cache   available
    Mem:            976          73         834           1          68         786
    Swap:          2047          84        1963
    ```

- total  : là tổng lượng ram của máy.
- used : là số ram đã được sử dụng.
- free : là lượng ram còn lại chưa trừ số ram dùng để cache/buffer.
- buffer/cache : là lượng ram dùng để buffer/cache.
- available : lượng ram sẵn sàng đc sử dụng.

# Tham Khảo.

- https://github.com/nguyenminh12051997/meditech-thuctap/blob/master/MinhNV/Nagios/docs/l%C3%BD%20thuy%E1%BA%BFt/Ki%E1%BB%83m%20tra%20th%C3%B4ng%20s%E1%BB%91/stress-ng.md

- https://github.com/ducnc/iperf

- https://www.tecmint.com/linux-cpu-load-stress-test-with-stress-ng-tool/

- https://iperf.fr/iperf-doc.php

- https://github.com/hocchudong/command-linux/blob/master/command-dd.md#user-content-1-m%E1%BB%9F-%C4%91%E1%BA%A7u-v%C3%A0-khuy%E1%BA%BFn-ngh%E1%BB%8B

- http://tjeuba0.blogspot.com/2017/03/determining-linux-io-utilization.html

- https://www.cyberciti.biz/tips/linux-disk-performance-monitoring-howto.html

- https://www.viettelidc.com.vn/tim-hieu-ve-cac-thong-so-iops-latency-va-throughput-phan-2.html

- http://genk.vn/do-choi-so/tim-hieu-kien-thuc-can-ban-ve-ssd-phan-1-2012111208133883.chn