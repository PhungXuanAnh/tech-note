# Tìm hiểu và sử dụng crontab cho hệ thống tự đông back up cấu hình nagios.


## 1. Cron tab (cron table) là gì?

-  Cron là một kỹ thuật cho phép thực hiện các tác vụ một cách tự động theo định kỳ, ở chế độ nền của hệ thống hay còn gọi là daemon .Contab là một file chưa đựn thời khóa biểu (schedule) của các entries được chạy . Nó thường được dùng để nén định kỳ các file ghi nhật ký, đồng bộ hóa hay backup dữ liệu. 


## 2. Một số commands đơn giản với cron.

```sh
crontab -l
```

Câu lệnh trên giúp chúng ta có thể list ra đợc những user crontable.

```sh
crontab -e
```

Tạo mới một cron table

```sh
crontab -r
```

Xóa bỏ một cron table và tất cả các công việc đã được lập lịch.

## 3. Cấu trúc của crontab.

Một crontab file có 5 trường xác định thời gian, cuối cùng là lệnh sẽ được chạy định kỳ, cấu trúc như sau:
*     *     *     *     *     command to be executed
-     -     -     -     -
|     |     |     |     |
|     |     |     |     +—– day of week (0 – 6) (Sunday=0)
|     |     |     +——- month (1 – 12)
|     |     +——— day of month (1 – 31)
|     +———– hour (0 – 23)
+————- min (0 – 59)
Nếu một cột được gán ký tự *, nó có nghĩa là tác vụ sau đó sẽ được chạy ở mọi giá trị cho cột đó.

## 4. Cài đặt Crontab.

- Cài đặt cơ bản bằng yum :

```sh
yum install crontabs.noarch -y
```

hoặc 

```sh
yum install vixie-cron -y
```

Khởi động crontab :

```sh
systemctl start crond
```

Kiểm tra xem crontab đã khởi động hay chưa :

```sh
systemctl status crond
```

Kết quả :

```sh
[root@nagios-core ~]# systemctl status crond
● crond.service - Command Scheduler
   Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2017-10-04 02:48:00 EDT; 1h 58min ago
 Main PID: 733 (crond)
   CGroup: /system.slice/crond.service
           └─733 /usr/sbin/crond -n

Oct 04 02:48:00 nagios-core systemd[1]: Started Command Scheduler.
Oct 04 02:48:00 nagios-core systemd[1]: Starting Command Scheduler...
Oct 04 02:48:00 nagios-core crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 33% if used.)
Oct 04 02:48:02 nagios-core crond[733]: (CRON) INFO (running with inotify support)
[root@nagios-core ~]#

```

## 5. Một số ví dụ đơn giản.

- Giả sử mình có một file scripts  là `test-crontab.sh` và muốn chạy nó bắt đầu vào lúc 4h44 sáng ngày 4/10 và tất cả các ngày trong tuần. Ta sẽ cấu hình file crontab như sau :

Mở file cấu hình crontab :

```sh
vi /etc/crontab
```

Thêm dòng sau vào cuối file :

```sh
44 4 4 10 * /root/test-crontab.sh
```

## 6. Áp  dụng crontab để lên lịch backup tự động cho nagios.


# Tham Khảo.

- http://forum.gocit.vn/threads/s-dung-crontab-tren-linux.166/