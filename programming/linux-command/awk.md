Bài viết này giới thiệu các bạn cách dùng lệnh awk trên hệ điều hành Linux.
---

- [1. Giới thiệu](#1-giới-thiệu)
- [2. In các dòng trong file](#2-in-các-dòng-trong-file)
- [3. Xử lý trường/cột](#3-xử-lý-trườngcột)
  - [3.1. Tách trường/cột](#31-tách-trườngcột)
  - [3.2. Chỉ định ký tự tách trường cột](#32-chỉ-định-ký-tự-tách-trường-cột)
- [4. Phép so sánh](#4-phép-so-sánh)
- [5. Cú pháp điều kiện](#5-cú-pháp-điều-kiện)
- [6. Lọc ký tự](#6-lọc-ký-tự)
- [7. Lọc dựa trên số dòng](#7-lọc-dựa-trên-số-dòng)
- [8. Thay thế](#8-thay-thế)
- [9. Tính tổng giá trị](#9-tính-tổng-giá-trị)
  - [9.1. Tính tổng giá trị của một cột](#91-tính-tổng-giá-trị-của-một-cột)
  - [9.2. Tính tổng giá trị của một cột và in các giá trị của cột đó](#92-tính-tổng-giá-trị-của-một-cột-và-in-các-giá-trị-của-cột-đó)
- [10. Tham khảo](#10-tham-khảo)

# 1. Giới thiệu

Ngôn ngữ **awk** là một ngôn ngữ lập trình giúp chúng ta thao tác dễ dàng với kiểu dữ liệu có cấu trúc và tạo ra những kết quả được định dạng. Nó được đặt tên bằng cách viết tắt các chữ cái đầu tiên của các tác giả: Aho, Weinberger và Kernighan.

Lệnh **awk** sử dụng để tìm kiếm và xử lý file text. Nó có thể tìm kiếm một hoặc nhiều file để xem các file có dòng nào bao gồm những pattern cần tìm kiếm và sau đó thực hiện những action. Cú pháp của lệnh **awk** như sau:

`awk pattern actions file`

Trong đó:
- **pattern**: là những biểu thức chính quy
- **actions**: là những câu lệnh cần thực hiện
- **file**: file cần thực hiện lệnh awk

Cách lệnh **awk** hoạt động:
- Lệnh **awk** đọc file đầu vào theo từng dòng.
- Đối với mỗi dòng, nó sẽ khớp lần lượt với các **pattern**, nếu khớp thì sẽ thực hiện **action** tương ứng. Nếu không có **pattern** nào được so khớp thì sẽ không có **action** nào thực hiện.
- Cú pháp cơ bản làm việc với lệnh **awk** thì **pattern** hoặc **action** phải có 1 trong 2 không thể thiếu cà 2.
- Nếu không có **pattern**, **awk** sẽ thực hiện **action** đối với mỗi dòng của dữ liệu. Nếu không có **action**, **awk** sẽ mặc định in ra tất cả những dòng khớp với **pattern** đã cho.
- Mỗi câu lệnh trong phần **action** được phân tách nhau bởi dấu chấm phẩy.

# 2. In các dòng trong file

Mặc định, lệnh **awk** sẽ in ra từng dòng của file. Ví dụ:

```shell
xuananh@K53SD:~$ cat file.txt
fruit   qty
apple   42
banana  31
fig     90
guava   6
xuananh@K53SD:~$ awk '{print}' file.txt
fruit   qty
apple   42
banana  31
fig     90
guava   6
```

# 3. Xử lý trường/cột

## 3.1. Tách trường/cột

- `$0`: Chứa toàn bộ văn bản
- `$1`: Chứa văn bản trường đầu tiên
- `$2`: chứa văn bản trường thứ hai
- `$(2+3)`: Kết quả của các biểu thức được sử dụng, đưa ra trường thứ năm
- `NF`: là một biến tích hợp có chứa số lượng các trường trong bản ghi hiện tại. Vì vậy `$NF `đưa ra trường cuối cùng và `$(NF-1)` sẽ đưa ra trường cuối cùng thứ hai.

Ví dụ:

```shell
# in toàn bộ text
xuananh@K53SD:~$ cat file.txt
fruit   qty
apple   42
banana  31
fig     90
guava   6
xuananh@K53SD:~$ awk '{print $1}' file.txt
fruit
apple
banana
fig
guava
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $0}'
1 2 3 4 5 6 7 8 9

# in trường/cột 1 và 3
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $1 $3}'
13

# in trường/cột 2 và 4
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $2 $4}'
24

# in ra tất cả các trường/cột trừ cột 1 và 2
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{$1=$2=""; print $0}'
  3 4 5 6 7 8 9

# in ra trường cuối cùng
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $NF}'
9

# in ra trường đầu tiên và trường cuối cùng 
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $1, $NF}'
1 9

# in ra trường thứ 2 tính từ cuối dòng
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $(NF-1)}'
8

# in ra tất cả các trường/cột trong khoảng từ 3 đến 7
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk -v f=3 -v t=7 '{for(i=f;i<=t;i++) printf("%s%s",$i,(i==t)?"\n":OFS)}'
3 4 5 6 7

# in ra tất cả các trường/cột ngoài khoảng từ 3 đến 7
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk -v f=3 -v t=7 '{for(i=1;i<=NF;i++)if(i>=f&&i<=t)continue;else printf("%s%s",$i,(i!=NF)?OFS:ORS)}'
1 2 8 9
```

## 3.2. Chỉ định ký tự tách trường cột

Mặc định là ký tự space, ta có thể chỉ định ký tự khác để tách trường, ví dụ:

```shell
xuananh@K53SD:~$ echo "1 2 3 4 5 6 7 8 9" | awk '{print $1 $3}'
13
xuananh@K53SD:~$ echo "1-2-3-4-5-6-7-8-9" | awk -F- '{print $1 $3}'
13
xuananh@K53SD:~$ echo "1:2:3:4:5:6:7:8:9" | awk -F: '{print $1 $3}'
13
```

# 4. Phép so sánh

Ví dụ: Sử dụng lệnh **awk** thực hiện như sau `awk '$1 > 200' file1.txt`
Nếu `$1` lớn hơn 200 thì chương trình sẽ thực hiện in nội dung của file1.txt

```shell
xuananh@K53SD:~$ cat file1.txt
500  Sanjay  Sysadmin   Technology  $7,000
300  Nisha   Manager    Marketing   $9,500
400  Randy   DBA        Technology  $6,000
xuananh@K53SD:~$ awk '$1 > 200' file1.txt
500  Sanjay  Sysadmin   Technology  $7,000
300  Nisha   Manager    Marketing   $9,500
400  Randy   DBA        Technology  $6,000
```

# 5. Cú pháp điều kiện

Mỗi câu lệnh bên trong **{}** có thể được thêm bởi một điều kiện để các câu lệnh sẽ chỉ thực thi nếu điều kiện là đúng. 

Ví dụ:

```shell
xuananh@K53SD:~$ cat file.txt
fruit   qty
apple   42
banana  31
fig     90
guava   6
xuananh@K53SD:~$ awk '{
         if($1 == "apple"){
            print $2
         }
       }' file.txt
42
xuananh@K53SD:~$ awk '{
         if(NR==1 || $2<35){
            print $0
         }
       }' file.txt
fruit   qty
banana  31
guava   6
```

# 6. Lọc ký tự

Để lọc ký tự ta sử dụng regex đặt trong  `'//'`

Ví dụ:

```shell
xuananh@K53SD:~$ cat temp.log
1 2 3 4 5 6 7 8 9 Chrome chrome1
1 2 3 4 5 6 7 8 9 Chrome chrome2
1 2 3 4 5 6 7 8 9 Firefox
1 2 3 4 5 6 7 8 9 IE
1 2 3 4 5 6 7 8 9 Other
xuananh@K53SD:~$ awk '/Chrome/' temp.log
1 2 3 4 5 6 7 8 9 Chrome chrome1
1 2 3 4 5 6 7 8 9 Chrome chrome2
xuananh@K53SD:~$ awk '!/Chrome/' temp.log
1 2 3 4 5 6 7 8 9 Firefox
1 2 3 4 5 6 7 8 9 IE
1 2 3 4 5 6 7 8 9 Other
xuananh@K53SD:~$ awk '/Chrome/ && !/chrome2/' temp.log
1 2 3 4 5 6 7 8 9 Chrome chrome1
xuananh@K53SD:~$ awk '/Chrome/{print $NF}' temp.log
chrome1
chrome2
```

# 7. Lọc dựa trên số dòng

```shell
xuananh@K53SD:~$ cat temp.log
1 2 3 4 5 6 7 8 9 line 1
1 2 3 4 5 6 7 8 9 line 2
1 2 3 4 5 6 7 8 9 line 3
1 2 3 4 5 6 7 8 9 line 4
1 2 3 4 5 6 7 8 9 line 5
1 2 3 4 5 6 7 8 9 line 6

# in ra dòng 2
xuananh@K53SD:~$ awk 'NR==2' temp.log
1 2 3 4 5 6 7 8 9 line 2

# in ra dòng 2 và dòng 4
xuananh@K53SD:~$ awk 'NR==2 || NR==4' temp.log
1 2 3 4 5 6 7 8 9 line 2
1 2 3 4 5 6 7 8 9 line 4

# in ra dòng cuối cùng của file
xuananh@K53SD:~$ awk 'END{print}' temp.log
1 2 3 4 5 6 7 8 9 line 6

# in ra cột 3 của dòng 4
xuananh@K53SD:~$ awk 'NR==4{print $3}' temp.log
3
```

# 8. Thay thế

Sử dụng hàm **sub** chuỗi để thay thế lần xuất hiện đầu tiên

Sử dụng **gsub** để thay thế tất cả các lần xuất hiện

Ví dụ:

```shell
# thay thế chuỗi đầu tiên tìm thấy
xuananh@K53SD:~$ echo ' 1-2-3-4-5 ' | awk ' {sub ("-", ":")} 1 '
 1:2-3-4-5 

# thay thế tất cả các chuỗi tìm thấy
xuananh@K53SD:~$ echo ' 1-2-3-4-5 ' | awk ' {gsub ("-", ":")} 1 '
 1:2:3:4:5 

# thay thế tất cả và in ra số lượng tìm thấy 
xuananh@K53SD:~$ echo '1-2-3-4-5' | awk '{n=gsub("-", ":"); print n} 1'
4
1:2:3:4:5

# thay thế với hàm regex ngược, tất cả các kỹ tự không phải là -
xuananh@K53SD:~$ echo '1-2-3-4-5' | awk '{gsub(/[^-]+/, "abc")} 1'
abc-abc-abc-abc-abc

# tìm và thay thế e bằng E trong cột số 3
xuananh@K53SD:~$ echo 'one;two;three;four' | awk -F';' '{gsub("e", "E", $3)} 1'
one two thrEE four
```

# 9. Tính tổng giá trị

## 9.1. Tính tổng giá trị của một cột

Lệnh **awk** thực hiện tính tổng dựa trên cú pháp sau:

`awk '{s+=$(cột cần tính)} END {print s}' {{filename}}`

Ví dụ:

```shell
xuananh@K53SD:~$ cat file1.txt
500  Sanjay  Sysadmin   Technology  $7,000
300  Nisha   Manager    Marketing   $9,500
400  Randy   DBA        Technology  $6,000
xuananh@K53SD:~$ awk '{s+=$1} END {print s}' file1.txt
1200
```

## 9.2. Tính tổng giá trị của một cột và in các giá trị của cột đó

Cú pháp:

```shell
awk '{s+=$1; print $(cột cần tính)} END {print "--------"; print s}' {{filename}}
```

Ví dụ:

```shell
xuananh@K53SD:~$ cat file1.txt
500  Sanjay  Sysadmin   Technology  $7,000
300  Nisha   Manager    Marketing   $9,500
400  Randy   DBA        Technology  $6,000
xuananh@K53SD:~$ awk '{s+=$1; print $1} END {print "--------"; print s}' file1.txt
500
300
400
--------
1200
```

# 10. Tham khảo

https://blogd.net/linux/su-dung-lenh-awk/

https://www.geeksforgeeks.org/awk-command-unixlinux-examples/

