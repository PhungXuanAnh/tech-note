- [1. usage](#1-usage)
  - [1.1. in ra ký tự ở vị trí chỉ định : -b(byte)](#11-in-ra-ký-tự-ở-vị-trí-chỉ-định---bbyte)
  - [1.2. in ra ký tự ở vị trí chỉ định : -c (column) chả khac gi -b ca](#12-in-ra-ký-tự-ở-vị-trí-chỉ-định---c-column-chả-khac-gi--b-ca)
  - [1.3. in ra các trường ở vị trí chỉ định, các trường được phân biệt bằng 1 ký tự bất kỳ do mình chọn : -f (field)](#13-in-ra-các-trường-ở-vị-trí-chỉ-định-các-trường-được-phân-biệt-bằng-1-ký-tự-bất-kỳ-do-mình-chọn---f-field)
- [2. reference](#2-reference)

# 1. usage

cut dùng để cắt các phần của 1 dòng theo **vị trí byte**, **theo ký tự, hoặc theo trường**

Syntax:

```shell
cut OPTION... [FILE]...
```

co 1 file **state.txt** chua 5 cai ten như sau:

```shell
$ cat state.txt
Andhra Pradesh
Arunachal Pradesh
Assam
Bihar
Chhattisgarh
```

dùng lệnh `cut` mà thiếu option sẽ có lỗi

```shell
$ cut state.txt
cut: you must specify a list of bytes, characters, or fields
Try 'cut --help' for more information.
```

## 1.1. in ra ký tự ở vị trí chỉ định : -b(byte)

In ra ký tự tại vị trí được chỉ định của mỗi hàng (row)

```shell
# In ra các ký tự tại hàng 1, 2, 3
$ cut -b 1,2,3 state.txt
And
Aru
Ass
Bih
Chh

# In ra các ký tự theo range, từ 1 đến 3 và từ 5 đến 7
$ cut -b 1-3,5-7 state.txt
Andra
Aruach
Assm
Bihr
Chhtti
```

Sử dụng cú pháp đặc biệt để lựa chọn in số ký tự từ 1 vị trí bất kỳ đến đầu dòng hoặc từ 1 vị trí bất kỳ đến cuối dòng

In this, 1- indicate from 1st byte to end byte of a line

```shell
# 1- : nghĩa là in từ ký tự ở vị trí số 1 đến cuối dòng
$ cut -b 1- state.txt
Andhra Pradesh
Arunachal Pradesh
Assam
Bihar
Chhattisgarh

# -3 : nghĩa là in từ byte số 3 đến đầu dòng
$ cut -b -3 state.txt
And
Aru
Ass
Bih
Chh
```

## 1.2. in ra ký tự ở vị trí chỉ định : -c (column) chả khac gi -b ca

cắt theo ký tự, đối số là 1 list number cách nhau bằng dấu phẩy (,) hoặc dải số sử dụng ký tự (-). Ký tự khoảng trắng và space sẽ được coi như là 1 ký tự

Syntax:

```shell
$cut -c [(k)-(n)/(k),(n)/(n)] filename
```

k là vị trí đầu tiên
n là vị trí cuối cùng
nếu k và n ngăn cách bởi dấu - thì nó là cắt 1 dải các ký tự
nếu k và n ngăn cách bởi dấu , thì nó là chọn các kỹ tự ở vị trí đó thôi

```shell
# lệnh sau in ra ký tự ở vị trí số 2, 5, 7 của mỗi dòng
$ cut -c 2,5,7 state.txt
nr
rah
sm
ir
hti

# lệnh sau in 7 ký tự đầu tiên của mỗi dòng
$ cut -c 1-7 state.txt
Andhra
Arunach
Assam
Bihar
Chhatti
```

sử dụng cú pháp đặc biệt

```shell
# lệnh sau in từ ký tự đầu tiên đến hết dòng
$ cut -c 1- state.txt
Andhra Pradesh
Arunachal Pradesh
Assam
Bihar
Chhattisgarh

# lệnh sau in 5 ký tự đầu tiên của mỗi dòng
$ cut -c -5 state.txt
Andhr
Aruna
Assam
Bihar
Chhat
```


## 1.3. in ra các trường ở vị trí chỉ định, các trường được phân biệt bằng 1 ký tự bất kỳ do mình chọn : -f (field)

Syntax:

```shell
$cut -d "delimiter" -f (field number) file.txt
```

```shell
# -d không được chỉ định thì nó in ra toàn bộ file
$ cut -f 1 state.txt
Andhra Pradesh
Arunachal Pradesh
Assam
Bihar
Chhattisgarh

# in ra trường đầu tiên trong mỗi dòng, phân biệt các trường bằng ký tự khoảng trắng " "
$ cut -d " " -f 1 state.txt
Andhra
Arunachal
Assam
Bihar
Chhattisgarh

# in ra các trường từ 1 đến 4, các trường phân biệt bằng ký tự khoảng trắng " "
$ cut -d " " -f 1-4 state.txt
Output:
Andhra Pradesh
Arunachal Pradesh
Assam
Bihar
Chhattisgarh
```

# 2. reference

https://www.geeksforgeeks.org/cut-command-linux-examples/
