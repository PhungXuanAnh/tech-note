# Cài đặt nagios trên CentOS 7, với bản nagios core 4.3.3.

## 1. Cài đặt các gói chuẩn bị.

Đối với nagios core để có thể sử dụng chúng ta phải cài đặt thêm các gói dịch vụ đi kèm :

Bước 1 : cài đặt các gói dịch vụ đi kèm

```sh
yum install gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip httpd php php-fpm curl wget -y
```

Bước 2 : Mở port 80 cho HTTPD trên firewall :

```sh
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
```

Bước 3 : Tắt SElinux.

- Mở file cấu hình SElinux :

```sh
vi /etc/sysconfig/selinux
```

- Tìm thông số `SELINUX=enforcing` và đổi thành `SELINUX=disable`.

## 2. Tạo user cho nagios.

Tạo user `nagios` trên nagios server :

```sh
useradd -m -s /bin/bash nagios
```

Tạo group `nagcmd` cho phép sử dụng thư mục Web UI, thêm nagios và apache:

```sh
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache

```

## 3. Cài đặt Nagios core 4.3.3 và plugin.

Tải bản nagios core mới nhất 4.3.3 về server :

```sh
 cd /opt
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.3.3.tar.gz
```

Giải nén file cài đặt :

```sh
tar xf nagios-4.3.3.tar.gz
```

Biên dịch Nagios :

```sh
cd nagios-4.3.3

./configure --with-command-group=nagcmd 
make all
make install
make install-commandmode
make install-init
make install-config
make install-webconf
```

Cho phép nagios khởi động cùng hệ thống :

```sh
chkconfig nagios on
```

Cài đặt password cho `nagiosadmin` , khi đăng nhập web :

```sh
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```

Tải gói plugin và  giải nén :

```sh
cd /opt
wget https://nagios-plugins.org/download/nagios-plugins-2.2.0.tar.gz
tar xzf nagios-plugins-2.2.0.tar.gz
```

Biên dịch các Plugin từ source code :

```sh
cd nagios-plugins-2.2.0
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
make install
```

Khởi động lại Apache và chạy nagios, cho phép khởi động cùng hệ thống:

```sh
systemctl enable httpd
systemctl restart httpd
service nagios restart
```

Truy cập vào WEB đăng nhập bằng tài khoản `nagiosadmin` và mật khẩu vừa tạo .

```sh
http://<IP nagios server>/nagios
```

Hình ảnh đầu tiên với Nagios core 4.3.3 :

![nagioscore](/docs/prepare/images/nagioscore.png)

# Tham Khảo

- https://github.com/meditechopen/meditech-ghichep-nagios/blob/master/docs/thuchanh-nagios/1.Setup-CentOS-7.md