Bài viết này giới thiệu các bạn cách dùng lệnh **sed** trên hệ điều hành Linux.
---

- [1. Giới thiệu](#1-giới-thiệu)
- [2. Cách sử dụng cơ bản](#2-cách-sử-dụng-cơ-bản)
- [3. Ví dụ](#3-ví-dụ)
  - [3.1. In ra chuỗi từ 1 đến 5 theo hàng dòng (in ra 5 hàng)](#31-in-ra-chuỗi-từ-1-đến-5-theo-hàng-dòng-in-ra-5-hàng)
  - [3.2. Tùy chọn lọc hàng (row)](#32-tùy-chọn-lọc-hàng-row)
    - [3.2.1. Lọc ra các hàng chứa 1 chuỗi cụ thể](#321-lọc-ra-các-hàng-chứa-1-chuỗi-cụ-thể)
    - [3.2.2. Lọc ra các hàng chứa 1 chuỗi và thay thế chuỗi đó bằng chuỗi chỉ định](#322-lọc-ra-các-hàng-chứa-1-chuỗi-và-thay-thế-chuỗi-đó-bằng-chuỗi-chỉ-định)
    - [3.2.3. Sao chép mọi dòng đầu vào](#323-sao-chép-mọi-dòng-đầu-vào)
    - [3.2.4. Lọc ra hàng (row) thứ n](#324-lọc-ra-hàng-row-thứ-n)
  - [3.3. Tìm kiếm và thay thế chuỗi](#33-tìm-kiếm-và-thay-thế-chuỗi)
    - [3.3.1. Chỉnh sửa chuỗi bất kỳ, thay thế ký tự cuối dòng](#331-chỉnh-sửa-chuỗi-bất-kỳ-thay-thế-ký-tự-cuối-dòng)
    - [3.3.2. Chỉnh sửa chuỗi trong file](#332-chỉnh-sửa-chuỗi-trong-file)
    - [3.3.3. Chỉnh sửa 1 file, sau đó lưu nội dung vào file gốc, tạo bản sao để backup và đặt tên bản sao với 1 hậu tố bất kỳ](#333-chỉnh-sửa-1-file-sau-đó-lưu-nội-dung-vào-file-gốc-tạo-bản-sao-để-backup-và-đặt-tên-bản-sao-với-1-hậu-tố-bất-kỳ)
    - [3.3.4. Chỉnh sửa đặt tên bản sao với tiền tố](#334-chỉnh-sửa-đặt-tên-bản-sao-với-tiền-tố)
    - [3.3.5. Chỉnh sửa và đặt bản sao lưu trong thư mục](#335-chỉnh-sửa-và-đặt-bản-sao-lưu-trong-thư-mục)
    - [3.3.6. Chỉnh sửa không có bản sao lưu](#336-chỉnh-sửa-không-có-bản-sao-lưu)
    - [3.3.7. Chỉnh sửa nhiều tập tin](#337-chỉnh-sửa-nhiều-tập-tin)
  - [3.4. Chỉ định không in ra 1 dòng với 1 điều kiện bất kỳ](#34-chỉ-định-không-in-ra-1-dòng-với-1-điều-kiện-bất-kỳ)
    - [3.4.1. Không in ra dòng chứa 1 chuỗi chỉ định](#341-không-in-ra-dòng-chứa-1-chuỗi-chỉ-định)
    - [3.4.2. Không in ra dòng chứa 1 chuỗi cụ thể không phân biệt chữ hoa chữ thường](#342-không-in-ra-dòng-chứa-1-chuỗi-cụ-thể-không-phân-biệt-chữ-hoa-chữ-thường)
  - [3.5. Ngừng xử lý và thoát (quit) trong sed](#35-ngừng-xử-lý-và-thoát-quit-trong-sed)
- [4. Tham khảo](#4-tham-khảo)
- [5. Thực hành](#5-thực-hành)

# 1. Giới thiệu

Lệnh **sed** là công cụ xử lý văn bản mạnh mẽ và là một tiện ích UNIX lâu đời nhất và phổ biến nhất. Nó được sử dụng để sửa đổi nội dung của một tệp, thường đặt nội dung vào một tệp mới.

Lệnh **sed** có thể lọc văn bản, cũng như thực hiện thay thế trong luồng dữ liệu.

Dữ liệu từ một nguồn/tệp đầu vào được lấy và di chuyển đến không gian làm việc. Toàn bộ danh sách các hoạt động/sửa đổi được áp dụng trên dữ liệu trong không gian làm việc và nội dung cuối cùng được chuyển đến không gian đầu ra tiêu chuẩn.

![sed](../../images/programming/shellscript/shellscript-sed-1.png)

# 2. Cách sử dụng cơ bản

- Thông thường lệnh **sed** hoạt động trên một luồng dữ liệu được đọc từ đầu vào chuẩn hoặc một file văn bản. 
- Lệnh **sed** sẽ hiển thị kết quả ra màn hình, trừ khi có sự chuyển hướng kết quả này. 
- Cú pháp cơ bản của lệnh sed:

```shell
sed [tùy chọn] commands [file]
```

- Để xem các tùy chọn của lệnh sed chúng ta dùng: `man sed`

- Chúng ta có thể gọi lệnh **sed** bằng cú pháp:
  - **sed -e command filename** : Chỉ định các lệnh chỉnh sửa tại dòng lệnh, hoạt động trên tệp và đưa đầu ra ra ngoài.
  - **sed -f scriptfile filename** : Chỉ định một scriptfile chứa lệnh sed, hoạt động trên tệp và đưa đầu ra ra ngoài.

- Chúng ta có thể thực hiện thao tác chỉnh sửa và lọc với lệnh **sed**. Bên dưới giải thích một số thao tác cơ bản, trong đó **pattern** là chuỗi hiện tại và **replace_string** là chuỗi mới:
  - **sed s/pattern/replace_string/ file** : Thay thế chuỗi đầu tiên tìm thấy trong mỗi dòng
  - **sed s/pattern/replace_string/g file** : Thay thế tất cả các chuỗi tìm thấy trong mỗi dòng
  - **sed 1,3s/pattern/replace_string/g file** : Thay thế tất cả các lần xuất hiện chuỗi trong một loạt các dòng
  - **sed -i s/pattern/replace_string/g file** : Lưu các thay đổi để thay thế chuỗi trong cùng một tệp

**Lưu ý**: Tùy chọn -i sử dụng một cách cẩn thận, vì không thể quay lại trạng thái trước khi thực hiện tuỳ chọn -i.

Để đảm bảo an toàn khi sử dụng lệnh **sed** mà không có tùy chọn `-i` và sau đó thay thế tệp mới, như trong ví dụ sau:

`sed s/pattern/replace_string/g file1 > file2`

Lệnh trên sẽ thay thế tất cả các lần xuất hiện của **pattern** bằng **replace_string** trong *file1* và di chuyển nội dung sang *file2*. Nội dung của *file2* có thể được xem với lệnh cat *file2*. Nếu kết quả *file2* chính sác, chúng ta có thể ghi đè lên tệp gốc bằng lệnh `mv file2 file1`

# 3. Ví dụ

## 3.1. In ra chuỗi từ 1 đến 5 theo hàng dòng (in ra 5 hàng)

```shell
$sed 5
1
2
3
4
5
```
## 3.2. Tùy chọn lọc hàng (row)

- Theo mặc định, lệnh **sed** sẽ in mọi dòng đầu vào, bao gồm mọi thay đổi được thực hiện bởi các lệnh.
- Sử dụng tùy chọn `-n` và lệnh `p`,lọc các dòng cụ thể

### 3.2.1. Lọc ra các hàng chứa 1 chuỗi cụ thể

```shell
xuananh@K53SD:~$ cat temp1.log
1 2 3 4 5 6 7 8 9 Chrome1
1 2 3 4 5 6 7 8 9 Chrome2
1 2 3 4 5 6 7 8 9 Chrome3
1 2 3 4 5 6 7 8 9 Firefox1
1 2 3 4 5 6 7 8 9 Firefox2
1 2 3 4 5 6 7 8 9 IE
1 2 3 4 5 6 7 8 9 Other
# in tất cả dòng chứa chuỗi "Chrome"
xuananh@K53SD:~$ sed -n '/Chrome/p' temp1.log
1 2 3 4 5 6 7 8 9 Chrome1
1 2 3 4 5 6 7 8 9 Chrome2
1 2 3 4 5 6 7 8 9 Chrome3
# in tất cả dòng chứa chuỗi "Firefox"
xuananh@K53SD:~$ sed -n '/Firefox/p' temp1.log
1 2 3 4 5 6 7 8 9 Firefox1
1 2 3 4 5 6 7 8 9 Firefox2
```

### 3.2.2. Lọc ra các hàng chứa 1 chuỗi và thay thế chuỗi đó bằng chuỗi chỉ định

```shell
xuananh@K53SD:~$ cat temp1.log
1 2 3 4 5 6 7 8 9 Chrome1
1 2 3 4 5 6 7 8 9 Chrome2
1 2 3 4 5 6 7 8 9 Chrome3
1 2 3 4 5 6 7 8 9 Firefox1
1 2 3 4 5 6 7 8 9 Firefox2
1 2 3 4 5 6 7 8 9 IE
1 2 3 4 5 6 7 8 9 Other
xuananh@K53SD:~$ sed -n 's/Chrome/cHOME/p' temp1.log
1 2 3 4 5 6 7 8 9 cHOME1
1 2 3 4 5 6 7 8 9 cHOME2
1 2 3 4 5 6 7 8 9 cHOME3
xuananh@K53SD:~$ sed -n 's/Firefox/fIREFOX/p' temp1.log
1 2 3 4 5 6 7 8 9 fIREFOX1
1 2 3 4 5 6 7 8 9 fIREFOX2
```

### 3.2.3. Sao chép mọi dòng đầu vào

Đầu vào từ lệnh  **seq** sẽ được lệnh **sed** sao chép và in ra phía dưới:

```shell
xuananh@K53SD:~$ seq 2 | sed 'p'
1
1
2
2
xuananh@K53SD:~$ seq 3 | sed 'p'
1
1
2
2
3
3
xuananh@K53SD:~$ 
```

### 3.2.4. Lọc ra hàng (row) thứ n

Sử dụng tùy chọn -n để lọc số dòng

```shell
xuananh@K53SD:~$ cat temp.log
1 2 3 4 5 6 7 8 9 line 1
1 2 3 4 5 6 7 8 9 line 2
1 2 3 4 5 6 7 8 9 line 3
1 2 3 4 5 6 7 8 9 line 4
# IN DÒNG SỐ 2
xuananh@K53SD:~$ sed -n '2p' temp.log
1 2 3 4 5 6 7 8 9 line 2
# IN DÒNG SỐ 2 VÀ 4
xuananh@K53SD:~$ sed -n '2p; 4p' temp.log
1 2 3 4 5 6 7 8 9 line 2
1 2 3 4 5 6 7 8 9 line 4
# IN DÒNG CUỐI
xuananh@K53SD:~$ sed -n '$p' temp.log
1 2 3 4 5 6 7 8 9 line 4
# IN DÒNG SÔ 2 ĐẾN DÒNG 4
xuananh@K53SD:~$ sed '2,4!d' temp.log
1 2 3 4 5 6 7 8 9 line 2
1 2 3 4 5 6 7 8 9 line 3
1 2 3 4 5 6 7 8 9 line 4
# TÌM KIẾM BẮT ĐẦU TỪ DÒNG 2 VÀ THAY THẾ CHUỖI XUẤT HIỆN ĐẦU TIÊN
xuananh@K53SD:~$ sed '2 s/line/LINE/' temp.log
1 2 3 4 5 6 7 8 9 line 1
1 2 3 4 5 6 7 8 9 LINE 2
1 2 3 4 5 6 7 8 9 line 3
1 2 3 4 5 6 7 8 9 line 4
# TÌM KIẾM BẮT ĐẦU TỪ DÒNG 3 VÀ THAY THẾ CHUỖI XUẤT HIỆN ĐẦU TIÊN
xuananh@K53SD:~$ sed '3 s/line/LINE/' temp.log
1 2 3 4 5 6 7 8 9 line 1
1 2 3 4 5 6 7 8 9 line 2
1 2 3 4 5 6 7 8 9 LINE 3
1 2 3 4 5 6 7 8 9 line 4
```

## 3.3. Tìm kiếm và thay thế chuỗi

Cú pháp:

`sed s/pattern/replace_string/ file`

**Lưu ý**: Kí tự / được sử dụng như là một ký tự phân cách.

### 3.3.1. Chỉnh sửa chuỗi bất kỳ, thay thế ký tự cuối dòng

```shell
# lệnh tạo dữ liệu đầu ra
xuananh@K53SD:~$ seq 15 | paste -sd,
1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

# chỉ thay đổi dấu phẩy đầu tiên của dữ liệu trên
xuananh@K53SD:~$ seq 15 | paste -sd, | sed 's/,/ : /'
1 : 2,3,4,5,6,7,8,9,10,11,12,13,14,15

# thay đổi tất cả "," thành dấu ":" bằng cách sử dụng công cụ sữa đổi "r"
xuananh@K53SD:~$ seq 15 | paste -sd, | sed 's/,/ : /g'
1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 : 9 : 10 : 11 : 12 : 13 : 14 : 15

#-----------------------------------------------
# lệnh tạo dữ liệu test
╭─xuananh@xuananh-PC ~/repo/tech-note  ‹master) ✗› 
╰─➤  seq 5 | paste -sd\\n

1
2
3
4
5
# thêm dấu , vào cuối mỗi dòng
╭─xuananh@xuananh-PC ~/repo/tech-note  ‹master) ✗› 
╰─➤  seq 5 | paste -sd\\n | sed 's/$/,/'

1,
2,
3,
4,
5,
```

### 3.3.2. Chỉnh sửa chuỗi trong file

```shell
# giả sử có 1 file với nội dung như sau :
xuananh@K53SD:~$ cat file.txt
Hello
Have a nice day

# Đọc file và thay đổi chữ 'e' đầu tiên của mỗi dòng thành 'E' 
xuananh@K53SD:~$ sed 's/e/E/' file.txt
HEllo
HavE a nice day

# Đọc file và thay đổi chữ 'nice day' của mỗi dòng thành 'safe journey'
xuananh@K53SD:~$ sed 's/nice day/safe journey/' file.txt
Hello
Have a safe journey

# Đọc file và thay đổi chữ 'e' thành 'E' và lưu văn bản thành tệp mới
xuananh@K53SD:~$ sed 's/e/E/g' file.txt > out.txt
xuananh@K53SD:~$ cat out.txt
HEllo
HavE a nicE day
```

### 3.3.3. Chỉnh sửa 1 file, sau đó lưu nội dung vào file gốc, tạo bản sao để backup và đặt tên bản sao với 1 hậu tố bất kỳ

```shell
# ví dụ có 1 file với nội dung
xuananh@K53SD:~$ cat file.txt
Hello

# thay đổi nội dung file và lưu thay đổi vào file gôc, đồng thời tạo file backup có đuôi ".bkp"
xuananh@K53SD:~$ sed -i.bkp 's/Hello/Hi/' file.txt

# nội dung mới của file.txt là
xuananh@K53SD:~$ cat file.txt
Hi

# nội dung gốc được lưu giữ trong file.txt.bkp
xuananh@K53SD:~$ cat file.txt.bkp
Hello
```

### 3.3.4. Chỉnh sửa đặt tên bản sao với tiền tố

```shell
xuananh@K53SD:~$ cat > fileprefix.txt
foo
bar
baz
xuananh@K53SD:~$ sed -i'bkp.*' 's/foo/hello/' fileprefix.txt
xuananh@K53SD:~$ cat fileprefix.txt
hello
bar
baz
xuananh@K53SD:~$ cat bkp.fileprefix.txt
foo
bar
baz
```

### 3.3.5. Chỉnh sửa và đặt bản sao lưu trong thư mục

```shell
xuananh@K53SD:~$ mkdir bkp_dir
xuananh@K53SD:~$ sed -i'bkp_dir/*' 's/bar/hi/' fileprefix.txt
xuananh@K53SD:~$ cat fileprefix.txt
hello
hi
baz
xuananh@K53SD:~$ cat bkp_dir/fileprefix.txt
hello
bar
baz
# phần mở rộng có thể được thêm vào cùng 
# bkp_dir / *.bkp cho hậu tố 
# bkp_dir / bkp.* cho tiền tố
```


### 3.3.6. Chỉnh sửa không có bản sao lưu

```shell
xuananh@K53SD:~$ cat file.txt
Have a nice day

# tìm kiếm và thay thế
xuananh@K53SD:~$ sed -i 's/nice day/safe journey/' file.txt

# nội dung mới của file.txt
xuananh@K53SD:~$ cat file.txt
Have a safe journey
```

### 3.3.7. Chỉnh sửa nhiều tập tin

```shell
xuananh@K53SD:~$ cat file1
I ate 3 apples
xuananh@K53SD:~$ cat file2
I bought tow bananas and 3 mangoes
xuananh@K53SD:~$ sed -i 's/3/three/' file1 file2
xuananh@K53SD:~$ cat file1
I ate three apples
xuananh@K53SD:~$ cat file2
I bought tow bananas and three mangoes
```

## 3.4. Chỉ định không in ra 1 dòng với 1 điều kiện bất kỳ

Theo mặc định, lệnh **sed** in mọi dòng, bao gồm mọi thay đổi.

### 3.4.1. Không in ra dòng chứa 1 chuỗi chỉ định

Sử dụng tùy chọn `d`, những dòng cụ thể sẽ không được in:

```shell
xuananh@K53SD:~$ cat filea.txt
Roses are red,
Violets are blue,
Sugar is sweet,
And so are you.
# KHÔNG IN DÒNG CÓ CHỨA CHUỖI "are"
xuananh@K53SD:~$ sed '/are/d'  filea.txt
Sugar is sweet,
# KHÔNG IN DÒNG CÓ SỐ 3
xuananh@K53SD:~$ seq 5 | sed '/3/d'
1
2
4
5
```

### 3.4.2. Không in ra dòng chứa 1 chuỗi cụ thể không phân biệt chữ hoa chữ thường

Tùy chọn `I` cho phép lọc các dòng theo cách không phân biệt chữ hoa chữ thường

```shell
xuananh@K53SD:~$ cat filea.txt
Roses are red,
Violets are blue,
Sugar is sweet,
And so are you.
xuananh@K53SD:~$ sed '/rose/Id' filea.txt
Violets are blue,
Sugar is sweet,
And so are you.
```

## 3.5. Ngừng xử lý và thoát (quit) trong sed

Thoát lệnh sed và không xử lý thêm

```shell
# in ra dòng 1 đến 9 nhưng thoát lệnh sed sau 5 dòng
xuananh@K53SD:~$ seq 1 9 | sed '5q'
1
2
3
4
5
```

Thoát với tùy chọn `q` và `Q`. Qua ví dụ dưới đây chúng ta sẽ phân biệt được sự khác nhau giữa `q` và `Q`

```shell
# q sẽ in ra số dòng bằng chỉ số trước q, ví dụ sau '5q' --> in ra 5 dòng
xuananh@K53SD:~$ seq 1 15 | sed '5q'
1
2
3
4
5
# Q sẽ in ra số dòng bằng chỉ số trước Q trừ 1
# ví dụ sau '5Q' --> in ra 4 dòng 
xuananh@K53SD:~$ seq 1 15 | sed '5Q'
1
2
3
4
```

Sử dụng `tac` để in tất cả các dòng bắt đầu từ lần xuất hiện cuối cùng của chuỗi tìm kiếm

```shell
# ví dụ sau đầu vào là 1 cột có 50 hàng đánh số từ 1 đến 50, lần cuối cùng xuất hiện của số 6 là 46, vì thế lệnh sau sẽ in ra bắt đàu từ 46, in cả giá trị cuối cùng là 46
xuananh@K53SD:~$ seq 50 | tac | sed '/6/q' | tac
46
47
48
49
50
# ví dụ sau đầu vào là 1 cột có 50 hàng đánh số từ 1 đến 50, lần cuối cùng xuất hiện của số 6 là 46, vì thế lệnh sau sẽ in ra bắt đàu từ 46, bỏ qua giá trị cuối cùng là 46
xuananh@K53SD:~$ seq 50 | tac | sed '/6/Q' | tac
47
48
49
50
```

# 4. Tham khảo

https://blogd.net/linux/su-dung-lenh-sed/

https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/?ref=rp

https://www.geeksforgeeks.org/sed-command-linux-set-2/

# 5. Thực hành

https://vietjack.com/unix/regular_expression_trong_unix_linux.jsp
