- [1. Tính năng](#1-tính-năng)
- [2. Cài đặt](#2-cài-đặt)
- [3. Sử dụng](#3-sử-dụng)
- [4. Ví dụ](#4-ví-dụ)
- [5. Auto sync](#5-auto-sync)
- [6. Icron](#6-icron)
- [7. Crontab](#7-crontab)

# 1. Tính năng

- Copy cả user, group, permission(quyền) giúp chúng ta bảo toàn dữ liệu.
- RSYNC kết hợp SSH bảo mật dữ liệu.
- RSYNC nén dữ liệu trên server trước khi gửi đi.
- Tự động xóa dữ liệu nếu dữ liệu đó không tồn tại trên source giúp đồng bộ dữ liệu giữa hai máy chủ.
- RSYNC nhanh hơn SCP.

# 2. Cài đặt

Red Hat/CentOS 
```shell    
yum install rsync
```

Debian/Ubuntu
```shell
apt-get install rsync
```

# 3. Sử dụng

Cú pháp của RSYNC:
```shell
rsync option source destination
```

Trong đó:

**Source**: đường dẫn thư mục chứa dữ liệu gốc muốn đồng bộ, nơi truyền dữ liệu.

**destination**: đường dẫn nơi chứa dữ liệu đồng bộ đến, nơi nhận dữ liệu.

**option**: các tham số  tùy chọn.

   * -a: option này sẽ bảo toàn user, group, permission của dữ liệu truyền đi
   * -v: show trạng thái truyền tải file ra màn hình command line  để bạn theo dõi.
   * -h: kết hợp với -v để định dạng dữ liệu show ra dễ nhìn hơn.
   * -z: nén dữ liệu trước khi truyền đi giúp tăng tốc quá trình đồng bộ file.
   * -e: sử dụng giao thức SSH để mã hóa dữ liệu.
   * -P: Option này dùng khi đường truyền không ổn định, nó sẽ gửi tiếp các file chưa được gửi đi khi có kết nối trở lại.
   * --delete: xóa dữ liệu ở destination nếu source không tồn tại dữ liệu đó.
   * --exclude: loại trừ ra dữ liệu không muốn truyền đi, nếu cần loại ra nhiều file hoặc folder ở nhiều đường dẫn khác nhau thì mỗi cái bạn phải thêm –-exclude tương ứng( cũng có thể sử dụng –exclude-from chỉ đến một file liệt kê các file, thư mục không truyền đi).
Còn có rất nhiều option khác, các bạn có thể tham khảo thêm [ở đây](https://download.samba.org/pub/rsync/rsync.html)

# 4. Ví dụ

```shell
rsync -azvhP --delete \
        --exclude-from='/home/test/filessh/excluded.txt' \ 
        -e 'ssh -i /home/test/filessh/server2.pem' \    # chi dinh ssh private key, tot nhat nen cho vao ssh config, tham khao : https://unix.stackexchange.com/a/127355/474544
        -e 'ssh -p 12345' \     # port
        /var/www/html/web/staging/* test@192.168.0.2:/var/www/html/web/production/
```

chuẩn bị data để test

```shell
# tao thu muc test
export RSYNC_TEST_SOURCE_DIR=/home/xuananh/Downloads/test-rsync/source-dir
export RSYNC_TEST_DESTINATION_DIR=/home/xuananh/Downloads/test-rsync/destination-dir
mkdir -p $RSYNC_TEST_SOURCE_DIR
mkdir -p $RSYNC_TEST_DESTINATION_DIR
# tao data test
echo `date` >> $RSYNC_TEST_SOURCE_DIR/test.txt
cat $RSYNC_TEST_SOURCE_DIR/test.txt
touch $RSYNC_TEST_SOURCE_DIR/test-$(date '+%d-%m-%Y__%H:%M:%S').txt
ls -lha $RSYNC_TEST_SOURCE_DIR/
```

chạy lệnh test với thư các thư mục vừa tạo

```shell
rsync --archive --compress \
        --verbose --human-readable \
        --progress --partial \
        $RSYNC_TEST_SOURCE_DIR/* xuananh@localhost:$RSYNC_TEST_DESTINATION_DIR
ls -lha $RSYNC_TEST_SOURCE_DIR
ls -lha $RSYNC_TEST_DESTINATION_DIR
```

Nội dung file `excluded.txt` của rsync định dạng như sau:

```conf
application/config/*
application/cache/*
application/hooks/*
application/index.html
index.php
```
Chú ý là file `excluded.txt` nó sẽ tính thư mục /var/www/html/web/staging/ ở source là thư mục gốc

# 5. Auto sync

# 6. Icron

Tự động sync khi có sự thay đổi ở thử mục nguồn, tham khảo:[https://www.cyberciti.biz/faq/linux-inotify-examples-to-replicate-directories/](https://www.cyberciti.biz/faq/linux-inotify-examples-to-replicate-directories/)
[https://support.maxserver.com/415383-T%C3%ACm-hi%E1%BB%83u-v%E1%BB%81-incron](https://support.maxserver.com/415383-T%C3%ACm-hi%E1%BB%83u-v%E1%BB%81-incron)


# 7. Crontab

Tự động sync sau 1 khoảng thời gian