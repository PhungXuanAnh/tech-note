- [1. Add dashboard](#1-add-dashboard)
- [2. Alert](#2-alert)
  - [2.1. Tạo notification channels](#21-tạo-notification-channels)
    - [2.1.1. Gmail](#211-gmail)
    - [2.1.2. Slack](#212-slack)
      - [2.1.2.1. Tạo webhook url từ app riêng](#2121-tạo-webhook-url-từ-app-riêng)
      - [2.1.2.2. Tạo webhook url bằng app incoming webhooks](#2122-tạo-webhook-url-bằng-app-incoming-webhooks)
      - [2.1.2.3. Thêm screenshots của alert vào slack message](#2123-thêm-screenshots-của-alert-vào-slack-message)
  - [2.2. Cấu hình alert trên các pannel](#22-cấu-hình-alert-trên-các-pannel)
  - [2.3. Test sử dụng stress test](#23-test-sử-dụng-stress-test)
  - [2.4. Ví dụ](#24-ví-dụ)
    - [2.4.1. Alert docker](#241-alert-docker)
    - [2.4.2. Alert CPU](#242-alert-cpu)
    - [2.4.3. Alert mysql](#243-alert-mysql)
      - [2.4.3.1. Command để check influxdb](#2431-command-để-check-influxdb)
  - [2.5. References](#25-references)


# 1. Add dashboard

Telegraf metrics [https://grafana.com/dashboards/61](https://grafana.com/dashboards/61)

Docker Metrics per container [https://grafana.com/dashboards/3056](https://grafana.com/dashboards/3056)

InfluxDB Docker [https://grafana.com/dashboards/1150](https://grafana.com/dashboards/1150)

# 2. Alert

- Tính năng cảnh báo của Grafana cũng là một tính năng mà mình cực thích. Nó hơn Graphite ở chỗ có thể thực hiện cấu hình bằng giao diện và hỗ trợ cảnh báo của gmail. Lưu ý, tính năng cảnh báo sẵn có từ phiên bản 4.0 của Grafana.

- Cảnh báo trong Grafana cho phép gán các rule ngay trong dashboard panel. Khi lưu lại cấu hình dashboard, Grafana sẽ trích xuất các quy tắc cảnh báo thành một lưu trữ cảnh báo tách biệt và lên lịch cho chúng để đánh giá. Tuy nhiên, hiện tại Grafana chỉ hỗ trợ một số Data source: Graphite, Promethus, InfluxDB, OpenTSDB, MySQL, Postgres và Cloudwatch.


## 2.1. Tạo notification channels

Bên thanh menu chọn bên trái màn hình, click vào biểu tưởng Alert để cấu hình xử lý gửi cảnh báo qua các kênh khi có cảnh báo xảy ra:

![](../../images/devops/grafana/2018-08-21-grafana-01.png)


![](../../images/devops/grafana/2018-08-21-grafana-02.png)


### 2.1.1. Gmail

Để thực hiện gửi được cảnh báo qua gmail, cần cấu hình thông tin SMTP server của gmail trong file cấu hình grafana: `/etc/grafana/grafana.ini` như sau:

![](../../images/devops/grafana/2018-08-21-grafana-04.png)

(email nhập ở đây sử dụng để làm email gửi đi cảnh báo, điền password thích hợp email của bạn)

hoặc nếu dùng docker thì set các biến môi trường như sau:

```yml
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=password-access-to-grafana # mật khẩu truy cập grafana page
      - GF_SERVER_ROOT_URL=http://grafana-server:3000         # url đến grafana page
      - GF_SMTP_ENABLED=true
      - GF_SMTP_HOST=smpt:gmail.com:587                       # mail server sẽ gửi email, ở đây là server gmail
      # - GF_SMTP_HOST=mail.sigma-solutions.eu:587            # hoặc server của công ty sigma
      - GF_SMTP_USER=grafana-alert@gmail.com                  # email dùng để gửi
      - GF_SMTP_PASSWORD=password                             # password của email trên
      - GF_SMTP_SKIP_VERIFY=true
      - GF_SMTP_FROM_ADDRESS=grafana-alert@gmail.com          # địa chỉ email gửi, trùng với email trên
      - GF_SMTP_FROM_NAME=Grafana
```

Quay lại phần setup alert

![](../../images/devops/grafana/2018-08-21-grafana-03.png)

Click Send Test để kiểm tra cài đặt có đúng không.
Click Save để lưu lại cấu hình.


### 2.1.2. Slack

![](../../images/devops/grafana/2018-08-21-grafana-05.png)

Slack setting:

- Url: slack webhook url 
- Recipient: thay thế channel hoặc user mặc định, sử dụng #channel-name hoặc @username
- Metion: tag tên người gửi, ví dụ @xuananh
- Token: cung cấp tooken của bot upload API

Bấm **Send Test** để kiểm tra
Bấm **Save để lưu**

#### 2.1.2.1. Tạo webhook url từ app riêng

Khi bạn có tài khoản premium của slack, và có quyền tạo được nhiều app trong slack, với tài khoản free thì chỉ tạo được khoảng 5 apps (đoán thế, không nhớ lắm)

Để tạo webhook url truy cập: https://api.slack.com/incoming-webhooks

Click **Create your slack app**:

![](../../images/devops/grafana/2018-08-21-grafana-06.png)

Điền các thông tin như bên dưới và chọn **Create App**
![](../../images/devops/grafana/2018-08-21-grafana-07.png)

Nó sẽ chuyển sang trang kế tiếp, chọn **Incoming Webhooks**
![](../../images/devops/grafana/2018-08-21-grafana-08.png)

Turn on webhooks

![](../../images/devops/grafana/2018-08-21-grafana-09.png)

Kéo xuống dưới chọn **Add New Webhook to Workspace**

![](../../images/devops/grafana/2018-08-21-grafana-10.png)

Chọn channel và bấm Authorize

![](../../images/devops/grafana/2018-08-21-grafana-11.png)

Copy Webhook URL và điền vào bảng alert channel của grafana

![](../../images/devops/grafana/2018-08-21-grafana-12.png)

#### 2.1.2.2. Tạo webhook url bằng app incoming webhooks

Khi bạn không có xiền để mua tài khoản permium, slack có 1 app tên là incoming webhooks
có thể tạo nhiều webhook cho nhiều slack channel tại đây

Truy cập [https://sigma-solutions.slack.com/apps](https://sigma-solutions.slack.com/apps)

Điền **incoming webhooks** vào mục search: 

![](../../images/devops/grafana/2018-08-21-grafana-20.png)

Click vào tên app hiện ra, bạn có thể thấy các webhook đã thêm trước đó bên dưới, chọn **Add Configuration**

![](../../images/devops/grafana/2018-08-21-grafana-21.png)

Chọn channel rồi bấm **Add Incoming Webhooks integrations**

![](../../images/devops/grafana/2018-08-21-grafana-22.png)

Copy **Webhook URL** điền vào alert config của grafana

![](../../images/devops/grafana/2018-08-21-grafana-23.png)
or
![](../../images/devops/grafana/2018-08-21-grafana-23.1.png)

#### 2.1.2.3. Thêm screenshots của alert vào slack message

Thêm images của alert vào tin nhắn slack, tham khảo link: http://docs.grafana.org/alerting/notifications/#slack


## 2.2. Cấu hình alert trên các pannel

Kích vào 1 pannel muốn alert, chọn edit

![](../../images/devops/grafana/2018-08-21-grafana-30.png)

Tab Metrics, thêm query metric muốn theo dõi và alert, 

**Chú ý:** Không dùng các biến template trong query sử dụng cho alert, ví dụ không dùng $server$ , $host$ , ..., nếu không sẽ bị lỗi **Template variables are not supported in alert queries**, tham khảo [cách thêm query](http://docs.grafana.org/features/datasources/influxdb/#query-editor), để test query mới, tắt các query cũ đi bằng cách kích vào biểu tượng con mắt phía bên phải, theo dõi kết quả biểu đồ phía trên.

![](../../images/devops/grafana/2018-08-21-grafana-35.png)

Tab Alert:

![](../../images/devops/grafana/2018-08-21-grafana-31.png)

chọn Create Alert:

![](../../images/devops/grafana/2018-08-21-grafana-36.png)

Click Test Rule để kiểm tra
![](../../images/devops/grafana/2018-08-21-grafana-37.png)

Ví dụ: Tạo cảnh báo khi phát hiện thấy ngưỡng cpu-idle giảm xuống dưới 20%:

![](../../images/devops/grafana/2018-08-21-grafana-32.png)

Giao diện panel sẽ xuất hiện thêm dòng cảnh báo màu hồng icon trái tim. Có thể kéo chuột để thay đổi giá trị cảnh báo.

Cấu hình lựa chọn kênh gửi cảnh báo. Click tab Notification:

![](../../images/devops/grafana/2018-08-21-grafana-33.png)

Click vào Save lại dashboard.

## 2.3. Test sử dụng stress test

```shell
sudo apt-get install stress
#su dung:
stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s
stress --cpu 16 --io 4 --vm 2 --vm-bytes 1024M
stress --help
```

Thực hiện đẩy CPU với lệnh `stress` (xem bên dưới) để giảm cpu-idle.

Alert slack:

![](../../images/devops/grafana/2018-08-21-grafana-34.1.png)

Alert mail:

![](../../images/devops/grafana/2018-08-21-grafana-34.png)

## 2.4. Ví dụ

### 2.4.1. Alert docker

Cấu hình query

![](../../images/devops/grafana/2018-08-21-grafana-38.png)

Cấu hình alert

![](../../images/devops/grafana/2018-08-21-grafana-39.png)

### 2.4.2. Alert CPU

Cấu hình query

![](../../images/devops/grafana/2018-08-21-grafana-40.png)

Cấu hình alert

![](../../images/devops/grafana/2018-08-21-grafana-41.png)

### 2.4.3. Alert mysql

Cấu hình query

![](../../images/devops/grafana/2018-08-21-grafana-42.png)

Cấu hình alert

![](../../images/devops/grafana/2018-08-21-grafana-43.png)

Test

Chạy command sau để test:

```sql
STOP SLAVE;
START SLAVE;
```

#### 2.4.3.1. Command để check influxdb

```shell

influx -execute 'SHOW DATABASES'
# show table
influx -execute 'SHOW MEASUREMENTS' -database="telegraf"
influx -execute 'SHOW SERIES' -database="telegraf"  -format=json -pretty
influx -execute 'SELECT * FROM mysql WHERE time > now() - 3s' -database="telegraf" -format=json -pretty
influx -execute 'SELECT commands_show_slave_status FROM mysql WHERE time > now() - 1m' -database="telegraf" -format=json -pretty
influx -execute 'SELECT slave_Last_IO_Errno FROM mysql WHERE time > now() - 3h' -database="telegraf" -format=json -pretty
influx -execute 'SELECT slave_Last_SQL_Errno FROM mysql WHERE time > now() - 3h' -database="telegraf" -format=json -pretty
# list all column
influx -execute 'select * from /.*/ limit 1' -database="telegraf" -format=json -pretty
```

## 2.5. References

[http://docs.grafana.org/alerting/notifications/](http://docs.grafana.org/alerting/notifications/)
[http://docs.grafana.org/alerting/rules/](http://docs.grafana.org/alerting/rules/)




