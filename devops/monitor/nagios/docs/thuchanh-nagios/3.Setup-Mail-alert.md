# Cấu hình cảnh báo Nagios qua Gmail

# Mục lục:
- [1. Tính năng gửi cảnh báo qua email](#1)
- [2. Topology lab & IP Planning](#2)
	- [2.1. Topology lab](#21)
	- [2.2. IP Planning](#22)
- [3. Các bước cấu hình để chuẩn bị gửi cảnh báo qua email](#3)
	- [3.1. Cấu hình gửi cảnh báo qua gmail](#31)
	- [3.2. Kiểm tra gửi email thử](#32)
- [4. Gửi cảnh báo khi có sự cố](#4)
	- [4.1. Gửi cảnh báo khi dịch vụ ssh down](#41)
	- [4.2. Gửi cảnh báo khi dịch vụ http down](#42)
	- [4.3. Gửi cảnh báo khi máy chủ off hoặc restart](#43)
- [5. Khác](#5)
	- [5.1. Gửi mail cảnh báo qua mail domain](#51)
	- [5.2. Gửi mail cảnh báo cho nhiều người dùng](#52)
	- [5.3. Gửi mail cảnh báo theo từng nhóm người dùng](#53)
		- [5.3.1. Gửi mail cảnh báo về dịch vụ cho nhóm người dùng](#531)
		- [5.3.2. Gửi mail cảnh báo về host cho nhóm người dùng](#532)
- [6. Tài liệu tham khảo](#6)
	

----------------------------------------------


<a name="1"></a>
## 1. Tính năng gửi cảnh báo qua email
Trong thực tế, người quản trị viên không phải lúc nào cũng có thể ngồi theo dõi và nắm bắt các hoạt động của hệ thống qua giao diện giám sát. Bởi vậy bất cứ hệ thống giám sát nào cũng cần cung cấp các chức năng thông báo về tình trạng của hệ thống qua các phương tiện truyền thông. Nagios cũng cấp tính năng thông báo các sự kiện xảy ra qua phương tiện truyền thông là email. Bài viết này sẽ cung cấp cách gửi mail cảnh báo qua Gmail


<a name="2"></a>
## 2. Topology lab & IP Planning

<b>Lưu ý:</b> Để thực hành bài lab gửi email cảnh báo này, bạn bắt buộc phải thực hiện xong cài đặt Nagios Core trên Nagios Server và các dịch vụ ssh, http trên Client theo mô hình ở bài lab này trên CentOS7 tại [đây](https://github.com/meditechopen/meditech-ghichep-nagios/blob/master/docs/thuchanh-nagios/1.Setup-CentOS-7.md)

Đối với bài lab này cần ít nhất là 02 máy chủ: Nagios Server và Web

<a name="21"></a>
### 2.1. Topology lab

<img src="http://i.imgur.com/gl7j9lP.png">

<a name="22"></a>
### 2.2. IP Planning

| Hostname | OS | IP | Dịch vụ |
|----------|----|----|---------|
| Nagios Server | Centos 7 | 192.168.100.125 | Nagios Core |
| Web (client) | Ubuntu 14 | 192.168.100.150 | HTTP, SSH |


<a name="3"></a>
## 3. Các bước cấu hình để chuẩn bị gửi cảnh báo qua email

Trong bài viết này tôi sẽ hướng dẫn cấu hình gửi cảnh báo qua Gmail

<a name="31"></a>
### 3.1. Cấu hình gửi cảnh báo qua Gmail:

#### Các bước sau đây được thực hiện trên Nagios Server

- Bước 1: Cài đặt gói mail postfix

```sh
yum -y install postfix cyrus-sasl-plain mailx
```

- Bước 2: Cấu hình dịch vụ mail postfix

```sh
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
```

- Bước 3: Khởi động lại dich vụ

```sh
systemctl restart postfix
systemctl enable postfix
```

- Bước 4: Tạo 1 file để khai báo các thông số tài khoản mail xác thực

```sh
vi /etc/postfix/sasl_passwd

[smtp.gmail.com]:587 username:password
```

- Bước 5: Thiết lập chế độ less secure của Gmail

Trong 1 số trường hợp cần phải tắt chế độ hạn chế truy cập từ các ứng dụng không an toàn cho tài khoản gmail của bạn. Tham khảo link sau:

https://myaccount.google.com/lesssecureapps


<a name="32"></a>
### 3.2. Kiểm tra gửi email thử

- Bước 1: Thực hiện câu lệnh sau trên Nagios Server

```sh
echo "This is a test." | mail -s "test message" maiquoctri2102@gmail.com
```

- Bước 2: Kiểm tra trên hòm thư của Gmail
Nếu nhận được email như sau thì các bước cấu hình dịch vụ mail đã thành công

<img src="http://i.imgur.com/MoqAlng.png">

<a name="4"></a>
## 4. Gửi cảnh báo khi có sự cố
Đầu tiên phải thực hiện tạo thông tin liên lạc để Nagios biết được là phải gửi cảnh báo tới đâu khi hệ thống gặp vấn đề

#### Thực hiện các bước sau trên Nagios Server

- Bước 1: Thêm các thông tin liên lạc của Nagios
Ta sẽ tạo các thông tin liên lạc trong file `/usr/local/nagios/etc/objects/contacts.cfg`

```sh
vi /usr/local/nagios/etc/objects/contacts.cfg


define contact{
        contact_name                    nagiosadmin             ; Short name of user
        use                             generic-contact         ; Inherit default values from generic-contact template (defined above)
        alias                           Nagios Admin            ; Full name of user

        email                           trimq212@gmail.com        ; <<***** CHANGE THIS TO YOUR EMAIL ADDRESS ******

        service_notification_period             24x7
        service_notification_options            w,u,c,r,f,s
        service_notification_commands           notify-service-by-email
        host_notification_period                24x7
        host_notification_options               d,u,r,f,s
        host_notification_commands              notify-host-by-email
        }
```

#### Ý nghĩa của các tham số khai báo trên

<ul>
<li>service_notification_options: trạng thái sẽ gửi cảnh báo của service</li>
<li>w: warning</li>
<li>u: unknown service</li>
<li>c: critical</li>
<li>r: recovery service (trạng thái OK)</li>
<li>f: cảnh báo khi service khởi động và tắt FLAPPING</li>
<li>s: gửi cảnh báo khi dịch vụ downtime trong lịch trình</li>
<li>host_notification_options: trạng thái sẽ gửi cảnh báo của host</li>
<li>d: DOWN, cảnh báo khi host rơi vào trạng thái down</li>
</ul>

- Bước 2: Khởi động lại dịch vụ

```sh
/etc/init.d/nagios restart
```

Những bước cấu hình ở trên là để Nagios có thể tự động gửi mail khi hệ thống gặp sự cố. Trong trường hợp dịch vụ hoặc host được giám sát của tôi bị down thì Nagios phải gửi được email cho tôi để khắc phục sự cố.

Để kiểm chứng cho việc này, tôi sẽ thử kiểm tra bằng cách ngắt dịch vụ (ssh, http) và shutdown host đang giám sát. Lưu ý là trên client tôi đã giám sát được dịch vụ ssh và http như đã nói ở đầu bài viết

<a name="41"></a>
### 4.1. Gửi cảnh báo khi dịch vụ ssh down
Như đã nói ở trên, sau đây tôi sẽ thử lab email cảnh báo với dịch vụ ssh.

- Bước 1: Trên máy Client, thực hiện dừng dịch vụ ssh trên Client

```sh
service ssh stop
```

- Bước 2: Kiểm tra dịch vụ trên dashboard Nagios
Sau khi thực hiện ngừng dịch vụ ssh trên máy client, quay lại dashboard của Nagios để kiểm tra nếu trên dashboard thông báo như sau nghĩa là dịch vụ đã bị dừng

<img src="http://i.imgur.com/PiZI9vC.png">

- Bước 3: Kiểm tra hòm thư Gmail 
Kiểm tra hòm thư Gmail để xem Nagios có tự động gửi mail cảnh báo đến không. Ở đây tôi đã nhận được mail cảnh báo đến

<img src="http://i.imgur.com/lnsAPcK.png">

- Bước 4: Khởi động lại dịch vụ trên Client
Sau khi nhận được email cảnh báo, tôi sẽ khởi động lại dịch vụ để thử xem Nagios có gửi email bản tin Recovery

```sh
service ssh start
```

-Bước 5: Kiểm tra hoạt động của dịch vụ trên dashboard

Sau khi thực hiện khởi động dịch vụ, kiểm tra trên dashboard

<img src="http://i.imgur.com/J49YOOH.png">

- Bước 6: Kiểm tra email Recovey

Sau khi dịch vụ đã hoạt động trở lại, Nagios sẽ thông báo 1 bản tin cho người quản trị trạng thái của dịch vụ đó. Kiểm tra hòm thư để xác nhận

<img src="http://i.imgur.com/lulFsEU.png">

Như vậy là Nagios đã có thể gửi email cảnh báo khi dịch vụ bị down. Để kiểm chứng thêm tôi sẽ lab với dịch vụ khác là web

<a name="42"></a>
### 4.2. Gửi cảnh báo khi dịch vụ http down

Tương tự như dịch vụ ssh, tôi sẽ ngắt hoạt động của dịch vụ sau đó các bước làm sẽ giống như dịch vụ ssh

- Bước 1: Tương tự ssh, trên client tôi sẽ ngắt hoạt động dịch vụ web

```sh
service apache2 stop
```

- Bước 2: Kiểm tra trên dashboard của Nagios

<img src="http://i.imgur.com/OuaOAcM.png">

- Bước 3: Kiểm tra hòm thư Gmail

<img src="http://i.imgur.com/Yz88LeW.png">

- Bước 4: Khởi động lại dịch vụ

```sh
service apache2 start
```

- Bước 5: Kiểm tra trên dashboard 

<img src="http://i.imgur.com/G3aYXWJ.png">

- Bước 6: Kiểm tra hòm thư Gmail

<img src="http://i.imgur.com/1LQJtgD.png">


<a name="43"></a>
### 4.3. Gửi cảnh báo khi máy chủ off hoặc restart

Như 2 bài lab ở trên, tôi đã thử nghiệm khi các dịch vụ bị down Nagios sẽ gửi email cảnh báo tới người quản trị. Bây giờ tôi sẽ thực hiện lab tính năng gửi cảnh báo khi máy chủ bị down

- Bước 1: Tắt máy chủ chủ đi

```sh
init 0
```

- Bước 2: Kiểm tra trên dashboard

<img src="http://i.imgur.com/iFFQG94.png">

- Bước 3: Kiểm tra hòm thư Gmail

<img src="http://i.imgur.com/DVGNQbU.png">

- Bước 4: Khởi động lại máy


- Bước 5: Kiểm tra trên dashboard

<img src="http://i.imgur.com/YPEyN4i.png">

- Bước 6: Kiểm tra hòm thư email Recovery

<img src="http://i.imgur.com/G3aEZdA.png">


<a name="5"></a>
## 5. Khác

<a name="51"></a>
### 5.1. Gửi mail cảnh báo qua mail domain:
Với bài hướng dẫn ở trên, tôi đã hướng dẫn setup email cảnh báo gửi qua Gmail. Tuy nhiên Nagios còn có thể hỗ trợ gửi mail thông qua email domain, sau đây tôi sẽ hướng dẫn cấu hình gửi cảnh báo qua email domain

Điều kiện để cấu hình email domain cũng tương tự Gmail, ta phải cài đặt thành công Nagios Core trên CentOS7

Tham khảo cài đặt tại [đây](https://github.com/meditechopen/meditech-ghichep-nagios/blob/master/docs/thuchanh-nagios/1.Setup-CentOS-7.md)

<b>Lưu ý</b>: Ở đây tôi sẽ sử dụng mô hình lab tương tự như với Gmail. Chỉ được chọn 1 trong 2 cách để gửi mail (hoặc là qua Gmail, hoặc là qua Mail domain) 

### Với những bước cài đặt sau, thực hiện trên Nagios Server

- Bước 1: Cài đặt gói mail postfix

```sh
yum -y install postfix cyrus-sasl-plain mailx
```

- Bước 2: Chỉnh sửa file cấu hình `/etc/postfix/main.cf`

```sh
relayhost =
sender_dependent_relayhost_maps = hash:/etc/postfix/relayhost_maps
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sender_dependent_authentication = yes
smtp_sasl_security_options = noanonymous
#smtp_sasl_mechanism_filter = AUTH LOGIN
sender_canonical_maps = hash:/etc/postfix/sender_canonical
smtp_sasl_tls_security_options =
```

- Bước 3: Khai báo thông tin domain trong file `/etc/postfix/relayhost_maps`

```sh
email  [domain]
```

Thay email domain bằng địa chỉ email và tên domain của bạn

- Bước 4: Tạo file `/etc/postfix/sasl_passwd` và khai báo thông tin email xác thực

```sh
vi /etc/postfix/sasl_passwd


domain  username:password
```
Khai báo thông tin username và password

- Bước 5: Cấu hình, phân quyền và khởi động lại dịch vụ

```sh
postmap /etc/postfix/sasl_passwd
chown root:postfix /etc/postfix/sasl_passwd*
chmod 640 /etc/postfix/sasl_passwd*
systemctl reload postfix
```

Bước 6: Gửi mail test thử với email domain

```sh
echo "This is a test." | mail -s "test message" tri.maiquoc@meditech.vn
```

- Bước 7: Kiểm tra thư

<img src="http://i.imgur.com/T9QAh3B.png">

Với các bước thực hiện cảnh báo, làm tương tự như với Gmail

<a name="52"></a>
### 5.2. Gửi mail cảnh báo cho nhiều người dùng

Trong mục này tôi sẽ hướng dẫn gửi email cảnh báo theo nhóm người dùng. Mô hình lab vẫn như trên

### Thực hiện những bước sau trên Nagios Server

- Bước 1: Add thêm user vào Nagios và đặt mật khẩu cho user vừa add

```sh
htpasswd -D /usr/local/nagios/etc/htpasswd.users trimq
```

- Bước 2: Khai báo thông tin về user trong file `contacts.cfg`

```sh
vi /usr/local/nagios/etc/objects/contacts.cfg


define contact{
        contact_name                    trimq             ; Short name of user
        use                             generic-contact         ; Inherit default values from generic-contact template (defined above)
        alias                           Quoc Tri            ; Full name of user

        email                           trimq212@gmail.com        ; <<***** CHANGE THIS TO YOUR EMAIL ADDRESS ******
        service_notification_period             24x7
        service_notification_options            w,u,c,r,f,s
        service_notification_commands           notify-service-by-email
        host_notification_period                24x7
        host_notification_options               d,u,r,f,s
        host_notification_commands              notify-host-by-email
        }
```

#### Ý nghĩa các tham số khai báo

<ul>
<li>contact_name: tên của user gửi mail đến</li>
<li>use: loại user là generic</li>
<li>alias: tên này được gán cho user</li>
<li>email: địa chỉ email Nagios sẽ gửi cảnh báo đến</li>
</ul>


- Bước 3: Thêm thông số vào CONTACT GROUP trong file `/usr/local/nagios/etc/objects/contacts.cfg`

```sh
define contactgroup{
        contactgroup_name       admins
        alias                   Nagios Administrators
        members                 nagiosadmin,trimq
        }
```

- Bước 4: Khởi động lại Nagios

```sh
/etc/init.d/nagios restart
```

- Bước 5: Gửi mail cảnh báo thử

Trên Web Interface tôi sẽ sử dụng command để gửi nhanh 1 thông báo

<img src="http://i.imgur.com/81Gvs3D.png">

- Bước 6: Trên hòm thử Gmail tôi kiểm tra 2 hòm thư của tôi là `maiquoctri2102@gmail` và `trimq212@gmail`

Hòm thư thứ nhất

<img src="http://i.imgur.com/MfET12a.png">

Hòm thư thứ 2

<img src="http://i.imgur.com/xNe4tDP.png">


Như vậy là tôi đã có thể gửi email cảnh báo theo nhóm người dùng trong Nagios


<a name="53"></a>
### 5.3. Gửi mail cảnh báo theo từng nhóm người dùng

Trong thực tế 1 hệ thống Data center gồm nhiều máy chủ và nhiều dịch vụ chạy trên các máy chủ đó. Sẽ có nhiều nhóm quản trị viên phụ trách các nhóm máy chủ hoặc dịch vụ. Ví dụ nhóm system admin sẽ phụ trách hệ thống server, nhóm network sẽ phụ trách các dịch vụ liên quan về mạng... Do vậy khi có sự cố xảy ra trên hệ thống, dịch vụ giám sát cần gửi mail đến đúng nhóm quản trị để xử lý.

Sau đây tôi sẽ hướng dẫn cách để gửi mail theo nhóm. Mô hình lab vẫn giữ nguyên như trên


<a name="531"></a>
#### 5.3.1. Gửi mail cảnh báo về dịch vụ cho nhóm người dùng

Gửi mail cảnh báo về dịch vụ tới nhóm quản trị

#### Thực hiện các bước sau trên Nagios server


- Bước 1: Thêm contact trong file `/usr/local/nagios/etc/objects/contacts.cfg`. Ở đây tôi thêm các địa chỉ email và tên người dùng để liên lạc

```sh
# CONTACTS


define contact{
        contact_name                    trimq             ; Short name of user
        use                             generic-contact         ; Inherit default values from generic-contact template (defined above)
        alias                           Quoc Tri            ; Full name of user

        email                           trimq212@gmail.com        ; <<***** CHANGE THIS TO YOUR EMAIL ADDRESS ******
        service_notification_period             24x7
        service_notification_options            w,u,c,r,f,s
        service_notification_commands           notify-service-by-email
        host_notification_period                24x7
        host_notification_options               d,u,r,f,s
        host_notification_commands              notify-host-by-email
        }


define contact{
        contact_name                    quoctri             ; Short name of user
        use                             generic-contact         ; Inherit default values from generic-contact template (defined above)
        alias                           Tri Mai            ; Full name of user

        email                           fsddfas123max@gmail.com        ; <<***** CHANGE THIS TO YOUR EMAIL ADDRESS ******
        service_notification_period             24x7
        service_notification_options            w,u,c,r,f,s
        service_notification_commands           notify-service-by-email
        host_notification_period                24x7
        host_notification_options               d,u,r,f,s
        host_notification_commands              notify-host-by-email
        }
```

- Bước 2: Thêm các contact group trong file `/usr/local/nagios/etc/objects/contacts.cfg`, nghĩa là liên lạc với nhóm người dùng

```sh
# CONTACT GROUPS

define contactgroup{
        contactgroup_name       admins
        alias                   Nagios Administrators
        members                 trimq
        }


define contactgroup{
        contactgroup_name       http-group
        alias                   HTTP Admin
        members                 quoctri
        }
```

#### Ý nghĩa đoạn cấu hình

<ul>
<li>contactgroup_name: Tên của nhóm liên lạc</li>
<li>alias: Đặt alias của nhóm này là HTTP Admin</li>
<li>members: tên các thành viên có trong nhóm này</li>
</ul>

- Bước 3: Sửa trong file `template.cfg`. Trong `# SERVICE TEMPLATES` comment dòng sau:


```sh
#        contact_groups
```

- Bước 4: Thêm cấu hình sau trong file cấu hình của giám sát dịch vụ. Ví dụ tôi muốn gửi mail cảnh báo cho dịch vụ http cho nhóm HTTP-admin, tôi sẽ thêm dòng `contact_groups      http-group` vào define service. `http-group` là nhóm mà tôi đã tạo ra trong file contact

```sh
vi /usr/local/nagios/etc/servers/host1.cfg

define service {
    use                 generic-service
    host_name           host-01
    service_description Check HTTP service
    check_command       check_http
    normal_check_interval           5
    retry_check_interval            2
    contact_groups      http-group
```

- Bước 5: Khởi động lại dịch vụ

```sh
/etc/init.d/nagios restart
```



- Bước 6: Thực hiện trên client được giám sát, ngừng hoạt động của http

```sh
service apache2 stop
```

- Bước 7: Kiểm tra trên dashboard

<img src="http://i.imgur.com/G3aYXWJ.png">

- Bước 8: Kiểm tra hòm thư Gmail các địa chỉ email thuộc nhóm `http-group`

<img src="http://i.imgur.com/xNe4tDP.png">


- Bước 9: Để chắc chắn rằng Nagios chỉ gửi cảnh báo đến các contact trong nhóm `http-group`. Kiểm tra thử 1 contact trong nhóm khác không thuộc `http-group`, nếu không có mail cảnh báo nghĩa là đã thành công


<a name="532"></a>
#### 5.3.2. Gửi mail cảnh báo về host cho nhóm người dùng

Gửi mail cảnh báo về tính trạng host tới nhóm quản trị host

#### Thực hiện các bước sau trên Nagios server

- Với bài lab này, làm tương tự như bước 1 và bước 2 của cấu hình gửi cảnh báo về dịch vụ

- Bước 3: Sửa trong file `template.cfg`. Trong `# HOST TEMPLATES` comment dòng sau `contact_groups`

```sh
# Linux host definition template


# contact_groups        admins
```

Bước 4: Thêm contact trong define host của file cấu hình host giám sát

```sh
define host {
use                             linux-server
host_name                       host-01
alias                           host-01
address                         192.168.100.150
max_check_attempts              5
check_period                    24x7
notification_interval           30
notification_period             24x7
contact_groups                  admins
```

Như vậy là tôi đã thêm `contact_groups` cho host là `admins`. Khi có cảnh báo sẽ được gửi đến nhóm người dùng trong group `admins`


- Bước 5: Khởi động lại dịch vụ

```sh
/etc/init.d/nagios restart
```

- Bước 6: Để kiểm nghiệm tôi tắt client đi

```sh
init 0
```

- Bước 7: Kiểm tra hoạt động của client trên dashboard

<img src="http://i.imgur.com/iFFQG94.png">

- Bước 8: Kiểm tra trong hòm thư Gmail của người dùng trong nhóm `admins`

<img src="http://i.imgur.com/DVGNQbU.png">

- Bước 9: Để chắc chắn rằng Nagios chỉ gửi cảnh báo đến các contact trong nhóm `admins`. Kiểm tra thử 1 contact trong nhóm khác không thuộc `admins`, nếu không có mail cảnh báo nghĩa là đã thành công



<a name="6"></a>
## 6. Tài liệu tham khảo

- https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Console_Administration_Guide/Configuring_Nagios_to_Send_Mail_Notifications.html












