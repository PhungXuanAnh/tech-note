RabbitMQ Best Practice for High Performance (High Throughput) part 2
---
- [1. Chắc chắn các hàng đợi ngắn](#1-chắc-chắn-các-hàng-đợi-ngắn)
- [2. Đặt độ dài tối đa của hàng đợi nếu cần](#2-Đặt-độ-dài-tối-đa-của-hàng-đợi-nếu-cần)
- [3. Gỡ bỏ policy cho lazy queues](#3-gỡ-bỏ-policy-cho-lazy-queues)
- [4. Sử dụng thông điệp chuyển tiếp (transit message)](#4-sử-dụng-thông-điệp-chuyển-tiếp-transit-message)
- [5. Sử dụng nhiều queue và consumer](#5-sử-dụng-nhiều-queue-và-consumer)
- [6. Chia các queue trên các core khác nhau](#6-chia-các-queue-trên-các-core-khác-nhau)
- [7. Vô hiệu hóa manual ack và publish confirm](#7-vô-hiệu-hóa-manual-ack-và-publish-confirm)
- [8. Tránh có nhiều node (HA)](#8-tránh-có-nhiều-node-ha)
- [9. Cho phép Rabbitmq HiPE (đây là một thực nghiệm)](#9-cho-phép-rabbitmq-hipe-đây-là-một-thực-nghiệm)
- [10. Vô hiệu hóa plugin không sử dụng](#10-vô-hiệu-hóa-plugin-không-sử-dụng)
- [11. Tham khảo](#11-tham-khảo)

Trong phần 2 của **RabbitMQ Best Practice** là lời khuyên về các cài đặt và tùy chọn cấu hình giúp tối đã lưu lượng message qua hệ thống. Chúng ta sẽ đề cập đến các cài đặt chuẩn, các thay đổi và các plugin có thể được sử dụng dụng để nhận được lưu lượng tốt hơn.

# 1. Chắc chắn các hàng đợi ngắn

Để có hiệu suất tối ưu chắc chắn hàng đợi ngắn nhất có thể ở tất cả các thời điểm. Hàng đợi dài hơn áp đặt nhiều chi phí xử lý hơn. Chúng tôi đề nghị là các hàng đợi luôn xoay quanh 0 để tối ưu hóa hiệu suất.

# 2. Đặt độ dài tối đa của hàng đợi nếu cần

Một tính năng có thể được đề xuất cho các ứng dụng thường bị ảnh hưởng bởi các thông điệp đột biến, là đặt độ dài tối đa trên hàng đợi. Nó sẽ giữ hàng đợi ngắn bằng cách loại bỏ các message từ đầu hàng đợi vì thế nó sẽ không bao giờ lớn hơn độ dài tối đa cài đặt

# 3. Gỡ bỏ policy cho lazy queues

CloudAMQP mặc định cho phép lazy queues. Lazy queues là các hàng đợi mà các message tự động lưu trữ vào disk. Message chỉ được tải vào memory khi cần. Với lazy queue, thì message đến thẳng disk và do đó sử dụng Ram là tối thiểu, nhưng thời gian throughput sẽ lớn hơn.

# 4. Sử dụng thông điệp chuyển tiếp (transit message)

Persistent message được ghi vào disk ngay khi tới queue, điều này sẽ ảnh hưởng tới throughput. Sử dụng transit message cho throughput nhanh nhất.

# 5. Sử dụng nhiều queue và consumer

Queue là các luồng đơn trong RabbitMQ, một queue có thể xử lý lên đến 50k message/s. Throughput sẽ tốt hơn trên hệ thống multi-core nếu có nhiều queue và consumer. Throughput sẽ tối ưu nếu có nhiều queue như các core trên các node bên dưới.

Giao diện quản lý Rabbitmq sẽ giữ thông tin về tất cả queue và nó có thể làm chậm server. CPU và Ram sử dụng có thể ảnh hưởng tiêu cực nếu có quá nhiều queue (nhiều ở đây là hàng hàng queue). Giao diện quản lý Rabbitmq thu thập và tính toán số liệu cho mỗi queue sử dụng một số tài nguyên và CPU và tranh chấp disk có thể xảy ra nếu có hàng nghìn, hàng nghìn queue và consumer đang hoạt động.

# 6. Chia các queue trên các core khác nhau

Hiệu suất hàng đợi bị giói hạn trong 1 CPU core. Sẽ có được hiệu suất tốt hơn nếu chia các queue trong các core khác nhau, và cũng trong các node khác nhau nếu có một cụm Rabbitmq. Hàng đợi Rabbitmq được gắn với node mà chúng được khai báo. Thậm chí nếu bạn khai báo 1 cụm rabbitmq, tất cả các message gửi đến 1 queue cụ thể sẽ đến node mà queue đó sống. Có thể chia thủ công các queue thậm chí giữa các node, nhưng nhược điểm là bạn cần nhớ vị trí queue ở đâu.

Chúng tôi khuyên dùng 2 plugin nếu có nhiêu node hoạc một cụm node đơn với nhiều core.

**Consistent hash exchange plugin** xem trong phần tham khảo

**RabbitMQ sharding** xem trong phần tham khảo

# 7. Vô hiệu hóa manual ack và publish confirm

Ack và publish confirm ảnh hưởng đến hiệu suất, để có throughput nhanh hơn, manual ack nên bị vô hiệu hóa.

# 8. Tránh có nhiều node (HA)

Một node sẽ có throughput cao nhất, so với HA cluster. Message và queue không được phản chiếu đến node khác.

# 9. Cho phép Rabbitmq HiPE (đây là một thực nghiệm)

Xem trong tham khảo

# 10. Vô hiệu hóa plugin không sử dụng

Có thể kích hoạt nhiều plugin khác nhau qua thanh điều khiển trong CloudAMQP. Một vài plugin có thể cần quyền super, nhưng mặt khác nó có thể tiêu tốn nhiều. Vì thế nó không được khuyến khích cho production server. Chắc chắn vô hiệu hóa plugin không sử dụng.

# 11. Tham khảo

[part2-rabbitmq-best-practice-for-high-performance](https://www.cloudamqp.com/blog/2018-01-08-part2-rabbitmq-best-practice-for-high-performance.html)
