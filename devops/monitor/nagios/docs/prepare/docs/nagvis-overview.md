# Tìm hiểu về Nagvis.

===========================================================

# Mục lục.

[1. Nagvis là gì?](#1)

[2. Nagvis làm việc như thế nào?](#2)

[3. Cài đặt.](#3)

[4. Hướng dẫn sử dụng.](#4)</br>
        -  [4.1. Đổi ngôn ngữ.](#4.1)</br>
        -  [4.2. Tích hợp Nagvis với Nagios sử dụng ndo2db.](#4.2)</br>
        -  [4.3. Tích hợp Nagvis với Nagios sử dụng mklivestatus.](#4.3)</br>
        -  [4.4. Những thao tác ban đầu với nagvis.](#4.4)


===========================================================

<a name="1"></a>
## 1. Nagvis là gì?

Nagvis là một addon trực quan giúp cho chúng ta có thể thấy được hệ thống quản lý mạng Nagios.

Nagvis có thể cho chúng ta thấy được dữ liệu từ Nagios (ví dụ như hiển thị các IT process như là một mail system hoặc một cơ sở hạ tầng mạng). Sử dụng dữ liệu được cung cấp bởi backend nó sẽ cập nhật vị trí của các đối tượng trên map trong khoảng thời gian nhất định để phản ánh tình trạng hiện tại . Các maps cho phép chúng ta thay đổi các đối tượng để có thể hiển thị chúng trên các layouts khác nhau : 

- Physical : tất cả các host trong một rack/room/department.

- Logical : Tất cả các application servers.

- Geographical : Tất cả các hosts trong một khu vực.

- Business processes : Tất cả các host và services liên quan tới một processs.

<a name="2"></a>
## 2. Nagvis làm việc như thế nào.

Nói chung Nagvis là công cụ phục vụ cho việc hiển thị các các thông tin được thu thập bởi Nagios và chuyển giao thông qua các backends.

Nó hỗ trợ các backends :

- Mklivestatus : mặc định từ bản Nagvis 1.5.

- NDoutils/IDoutils (yêu cầu Mysql).

- Merlin (yêu cầu Mysql).

Backend sẽ lấy thông tin từ Nagios process (mklivestatus) hoặc từ một cơ sở dữ liệu (NDoutils, IDoutils,merlin).

Chúng ta có thể đặt tất cả các đối tượng từ Nagios (Host, Services, Hostgroups, Servicegroups) trên một thứ được gọi là maps. Một map cần được cấu hình thông qua một file cấu hình .CHúng ta có thể chinh sửa file cấu hình này bằng một trình sửa văn bản như `vi` hoặc có thể chỉnh sửa thông qua web. Hơn nữa chúng ta có thể thêm một vài những đối tượng đặc biệt trên Nagvis . Những đối tượng đó là  shapes, textboxes và tham khảo các đối tượng từ các maps khác.

Mỗi đối tượng trên maps của chúng ta đều có thể được cấu hình đúng như những gì chúng ta cần . Ví dụ chúng ta có những liên kết đến giao diện Nagios đến mỗi đối tượng đại diện cho Nagios. Chúng ta có thể tùy chỉnh cho các liên kết này. 

<a name="3"></a>
## 3. Cài đặt.

Tải file cài đặt từ git :

```sh
cd /opt
git clone https://github.com/NagVis/nagvis.git
```

Cài đặt gói `graphviz` . Khi cài đặt hệ thống không thể tự động tìm được các gói `graphviz` cho lên chúng ta cài đặt trước gói này :

```sh
yum install graphviz -y
```

Phân quyền và cài đặt :

```sh
cd nagvis
chmod +x install.sh
./install.sh
```

Cài đặt theo hướng dẫn có sẵn . Sau khi cài đặt xong chúng ta check file log :

```sh
cat install.log
```

Kiểm tra lại file log :

```sh
[root@nagios-core nagvis]# cat install.log
+------------------------------------------------------------------------------+
| Welcome to NagVis Installer 1.9.4                                            |
+------------------------------------------------------------------------------+
| This script is built to facilitate the NagVis installation and update        |
| procedure for you. The installer has been tested on the following systems:   |
| - Debian, since Etch (4.0)                                                   |
| - Ubuntu, since Hardy (8.04)                                                 |
| - SuSE Linux Enterprise Server 10 and 11                                     |
|                                                                              |
| Similar distributions to the ones mentioned above should work as well.       |
| That (hopefully) includes RedHat, Fedora, CentOS, OpenSuSE                   |
|                                                                              |
| If you experience any problems using these or other distributions, please    |
| report that to the NagVis team.                                              |
+------------------------------------------------------------------------------+
| Do you want to proceed? [y]: +------------------------------------------------------------------------------+
| Starting installation of NagVis 1.9.4                                        |
+------------------------------------------------------------------------------+
|                                                                              |
+--- Checking for tools -------------------------------------------------------+
| Using packet manager /usr/bin/rpm                                      found |
|                                                                              |
+--- Checking paths -----------------------------------------------------------+
| Please enter the path to the nagios base directory [/usr/local/nagios]: |   nagios path /usr/local/nagios                                        found |
| Please enter the path to NagVis base [/usr/local/nagvis]: |                                                                              |
+--- Checking prerequisites ---------------------------------------------------+
| PHP 5.4                                                                found |
|   PHP Module: gd                                                     MISSING |
|   PHP Module: mbstring                                               MISSING |
|   PHP Module: gettext compiled_in                                      found |
|   PHP Module: session compiled_in                                      found |
|   PHP Module: xml compiled_in                                          found |
|   PHP Module: pdo php                                                  found |
|   Apache mod_php                                                       found |
| Do you want to update the backend configuration? [n]: | Graphviz 2.30                                                          found |
|   Graphviz Module dot 2.30.1                                           found |
|   Graphviz Module neato 2.30.1                                         found |
|   Graphviz Module twopi 2.30.1                                         found |
|   Graphviz Module circo 2.30.1                                         found |
|   Graphviz Module fdp 2.30.1                                           found |
| SQLite 3.7                                                             found |
|                                                                              |
+--- Trying to detect Apache settings -----------------------------------------+
| Please enter the web path to NagVis [/nagvis]: | Please enter the name of the web-server user [apache]: | Please enter the name of the web-server group [apache]: | create Apache config file [y]: |                                                                              |
+--- Checking for existing NagVis ---------------------------------------------+
| NagVis 1.9.4                                                           found |
| Do you want the installer to update your config files when possible? [y]: | Remove backup directory after successful installation? [n]: |                                                                              |
+------------------------------------------------------------------------------+
| Summary                                                                      |
+------------------------------------------------------------------------------+
| NagVis home will be:           /usr/local/nagvis                             |
| Owner of NagVis files will be: apache                                        |
| Group of NagVis files will be: apache                                        |
| Path to Apache config dir is:  /etc/httpd/conf.d                             |
| Apache config will be created: yes                                           |
|                                                                              |
| Installation mode:             update                                        |
| Old version:                   1.9.4                                         |
| New version:                   1.9.4                                         |
| Backup directory:              /usr/local/nagvis.old-2017-10-05_03:54:38     |
|                                                                              |
| Note: The current NagVis directory will be moved to the backup directory.    |
|       The backup directory will be NOT removed after successful installation |
|       Your configuration files will be copied.                               |
|       The configuration files will be updated if possible.                   |
|                                                                              |
| Do you really want to continue? [y]: +------------------------------------------------------------------------------+
| Starting installation                                                        |
+------------------------------------------------------------------------------+
| Moving old NagVis to /usr/local/nagvis.old-2017-10-05_03:54:38..       done  |
| Creating directory /usr/local/nagvis...                                done  |
| Creating directory /usr/local/nagvis/var...                            done  |
| Creating directory /usr/local/nagvis/var/tmpl/cache...                 done  |
| Creating directory /usr/local/nagvis/var/tmpl/compile...               done  |
| Creating directory /usr/local/nagvis/share/var...                      done  |
| Copying files to /usr/local/nagvis...                                  done  |
| Creating directory /usr/local/nagvis/etc/profiles...                   done  |
| Creating main configuration file...                                    done  |
|   Adding webserver group to file_group...                              done  |
| *** /etc/httpd/conf.d/nagvis.conf will NOT be overwritten !                  |
| *** creating /etc/httpd/conf.d/nagvis.conf.2017-10-05_03:54:38 instead (comm |
| Creating web configuration file...                                     done  |
| Setting permissions for web configuration file...                      done  |
|                                                                              |
| Restoring main configuration file(s)...                                done  |
| Restoring custom map configuration files...                            done  |
| Restoring custom geomap source files...                                done  |
| Restoring user configuration files...                                  done  |
| Restoring conf.d/ configuration files...                               done  |
| Restoring custom map images...                                         done  |
| Restoring custom gadget images...                                      done  |
| Restoring custom iconsets...                                           done  |
| Restoring custom shapes...                                             done  |
| Restoring custom templates...                                          done  |
| Restoring custom template images...                                    done  |
| Restoring custom gadgets...                                            done  |
| Restoring custom scripts...                                            done  |
| Restoring custom stylesheets...                                        done  |
|                                                                              |
+------------------------------------------------------------------------------+
| Handling changed/removed options                                             |
+------------------------------------------------------------------------------+
| Removing allowedforconfig option from main config...                   done  |
| Removing autoupdatefreq option from main config...                     done  |
| Removing htmlwuijs option from main config...                          done  |
| Removing wuijs option from main config...                              done  |
| Removing showautomaps option from main config...                       done  |
| Removing usegdlibs option from main config...                          done  |
| Removing displayheader option from main config...                      done  |
| Removing hovertimeout option from main config...                       done  |
| Removing requestmaxparams option from main config...                   done  |
| Removing requestmaxlength option from main config...                   done  |
| Removing allowed_for_config option from map configs...                 done  |
| Removing allowed_user from map configs...                              done  |
| Removing hover_timeout from map configs...                             done  |
| Removing usegdlibs from map configs...                                 done  |
| Removing gadget_type from map configs...                               done  |
+------------------------------------------------------------------------------+
| HINT: Please check the changelog or the documentation for changes which      |
|       affect your configuration files                                        |
|                                                                              |
+--- Setting permissions... ---------------------------------------------------+
| /usr/local/nagvis/etc/nagvis.ini.php-sample                            done  |
| /usr/local/nagvis/etc                                                  done  |
| /usr/local/nagvis/etc/maps                                             done  |
| /usr/local/nagvis/etc/maps/*                                           done  |
| /usr/local/nagvis/etc/geomap                                           done  |
| /usr/local/nagvis/etc/geomap/*                                         done  |
| /usr/local/nagvis/etc/profiles                                         done  |
| /usr/local/nagvis/share/userfiles/images/maps                          done  |
| /usr/local/nagvis/share/userfiles/images/maps/*                        done  |
| /usr/local/nagvis/share/userfiles/images/shapes                        done  |
| /usr/local/nagvis/share/userfiles/images/shapes/*                      done  |
| /usr/local/nagvis/var                                                  done  |
| /usr/local/nagvis/var/*                                                done  |
| /usr/local/nagvis/var/tmpl                                             done  |
| /usr/local/nagvis/var/tmpl/cache                                       done  |
| /usr/local/nagvis/var/tmpl/compile                                     done  |
| /usr/local/nagvis/share/var                                            done  |
|                                                                              |
+------------------------------------------------------------------------------+
| Installation complete                                                        |
|                                                                              |
| You can safely remove this source directory.                                 |
|                                                                              |
| For later update/upgrade you may use this command to have a faster update:   |
| ./install.sh -n /usr/local/nagios -p /usr/local/nagvis -u apache -g apache -w /etc/httpd/conf.d -a y
|                                                                              |
| What to do next?                                                             |
| - Read the documentation                                                     |
| - Maybe you want to edit the main configuration file?                        |
|   Its location is: /usr/local/nagvis/etc/nagvis.ini.php                      |
| - Configure NagVis via browser                                               |
|   <http://localhost/nagvis/config.php>                                       |
| - Initial admin credentials:                                                 |
|     Username: admin                                                          |
|     Password: admin                                                          |
+------------------------------------------------------------------------------+

```


Ở đây chúng ta nhận thấy có 2 gói bị miss đó là :

```sh
|   PHP Module: gd                                                     MISSING |
|   PHP Module: mbstring                                               MISSING |
```

Chúng ta tiến hành cài đặt 2 gói không được tìm thấy này :

```sh
yum install php-gd -y
yum install php-mbstring -y
```

Nếu như có file PHP nào bị miss chúng ta cài đặt thêm tương tự như trên.

Restart `httpd` :

```sh
systemctl restart httpd
```

Đăng nhập vào web để kiểm tra :

![scr1](/docs/prepare/images/scr1.png)

<a name="4"></a>
## 4. Hướng dẫn sử dụng.

<a name="4.1"></a>

### 4.1. Đổi ngôn ngữ.

- Khi đăng nhập vào web interface thì ngôn ngữ mặc định là tiếng Đức do đó chúng ta cần đổi lại ngôn ngữ để dễ dàng thao tác vs web interface hơn . Làm theo 2 bước sau  :

Bước 1 :

![scr2](/docs/prepare/images/scr2.png)

Bước 2 : 

![scr3](/docs/prepare/images/scr3.png)

<a name="4.2"></a>

### 4.2. Tích hợp Nagvis với Nagios sử dụng ndo2db.

Yêu cầu : trên máy chủ nagios cần được [cài đặt nagvis](https://github.com/meditechopen/meditech-ghichep-nagios/blob/master/docs/prepare/docs/nagvis-overview.md#3) và được [cài đặt ndoutils](https://github.com/meditechopen/meditech-ghichep-nagios/blob/master/docs/prepare/docs/pull-data-with-MySQl.md) để đẩy dữ liệu ra mysql.

Lưu ý trong phần cài đặt Nagvis đến bước chọn backend, chúng ta chọn `n` với mklivestatus và idodb và chọn `y` với ndo2db.

Khi sử dụng ndo2db nagvis yêu cầu cần có mysql do đó ta cần cài đặt thêm gói `php-mysql` :

```sh
yum install php-mysql -y
```

Khởi động lại dịch vụ httpd :

```sh
systemctl restart httpd
```

Sau khi đã cài đặt được ndo2db và đẩy dữ liệu ra Mysql thành công và đã cài đặt được nagvis chúng ta tiến hành cấu hình lại để nagvis có thể lấy được dữ liệu thông qua ndo2db.

- Mở file cấu hình bằng trình soạn thảo `vi` :

    ```sh
    vi /usr/local/nagvis/etc/nagvis.ini.php
    ```

-  Tìm và sửa lại đoạn cấu hình ở section [backend_ndomy_1] như sau :

    ```sh
    [backend_ndomy_1]
    ; type of backend - MUST be set
    backendtype="ndomy"
    ; The status host can be used to prevent annoying timeouts when a backend is not
    ; reachable. This is only useful in multi backend setups.
    ;
    ; It works as follows: The assumption is that there is a "local" backend which
    ; monitors the host of the "remote" backend. When the remote backend host is
    ; reported as UP the backend is queried as normal.
    ; When the remote backend host is reported as "DOWN" or "UNREACHABLE" NagVis won't
    ; try to connect to the backend anymore until the backend host gets available again.
    ;
    ; The statushost needs to be given in the following format:
    ;   "<backend_id>:<hostname>" -> e.g. "live_2:nagios"
    ;statushost=""
    ; hostname for NDO-db
    dbhost="localhost"
    ; portname for NDO-db
    dbport=3306
    ; database name for NDO-db
    dbname="nagios"
    ; username for NDO-db
    dbuser="ndoutils"
    ; password for NDO-db
    dbpass="ndoutils_password"
    ; prefix for tables in NDO-db
    ;dbprefix="nagios_"
    ; instance name for tables in NDO-db
    ;dbinstancename="default"
    ; maximum delay of the NDO Database in seconds
    ;maxtimewithoutupdate=180
    ; path to the cgi-bin of this backend
    ;htmlcgi="/nagios/cgi-bin"

    ```

- Restart lại các dịch vụ :

```sh
systemctl restart ndo2db
systemctl restart nagios
```

<a name="4.3"></a>

### 4.3. Tích hợp Nagvis với Nagios sử dụng mklivestatus.

#### Yêu cầu : 

Trên máy chủ nagios cần được cái đặt mklive status. Đối với Nagios 4.x trở lên thì chỉ hỗ trợ mklivestatus phiên bản từ 1.2.4 trở lên. Ở đây chúng ta tiến hành cài đặt mklivestatus

- Tải bản cài đặt nagios về máy :

    ```sh
    cd /opt
    wget https://mathias-kettner.de/download/mk-livestatus-1.2.8p18.tar.gz
    ```

- Tiến hành giải nén :

    ```sh
    tar xzf mk-livestatus-1.2.8p18.tar.gz
    cd mk-livestatus-1.2.8p18
    ```

- Cài đặt :

    ```sh
    ./configure --with-nagios4
    ```

- Cài đặt các gói phụ trợ và thiết lập cho quá trình complie :

    ```sh
    yum install centos-release-scl -y
    yum install devtoolset-4 -y

    export CC=/opt/rh/devtoolset-4/root/usr/bin/gcc
    export CPP=/opt/rh/devtoolset-4/root/usr/bin/cpp
    export CXX=/opt/rh/devtoolset-4/root/usr/bin/c++

    scl enable devtoolset-4 bash
    ```

- Tiến hành complie :

    ```sh
    cd /opt/mk-livestatus-1.2.8p18
    make
    make install
    ```

- Thêm broker module :

    ```sh
    echo "broker_module=/usr/local/lib/mk-livestatus/livestatus.o /usr/local/nagios/var/rw/live" >> /usr/local/nagios/etc/nagios.cfg
    ```

- Mở file cấu hình nagvis :

    ```sh
    vi /usr/local/nagvis/etc/nagvis.ini.php
    ```

- Tìm đến section [backend_live_1] và sửa lại các thông số như sau :

    ```sh
    [backend_live_1]
    backendtype="mklivestatus"
    ; The status host can be used to prevent annoying timeouts when a backend is not
    ; reachable. This is only useful in multi backend setups.
    ;
    ; It works as follows: The assumption is that there is a "local" backend which
    ; monitors the host of the "remote" backend. When the remote backend host is
    ; reported as UP the backend is queried as normal.
    ; When the remote backend host is reported as "DOWN" or "UNREACHABLE" NagVis won't
    ; try to connect to the backend anymore until the backend host gets available again.
    ;
    ; The statushost needs to be given in the following format:
    ;   "<backend_id>:<hostname>" -> e.g. "live_2:nagios"
    ;statushost=""
    socket="unix:/usr/local/nagios/var/rw/live"

    ; Example definition for a MySQL backend
    ; in this example the ID of the Backend is "ndomy_1" you can define another ID.
    ```

- Khởi động lại hệ thống :

    ```sh
    systemctl restart nagios
    ```

- Check log nagios để kiểm tra :

    ```sh
    tailf /usr/local/nagios/var/nagios/log
    ```

- Kết quả :

    ```sh
    Event broker module '/usr/local/lib/mk-livestatus/livestatus.o' deinitialized successfully.
    ```

Trên máy chủ nagios cần được [cài đặt nagvis](https://github.com/meditechopen/meditech-ghichep-nagios/blob/master/docs/prepare/docs/nagvis-overview.md#3) 

- Lưu ý , cài đặt nagvis sử dụng mklivestatus yêu cầu `php-pdo` , gói này không tìm thấy trong quá trình cài đặt, sau khi hoàn tất các bước cài đặt nagvis chúng ta tiến hành cài đặt thêm các gói còn thiếu như sau :

    ```sh
    yum install php-pdo -y
    systemctl restart httpd
    ```

- Sau khi hoàn thành tất cả các bước chúng ta có thể truy cập vào web interface của nagvis để sử dụng với backend mklivestatus.

<a name="4.4"></a>

### 4.4. Những thao tác ban đầu với nagvis.

Sau khi đã hoàn thành các bước ở phần 4.2 chúng ta có thể truy cập theo đường link `ip/nagvis` và tiến hành sử dụng.

#### 4.4.1. Tạo một map mới :

- Bước 1 : chọn tab `Options` và lựa chọn `Manage Maps` :

![manage-map](/docs/prepare/images/manage-map.png)

- Bước 2 : Điền thông tin về tên map và alias và chọn `create`

![create-map](/docs/prepare/images/create-map.png)

Như thế chúng ta đã hoàn thành thêm một map mới.

#### 4.4.2. Thêm một host vào trong map.

-  Bước 1 : Chọn `Edit Map` >> `Add Icon` >> `Host` :

![addhost1](/docs/prepare/images/addhost1.png)

- Bước 2 : Chọn host muốn thêm vào map và các tùy chọn bổ sung :

![addhost2](/docs/prepare/images/addhost2.png)

![addhost3](/docs/prepare/images/addhost3.png)

![addhost4](/docs/prepare/images/addhost4.png)


####  4.4.3. Thêm một service mới.

- Bước 1 : 

![addservice1](/docs/prepare/images/addservice1.png)

- Bước 2 : 

![addservice2](/docs/prepare/images/addservice2.png)

![addservice3](/docs/prepare/images/addservice3.png)

![addservice4](/docs/prepare/images/addservice4.png)


#### 4.4.4. Tạo một graph để theo dõi services.

- Bước 1 : 

![graph1](/docs/prepare/images/graph1.png)

- Bước 2 :

![graph2](/docs/prepare/images/graph2.png)

![graph3](/docs/prepare/images/graph3.png)

![graph4](/docs/prepare/images/graph4.png)