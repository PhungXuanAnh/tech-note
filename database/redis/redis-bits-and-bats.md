Redis - bits and bats
---

- [1. Bitwise operations](#1-bitwise-operations)
- [2. Example](#2-example)
- [3. References](#3-references)

Trong bài post này, chúng ta sẽ học cách thực hiện các hoạt động bitwise trong Redis keys, cũng như các thao tác thiết lập lập, lấy, so sánh các giá trị nhị phân

# 1. Bitwise operations


Bằng cách ứng dụng bitmap ánh xạ một dải các bít đến một giá trị nhị phân, chúng ta có thể thực hiện rất nhanh và và sự so sánh phân tích bộ nhớ hiệu quả.

Bất kỳ key nào trong Redis database có thể lưu trữ (2^32-1) bits, hoặc dưới 512MB. Nghĩa là có sấp xỉ 4.29 tỉ cột, hoặc offsets có thể được set để sử dụng trong mỗi key. Đây là một số lượng bít lớn được tham chiếu trong một key đơn. Chúng ta có thể set các bít cùng với những dải bít để mô tả các đặc tính của một danh mục mà ta muốn theo dõi, như số lượng người dùng đã xem một bài báo. Xem ví dụ bên dưới.

# 2. Example

Giả sử chúng ta phục vụ rất nhiều bài báo, và mỗi bài báo được gán 1 id riêng. Cũng giả sử chúng ta có 100.000 người dùng đăng ký với website, và mỗi người dùng cũng có 1 ID riêng - một số nằm giữa khoảng từ 1 - 100.000. Chúng ta có thể sử dụng các thao tác bit để theo dõi hoạt động xem 1 bài báo của người dùng bằng cách tạo một key duy nhất cho bài báo đó, sau đó set bit tương ứng với ID của người dùng xem bài báo đó lên 1. Ví dụ sau thể hiện rằng, bài báo 808 được xem bởi người dùng 4,6,9-11:

```
article:808:01-03-2018 : 00010100111010001001111...
```

Key trên mô tả bài báo 808 trong một ngày cụ thể, lưu trữ hiệu quả ID của người dùng đã xem bài báo trong ngày đó bằng cách lật bít tại offset tương ứng với ID của người dùng. Bất cứ khi nào người dùng xem 1 bài báo, chúng ta sử dụng lệnh **SETBIT** để set 1 bit tại offset bằng ID của người dùng.

```python
redis_cli.setbit('article:808:01-03-2018', userId, 1)
```

Hãy tạo data cho 3 bài báo:

```python
pool = redis.ConnectionPool(host='localhost', port=6379, db=2)
redis_cli = redis.Redis(connection_pool=pool)

pipe = redis_cli.pipeline()

user_id = 100000

while user_id:
    redis_cli.setbit('article1:today', user_id, random.choice([1, 1, 1, 0]))
    redis_cli.setbit('article2:today', user_id, random.choice([1, 1, 1, 0, 0]))
    redis_cli.setbit('article3:today', user_id, random.choice([1, 1, 1, 0, 0, 0, 0]))
```

Ở đây, chúng ta tạo 3 Redis key, article(1:3):today, sau đó set ngẫu nhiên 100.000 bit trong mỗi key thành 1 hoặc 0. Sử dụng công nghệ lưu trữ hoạt đông người dùng dựa trên offset ID, bây giờ chúng ta có dữ liệu mẫu cho một ngày giả định về lưu lượng truy cập 3 bài báo.

Để đếm số lượng người dùng đã xem 1 bài báo, chúng ta sử dụng BITCOUNT:

```python
print('So luong nguoi dung da xem bai bao 1: ', redis_cli.bitcount('article1:today'))
```

Hàm này đơn giản, số người dùng đã xem một bài báo bằng số bít 1 trong key. Bây giờ hãy tính tổng số người xem:

```python

pipe.bitcount('article1:today')
pipe.bitcount('article2:today')
pipe.bitcount('article3:today')
print('Tong so nguoi da xem moi bai bao la: ', pipe.execute())
```

Nếu muốn tính số bài báo mà người dùng 123 đã xem trong ngày hôm nay, chúng ta sử dụng **GETBIT**, hàm này trả về giá trị (0 hoặc 1) của bit tại vị trí offset:

```python
pipe.getbit('article1:today', 123)
pipe.getbit('article2:today', 123)
pipe.getbit('article3:today', 123)
print('So bai bao nguoi dung 123 da xem ngay hom nay: ', sum(pipe.execute()))
```

Có những cách rất hiệu quả để thu lượm dữ liệu từ các bản mô tả bit. Hãy tiếp tục học cách lọc bit sử dụng bitmasks và các toán tử AND, OR, XOR.

Nếu muốn kiểm tra người dùng 123 đã đọc 2 bài báo hay chưa. Sử dụng **BITOP AND**, dễ dàng để làm việc này:

```python
pipe.setbit('user123', 123, 1)
pipe.bitop('AND', '123:sawboth', 'user123', 'article1:today', 'article3:today')
pipe.getbit('123:sawboth', 123)
print('Nguoi dung 123 da xem 2 bai bao ngay hom nay? ', bool(pipe.execute()[2]))
```

Đầu tiên chúng ta tạo 1 mặt nạ (mask) tách ra 1 người dùng cụ thể  và lưu trữ tại key 'user123', chứa một bit 1 tại vị trí offset 123 (ID của người dung). Kết quả của phép AND trên 2 hoặc nhiều bản mô tả bit không trả về như một giá trị bởi Redis mà nó được ghi vào một key được chỉ định, trong ví dụ trên là '123:sawboth'. Key này chứa mô tả bit, mô tả này trả lời các hỏi 2 key 'article1:today' và 'article3:today' có chứa bit 1 tại vị trí offset giống với bit 1 của key 'user123' không, tức là cùng có bít 1 tại vị trí 123 hay không.

Toán tử OR làm việc tốt khi tìm tổng số người dùng đã xem ít nhất 1 bài báo:

```python
pipe.bitop('OR', 'atleastonearticle', 'article1:today', 'article2:today', 'article3:today')
pipe.bitcount('atleastonearticle')
print('So nguoi xem it nhat mot bai bao hom nay: ', pipe.execute()[1])
```

Ở đây, key 'atleastonearticle' đánh dấu các bit tại các vị trí offset đã được set 1 của tất cả các bài báo. Chúng ta có thể sử dụng công nghệ này để tạo một bộ máy giới thiệu đơn giản (recommandation engine)

Ví dụ, nếu chúng ta có thể xác định qua một ý nghĩa khác, rằng 2 bài báo tương tự nhau (dựa vào tags, từ khóa..), chúng ta có thể tìm ra những người đã đọc 1 bài báo, và giới thiệu những bài khác. Để làm vậy, chúng ta sử dụng XOR để tìm ra tất cả những người dùng đã đọc bài báo đầu tiên hoặc bài báo thứ 2, nhưng chưa đọc cả 2. Như vậy chúng ta sẽ chia thành 2 danh sách: những người đã đọc bài báo số 1, những người đã đọc bài báo số 2, sau đó so sánh 2 danh sách này để đưa ra giới thiệu:

```python
pipe.bitop('XOR', 'recommendother', 'article1:today', 'article2:today')
pipe.bitop('AND', 'recommend:article1', 'recommendother', 'article2:today')
pipe.bitop('AND', 'recommend:article2', 'recommendother', 'article1:today')
pipe.bitcount('recommendother')
pipe.bitcount('recommend:article1')
pipe.bitcount('recommend:article2')
pipe.delete('recommendother', 'recommend:article1', 'recommend:article2')
result = pipe.execute()
print('So nguoi chua doc ca 2 bai bao: ', result[3])
print('So nguoi da doc bai 2, va se gioi thieu bai 1', result[4])
print('So nguoi da doc bai 1, va se gioi thieu bai 2', result[5])
```

Để tính toán tổng số byte trong giá trị nhị phân của Redis, chia offset lớn nhất cho 8. Lưu trữ dữ liệu truy cập 1 bài báo với 1.000.000 người dùng yêu cầu tối đa ~ 125kB, không phải là một bộ nhớ quá lớn cho bộ dữ liệu phân tích phong phú như vậy. Bởi vì chúng ta có thể đo lường chính xác không gian cần thiết. Nó cũng cho chúng ta sự tự tin khi lên kế hoạch lưu trữ và mở rộng.

# 3. References

[https://redislabs.com/blog/bits-and-bats/](https://redislabs.com/blog/bits-and-bats/)