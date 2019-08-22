Redis - Lua Scripting
---
- [1. Redis cho phép làm gì với lua](#1-redis-cho-phép-làm-gì-với-lua)
- [2. Keys and arguments](#2-keys-and-arguments)
- [3. Call redis trong lua script](#3-call-redis-trong-lua-script)
- [4. What can I do with lua?](#4-what-can-i-do-with-lua)
- [5. Upload lua script](#5-upload-lua-script)
- [6. Time limmited](#6-time-limmited)
- [7. Lua library](#7-lua-library)
- [8. Check lua version](#8-check-lua-version)
- [9. Example](#9-example)
  - [9.1. Embed third-party lua library into Redis](#91-embed-third-party-lua-library-into-redis)
  - [9.2. Thêm hàm Lua vào Redis](#92-thêm-hàm-lua-vào-redis)
  - [9.3. Thêm bitwise operations](#93-thêm-bitwise-operations)
- [10. Reference](#10-reference)

# 1. Redis cho phép làm gì với lua

Nó cho phép tạo script mở rộng đến Redis database. Nghĩa là với Redis bạn có thể chạy Lua script như sau:

```shell
> EVAL 'local val="Hello Compose" return val' 0
"Hello Compose"
```

String phía sau **eval** là lua script:

```lua
local val="Hello Compose"  
return val 
```

Lua script có thể được thực hiện như một giao dịch thông minh. Bạn có thể điều khiển lỗi nhanh, vì vậy thay vì quay lại, bạn có thể tiếp tục xử lý. Tất nhiên sự thông minh của phiên giao dịch phụ thuộc vào bạn.

# 2. Keys and arguments

Số 0 ở cuối lệnh **eval**, là số lượng key được truyền vào lua script, trong ví dụ trên là 0. Nếu thay là `2 foo bar fizz buzz` thì foo và bar sẽ được truyền như các **KEYS**, còn fizz và buzz sẽ được truyền như **ARGV**

Nếu truyền các keys, chúng sẽ có trong lua script trong bảng **KEYS** ( một bảng là một mảng liên kết của lua, được sử dụng như mảng 1 chiều). Nếu truyền các arguments, chúng lưu trong bảng **ARGV**. Ví dụ:

```lua
return ARGV[1]..' '..KEYS[1] 
```

Ký tự .. là toán tử  nối string của lua. Nó sẽ trả về chuỗi ký tự nối từ các key và argument truyền vào, như bên dưới:

```shell
> EVAL "return ARGV[1]..' '..KEYS[1]" 1 name:first "Hello"
"Hello name:first"
```

# 3. Call redis trong lua script

Bạn có thể gọi các hàm của Redis bằng lệnh `redis.call()` bên trong lua scrip:

```lua
return ARGV[1].." "..redis.call("get",KEYS[1])  
```

hoặc trong lệnh eval:

```shell
> EVAL 'return ARGV[1].." "..redis.call("get",KEYS[1])' 1 name:first "Hello"
"Hello Brian"
```

**Chú ý:** Nếu bạn nhận được thông báo `attempt to concatenate a boolean value`, nghĩa là key `name:first` chưa được set giá trị.

# 4. What can I do with lua?

Xem sét tình huống các bộ phận khác nhau của công ty gia tăng số lượng quầy hàng. Ví dụ, `region:one` có các quầy key  `count:emea`, `count:usa`, `count:atlantic`, trong khi đó `region:two` có quầy key `count:usa`. Danh sách các quầy có thể thêm trong tương lai, nhưng bạn thực sự muốn chắc chắn nó xảy ra trong một lần giảm. Bây giờ chúng ta hãy thưc hiện một phiên giao dịch thông minh.

Hãy thiết lập các khu vực như một danh sách:

```shell
> rpush region:one count:emea count:usa count:atlantic
(integer) 3
> rpush region:two "count:usa"
(integer) 1
```

Tạo lua script:

```lua
local count=0  
```

Khai báo biến count, đếm sự gia tăng và trả về giá trị

```lua
local broadcast=redis.call("lrange", KEYS[1], 0,-1)  
```

Gọi lệnh redis, lấy tất cả các giá trị trong danh sách được tham chiếu trong key đầu

```lua
for _,key in ipairs(broadcast) do  
```

Bắt đầu vòng lặp trong lua. hàm `ipairs` liệt kê qua bảng lua mà chúng ta có theo tứ tự, lấy ra giá trị key từ mỗi bảng.

```lua
  redis.call("INCR",key)
  count=count+1
```

Với mỗi key chúng ta yêu cầu redis tăng lên 1 sau đó tăng biến count lên 1

```lua
end  
return count  
```

Kết thúc vòng for và trả về count. 

Lưu tất cả nội dung trên vào 1 file và chạy với 1 argument

```shell
$ redis-cli --eval broadcast.lua region:one
(integer) 3
```

Kết quả:

```shell
> mget count:usa count:atlantic count:emea
1) "1"  
2) "1"  
3) "1"
```

Sử dụng script trên khu vực 2 ( region 2):

```shell
 $ redis-cli --eval broadcast.lua region:two
(integer) 1
...
> mget count:usa count:atlantic count:emea
1) "2"  
2) "1"  
3) "1"  
```

Chúng ta đã làm xong một hàm chức năng nho nhỏ. Nếu có lỗi thì sao, nó sẽ bắn ra lỗi khi dùng với `redis.call()`. Nếu sử dụng `redis.pcall()` chi tiết của lỗi sẽ được trả về  và chúng ta có thể quyết định sẽ làm gì

# 5. Upload lua script

Redis có script cache và một lệnh **SCRIPT LOAD** để load script vào cache:

```shell
$ redis-cli SCRIPT LOAD "$(cat broadcast.lua)"
"84ffc8b6e4b45af697cfc5cd83894417b7946cc1"
```

Kết quả trả về là 1 chuỗi hex. Đó là chữ ký SHA1 của script. Chúng ta có thể  sử dụng chuỗi này để gọi script bằng lệnh: 

```shell
> EVALSHA 84ffc8b6e4b45af697cfc5cd83894417b7946cc1 1 region:one
(integer) 3
```

# 6. Time limmited

Trong một khoảng thời gian giới hạng (mặc định là 5s), lua script sẽ bị lỗi, một lỗi sẽ được ghi vào log, các lệnh duy nhất còn lại là kill the script (KILL SCRIPT) hoặc shutdown server (SHUTDOWN NOSAVE) trong tình huống này. Giới hạn 5s là rất hào phóng, vì chúng ta viết lua script thường chạy rất nhanh ở mini giậy. Tạo sao có giới hạn này? Bởi vì, trong khi script chạy, mọi thứ khác sẽ  bị giữ.

# 7. Lua library

Lua có rất nhiều thư viện, nhưng chúng ta không thể sử dụng tất cả chúng. Xem chi tiết tại [đây](https://redis.io/commands/eval#available-libraries)

# 8. Check lua version

```shell
eval 'return _VERSION' 0
```

# 9. Example

Điều đưa tôi đến với Lua trong Redis là khả năng cung cấp các hoạt động nguyên tử phức tạp. Xem xét hoạt động nhân một sô - không thực sự phức tạp, nhưng một điểm khởi đầu tốt. Redis cung cấp lệnh để lấy 1 số, ghi 1 số hoặc tăng giá trị 1 số, nhưng không có phép nhân, vì vậy phép nhân trở thành 1 hoạt động 3 bước: đọc số từ Redis, thực hiện nhân tại phía client, sau đó ghi giá trị trở lại Redis. Nhưng điều gì xảy ra khi 2 client thực hiện điều này đông thời.

- Client A đọc số 3, với ý định nhân với 2
- Client B cũng đọc số 3, với cùng ý định trên
- Client A đã đọc giá trị, tại client, nhân với 2 được 6, giá trị này sẽ được ghi trở lại Redis
- Client B làm tương tự, ghi giá trị 6

Điều gì xảy ra với thực tế là client A đã thực hiện phép tính nhân. Nó luôn thất bại. Cái chúng ta cần là 1 cách mà tất cả các bước trong hoạt động nhân được thực hiện một cách nguyên tử (atomically), điều này dẫn đến kết quả được lưu trữ cuối cùng là 12, theo như ví dụ trên. Redis là đơn luồng, vì vậy tất cả các lệnh nó cung cấp mặc định là nguyên tử (atomic). Rất nhiều lệnh giải quyết chính xác theo kiểu kịch bản kiểm tra và thiết lập (check and set) được mô tả trong ví dụ về phép nhân ở trên, ví dụ như ghi ghi một giá trị mới vào trường hash nếu chúng chưa tồn tại, tăng một cách nguyên tử giá trị nguyên.

Trong dự án hiện tại của tôi có hàng tá các kiểu hoạt động khác nhau như hoạt động nhân phía trên, mà chúng yêu cầu nguyên tử hóa, và rơi ngoài phạm vi của bất cứ lệnh nào cung cấp bởi Redis. Redis cung cấp một vài hỗ trợ cho các hoạt động nguyên tử tùy chỉnh vơi lệnh [MULTI](http://redis.io/commands/multi) và [WATCH](http://redis.io/commands/watch), tuy nhiên MULTI  chỉ hữu ích khi mỗi bước trong kịch bản hoạt động không phụ thuộc lẫn nhau và WATCH thì theo ý kiến của tôi không phải là 1 API quá trực quan. Redis lua giúp vượt qua các giới hạn của việc thực thi các hoạt động nguyên tử.

## 9.1. Embed third-party lua library into Redis

Trong phần tiếp theo của bài post này bạn sẽ biết làm thế nào để nhúng bất kỳ thư viện Lua của bên thứ 3 nào đó vào Redis, đây là một trường hợp đặc biệt, cung cấp các hoạt động bitwise đến bất kỳ các hoạt động Redis nguyên tử nào được ghi trong Lua.

## 9.2. Thêm hàm Lua vào Redis

Tạo file **atoms.lua**, định nghĩa hàm **list_pop** thực hiện lấy ra 1 item từ 1 Redis list, trả về chỉ số của item, 1 hoạt động mà Redis không cung cấp trong tập lệnh của nó.

```lua
function list_pop()
    local l = redis.call('LRANGE', KEYS[1], 0, -1)
    local i = tonumber(ARGV[1]) + 1
    local v = table.remove(l, i)
    redis.call('DEL', KEYS[1])
    redis.call('RPUSH', KEYS[1], unpack(l))
    return v
end
```

Bây giờ, trong python, mở rộng redis-py để hỗ trợ tải hàm lua lên Redis, sau đó goi trực tiếp hàm này trong python theo tên.

```python
import redis

class LuaRedisClient(redis.Redis):

    def __init__(self, *args, **kwargs):
        super(LuaRedisClient, self).__init__(*args, **kwargs)
        for name, snippet in self._get_lua_funcs():
            self._create_lua_method(name, snippet)

    def _get_lua_funcs(self):
        """
        Returns the name / code snippet pair for each Lua function
        in the atoms.lua file.
        """
        with open("atoms.lua", "r") as f:
            for func in f.read().strip().split("function "):
                if func:
                    bits = func.split("\n", 1)
                    name = bits[0].split("(")[0].strip()
                    snippet = bits[1].rsplit("end", 1)[0].strip()
                    yield name, snippet

    def _create_lua_method(self, name, snippet):
        """
        Registers the code snippet as a Lua script, and binds the
        script to the client as a method that can be called with
        the same signature as regular client methods, eg with a
        single key arg.
        """
        script = self.register_script(snippet)
        method = lambda key, *a, **k: script(keys=[key], args=a, **k)
        setattr(self, name, method)
```

function **_get_lua_funcs** tách tên hàm và nội dung hàm trong lua script, sau đó trả về theo cặp tên hàm/nội dung hàm

function **_create_lua_method** đăng ký nội dung hàm với Redis server, sau đó thêm tên hàm thành một thuộc tính của **LuaRedisClient**

Bây giờ chúng ta có thể gọi nguyên tử hàm lua **list_pop** từ Python client:

```shell
>>> client = LuaRedisClient()
>>> client.rpush("key", "foo", "bar", "baz")
>>> client.list_pop("key", 1)
'bar'
```

## 9.3. Thêm bitwise operations

Redis chỉ hỗ trợ Lua vesion 5.1 (check bằng lệnh bên trên), version này không chứa bitwise operator, tuy nhiên chúng có trong thirt-party library. 1 thư viện tôi chọn là [Luabit](http://luaforge.net/projects/bit/), điều quan trọng cần lưu ý để phương pháp này hoạt động là bất kỳ thư viện lua nào chúng ta dùng cũng phải được viết hoàn toàn bằng Lua, không phải C. May mắn là Luabit thỏa mãn điều kiện đó.

Tải file [luabit-0.4.zip](http://files.luaforge.net/releases/bit/bit/luabitv0.4/luabit-0.4.zip), giải nén và copy file **bit.lua** vào thư mục project

Bây giờ, chúng ta lại coi Lua script trong Redis đơn giản là những chuỗi code dài, giải pháp để nhúng thư viện LuaBit là rõ ràng: chúng ta đơn giản là chỉnh sửa class mở rộng Redis client để tiêm các phần của thư viện chúng ta cần vào mỗi Redis script yêu cầu nó:

```python
import redis

class LuaRedisClient(redis.Redis):

    def __init__(self, *args, **kwargs):
        super(LuaRedisClient, self).__init__(*args, **kwargs)
        requires_luabit = ("number_and", "number_or", "number_xor",
                           "number_lshift", "number_rshift")
        with open("bit.lua", "r") as f:
            luabit = f.read()
        for name, snippet in self._get_lua_funcs():
            if name in requires_luabit:
                snippet = luabit + snippet
            self._create_lua_method(name, snippet)

    def _get_lua_funcs(self):
        """
        Returns the name / code snippet pair for each Lua function
        in the atoms.lua file.
        """
        with open("atoms.lua", "r") as f:
            for func in f.read().strip().split("function "):
                if func:
                    bits = func.split("\n", 1)
                    name = bits[0].split("(")[0].strip()
                    snippet = bits[1].rsplit("end", 1)[0].strip()
                    yield name, snippet

    def _create_lua_method(self, name, snippet):
        """
        Registers the code snippet as a Lua script, and binds the
        script to the client as a method that can be called with
        the same signature as regular client methods, eg with a
        single key arg.
        """
        script = self.register_script(snippet)
        method = lambda key, *a, **k: script(keys=[key], args=a, **k)
        setattr(self, name, method)
```        

Tôi đã định nghĩa danh sách tên các hàm tham chiếu đến LuaBit, trong biến **requires_luabit**. Khi các hàm này được đăng ký trong Redis, mã nguồn của LuaBit được tiêm vào Redis.

Một yêu cầu cuối cùng là sửa đổi các chữ ký hàm bên trong LuaBit. Lua script trong Redis bị giới hạn trong các câu lệnh hàm, nhưng chúng ta có thể giải quyết vấn đề này bằng cách chuyển đổi bất kỳ hàm nào sang định nghĩa hàm ẩn danh.

```lua
-- Original function statement
local function bit_and(m, n)
    ...
end

-- Converted to an anonymous function
local bit_and = function(m, n)
    ...
end
```

Thế thôi, khá là đơn giản. Để mở rộng phương pháp này hơn nữa sử dụng [directed graph](http://blog.jupo.org/2012/04/06/topological-sorting-acyclic-directed-graphs/) sẽ không đòi hỏi nhiều công việc hơn, và sẽ cho phép nhiều sự kế thừa phụ thuộc phức tạp.

# 10. Reference

[https://www.redisgreen.net/blog/intro-to-lua-for-redis-programmers/](https://www.redisgreen.net/blog/intro-to-lua-for-redis-programmers/)
[http://blog.jupo.org/2013/06/12/bitwise-lua-operations-in-redis/](http://blog.jupo.org/2013/06/12/bitwise-lua-operations-in-redis/)

