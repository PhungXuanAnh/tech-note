# Các thông số hệ thống.

## 1. RAM.

- RAM ( Randon Access Memory) - Là bộ nhớ truy cập ngẫu nhiên,khác với các bộ nhớ truy cập tuần tự là CPU có thể truy cập 
vào một địa chỉ nhớ bất kỳ mà không cần phải truy cập một cách tuần tự, điều này cho phép CPU đọc và ghi vào RAM vớ tốc độ 
nhanh hơn

- RAM nhanh hơn so với ổ đĩa cứng. Thậm chí ngay cả các ổ cứng thể rắn (solid state drives) mới nhất và tốt nhất cũng có 
tốc độ thấp hơn rất nhiều so với RAM. Trong khi ổ cứng thể rắn (solid state drives) có thể đạt được tốc độ truyền tải hơn 
1000 MB/s, module RAM hiện đại vượt qua tốc độ 15000 MB/s.

- Bộ nhớ RAM là môi trường "dễ bay hơi" (tạm thời). Bất kỳ dữ liệu nào được lưu trữ trên RAM đều sẽ bị mất ngay sau khi máy 
tính của bạn tắt. RAM hoạt động như bộ nhớ ngắn hạn, trong khi ổ đĩa cứng hoạt động giống như bộ nhớ dài hạn.

- Swap : có thể được sử dụng để lưu trữ các dữ liệu mà không được sử dụng trên bộ nhớ vật lý (RAM). 
Đây là nơi tạm thời chứa các tài nguyên đang không hoạt động trong bộ nhớ.

### Cache và buffered.

- Cả Cached và Buffers đều có ý nghĩa là vùng lưu trữ tạm, nhưng mục đích sử dụng thì khác nhau
 <ul>
  <li>Mục đích của cached là tạo ra một vùng nhớ tốc độ cao nhằm tăng tốc quá trình đọc/ghi file ra đĩa. Cached được tạo từ static RAM (SRAM) 
  nên nhanh hơn dynamic RAM (DRAM) dùng để tạo ra buffers.</li>
  <li>Buffers là tạo ra 1 vùng nhớ tạm có tốc độ bình thường, mục đích để gom data hoặc giữ data để dùng cho mục đích nào đó. Buffers thường dùng cho các 
  tiến trình input/output, trong khi cached chủ yếu được dùng cho các tiến trình đọc/ghi file ra đĩa</li>
 </ul>

- Tuỳ theo công nghệ chế tạo, người ta phân biệt RAM tĩnh (SRAM: Static RAM) và RAM động (Dynamic RAM).

- RAM tĩnh được chế tạo theo công nghệ ECL (CMOS và BiCMOS). Mỗi bit nhớ gồm có các cổng logic với độ 6 transistor MOS, việc nhớ một dữ liệu là tồn tại nếu bộ
nhớ được cung cấp điện. SRAM là bộ nhớ nhanh, việc đọc không làm huỷ nội dung của ô nhớ và thời gian thâm nhập bằng chu kỳ bộ nhớ.
RAM động dùng kỹ thuật MOS. Mỗi bit nhớ gồm có một transistor và một tụ điện. Cũng như SRAM, việc nhớ một dữ liệu là tồn tại nếu bộ nhớ được cung cấp điện.
Việc ghi nhớ dựa vào việc duy trì điện tích nạp vào tụ điện và như vậy việc đọc một bit nhớ làm nội dung bit này bị huỷ.

- SRAM không cần chu kì refresh như trong bộ nhớ động cho nên SRAM được dùng để làm cache trong CPU, còn DRAM được dùng 
làm bộ nhớ RAM của hệ thống trên mainboard.

### 1 số câu lệnh trong Linux thao tác với RAM.

- Lệnh kiểm tra thông số RAM

    ```sh
    free -m
    ```

- Câu lệnh chỉ xóa cached

    ```sh
    sync; echo 1 > /proc/sys/vm/drop_caches
    ```  

- Xóa dentries và inodes.

    ```sh
    sync; echo 2 > /proc/sys/vm/drop_caches
    ```

- Xóa PageCache, dentries và inodes.

    ```sh
    sync; echo 3 > /proc/sys/vm/drop_caches
    ```

## 2. CPU.

- CPU viết tắt của chữ Central Processing Unit (tiếng Anh): 
bộ xử lý trung tâm, là các mạch điện tử trong một máy tính, thực 
hiện các câu lệnh của chương trình máy tính bằng cách thực hiện các 
phép tính số học, logic, so sánh và các hoạt động nhập/xuất dữ liệu (I/O) cơ bản do mã lệnh chỉ ra.

- CPU có nhiều kiểu dáng khác nhau. Ở hình thức đơn giản nhất, CPU là một con chip với vài chục chân. Phức tạp hơn, 
CPU được ráp sẵn trong các bộ mạch với hàng trăm con chip khác.

- CPU là một mạch xử lý dữ liệu theo chương trình được thiết lập trước. Nó là một mạch tích hợp phức tạp gồm hàng triệu transistor.


### Các thành phần .

![cpu_1](/docs/prepare/images/cpu_1.png)

CPU có 3 khối chính là : 

