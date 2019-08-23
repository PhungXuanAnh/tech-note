# Tổng quan về Nagios.

![](/docs/prepare/images/nagios.png)


======================================================
<a name="top"></a>
# Mục Lục.

[1. Hệ thống giám sát mạng.](#1)
  - [1.1 Tổng quan về hệ thống giám sát mạng.](#1.1)
  - [1.2. Những thành phần quan trọng và những tình huống cố hữu xảy ra trong một hệ thống.](#1.2)</br>

[2. Tổng quan về Nagios.](#2)
  - [2.1.Nagios là gì?](#2.1)
  - [2.2. Tóm lược về lịch sử của nagios.](#2.2)
  - [2.3. Phân loại phiên bản của Nagios.](#2.3)
  - [2.4. Tổng hợp một số chức năng chính của Nagios.](#2.4)
  - [2.5. Đặc điểm của Nagios.](#2.5)
  - [2.6. Kiến trúc của nagios.](#2.6)
    - [2.6.1. Nagios core.](#2.6.1)
    - [2.6.2. Nagios Plugins.](#2.6.2)
    - [2.6.3. Kiến trúc tổng quan, nội tại và mối quan hệ giữa các thành phần với nhau.](#2.6.3)
  - [2.7. Cách thức hoạt động của nagios.](#2.7)
  - [2.8. Mô tả về cách thức thực hiện kiểm tra của nagios.](#2.8)


=======================================================

<a name="1"></a>
## 1. Hệ thống giám sát mạng.
<a name="1.1"></a>
### 1.1 Tổng quan về hệ thống giám sát mạng.

Giám sát mạng là một thuật ngữ dùng để chỉ việc sử dụng liên tục một hệ thống (có thể là một chương trình hoặc một thiết bị) 
để theo dõi tất cả các hoạt động của các thiết bị, các dịch vụ trong một hệ thống mạng.

Cần giám sát những gì và tại sao? Đối với hệ thống mạng, điều quan trọng nhất là nắm được những thông tin chính xác nhất vào 
mọi thời điểm. Những thông tin cần nắm bắt khi giám sát một hệ thống mạng bao gồm:

-  Tính sẵn sàng của thiết bị (Router, Switch, Server,…): những thiết bị giữ cho mạng hoạt động.

-  Các dịch vụ trong hệ thống (dns, ftp, http,…): những dịch vụ này đóng vai trò quan trọng trong một công ty, tổ chức, nếu 
các dịch vụ này không được đảm bào hoạt động bình thường và liên tục, nó sẽ ảnh hưởng nghiêm trọng đến công ty, tổ chức đó.

- Tài nguyên hệ thống: Các ứng dụng đều đòi hỏi tài nguyên hệ thống, việc giám sát tài nguyên sẽ đảm bảo cho chúng ta có những 
can thiệp kịp thời, tránh ảnh hưởng đến hệ thống.

-  Lưu lượng trong mạng: nhằm đưa ra những giải pháp, ngăn ngừa hiện tượng quá tải trong mạng.

- Các chức năng về bảo mật: nhằm đảm bảo an ninh trong hệ thống.

-  Nhiệt độ, thông tin về máy chủ, máy in: giúp tránh những hư hỏng xảy ra.

- Tạo file log: thu được những thông tin về những thay đổi trong hệ thống.

<a name="1.2"></a>
### 1.2. Những thành phần quan trọng và những tình huống cố hữu xảy ra trong một hệ thống.

Đối với 1 hệ thống thông thường những thông số qaun trọng cần phải giám sát như sau :

- RAM (Lượng RAM sử dụng và lượng RAM còn lại)

- CPU (Lượng CPU bị chiếm dụng để xử lý các tiến trình)

- Disk (Lượng bộ nhớ còn trống)

- Lưu lượng mạng vào/ra (Cái này e chưa nắm được rõ, vì trước kia e có theo dõi lưu lượng mạng ở trên góc độ xem những IP nào 
sử dụng lưu lượng nhiều "dowload/upload" và những nguồn được các user trong mạng truy cập thường xuyên.)

Những sự cố chủ quan có thể xảy ra trong hệ thống.

- RAM vượt quá ngưỡng cho phép.

- CPU full do xử lý nhiều tiến trình trong một thời điểm nhất định.

- Lưu lượng ổ cứng full.

- Card mạng bị down .

- Nhiệt độ tăng cao khiến cho các thành phần hệ thống ko đảm bảo hoạt động ở ngưỡng tốt nhất.

- Mạng bị quá tải.

Những sự cố khách quan có thể xảy ra với hệ thống

- Mất điện, mất mạng.

- Ổ cứng bị hỏng dẫn tới việc lưu trữ bị chậm hoặc ngừng hoạt động.

- BỊ tấn công từ các nhân tố bên ngoài.

- Đường dây mạng bị đứt.

<a name="2"></a>
## 2. Tổng quan về Nagios.

<a name="2.1"></a>
### 2.1.Nagios là gì?

Nagios là một hệ thống giám sát mạnh mẽ cho phép các tổ chức xác định và giải quyết các vấn đề cơ sở hạ tầng CNTT trước khi chúng ảnh hướng đến quá trình kinh doanh quan trọng

Lần đầu tiên ra mắt vào năm 1999, Nagios đã có hàng ngàn dự án được phát triển bởi cộng đồng Nagios trên toàn thế giới. Nagios được bảo trợ chính thức bởi Nagios Enterprises, hỗ 
trợ cộng đồng trong một số cách khác nhau thông qua việc bán các sản phẩm thương mại và dịch vụ của mình.

Nagios theo dõi toàn bộ cơ sở hạ tầng CNTT của bạn để đảm bảo hệ thống, ứng dụng, dich vụ và quy trình kinh quanh đang hoạt động tốt. Trong trường hợp bị lỗi, 
Nagios có thể cảnh báo nhân viên kỹ thuật các vấn đề, cho phép họ bắt đầu quá trình phục hồi trước khi ảnh hưởng đến quá trình kinh doanh, người sử dụng, hoặc khách hàng.

Được thiết kế với khả năng mở rộng và tính linh hoạt trong, Nagios mang đến cho bạn sự an tâm đến từ hiểu biết quy trình kinh doanh của tổ chức bạn sẽ không bị ảnh hưởng bởi 
sự cố ngừng hoạt động không rõ nguyên nhân.

Nagios hỗ trợ người quản trị trong việc  :

- Lên kế hoạch cho việc nâng cấp cơ sở hạ tầng trước khu hệ thống lỗi thời gây ra lỗi.

- Ứng phó với các vấn đề ngay khi có dấu hiệu đầu tiên.

-  Tự động sửa chữa các vấn đề khi chúng đượcn phát hiện.

- Đảm bảo sự ngưng hoạt động của các cơ sở hạ tầng CNTT có ảnh hưởng tối thiểu đến hệ thống.

- Theo dõi toàn bộ cơ sở hạ tầng và quy trình kinh doanh của bạn.

- Giám sát các dịch vụ mạng (HTTP, SMTP, POP3, PING,…)

- Giám sát tài nguyên máy chủ (processor load, disk usage,…)

- Những phần bổ trợ đơn giản cho phép người dùng phát triển dịch vụ kiểm tra riêng của họ.

- Phát hiện và phân biệt được các máy chủ hay dich vụ xuống cấp và không thể truy cập được.

- Thông báo cho người giám sát khi máy chủ hay dịch vụ có vấn đề và được giải quyết.

- Tùy chọn giao diện web để xem tình trạng mạng hiện có, thông báo và lịch sử các vấn đề, đăng nhập tập tin,…

<a name="2.2"></a>
### 2.2. Tóm lược về lịch sử của nagios.

- 1996 : Ethan Galstad đã tạo ra một ứng dụng MS-DOS đơn giản để "Ping" các máy chủ Novell Netware và trả về các trang số liệu .
 ứng dụng này được thiết kết bằng các sử dụng các ứng dụng ở bên thứ 3 ở bên ngoài để thực hiện kiểm tra các máy chủ và gửi các trang 
Khái niệm về kiến trúc cở bản của nagios được sinh ra.

- 1998 : Ethan đã sử dụng những ý tưởng trước đây của mình để bắt đầu xây dựng một ứng dụng mới và được cải tiến để chạy dưới Linux.

- 1999 : Ethan công bố sản phẩm của mình dưới dạng một dự án mã nguồn mở dưới cái tên "NetSaint". Ông ước tính có thể khoảng vài chục người 
quan tâm đến sản phẩm này.

- 2002 : Do những vấn đề gặp phải với tên nhãn hiệu "NetSaint" có thể có tác động lâu dài. Ethan quyết định đổi tên dự án thành "nagios"  
được viết tắt của từ "Nagios Ain’t Gonna Insist On Sainthood" . Phát triển dự án NetSaint Plugins được chuyển đến dự án Nagios Plugins.

- 2005 : Nagios được bình chọn là dự án của tháng (Project of the month-potm) theo bình chọn của  SourceForge.net

- 2006 : Nagios được đánh giá bởi eWeek Labs là một trong số những công cụ phải có của doanh nghiệp. Nagios được đề cập đến như là một 
"Hot Companies in Open Source" .

- 2007 : Ethan đã thành lập Nagios Enterprises, LLC để cung cấp các dịch vụ tư vấn và phát triển xung quanh nagios. Nagios là sản phẩm cuối cùng 
trong danh mục 'Công cụ tốt nhất hoặc tiện ích nhất cho người quản trị hệ thống' của giải thưởng cộng đồng SourceForge.net. Cùng năm nagios cũng đạt 
được giải thưởng "Ứng dụng giám sát mạng của năm" 2007 của LinuxQuestions.org. LinuxWorld.com đánh giá Nagios là một trong "5 công cụ bảo mật mã nguồn 
mở hàng đầu trong doanh nghiệp". EWeek đánh giá Nagios là một trong những "Ứng dụng mã nguồn mở quan trọng nhất mọi thời đại".

- 2008 : Nagios làm bìa trước của tạp chí Thông tin Tuần báo mang tên "Doanh nghiệp mã nguồn mở". Nagios đoạt giải thưởng "Ứng dụng giám sát mạng trong 
năm" của LinuxQuestions.org 2008 trong năm thứ hai liên tiếp. Nagios được vinh danh là một trong những Người đoạt giải nhất của Phần mềm nguồn mở Phần mềm 
Nguồn mở của Infoworld ("BOSSIE") 2008. Nagios đoạt danh hiệu "Server Monitoring". Nagios được tải trực tiếp từ SourceForge.net trên 500.000 lần.

- 2009 : Hợp đồng hỗ trợ hàng năm lần đầu tiên được Nagios Enterprises chính thức cung cấp. Nagios Enterprises đưa ra sản phẩm giám sát thương mại đầu tiên, Nagios XI.
 Nagios thắng Giải thưởng Reader's Choice 2009 cho "Ứng dụng giám sát yêu thích của Linux". Nagios là người cuối cùng trong Giải thưởng Cộng đồng SourceForge.net năm 2009 
cho "Công cụ Tốt nhất hoặc Tiện ích dành cho Người quản trị Hệ thống". Nagios đoạt giải thưởng "Ứng dụng giám sát mạng của năm" của LinuxQuestions.org năm thứ ba liên tiếp 
trong năm thứ ba. Infoworld đặt tên Nagios là một trong số những người đoạt giải nhất của Phần mềm nguồn mở ("BOSSIE") năm 2009. Đây là năm thứ hai liên tiếp Nagios đạt được 
danh hiệu như vậy. Nagios được đổi tên thành Nagios Core. Nagios Core được tải trực tiếp từ SourceForge.net trên 600.000 lần.

- 2010 : Nagios đoạt giải thưởng "Ứng dụng giám sát mạng của năm" của LinuxQuestions.org năm thứ năm liên tiếp trong năm thứ tư. Nagios đoạt Giải thưởng 
Linux Journal 2010 Readers’ Choice Award cho "Ứng dụng giám sát tốt nhất". Nagios đã giành được cuộc thăm dò LinuxCon 2010 cho "Các Công cụ Hoạt động CNTT Ưa thích". 
Nagios Fusion được phát hành như là một bảng điều khiển trung tâm theo dõi máy chủ.

- 2011 : Nagios BPI được phát hành để theo dõi quá trình kinh doanh. Hội nghị Thế giới Nagios đầu tiên được tổ chức tại Saint Paul, MN (Hoa Kỳ). 
Nagios đoạt giải thưởng "Ứng dụng giám sát mạng của năm" của LinuxQuestions.org năm thứ năm liên tiếp. Nagios đoạt Giải thưởng 
Linux Journal 2011 Readers’ Choice Award cho "Ứng dụng giám sát tốt nhất". Nagios đoạt giải nguồn mở mã nguồn mở PortalProgramas 2011 trong danh mục "Essential for Communications Networks". 
Nagios được WebhostingSearch.com trao tặng "Best Web Tool". Nagios được liệt kê trong danh sách SecTools.org của 125 công cụ bảo mật hàng đầu.

-  2012 : NSTI được phát hành để quản lý SNMP. Nagios Incident Manager được phát hành. Hội nghị Thế giới lần thứ hai Nagios được tổ chức tại Saint Paul, MN (Hoa Kỳ). 
Nagios đoạt giải thưởng "Ứng dụng giám sát mạng của năm" của LinuxQuestions.org năm thứ sáu liên tiếp trong năm thứ sáu. Nagios đoạt Giải thưởng 
Linux Journal 2012 Readers’ Choice Award cho "Ứng dụng giám sát tốt nhất". Nagios là một dự án đặc trưng trên SourceForget.net.

- 2013 : Nagios Network Analyzer được phát hành để cung cấp phân tích sâu về mô hình lưu lượng mạng. NCPA được phát hành để tăng thêm độ mở rộng cho nagios . 
Nagios Core 4 được phát hành. Hội nghị Thế giới Nagios lần thứ ba được tổ chức tại Saint Paul, MN (Hoa Kỳ).Nagios giành được giải thưởng "Ứng dụng giám sát mạng của năm" của LinuxQuestions.org năm 
2013 cho năm thứ bảy liên tiếp. Nagios đoạt Giải thưởng Linux Journal 2013 Readers’ Choice Award cho "Ứng dụng giám sát tốt nhất".

- 2014 : Nagios đã được cài đặt hơn 8 triệu lần kể từ năm 2008. Nagios được đặt tên là Kho tàng ẩn của St. Paul trong Tech{dot}MN. Nagios thông báo rằng nhóm Nagios Plugin đang trải qua một số 
thay đổi, bao gồm cả việc giới thiệu một người bảo trợ mới. Nagios đoạt giải thưởng "Ứng dụng Theo dõi Mạng của năm" năm 2014 cho năm thứ tám liên tiếp. Hội nghị Thế giới Nagios lần thứ tư được 
tổ chức tại Saint Paul, MN (Hoa Kỳ). Nagios Log Server được phát hành để cung cấp giám sát đăng nhập cấp doanh nghiệp và quản lý.

- 2015 : Nagios XI 5 đến với hơn 200 cải tiến và đổi mới. Nagios đoạt giải thưởng "Ứng dụng giám sát mạng của năm" năm LinuxQuestions.org năm thứ chín liên tiếp. Nagios Log Server đã được lựa chọn 
lần thứ nhì trong phần sản phẩm ShowNet của giải Best of Show Interop Tokyo 2015. Hội nghị Nagios World lần thứ năm được tổ chức tại Saint Paul, MN (Hoa Kỳ).

- 2016 : Nagios Core vượt quá 7.500.000 lượt tải xuống trực tiếp từ SourceForge.net. Nagios giành được "Dự án Tháng" của SourceForge cho tháng 10 năm 2016.
<a name="2.3"></a>
### 2.3. Phân loại phiên bản của Nagios.

#### 2.3.1. Nagios XI (Enterprise Server and Network Monitoring SoftwareEnterprise Server and Network Monitoring Software)

- Bảng liệt kê các lợi ích của phiên bản.

|Lợi ích|chi tiết|
|---------|----------------|
|Comprehensive IT Infrastructure Monitoring| Cung cấp giám sát của tất cả các thành phần cơ sở hạ tầng quan trọng bao gồm các ứng dụng, dịch vụ, hệ điều hành, các giao thức mạng, các hệ thống đo và cơ sở hạ tầng mạng. Hàng trăm addons của bên thứ ba cung cấp cho việc giám sát hầu như tất cả các ứng dụng, dịch vụ và hệ thống trong hệ thống.|
|Performance|Công cụ giám sát Nagios Core 4 mạnh mẽ cung cấp cho người dùng mức độ cao nhất về việc theo dõi hiệu suất của máy chủ. Các worker process hiệu quả cao cho phép khả năng mở rộng gần như vô hạn và giám sát hiệu quả.|
|Visibility|Cung cấp một cái nhìn trung tâm về toàn bộ mạng lưới hoạt động CNTT và quy trình kinh doanh của bạn. Các bảng điều khiển mạnh mẽ cung cấp khả năng truy cập thông tin giám sát mạnh mẽ và dữ liệu của bên thứ ba. Chế độ xem giúp người dùng truy cập nhanh vào thông tin mà họ thấy hữu ích nhất.|
|Proactive Planning & Awareness|Biểu đồ quy hoạch xu hướng và năng suất được tích hợp tự động, cho phép các tổ chức lên kế hoạch nâng cấp cơ sở hạ tầng trước khi hệ thống rơi vào lạc hậu. Cảnh báo được gửi cho nhân viên CNTT, các bên liên quan đến kinh doanh và người dùng cuối qua email hoặc tin nhắn văn bản di động, cung cấp cho họ thông tin để họ có thể bắt đầu giải quyết vấn đề ngay lập tức.|
|Customizability|Một giao diện mạnh mẽ cung cấp cho tùy biến bố trí, thiết kế và sở thích trên cơ sở người dùng mỗi lần, cho khách hàng của bạn và các thành viên trong nhóm sự linh hoạt mà họ muốn.|
|Ease of Use|Giao diện cấu hình dựa trên web cho phép quản trị viên có thể dễ dàng kiểm soát việc quản lý cấu hình giám sát, cài đặt hệ thống, và nhiều hơn nữa cho người dùng cuối và các thành viên trong nhóm. Các cấu hình thay đổi hướng dẫn người dùng thông qua quá trình giám sát các thiết bị, dịch vụ và ứng dụng mới - tất cả mà không cần phải hiểu các khái niệm giám sát phức tạp.|
|Multi-Tenant Capabilities|Truy cập vào giao diện web của nhiều người dùng cho phép các bên liên quan xem trạng thái cơ sở hạ tầng có liên quan. Cá nhân hóa của người dùng cụ thể đảm bảo khách hàng chỉ nhìn thấy các thành phần cơ sở hạ tầng mà họ được ủy quyền cho. Quản lý người dùng nâng cao giúp đơn giản hóa quản trị bằng cách cho phép bạn quản lý tài khoản người dùng một cách dễ dàng. Cung cấp tài khoản người dùng mới với một vài cú nhấp chuột và người dùng tự động nhận được một email với các thông tin đăng nhập của họ.|
|Extendable Architecture|Nhiều API cho phép tích hợp đơn giản với các ứng dụng của bên thứ ba và bên thứ ba. Hàng ngàn cộng đồng phát triển addons mở rộng giám sát và chức năng cảnh báo. Giao diện tùy chỉnh và phát triển addon có sẵn để điều chỉnh Nagios XI để đáp ứng nhu cầu chính xác của tổ chức bạn.|

- Bảng liệt kê các tính năng.

|Tính năng|Chi tiết|
|---------|--------|
|Powerful Monitoring Engine|Nagios XI sử dụng công cụ giám sát Nagios Core 4 mạnh mẽ để cung cấp cho người dùng hiệu quả, khả năng mở rộng theo dõi.|
|Updated Web Interface|Trang tổng quan mới của bạn cung cấp tổng quan cấp cao về host, services và network devices.|
|Advanced Graphs & More|Quản trị viên có thể dễ dàng xem sự cố mạng và giải quyết chúng trước khi chúng trở thành những thảm họa lớn.|
|Capacity Planning|Biểu đồ quy hoạch xu hướng và năng suất được tích hợp tự động cho phép các tổ chức lên kế hoạch nâng cấp.|
|Configuration Wizards|Nhanh chóng thay đổi! Đơn giản chỉ cần nhập các thông tin cần thiết, và bạn đang lên và theo dõi với một vài cú nhấp chuột đơn giản.|
|Infrastructure Management|Tập hơn số lượng lớn máy chủ, Tự động Phát hiện, Tự động Tạm ngừng, đưa ra cái nhìn tổng quan và nhiều hơn nữa!|
|Configuration Snapshot|Lưu các cấu hình gần đây nhất của bạn. Lưu trữ nó. Revert lại bất cứ khi nào bạn muốn. Không bao giờ mất nó một lần nữa.|
|Advanced User Management|Dễ dàng thiết lập và quản lý tài khoản người dùng chỉ với một vài cú nhấp chuột sau đó chỉ định các vai trò tùy chỉnh để đảm bảo một môi trường an toàn.|

#### 2.3.2. Centralized Log Management, Monitoring and Analysis Software.

- Bảng liệt kê các lợi ích của phiên bản.

|Lợi ích|chi tiết|
|---------|----------------|
|Ease of Use|Máy chủ Log Nagios đơn giản hóa quá trình tìm kiếm dữ liệu đăng nhập của bạn. Thiết lập các cảnh báo để thông báo cho bạn khi các mối đe dọa tiềm ẩn xuất hiện hoặc chỉ cần truy vấn dữ liệu nhật ký để kiểm tra nhanh bất kỳ hệ thống nào. Với Nagios Log Server, bạn sẽ nhận được tất cả các dữ liệu nhật ký của mình ở một vị trí, với tính sẵn sàng cao và khả năng vượt qua. Nhanh chóng cấu hình các máy chủ của bạn để gửi tất cả dữ liệu đăng nhập với các trình hướng dẫn cài đặt nguồn dễ dàng và bắt đầu giám sát các bản ghi của bạn chỉ trong vài phút.|
|Infinite Scalability|Máy chủ Nagios Log có thể mở rộng để đáp ứng nhu cầu của toàn bộ cơ sở hạ tầng IT của bạn, vì vậy khi tổ chức của bạn phát triển, bạn có thể dễ dàng bổ sung thêm các trường hợp Nagios Log Server vào nhóm giám sát của bạn. Điều này cho phép bạn nhanh chóng thêm nhiều sức mạnh, tốc độ, lưu trữ và độ tin cậy vào nền tảng phân tích đăng nhập tổng thể của bạn. Nagios Log Server được thiết kế cho các tổ chức có kích thước bất kỳ và có thể thích ứng với một nút bấm.|
|Your Data in Real Time|Dễ dàng tương quan các sự kiện đăng nhập trên tất cả các máy chủ trong một vài cú nhấp chuột. Nagios Log Server cho phép bạn xem các dữ liệu đăng nhập trong thời gian thực, cung cấp khả năng phân tích và giải quyết nhanh các vấn đề khi chúng xảy ra. Điều này giúp tổ chức của bạn an toàn, bảo mật và hoạt động trơn tru.|
|Adaptability|Nagios Log Server có một API hoàn toàn có thể truy cập cho phép tích hợp hoàn chỉnh để phù hợp với nhu cầu của các ứng dụng bên ngoài của bạn. Máy chủ Nagios Log dễ dàng tích hợp với các giải pháp của bên thứ ba hoặc cơ sở hạ tầng hiện tại của bạn.|
|Network Security|Nagios Log Server là một giải pháp hàng đầu được thiết kế hoàn hảo cho việc kiểm tra bảo mật và mạng. Dễ dàng tạo cảnh báo từ giao diện web dựa trên các truy vấn và ngưỡng quan trọng nhất đối với bạn. Thông báo cho người dùng thông qua Nagios XI / Nagios Core, email,SNMP hoặc thực hiện một kịch bản để đảm bảo giải quyết nhanh vấn đề. Nagios Log Server cho phép bạn lặn sâu vào vấn đề để giúp bạn tìm ra giải pháp. Ngoài ra, Nagios Log Server có thể lưu trữ các bản ghi lịch sử của tất cả các sự kiện cần kiểm tra bảo mật, giữ cho tổ chức của bạn tuân thủ các yêu cầu về bảo mật.|
|Advanced User Management|Khả năng đa người dùng cho phép các đội CNTT cùng làm việc hiệu quả. Quản trị viên có thể thêm, chỉnh sửa và xóa người dùng cũng như thiết lập quyền truy cập. Quản trị viên cũng có thể cấp cho người dùng cụ thể quyền truy cập vào API bên ngoài thông qua khóa truy cập.|
|Customized Dashboards|Một giao diện mạnh mẽ cung cấp cho tùy biến bố trí, thiết kế và sở thích trên cơ sở người dùng mỗi lần, cho khách hàng của bạn và các thành viên trong nhóm sự linh hoạt mà họ muốn. Người dùng có thể tạo trang tổng quan tùy chỉnh trong giao diện web để xem quan điểm nhanh của dữ liệu quan trọng nhất đối với họ. Người dùng cũng có thể dễ dàng chia sẻ bảng điều khiển với một URL tùy chỉnh để tăng cường sự hợp tác của đội.|
|Network Insights|Máy chủ Nagios Log cung cấp cho người dùng nhận thức về cơ sở hạ tầng của họ. Lặn sâu vào các sự kiện mạng, nhật ký và sự kiện bảo mật. Sử dụng Log Server để cung cấp các bằng chứng cần thiết để theo dõi các mối đe dọa bảo mật và nhanh chóng giải quyết các lỗ hổng với các thông báo và cảnh báo được cài sẵn.|

- Bảng liệt kê các tính năng.

|Tính năng|Chi tiết|
|---------|--------|
|Comprehensive Dashboards|Hệ thống bảng điều khiển mạnh mẽ cung cấp cho người dùng khả năng truy vấn, lọc và phân tích sự kiện nhật ký đến.|
|High Availability & Failover|Máy chủ nhật ký sử dụng một cụm máy chủ lưu trữ dữ liệu nhật ký để tránh mất dữ liệu và đảm bảo tính sẵn có của thông tin đăng nhập của bạn.|
|Alerting|Tạo cảnh báo dựa trên các truy vấn có các ngưỡng cụ thể và gửi cho các thành viên thích hợp.|
|Setup Wizards|Nhận dữ liệu nhật ký từ nguồn được chỉ định chỉ với một vài cú nhấp chuột bằng cách dễ dàng thực hiện theo các hướng dẫn từng bước.|
|Quick Search & Query|Tìm kiếm với nhiều truy vấn và bộ lọc cho phép bạn nhanh chóng tìm ra vấn đề chính xác mà bạn đang tìm kiếm.|
|Extendable Architecture|Quản trị viên có quyền truy cập đầy đủ vào API backend cho phép tùy chỉnh vô hạn với các ứng dụng của bên mình và bên thứ ba.|
|Real-Time Data|Xem dữ liệu đăng nhập từ tất cả các máy chủ của bạn trong thời gian thực, cho phép bạn phân tích và giải quyết các vấn đề khi chúng xảy ra.|
|Highly Scalable|Bạn có thể dễ dàng thêm các trường hợp cluster khác để cung cấp cho hệ thống của bạn mạnh mẽ hơn, tốc độ, dung lượng lưu trữ và độ tin cậy cao hơn.|

#### 2.3.3. Netflow Analysis, Monitoring, and Bandwidth Utilization Software.

- Bảng liệt kê các lợi ích của phiên bản.

|Lợi ích|chi tiết|
|---------|----------------|
|Extensive Network Analysis|Network Analyzer cung cấp một cái nhìn sâu vào tất cả các nguồn lưu lượng mạng và các mối đe dọa bảo mật tiềm ẩn cho phép các quản trị viên hệ thống nhanh chóng thu thập thông tin cấp cao về sức khoẻ của mạng cũng như dữ liệu hạt rất cao để phân tích mạng hoàn chỉnh và toàn diện.|
|Intuitive Design|Với giao diện web mạnh mẽ và trực quan, Network Analyzer rất dễ sử dụng, đồng thời cung cấp hiệu năng và tốc độ tối ưu. Network Analyzer liên tục tích hợp với giải pháp giám sát mạng của nagios, Nagios XI, cho phép hợp nhất các cảnh báo và thông báo cũng như duy trì một mạng lưới an toàn và an toàn. Dễ dàng thiết lập các cảnh báo và thêm các nguồn bằng trình thuật toán trực quan của Network Analyzer chỉ với một vài cú nhấp chuột.|
|Network Clarity|Network Analyzer cung cấp một cái nhìn trung tâm về dữ liệu lưu lượng truy cập mạng và dữ liệu băng thông cũng như sự phân chia lưu lượng mạng. Bảng điều khiển mạnh mẽ cung cấp chế độ xem nhanh các nguồn dữ liệu dòng chảy hoặc luồng dữ liệu quan trọng, số liệu hệ thống máy chủ và hành vi mạng bất thường để đánh giá nhanh về sức khoẻ của mạng. Người dùng có thể dễ dàng tìm hiểu thông tin cụ thể về từng IP, cổng nguồn, cổng đích hoặc bất kỳ sự kết hợp nào của nó.|
|In-Depth Insight|Khả năng cảnh báo và báo cáo tiên tiến của Network Analyzer cung cấp cho nhân viên CNTT nhận thức cao về mạng của họ. Có thể truy cập và lưu trữ dữ liệu chi tiết, chi tiết đến từng gói dữ liệu để theo dõi và phân tích thêm. Khi các ngưỡng quan trọng được vượt quá, hoạt động mạng bất thường xảy ra hoặc các yêu cầu về băng thông đã được đáp ứng, Network Analyzer có thể kích hoạt cảnh báo cho phép Quản trị viên bắt đầu giải quyết các vấn đề ngay lập tức.|
|Adaptability|Tạo môi trường Mạng Analyzer thể hiện bản sắc mạng của bạn. Nhóm nguồn cho phép Quản trị viên tổ chức các nguồn tương tự cũng như áp dụng chế độ xem và truy vấn vào nhiều nguồn đồng thời và với các thông số chính xác của bạn. Bổ sung thêm các tính năng cho phép người sử dụng Network Analyzer để đẩy thông báo SNMP để giám sát và hệ thống quản lý SNMP trap. Network Analyzer thích ứng với môi trường hiện tại của bạn để thực hiện một quá trình triển khai không quá khó khăn chỉ mất vài phút để bắt đầu và chạy.|
|Bandwidth Utilization Calculator|Một máy tính sử dụng băng thông có thể tuỳ chỉnh được bao gồm cho phép tạo báo cáo để tóm tắt việc sử dụng băng thông trên mỗi nguồn, IP hoặc bất kỳ sự kết hợp nào mà người dùng mong muốn.|


- Bảng liệt kê các tính năng.

|Tính năng|Chi tiết|
|---------|--------|
|Comprehensive Dashboard|Trang tổng quan nhà cung cấp tổng quan cấp cao về các nguồn, kiểm tra, dữ liệu luồng dữ liệu mạng và nhiều hơn nữa.|
|Security and Reliability|Trình phân tích mạng có khả năng cảnh báo người dùng khi hoạt động đáng ngờ xảy ra trên mạng.|
|Advanced Visualizations|Hình ảnh nâng cao cung cấp thông tin chi tiết sâu sắc, nhanh chóng về lưu lượng mạng, băng thông và sức khoẻ tổng thể của mạng.|
|Custom Application Monitoring|Các truy vấn, lượt xem và báo cáo được cá nhân cung cấp cho bạn khả năng giám sát việc sử dụng mạng của các ứng dụng cụ thể.|
|Automated Alert System|Nhận cảnh báo khi hoạt động bất thường diễn ra hoặc khi quá trình sử dụng băng thông vượt quá ngưỡng quy định của bạn.|
|Seamless Nagios XI Integration|Tích hợp với Nagios XI để xem chính xác Mạng Analyzer máy chủ tải và không gian đĩa cứng từ bên trong hệ thống XI.|
|Advanced User Management|Tùy chọn người dùng nâng cao cho phép các đội CNTT cùng làm việc hiệu quả để giữ cho mạng hoạt động trơn tru.|

#### 2.3.4. Nagios Core "The open source industry standard in IT infrastructure monitoring and alerting"

- Bảng liệt kê các lợi ích của phiên bản.

|Lợi ích|chi tiết|
|-------|--------|
|Monitoring|Nhân viên CNTT cấu hình Nagios để theo dõi các thành phần cơ sở hạ tầng CNTT quan trọng, bao gồm hệ thống số liệu, giao thức mạng, ứng dụng, dịch vụ, máy chủ và cơ sở hạ tầng mạng.|
|Alerting|Nagios gửi thông báo khi các thành phần cơ sở hạ tầng quan trọng bị fail và phục hồi, cung cấp cho các quản trị viên thông báo các sự kiện quan trọng. Cảnh báo có thể được gửi qua email, SMS hoặc tập lệnh tùy chỉnh.|
|Response|Nhân viên CNTT có thể nhận cảnh báo và bắt đầu giải quyết sự cố và điều tra các cảnh báo bảo mật ngay lập tức. Cảnh báo có thể được leo thang đến các nhóm khác nhau nếu cảnh báo không được công nhận kịp thời.|
|Reporting|Báo cáo cung cấp bản ghi lịch sử về sự cố, sự kiện, thông báo và phản hồi thông báo để xem xét sau. Báo cáo khả dụng giúp đảm bảo SLA của bạn đang được đáp ứng.|
|Maintenance|Thời gian ngừng hoạt động theo lịch trình sẽ được lên lịch để ngăn ngừa các cảnh báo trong thời gian bảo trì và nâng cấp.|
|Planning|Đồ thị và báo cáo về xu hướng và năng suất cho phép bạn xác định các nâng cấp cơ sở hạ tầng cần thiết trước khi xảy ra sự cố.|
|Free|!!!|

- Bảng liệt kê các tính năng.

|Tính năng|Chi tiết|
|---------|--------|
|Comprehensive Monitoring|Core cung cấp giám sát tất cả các thành phần cơ sở hạ tầng quan trọng trong cơ sở hạ tầng CNTT của bạn.|
|Visibility|Đạt được chế độ xem tập trung về toàn bộ hoạt động CNTT của bạn và xem lại thông tin trạng thái chi tiết thông qua giao diện web.|
|Awareness|Cảnh báo với khả năng leo thang được gửi tới nhân viên CNTT thông qua email và SMS để đảm bảo phát hiện nhanh các tình trạng như cúp điện.|
|Problem Remediation|Trình xử lý sự kiện có thể tự động khởi động lại các ứng dụng, máy chủ, thiết bị và dịch vụ không thành công khi có sự cố.|
|Proactive Planning|Việc mở rộng quy hoạch khả năng và năng lực cho phép bạn lập kế hoạch nâng cấp.|
|Reporting|Các báo cáo khả dụng đảm bảo SLA đang được đáp ứng và các báo cáo lịch sử cung cấp hồ sơ về các thông tin quan trọng.|
|Multi-Tenant Capabilities|Chế độ xem người dùng đa người dùng và quan điểm người dùng cụ thể có thể được định cấu hình để đảm bảo khách hàng xem thông tin cụ thể.|
|Extendable Architecture|Nhiều API cung cấp tích hợp với ứng dụng của bên thứ ba và các tiện ích do cộng đồng phát triển.|



<a name="2.4"></a>
### 2.4. Tổng hợp một số chức năng chính của Nagios. 

Cảnh báo: Nagios gửi cảnh báo khi có thành phần cơ sở hạ tầng bất ổn định và phục hồi, cung cấp cho các quản trị 
viên thông báo của các sự kiện quan trọng. Cảnh báo có thể được gửi qua email, SMS, hay tùy chỉnh.

Ứng phó: Nhân viên CNTT có thể xác nhận cảnh báo và bắt đầu giải quyết sự cố ngưng hoạt động và kiểm tra hệ thống 
cảnh báo ngay lập tức. Cảnh báo có thể được gia tăng cho các nhóm khác nhau nếu thông báo không xác nhận một cách kịp thời.

 Báo cáo: Báo cáo cung cấp một hồ sơ lịch sử của sự cố ngưng hoạt động, sự kiện, thông báo, và phản ứng cảnh báo để xem xét. 
 Sẵn có các báo cáo giúp đảm bảo SLAs của bạn đang được đáp ứng.

Bảo trì: Dự kiến thời gian ngừng làm việc ngăn cản các cảnh báo tỏng quá trình bảo trì theo lịch trình và nâng cấp.

Kế hoạch: Lập lịch đồ thị và báo cáo xu hướng và công suất cho phép bạn xách định sự cần thiết nâng cấp cơ sở hạ tầng trước khi xảy ra sự cố.

<a name="2.5"></a>
### 2.5. Đặc điểm của Nagios. 

Giám sát toàn diện

- Khả năng để giám sát các ứng dụng, dịch vụ, hệ điều hành, giao thức mạng, hệ thống số liệu và các thành phần cơ sở hạ tầng với một công cụ duy nhất.

- API mạnh mẽ cho phép giám sát dễ dàng các ứng dụng và tùy chỉnh các dịch vụ, và các hệ thống.

Tầm Nhìn

- Tập trung theo dõi toàn bộ cơ sở hạ tầng CNTT.

-  Chi tiết thông tin trạng thái hoạt động thông qua giao diện web.

Nhận thức

- Nhanh chóng phát hiện các sự cố ngưng hoạt động của cơ sở hạ tầng.

- Cảnh báo có thể được gửi đến nhân viên kỹ thuật qua email hoặc tin nhắn SMS.

- Khả năng leo thang đảm bảo các thông báo cảnh báo đến đúng người.

Khắc phục vấn đề

- Xác nhận cảnh báo cung cấp thông tin về các vấn đề được biết đến và ứng phó vấn đề.

- Xử lý sự kiện cho phép tự động khởi động các ứng dụng thất bại và dịch vụ.

Lập kế hoạch chủ động

- Những phần bổ trợ lập kế hoạch cho xu hướng và năng lực hoạt động đảm bảo bạn nhận thức được sự xuống cáp của cơ sở hạ tầng.

- Dự kiến thời gian ngưng hoạt động cho phép tắt cảnh bóa trong quá trình nâng cấp cơ sở hạ tầng.

Báo cáo

- Báo cáo sẵn có đảm bảo SLA (Service Level Agreement_Thỏa thuận cung cấp độ dịch vụ) đang được đáp ứng.

- Cung cấp lịch sử các báo cáo ghi lại các cảnh báo, thông báo, sự cố ngưng hoạt động, và xác nhận cảnh báo.

Nhiều người sử dụng

- Với chức năng này, cho phép nhiều người sử dụng có quyền truy cập xem tình trạng của cơ sở hạ tầng.

- Những người xem riêng biệt chỉ thấy được cơ sở hạ tầng của họ.

Kiến trúc mở rộng

- Hàng trăm phần bổ trợ được phát triển bởi cộng đồng mở rộng tính năng cốt lõi của Nagios.

- Ổn định, đáng tin cậy và nền tảng vững chắc.

- Hơn 10 năm phát triển hoạt động.

- Cân bằng để giám sát hàng ngàn điểm.

- Failover đảm bảo khả năng giám sát không ngừng của các thành phần cơ sở hạ tầng CNTT quan trọng.

- Nhiều giải thưởng, phương tiện truyền thông và công nhận chứng minh giá trị của Nagios.

Cộng đồng sôi nổi

- Ước tính hơn 1 triệu người sử dụng trên toàn thế giới.

- Các hoạt động của cộng đồng được hỗ trợ miễn phí.

Mã nguồn tùy chỉnh

- Phần mềm nguồn mở.

- Không giới hạn truy cập vào mã nguồn.

- Phát hành theo giấy phép GPL (General Public License_Giấy phép công cộng).

<a name="2.6"></a>
### 2.6. Kiến trúc của nagios. 

Hệ thống Nagios gồm hai phần chính:

<a name="2.6.1"></a>
#### 2.6.1. Nagios core. 

Nagios core là công cụ giám sát và cảnh báo, nó làm việc như các ứng dụng chính trên hàng trăm dự ansNagios được xây dựng. 
Nó làm việc như là lịch trình sự kiện cơ bản, xử lý sự kiện,và quản lý thông báo cho các phần tử được theo dõi. Nó khắc họa 
một sooss API (Application Programming Interface_Giao diện lập trình ứng dụng) được sử dụng để mở rộng khả năng của mình để 
thực hiện nhiệm vụ bổ sung, được thực hiện như một tiến trình được viết bằng C vì lý do hiệu suất, và được thiết kế để chạy 
tự nhiên trên hệ thống Linux/* nix.

<a name="2.6.2"></a>
#### 2.6.2. Nagios Plugins. 

Nagios plugins là phần mở rộng độc lập để Nagios Core cung cấp ở mức độ thấp về cách theo dõi bất cứ điều gì và tất cả mọi thứ 
với Nagios Core. Plugins hoạt động như các ứng dụng độc lập, nhưng thương được thiết kế để thực thi bởi Nagios Core.

Plugins xử lý đối số dòng lệnh, đi về các doanh nghiệp thực hiện kiểm tra, và sau đó trả lại kết quả cho Nagios Core để xử lý tiếp. 
Plugin có thể được biên dịch nhị phân (viết bằng C, C++, …) hoặc các bản thực thi (Perl, PHP,…).

Ngoài ra, còn có các thành phần Nagios Frontends, Nagios Configtools.
<a name="2.6.3"></a>
#### 2.6.3. Kiến trúc tổng qua, nội tại và mối quan hệ giữa các thành phần với nhau.

- Nagios được xây  dựng theo kiến trúc client/server . Nagios kiểm tra các thông tin của máy chủ lưu trữ và các dịch vụ phụ thuộc vào 
chương trình bên ngoài  (plugins) mà không có bất kỳ cơ chế nội bộ nào làm điều đó. Nagios server thường chạy trên một host và các plugins 
chạy trên các remote hosts cần được giám sát. Sau đó chúng sẽ gửi thông tin tới máy chủ để hiển thị trong một GUI. 3 thành phần nội tại cần chú ý :

![1](/docs/prepare/images/1.png)

1. Scheduler  : 1 phần của Nagios server được sử dụng để kiểm tra các plugins và gửi thông báo theo kết quả.

2. GUI : Một giao diện của Nagios được sử dụng để hiển thị các trang web được tạo bở CGI . Nó có thể là các nút màu xanh lá cây hoặc đỏ 
âm thanh, đồ thị,.... Một nút màu xanh lá sẽ bị chuyển thành màu đỏ và phát ra một âm thanh khi một  plugins trả về bị lỗi theo sau để gửi cảnh 
báo mềm. Khi cảnh báo mềm được nhắc đến  nhiều lần (số lần có thể đượ cấu hình). Một cảnh báo khos có thể được nâng lên , sau đó nagios sẽ gửi thông báo 
cho quản tri viên.

3. Plugins : Chúng được sử dụng để kiểm tra một dịch vụ và trả về kết quả cho máy chủ Nagios. Ngoài ra, chúng được cấu hình bởi người dùng.

![2](/docs/prepare/images/2.png)

Hình trên cho chúng ta cái nhìn tổng quan về nội bộ của nagios, Nagios có các plugins để theo dõi , nó kết nối vs apache được kiểm soát bởi CGI để hiển thị 
kết quả. Hơn nữa cơ sở dữ liệu kết nối với nagios để giữ một file log.

![3](/docs/prepare/images/3.png)

Hình ảnh này lại cho chúng ta thấy được kiến trúc bên ngoài của Nagios . Plugins của nagios server kiểm tra csc dịch vụ của máy khác sử dụng 
plugins của nó , NRPE (sử dụng NRPE để gửi dữ liệu được mã hóa bằng SSL / TSL), SSH (chạy trực tiếp qua sercure shell), SNMP (sử dụng cho máy chủ và các thiết bị mạng) 
NSCA (Để phân phối tải lên máy chủ nagios)

<a name="2.7"></a>
### 2.7. Cách thức hoạt động của nagios.

![nagios-architect](/docs/prepare/images/nagios-architect.png)

Nagios có 5 cách thực thi các hành động kiểm tra:

- Kiểm tra dịch vụ trực tiếp: Đối với các dịch vụ mạng có giao thức giao tiếp qua mạng như SMTP, HTTP, FTP,… Nagios có thể 
tiến hành kiểm tra trực tiếp một dịch vụ xem nó đang hoạt động hay không bằng cách gửi truy vấn kết nối dịch vụ đến server 
dịch vụ và đợi kết quả trả về. Các plugin phục vụ kiểm tra này được đặt ngay trên server Nagios.

- Chạy các plugin trên máy ở xa bằng secure shell: Nagios server không có cách nào có thể truy cập trực tiếp client để theo 
dõi những thông tin như tình trạng sử dụng ổ đĩa, swap, tiến trình … Để làm được việc này thì trên máy được giám sát phải 
cài plugin cục bộ. Nagios sẽ điểu khiển các plugin cục bộ trên client qua secure shell ssh bằng plugin check_by_ssh. 
Phương pháp này yêu cầu một tài khoản truy cập host được giám sát nhưng nó có thể thực thi được tất cả các plugin được 
cài trên host đó.

- Bộ thực thi plugin từ xa (NRPE - Nagios Remote Plugin Executor) NRPE là một addon đi kèm với Nagios. Nó trợ giúp việc 
thực thi các plugin được cài đặt trên máy/thiết bị được giám sát. NRPE được cài trên các host được giám sát. Khi nhận được 
truy vấn từ Nagios server thì nó gọi các plugin cục bộ phù hợp trên host này, thực hiện kiểm tra và trả về kết quả cho 
Nagios server. Phương pháp này không đòi hỏi tài khoản truy cập host được giám sát như sử dụng ssh. Tuy nhiên cũng như ssh 
các plugin phục vụ giám sát phải được cài đặt trên host được giám sát. NRPE có thể thực thi được tất cả các loại plugin giám 
sát. Nagios có thể điều khiển máy cài NRPE kiểm tra các thông số phần cứng, các tài nguyên, tình trạng hoạt động của máy đó 
hoặc sử dụng NRPE để thực thi các plugin yêu cầu truy vấn dịch vụ mạng đến một máy thứ 3 để kiểm tra hoạt động của các dịch 
vụ mạng như http, ftp, mail…

- Giám sát qua SNMP  Cốt lõi của giao thức SNMP (SimpleNetwork Management Protocol )là tập hợp đơn giản các hoạt động giúp 
nhà quản trị mạng có thể quản lý, thay đổi trạng thái thiết bị. Hiện nay rất nhiều thiết bị mạng hỗ trợ giao thức SNMP như 
Switch, router, máy in, firewall ... Nagios cũng có khả năng sử dụng giao thức SNMP để theo dõi trạng thái của các client, 
các thiết bị mạng có hỗ trợ SNMP. Qua SNMP, Nagios có được thông tin về tình trạng hiện thời của thiết bị. Ví dụ như với 
SNMP, Nagios có thể biết được các cổng của Switch, router có mở hay không, thời gian Uptime (chạy liên tục) là bao nhiêu…

- NSCA (Nagios Service Check Acceptor) : Nagios được coi là một phần mềm rất mạnh vì nó dễ dàng được mở rộng và kết hợp với 
các phần mềm khác. Nó có thể tổng hợp thông tin từ các phần mềm kiểm tra của hãng thứ ba hoặc các tiến trình Nagios khác về 
rạng thái của host/dịch vụ. Như thế Nagios không cần phải lập lịch và chạy các hành động kiểm tra host/dịch vụ mà các ứng 
dụng khác sẽ thực hiện điểu này và báo cáo thông tin về cho nó. Và các ứng dụ ng kiểm tra có thể tận dụng được khả năng rất 
mạnh của Nagios là thông báo và tổng hợp báo cáo. Nagios sử dụng công cụ NSCA để gửi các kết quả kiểm tra từ ứng dụ ng của 
bạn về server Nagios. Công cụ này giúp cho thông tin gửi trên mạng được an toàn hơn vì nó được mã hóa và xác thực.

<a name="2.8"></a>
### 2.8. Mô tả về cách thức thực hiện kiểm tra của nagios.

![nagios-test](/docs/prepare/images/nagios-test.png)

Hình trên cho ta cái nhìn tổng quan về các cách thức kiểm tra dịch với Nagios. Có 5 client được giám sát bằng 5 cách thức khác nhau:

- Client 1: Nagios sử dụng plugin „check_xyz‟ được cài đặt ngay trên server Nagios để gửi truy vấn kiểm tra dịch vụ trên client( http, ftp, dns, smtp…)

-  Client 2, 3: Nagios sử dụng các plugin trung gian để chạy plugin „check_xyz‟ giám sát được cài đặt trực tiếp trên client. (bởi vì có những dịch vụ 
không có hỗ trợ giao thức trao đổi qua mạng, ví dụ khi bạn muốn kiểm tra dung lượng ổ đĩa cứng còn trống trên client…)

-  Client 4: Kiểm tra dịch vụ qua giao thức snmp, nagios server sẽ sử dụng plugin check_snmp để kiểm tra các dịch vụ trên client có hỗ trợ giao thức SNMP. 
Rất nhiều thiết bị mạng như router, switch, máy in… có hỗ trợ giao thức SNMP.

- Client 5: Đây là phương pháp kiểm tra bị động. Nagios không chủ động kiểm tra dịch vụ mà là client chủ động gửi kết quả kiểm tra dịch vụ về cho Nagios 
thông qua plugin NSCA. Phương pháp này được áp dụng nhiều trong giám sát phân tán. Với các mạng có quy mô lớn, người ta có thể dùng nhiều server Nagios 
để giám sát từng phần của mạng. Trong đó có một server Nagios trung tâm thực hiện tổng hợp kết quả từ các server Nagios con thông qua plugin NSCA.







# Nguồn.

- http://scorpionit.blogspot.com/2016/01/tim-hieu-va-trien-khai-dich-vu-giam-sat.html?q=nagios
