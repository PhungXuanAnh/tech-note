# Note về một số loại giám sát trực tiếp trong Nagios.

## 1. Giám sát qua SNMP.

Các thiết bị mạng chủ yếu được giám sát (và điều khiển trong trường hợp cần thiết) thông qua giao thức quản trị mạng SNMP 
(Simple Network Management Protocol). Nagios cũng hoạt động theo cơ chế này, cũng thông qua chuỗi SNMP community string để 
lấy dữ liệu của các router/switch và thực hiện giám sát. Thực tế Nagios (cùng rất nhiều các phần mềm giám sát có hỗ trợ giám 
sát thông qua SNMP) cũng có thể giám sát các máy tính, máy chủ, … hoặc bất kỳ thứ gì có bật sẵn giao thức SNMP .

![](/docs/prepare/images/nrpe.png)
Đối với giám sát qua SNMP thì các trường hợp thường được áp dụng hiện nay như : Giám sát các thiết bị mạng (router, switch) 
để có được tình trạng hiện tại của các thiết bị mạng , nó cho ta biết đc các port hiện tại có mở hay không, tình trạng uptime 
như thế nào.

Để có thể giám sát qua SNMP nagios cần có một plugin tra dịch vụ qua giao thức snmp, nagios server sẽ sử dụng plugin check_snmp hoặc check_mrtgtraf
để kiểm tra các dịch vụ trên client có hỗ trợ giao thức SNMP.


## 2. Giám sát qua NRPE.

NRPE là một addon cho Nagios giúp thực thi các plugin khác để monitor/check các resources (CPU load, memory usage, swap usage, disk usage, logged in users, running processes, v.v..) 
và services (http, ftp, v.v..) trên các máy Linux/Unix ở xa.

Đối với giám sát qya NRPE thì trên client cần được cài đặt các plugins để thu thập dữ liệu và gửi về cho nrpe-plugin trên nagios server .


![](/docs/prepare/images/snmp.png)

NRPE addon bao gồm 2 thành phần:
 <ul>
  <li>Plugin check_nrpe: nằm trên máy Nagios (là monitoring server)</li>
  <li>Daemon NRPE: chạy trên máy Linux/Unix (remote host) cần monitor</li>
 </ul>

Khi máy Nagios cần check các resources/services trên máy Linux/Unix ở xa:
 <ul>
  <li>Nagios sẽ thực thi plugin check_nrpe và cho biết resource/service nào cần check</li>
  <li>Plugin check_nrpe sẽ liên lạc với daemon NRPE trên remote host. Kênh liên lạc có thể được bảo vệ bằng SSL</li>
  <li>Daemon NRPE sẽ chạy các plugin thích hợp (như check_disk, check_load, check_http, v.v..) để check các resource/service được yêu cầu</li>
  <li>NRPE daemon truyền kết quả cho check_nrpe, sau đó plugin này trả kết quả lại cho Nagios process</li>
 </ul>

Đối với giám sát qua NRPE thường được áp dụng để theo dõi Sử dụng để giám sát các thông số của host như check RAM, CPU, Disk... Hoặc để giám sát mail, 
database, web trên máy chủ để người quản trị 
có thể đưa ra những ứng phó kịp thời khi xảy ra những sự cố.

## 3. Giám sát trực tiếp.

- Là cách giám sát mà trên nagios server sẽ cài đặt plugin mà trên client không cần phải cài đặt bất cứ thứ gì cả.

![gstt](/docs/prepare/images/gstt.png)

- Như hình trên chúng ta có thể thấy được nagios đã sử dụng plugin „check_xyz‟  được cài đặt trên nagios server nhằm đáp ứng 
nhu cầu giám sát các dịch vụ đang chạy trên server.

- Một số plugin được sử dụng trong giám sát trực tiếp có thể kể đến như  : check_ping, check_http, check_snmp...

## 4. check_by_ssh.

- Nagios là một hệ thống monitoring có khả năng giám sát rất mạnh mẽ .Nó có thể giám sát được bất cứ thứ gì có thể truy cập từ xa : 
Như websites, SMTP server , FTP server ,.... Không những giám sát được những dịch vụ từ xa mà những tài nguyên cục bộ cũng có thể giám 
sát được như : load anverage, swap và memory,.... 

- Nếu chúng ta muốn giám sát các tài nguyên cục bộ của hệ thống trên một remote site thì nó có thể phức tạp hơn 1 chút. 
Có rất nhiều cách để chúng ta có thể làm việc này từ sử dụng NSCA cho đến sử dụng NRPE. Những giải pháp vừa nêu có thể sẽ là tốt nhất nếu như 
nó có thể được complie hoặc install một sofware  nào đó trên một máy chủ khác. 

- CÓ một giải pháp khác là sử dụng check thông qua SSH. Nếu như nó có thể truy cập vào máy chủ từ xa thì chúng ta có thể dùng cách này để giám sát 
các tài nguyên cục bộ của remote machine.

- Giải pháp này được sử dụng khi chúng nó không muốn cài đặt bất cứ thứ gì trên remote machine để phục vụ cho mục đích giám sát. Tuy nhiên check qua nrpe vẫn  
là phương pháp phổ biến nhất được sử dụng khi thực hiện giám sát với Nagios.