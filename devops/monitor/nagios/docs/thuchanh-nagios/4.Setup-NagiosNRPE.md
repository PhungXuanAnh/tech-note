# Hướng dẫn cài đặt giám sát Nagios với NRPE

# Mục lục
- [1. Tổng quan về cơ chế NRPE](#1)
- [2. Mô hình triển khai](#2)
- [3. Cài đặt trên client](#3)
- [4. Cài đặt trên Nagios server](#4)
- [5. Cấu hình giám sát các thông số host](#5)
- [6. Tài liệu tham khảo](#6)

---------------------------------------

<a name="1"></a>
## 1. Tổng quan về cơ chế NRPE
- NRPE (Nagios Remote Plugin Executor) là một add-on đi kèm với Nagios, được cài trên các host giám sát
- Nó trợ giúp việc thực thi các plugin được cài đặt trên máy/thiết bị được giám sát
- Khi nhận được truy vấn từ Nagios server thì nó gọi các plugin cục bộ phù hợp trên host này, thực hiện kiểm tra và trả về kết quả cho Nagios server
- Nagios có thể điều khiển máy cài NRPE kiểm tra các thông số phần cứng, các tài nguyên, tình trạng hoạt động của máy đó hoặc sử dụng NRPE để thực thi các plugin 

<a name="2"></a>
## 2. Mô hình triển khai

- IP Planing:

|  | Server Nagios | Client |
|--|---------------|--------|
| OS | CentOS 7 | Ubuntu 14 |
| IP | 192.168.100.125 | 192.168.100.150 |

- Mô hình:

<img src="http://i.imgur.com/Y7I2fgz.png">

<a name="3"></a>
## 3. Cài đặt trên client

- Tải gói cài đặt

```sh
apt-get install nagios-nrpe-server nagios-plugins -y
```

- Trong file `/etc/nagios/nrpe.cfg` chỉnh sửa các thông tin như sau:

```sh
allowed_hosts=127.0.0.1,<Nagios_Server_IP>
```

- Khởi động lại dịch vụ NRPE

```sh
/etc/init.d/nagios-nrpe-server restart
```

<a name="4"></a>
## 4. Cài đặt trên Nagios server
- Tải các gói cài đặt
```sh
yum install httpd php php-cli gcc glibc glibc-common gd gd-devel net-snmp openssl-devel wget unzip -y
```

- Tạo user và phần quyền
```sh
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache
```

- Tải các gói cài đặt nagios
```sh
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
tar zxf nagios-4.1.1.tar.gz	
tar zxf nagios-plugins-2.1.1.tar.gz
cd nagios-4.1.1
```

- Cài đặt các gói Nagios core
```sh
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
```

- Tạo password cho Nagios admin
```sh
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```

- Cài đặt Nagios plugin
```sh
cd /tmp/nagios-plugins-2.1.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make all
make install
```

- Tải gói và cài đặt NRPE
```sh
cd /tmp
wget http://liquidtelecom.dl.sourceforge.net/project/nagios/nrpe-3.x/nrpe-3.0.tar.gz
tar xzf nrpe-3.0.tar.gz
cd nrpe-3.0
./configure
make all
make install-daemon
```

- Kiểm tra cài đặt 
```sh
cd /usr/local/nagios/libexec/
./check_nrpe -H <client_IP>
```

```
OUTPUT:
NRPE v3.0
```

#### Trong 1 vài trường hợp có output như trên, kiểm tra firewall của client, hoặc kiểm tra port 5666 của NRPE đã mở chưa
- Kiểm tra port trên client
```sh
netstat -at | grep nrpe
```
Nếu OUTPUT như sau
```sh
tcp        0      0 *:nrpe                  *:*                     LISTEN
```

Quay lại kiểm tra file cấu hình nrpe hoặc filewall, hoặc kiểm tra dịch vụ như sau:
```sh
root@ubuntu12:~# cat /etc/services | grep 5666
nrpe            5666/tcp                        # Nagios Remote Plugin Executor
```

Nếu OUTPUT không phải như trên cần khai báo dịch vụ 

<a name="5"></a>
## 5. Cấu hình giám sát các thông số host

- Để giám sát các thông số như RAM, Disk, CPU...sẽ sử dụng một số scripts theo link sau:
[https://github.com/trimq/meditech-ghichep-nagios/tree/master/docs/plugin-nagios]

- Tải các file scripts về
```sh
cd /usr/lib/nagios/plugin
wget https://github.com/trimq/meditech-ghichep-nagios/blob/master/docs/plugin-nagios/check_disk_space.sh
wget https://github.com/trimq/meditech-ghichep-nagios/blob/master/docs/plugin-nagios/check_mem.sh
wget https://github.com/trimq/meditech-ghichep-nagios/blob/master/docs/plugin-nagios/check_cpu.sh
```

- Phân quyền cho các file
```sh
chmod +x check_cpu.sh
chmod +x check_disk_space.sh
chmod +x check_mem.sh
```

- Kiểm tra các file scripts 
```sh
./check_cpu.sh
./check_disk_space.sh -w 70 -c 80 -p /
././check_mem.sh -w 70 -c 80
```

Trong các câu lệnh trên
<ul>
<li>-w: ngưỡng cảnh báo warning</li>
<li>-c: ngưỡng cảnh báo critical</li>
<li>-p: phân vùng được kiểm tra</li>
</ul>

- Khai báo trong file cấu hình `/etc/nagios/nrpe.cfg`. Thêm vào những dòng sau
```sh
# The following examples use hardcoded command arguments.
command[check_disk_space]=/usr/lib/nagios/plugins/check_disk_space.sh -w 70 -c 80 -p /
command[check_cpu]=/usr/lib/nagios/plugins/check_cpu.sh
command[check_uptime]=/usr/lib/nagios/plugins/check_uptime
command[check_mem]=/usr/lib/nagios/plugins/check_mem.sh -w 75 -c 85
command[check_ping]=/usr/lib/nagios/plugins/check_icmp
```

<img src="http://i.imgur.com/4tRzF3k.png">

<ul>
<li>1: command của các thông số check</li>
<li>2: các thông số trong dấu ngoặc sẽ được gán và các file plugin để khi đứng từ srv Nagios có thể gọi đến các plugin trên client</li>
<li>3: Các đường dẫn file plugin và các ngưỡng cảnh báo được đặt ra</li>
</ul>

- Khởi động lại nrpe
```sh
service nagios-nrpe-server restart
```

- Kiểm chứng trên server. Trên server Nagios kiểm chứng như sau
```sh
cd /usr/local/nagios/libexec/
./check_nrpe -H 192.168.100.150 -c check_uptime
```

- Khai báo trên file cấu hình của server Nagios
```sh
vi /usr/local/nagios/etc/object/command.cfg

define command{
command_name check_nrpe
command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
```

- Khai báo file cấu hình của host để giám sát
```sh
vi /usr/local/nagios/etc/servers/host1.cfg


define host {
use                             linux-server
host_name                       host-01
alias                           host-01
address                         192.168.100.150
max_check_attempts              5
check_period                    24x7
notification_interval           30
notification_period             24x7
}
define service {
    use                 generic-service
    host_name           host-01
    service_description Check HTTP service
    check_command       check_http
    normal_check_interval           5
    retry_check_interval            2
}
define service {
    use                 generic-service     ; Inherit default values from a template
    host_name           host-01
    service_description Check SSH service
    check_command       check_ssh
}
define service {
    use                 generic-service     ; Inherit default values from a template
    host_name           host-01
    service_description check memory
    check_command       check_nrpe!check_mem
}
define service {
    use                 generic-service     ; Inherit default values from a template
    host_name           host-01
    service_description check uptime
    check_command       check_nrpe!check_uptime
}
define service {
    use                 generic-service     ; Inherit default values from a template
    host_name           host-01
    service_description check cpu
    check_command       check_nrpe!check_cpu
}
define service {
    use                 generic-service     ; Inherit default values from a template
    host_name           host-01
    service_description check disk
    check_command       check_nrpe!check_disk_space
}
```

- Khởi động lại nrpe trên server
```sh
systemctl restart nagios
```

- Kiểm tra trên dashboard:

<img src="http://i.imgur.com/Hv43Nc7.png">


<a name="6"></a>
## 6. Tài liệu tham khảo

- (1):http://www.tecmint.com/how-to-add-linux-host-to-nagios-monitoring-server/
- (2):https://assets.nagios.com/downloads/nagioscore/docs/nrpe/NRPE.pdf







