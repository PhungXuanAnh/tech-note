- [1. Architechture](#1-architechture)
- [2. Cách hoạt động](#2-cách-hoạt-động)
- [3. Thuật ngữ](#3-thuật-ngữ)
- [4. Reference](#4-reference)

# 1. Architechture

![img1](../../images/devops/monitor/prometheus-1.png)

- **Prometheus server**: pull data từ Prometheus targets và lưu dữ liệu xuống local Storage
- **Pushgateway**: làm điểm trung gian nhận *push metrics* từ các tác vụ xử lý không yêu cầu real-time monitoring (Như xử lý dữ liệu offline, các task backup…). Sử dụng để hỗ trợ các job có thời gian thực hiện ngắn (tạm thời). Đơn giản là các tác vụ công việc này không tồn tại lâu đủ để **Prometheus** chủ động lấy dữ liệu. Vì vậy là mà các dữ liệu chỉ số (metric) sẽ được đẩy về Push Gateway rồi đẩy về Prometheus Server.
- **Alertmanager**: quản lý alert và gởi alert tới các kênh thông tin như slack, chat, email
- **Grafana**: vẽ đồ thị và quản lý dashboard, kết nối với Prometheus bằng PromQL thông qua API.
- **Service discovery**: Prometheus mặc định hỗ trợ khá nhiều loại service discovery như: k8s, marathon, EC2, GCE, DNS, Consul, Openstack… Bạn có thể tự viết 1 module service discovery để tích hợp vào Prometheus.
- **Jobs/exporters**: client trên các server để expose các metrics, sau đó Prometheus sẽ scrape các thông tin này định kỳ (mặc định là 15s/lần). List các exporter hiện đang có sẵn: [link](https://prometheus.io/docs/instrumenting/exporters/). Nhưng bạn cũng có thể tự viết exporter của riêng mình.


# 2. Cách hoạt động 

Nói sơ về cách thức hoạt động của Prometheus:

- **Scrape endpoints**: đọc data từ endpoints. Prometheus sẽ đọc data từ các endpoints được monitor dưới dạng *pull-mode*, khác với **Zabbix** hoặc **InfluxDB** hoạt động theo dạng *push-mode*
- **Store metrics data**: data được lưu dưới dạng time series vào TSDB (time series database)
- **API**: Cho phép truy xuất dữ liệu monitor qua API
- **Alerting**: Check alert rule định kỳ và gởi alert

# 3. Thuật ngữ

- **Time-series Data**: là một chuỗi các điểm dữ liệu, thường bao gồm các phép đo liên tiếp được thực hiện từ cùng một nguồn trong một khoảng thời gian.
- **Client Library**: một số thư viện hỗ trợ người dùng có thể tự tuỳ chỉnh lập trình phương thức riêng để lấy dữ liệu từ hệ thống và đẩy dữ liệu metric về **Prometheus**.
- **Endpoint**: nguồn dữ liệu của các chỉ số (metric) mà **Prometheus** sẽ đi lấy thông tin.
- **Instance**: một instance là một nhãn (label) dùng để định danh duy nhất cho một target trong một job .
- **Job**: là một tập hợp các target chung một nhóm mục đích. Ví dụ: giám sát một nhóm các dịch vụ database,… thì ta gọi đó là một job .
- **PromQL**: promql là viết tắt của Prometheus Query Language, ngôn ngữ này cho phép bạn thực hiện các hoạt động liên quan đến dữ liệu metric.
- **Sample**: sample là một giá trị đơn lẻ tại một thời điểm thời gian trong khoảng thời gian time series.
- **Target**: một target là định nghĩa một đối tượng sẽ được Prometheus đi lấy dữ liệu (scrape). Ví dụ như: nhãn nào sẽ được sử dụng cho đối tượng, hình thức chứng thực nào sử dụng hoặc các thông tin cần thiết để quá trình đi lấy dữ liệu ở đối tượng được diễn ra.

# 4. Reference

https://cloudcraft.info/prometheus-at-scale-tong-quan-ve-prometheus/
https://cuongquach.com/prometheus-la-gi-tong-quan-prometheus.html