- Bộ điều khiển: Là các vi xử lí có nhiệm vụ thông dịch các lệnh của chương trình và điều khiển hoạt động xử lí,được điều tiết chính xác bởi xung nhịp đồng hồ hệ thống. Mạch xung nhịp đồng hồ hệ thống dùng để đồng bộ các thao tác xử lí trong và ngoài CPU theo các khoảng thời gian không đổi.Khoảng thời gian chờ giữa hai xung gọi là chu kỳ xung nhịp.Tốc độ theo đó xung nhịp hệ thống tạo ra các xung tín hiệu chuẩn thời gian gọi là tốc độ xung nhịp – tốc độ đồng hồ tính bằng triệu đơn vị mỗi giây-Mhz. Thanh ghi là phần tử nhớ tạm trong bộ vi xử lý dùng lưu dữ liệu và địa chỉ nhớ trong máy khi đang thực hiện tác vụ với chúng.

- Bộ số học-logic: Có chức năng thực hiện các lệnh của đơn vị điều khiển và xử lý tín hiệu. Theo tên gọi,đơn vị này dùng để thực hiện các phép tính số học( +,-,/ )hay các phép tính logic (so sánh lớn hơn,nhỏ hơn…)

- Các thanh ghi : Là các bộ nhớ có dung lượng nhỏ nhưng tốc độ truy cập rất cao, nằm ngay trong CPU, dùng để lưu trữ tạm thời các toán hạng, kết quả tính toán, địa chỉ các ô nhớ hoặc thông tin điều khiển. Mỗi thanh ghi có một chức năng cụ thể. Thanh ghi quan trọng nhất là bộ đếm chương trình (PC - Program Counter) chỉ đến lệnh sẽ thi hành tiếp theo.

### Các thông số khi xem CPU :

- Name: Tên của chip xử lý – vd: Core 2 Duo E6700, Core i3 320M…
- Code name: Tên của kiến trúc CPU hay còn gọi là thế hệ của CPU – vd: Wolfdale, Sandy Bridge, Ivy Bridge…
- Packpage: Là dạng socket của CPU – vd: 478, 775, 1155… thông số này rất quan trọng khi bạn có ý định nâng cấp CPU của mình.
- Core Speed: Đây là xung nhịp của chip CPU, hay thường được gọi là tốc độ của CPU
- Level 2: Thông số về bộ nhớ đệm, thông số này càng cao thì CPU càng ít bị tình trạng nghẽn dữ liệu khi xử lý (hiện tượng thắt cổ chai). Một số CPU còn có bộ nhớ Level 3… số level càng lớn, kèm theo dùng lượng càng cao, cpu của bạn chạy càng nhanh.
- Cores và Threads: đây là số nhân và số luồng của CPU. Số này thường là số chẵn và còn được biết đến với cách gọi kiểu như: CPU 2 nhân, CPU 4 nhân, CPU 6 nhân…

### Cache trong CPU.

Việc dùng cache trong có thể làm cho sự cách biệt giữa kích thước và thời gian
thâm nhập giữa cache trong và bộ nhớ trong càng lớn. Người ta đưa vào nhiều mức
cache:

- Cache mức một (L1 cache): thường là cache trong (on-chip cache; nằm bên
trong CPU)

- Cache mức hai (L2 cache) thường là cache ngoài (off-chip cache; cache
này nằm bên ngoài CPU).

- Ngoài ra, trong một số hệ thống (PowerPC G4, IBM S/390 G4, Itanium
của Intel) còn có tổ chức cache mức ba (L3 cache), đây là mức cache trung gian giữa
cache L2 và một thẻ bộ nhớ.

### 1 số câu lệnh thao tác với CPU :

- kiểm tra các thông số CPU :

    ```sh
    cat /proc/cpuinfo
    ```

- Kiểm tra tiến trình đang chiếm dụng (Phải cài đặt sysStat `yum install sysStat -y`) :

```sh
sar -u 3 10

# Trong đó 3 là số lần cách nhau kiểm tra, 10 là số lần kiểm tra.
```

- Khi kiểm tra có 1 số thông số chúng ta cần chú ý :

    ```sh
    %user : đây là lượng chiếm dụng CPU khi một user khởi tạo tiến trình
    %nice: đây là lượng chiếm dụng CPU khi tiến trình được tạo bởi user với độ ưu tiên là nice.
    %system: đây là lượng chiếm dụng CPU khi tiến trình được tạo ra bởi kernel (hệ thống).
    %iowait: đây là lượng chiếm dụng CPU khi cpu đang trong trạng thái idle ở thời điểm phát sinh I/O request.
    %idle: : đây là lượng chiếm dụng CPU khi cpu đang trong trạng thái idle ở thời điểm không có I/O request.
    ```

# Tham Khảo :

- https://github.com/meditechopen/meditech-thuctap/blob/master/HaiVD/Monitor/Cacthongsokythuat.md

- https://github.com/nguyenminh12051997/meditech-thuctap/blob/master/MinhNV/Nagios/docs/l%C3%BD%20thuy%E1%BA%BFt/Ki%E1%BB%83m%20tra%20th%C3%B4ng%20s%E1%BB%91/c%C3%A2u%20l%E1%BB%87nh%20ki%E1%BB%83m%20tra%20th%C3%B4ng%20s%E1%BB%91.md