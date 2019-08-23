# Đẩy dữ liệu từ Nagios sang MySQL.

- Đối với Nagios thông thường các metric sẽ được lưu dưới file `status.dat` nằm tại đường dẫn `/usr/local/nagios/var/status.dat`. Do do đó chúng ta cần đẩy dữ liệu từ file này ra output khác để phụ vụ cho việc làm báo cáo hoặc vẽ biểu đồ. 

- Sau đây mình sẽ hướng dẫn cách đẩy dữ liệu từ file `status.dat` ra MySQL sử dụng ndoutils thực hiện trên CentOS 7.

##  Bước 1 : Cài đặt MariaDB :

```sh
yum install -y mariadb mariadb-server mariadb-devel
```

Khởi động MariaDB :

```sh
systemctl start mariadb.service
```

Kiểm tra xem service đã chạy hay chưa :

```sh
ps ax | grep mysql | grep -v grep
```

Cấu hình tự khởi động cùng hệ thống :

```sh
systemctl enable mariadb.service
```

Cấu hình mật  khẩu cho MariaDB :

```sh
/usr/bin/mysqladmin -u root password 'mypassword'

# Với mypassword là mật khẩu mà chúng ta đặt, thông số tùy chọn.
```

Đăng nhập vào DB với tài khoản `root` và mật khẩu vừa mới được tạo :

```sh
mysql -u root -p'mypassword'
```

## Bước 2 : Tạo mới cơ sở dữ liệu .

Thực hiện các dòng lệnh sau :

- Tạo một cơ sở dữ liệu mới với tên là `nagios` :

    ```sh
    CREATE DATABASE nagios DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
    ```

- Tạo một user `ndoutils` :

    ```sh
    CREATE USER 'ndoutils'@'localhost' IDENTIFIED BY 'ndoutils_password';
    ```

- Phân quyền cho user vừa tạo :

    ```sh
    GRANT USAGE ON *.* TO 'ndoutils'@'localhost' IDENTIFIED BY 'ndoutils_password' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

    GRANT ALL PRIVILEGES ON nagios.* TO 'ndoutils'@'localhost' WITH GRANT OPTION
    ```

- Kiểm tra xem cơ sở dữ liệu đã được tạo ra thành công hay chưa :

    ```sh
    echo 'show databases;' | mysql -u ndoutils -p'ndoutils_password' -h localhost
    ```

## Bước 3 :  Kernel setting.

Ndoutils sử dụng kernel message queue để chuyển dữ liệu từ Nagios đến ndoutils . Do đó chúng ta cần thiết lập lại các thông số cài đặt trong kernel :

Thực hiện các commands sau :

```sh
sed -i '/msgmnb/d' /etc/sysctl.conf
sed -i '/msgmax/d' /etc/sysctl.conf
sed -i '/shmmax/d' /etc/sysctl.conf
sed -i '/shmall/d' /etc/sysctl.conf
printf "\n\nkernel.msgmnb = 131072000\n" >> /etc/sysctl.conf
printf "kernel.msgmax = 131072000\n" >> /etc/sysctl.conf
printf "kernel.shmmax = 4294967295\n" >> /etc/sysctl.conf
printf "kernel.shmall = 268435456\n" >> /etc/sysctl.conf
sysctl -e -p /etc/sysctl.conf
```

## Bước 4 : Cài đặt Ndoutils.

Dowload Ndoutils :

```sh
cd /tmp
wget -O ndoutils.tar.gz https://github.com/NagiosEnterprises/ndoutils/releases/download/ndoutils-2.1.3/ndoutils-2.1.3.tar.gz
tar xzf ndoutils.tar.gz
```

Complile Ndoutils :

```sh
cd /tmp/ndoutils-2.1.3/
./configure
make all
```

Install binary files :

```sh
make install
```

Initialize Database :

```sh
cd /tmp/ndoutils-2.1.3/db
./installdb -u 'ndoutils' -p 'ndoutils_password' -h 'localhost' -d nagios
cd ..
```

Coppy 2 file `ndo2db` và `ndomod.cfg`

```sh
cp /tmp/ndoutils-2.1.3/config/ndo2db.cfg-sample /usr/local/nagios/etc/ndo2db.cfg
cp /tmp/ndoutils-2.1.3/config/ndomod.cfg-sample /usr/local/nagios/etc/ndomod.cfg
```

Sửa lại file cấu hình :

```
vi /usr/local/nagios/etc/ndo2db.cfg
```

Tìm và sửa lại thông số 2 dòng sau phù hợp với các thông số đã tạo từ bước tạo db :

```sh
db_user=ndoutils
db_pass=ndoutils_password
```

Install Service / Daemon

```sh
sudo make install-config
make install-init
systemctl enable ndo2db.service
```

Start Service / Daemon :

```sh
systemctl start ndo2db.service
```

Update Nagios To Use NDO Broker Module :

```sh
printf "\n\n# NDOUtils Broker Module\n" >> /usr/local/nagios/etc/nagios.cfg
printf "broker_module=/usr/local/nagios/bin/ndomod.o config_file=/usr/local/nagios/etc/ndomod.cfg\n" >> /usr/local/nagios/etc/nagios.cfg
```

Restart Nagios

```sh
systemctl restart nagios.service
systemctl status nagios.service
```

Check NDOUtils Is Working

```sh
grep ndo /usr/local/nagios/var/nagios.log
```

Kiểm tra xem data được pull như thế nào :

```sh
echo 'select * from nagios.nagios_logentries;' | mysql -u ndoutils -p'ndoutils_password'
```

# Nguồn :

- https://support.nagios.com/kb/article.php?id=406#CentOS