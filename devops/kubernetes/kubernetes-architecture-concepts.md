- [1. Kiến trúc và các thành phần trong K8S](#1-kiến-trúc-và-các-thành-phần-trong-k8s)
  - [1.1. etcd](#11-etcd)
  - [1.2. API-server](#12-api-server)
  - [1.3. Controller-manager](#13-controller-manager)
  - [1.4. Scheduler](#14-scheduler)
  - [1.5. Agent - kubelet](#15-agent---kubelet)
  - [1.6. Proxy](#16-proxy)
  - [1.7. CLI](#17-cli)
- [2. Pod network](#2-pod-network)
- [3. Tại sao trên node master cũng có các thành phần `kubelet` và `kube-proxy`](#3-tại-sao-trên-node-master-cũng-có-các-thành-phần-kubelet-và-kube-proxy)
- [4. Các khái niệm trong K8S](#4-các-khái-niệm-trong-k8s)
  - [4.1. Pod](#41-pod)
  - [4.2. Replication Controllers](#42-replication-controllers)
  - [4.3. Services](#43-services)
  - [4.4. Volumes](#44-volumes)
  - [4.5. Namespaces](#45-namespaces)
  - [4.6. ConfigMap (cm) - Secret](#46-configmap-cm---secret)
  - [4.7. Labels - Annotations](#47-labels---annotations)

# 1. Kiến trúc và các thành phần trong K8S

Phần này sẽ mô tả về kiến trúc và các thành phần trong K8S. Muốn hiểu phần này được tốt nhất thì nên đọc phần bài về [giới thiệu K8S](./01.Gioithieuve_Kubernetes.md/) và [cài đặt K8S](./02.Caidat-Kubernetes.md/)

Như trong phần [cài đặt K8S](./02.Caidat-Kubernetes.md/) chúng ta có thể nhìn thấy các thành phần `kubeadm, kubelet, kube-proxy, ectd, flannet` nằm trên các node. Trong phần này ta sẽ làm rõ hơn về chúng.

Kubernetes được xếp vào một trong các orchestration tools nằm trong hệ sinh thái của container. Do vậy K8S có các thành phần để đảm bảo thực hiện được việc tự động triển khai, mở rộng và vận hành container trên các cụm cluster (chính là các máy chạy các container sau này).

Kubernetes có thể được triển khai trên một hoặc nhiều máy vật lý, máy ảo hoặc cả máy vật lý và máy ảo để tạo thành cụm cluster. Cụm cluster này chịu sự điều khiển của Kubernetes và sinh ra các container khi người dùng yêu cầu. Kiến trúc logic của Kubernetes bao gồm 02 thành phần chính dựa theo vai trò của các node, đó là: `Master node` và `Worker node`

- `Master node`: Đóng vai trò là thành phần Control plane, điều khiển toàn bộ các hoạt động chung và kiểm soát các container trên `node worker`. Các thành phần chính trên `master node` bao gồm: `API-server, Controller-manager, Schedule, Etcd và cả Docker Engine`. Lưu ý: Có thể trong hình vẽ dưới bạn không nhìn thấy thành phần là docker được hiển thị ra nhưng trên `master node`  cần có docker, lý do là để chạy các thành phần của K8S trên các container.

- `Worker node`: Vai trò chính của `worker node` là môi trường để chạy các container mà người dùng yêu cầu, do vậy thành phần chính của `worker node` bao gồm: `kubelet, kube-proxy` và chắc chắn là `Docker`

Thường thì khi triển khai thực tế thì số lượng `node worker` sẽ nhiều hơn số lượng `node master`. Do vậy `node master` hay chính xác là K8S cần hoàn thành tốt nhiệm vụ liên quan tới việc quản lý, xử lý các container sao cho linh hoạt và trơn tru nhất. Ngoài ra, nếu như với các hệ thống thực tế cần có khả năng `High Availability` thì chúng ta cần triển khai nhiều `node master`

![architecture-K8S](../../images/devops/kubernetes/kubernetes-architecture.jpg)

Các thành phần chính trong cụm cluster K8S bao gồm:

- ectd
- API-server
- Controller-manager
- Schedule
- Agent
- Proxy 
- CLI

Tuy một số thành phần kể tên ở trên không được liệt kê trong hình vẽ nhưng chúng là thành phần cần phải có để đảm bảo hoạt động của cụm Cluseter K8S. Sau đây chúng ta sẽ mô tả về vài trò của các thành phần chính trong kiến trúc của K8S. Sau khi hoàn tất phần này, chúng ta sẽ tìm hiểu về các khái niệm chính, mục tiêu là để người đọc hiểu được các thuật ngữ khi làm việc này này với K8S. 


## 1.1. etcd
- Etcd là một thành phần database phân tán, sử dụng ghi dữ liệu theo cơ chế `key/value` trong K8S cluster. Etcd được cài trên node master và lưu tất cả các thông tin trong Cluser. Etcd sử dụng port 2380 để listening từng request và port 2379 để client gửi request tới.
- Ectd nằm trên node master.

## 1.2. API-server
- API server là thành phần tiếp nhận yêu cầu của hệ thống K8S thông qua REST, tức là nó tiếp nhận các chỉ thị từ người dùng cho đến các services trong hệ thống Cluster thông qua API - có nghĩa là người dùng hoặc các service khác trong cụm cluster có thể tương tác tới K8S thông qua HTTP/HTTPS.

- API-server hoạt động trên port 6443 (HTTPS) và 8080 (HTTP).
- API-server nằm trên node master.

## 1.3. Controller-manager
- Thành phần controller-manager là thành phần quản lý trong K8S, nó có nhiệm vụ xử lý các tác vụ trong cụm cluster để đảm bảo hoạt động của các tài nguyên trong cụm cluster. Controller-manager có các thành phần bên trong như sau:

  - Node Controller: Tiếp nhận và trả lời các thông báo khi có một node bị down.
  - Replication Controller: Đảm bảo các công việc duy trì chính xác số lượng bản replicate và phân phối các container trong pod (Pod tạm hình dung là một tập hợp các container khi người dùng có nhu cầu tạo ra và cùng thực hiện chạy một ứng dụng).
  - Endpoints Controller: Populates the Endpoints object (i.e., join Services & Pods).
  - Service Account & Token Controllers:  Tạo ra các accounts và token để có thể sử dụng được các API cho các namespaces.

- Thành phần controller-manager hoạt động trên node master và sử dụng port 10252.

## 1.4. Scheduler

kube-scheduler có nhiệm vụ quan sát để lựa chọn ra các node mỗi khi có yêu cầu tạo pod. Nó sẽ lựa chọn các node sao cho phù hợp nhất dựa vào các cơ chế lập lịch mà nó có. Kube-scheduler được cài đặt trên node master và sử dụng port 10251.

## 1.5. Agent - kubelet
- Agent hay chính là kubelet, một thành phần chạy chính trên các node worker. Khi kube-scheduler đã xác định được một pod được chạy trên node nào thì nó sẽ gửi các thông tin về cấu hình (images, volume ...) tới kubelet trên node đó. Dựa vào thông tin nhận được thì kubelet sẽ tiến hành tạo các container theo yêu cầu.
- Vai trò chính của kubelet là: 
  - Dõi theo các pod trên node được gán để hoạt động. 
  - Mount các volume cho pod
  - Đảm bảo hoạt động của các container của pod hoạt động tốt trên node đó (node worker có cài docker đó).
  - Report về trạng thái của các pod để cụm cluster biết được xem các container còn hoạt động tốt hay không.

- Kubelet chạy trên các node worker và sử dụng port 10250 và 10255.

## 1.6. Proxy 
- Các service chỉ hoạt động ở chế độ logic, do vậy muốn bên ngoài có thể truy cập được vào các service này thì cần có thành phần chuyển tiếp các request từ bên ngoài và bên trong. 
- Kube-proxy được cài đặt trên các node worker, sử dụng port 31080

## 1.7. CLI

- kubectl là thành phần cung cấp câu lệnh để người dùng tương tác với K8S. kubectl có thể chạy trên bất cứ máy nào, miễn là có kết nối được với K8S API-server

# 2. Pod network

Như trong các phần trước, chúng ta còn thấy một thành phần khác đó là pod network, đây là thành phần xử lý về network trong cụm K8S cluster. Pod network đảm bảo cho các container có thể truyền thông được với nhau. Có nhiều lựa chọn về pod network, nhưng trong tài liệu này chỉ giới thiệu về `flannet`


# 3. Tại sao trên node master cũng có các thành phần `kubelet` và `kube-proxy`
- Trong hình dưới ta có thể thấy trên node master có các thành phần là `kubelet` và `kube-proxy`. Tại sao lại như vậy.

![K8S-topology](../../images/devops/kubernetes/kubernetes-topology.png)

Câu trả lời là: Do các node master cũng có các service (ứng dụng) được sử dụng để đảm bảo hoạt động của K8S, do vậy chúng được chạy trong các container và thuộc một pod với namespaces là `kube-system`.

Ta có thể sử dụng lệnh `kubectl get pod --all-namespaces -o wide` để quan sát việc này. Kết quả của lệnh như dưới.

```sh
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get pod --all-namespaces -o wide
```

Kết quả như sau (chú ý quan sát ở cột `NODE`): 
```sh
NAMESPACE     NAME                             READY     STATUS    RESTARTS   AGE       IP              NODE
kube-system   etcd-master                      1/1       Running   0          1d        172.16.68.130   master
kube-system   kube-apiserver-master            1/1       Running   0          1d        172.16.68.130   master
kube-system   kube-controller-manager-master   1/1       Running   0          1d        172.16.68.130   master
kube-system   kube-dns-6f4fd4bdf-ctxx7         3/3       Running   0          1d        10.244.0.2      master
kube-system   kube-flannel-ds-kjnhs            1/1       Running   0          1d        172.16.68.130   master
kube-system   kube-flannel-ds-wz648            1/1       Running   0          1d        172.16.68.131   node1
kube-system   kube-flannel-ds-xtcj9            1/1       Running   0          1d        172.16.68.132   node2
kube-system   kube-proxy-5slwp                 1/1       Running   0          1d        172.16.68.132   node2
kube-system   kube-proxy-5trrj                 1/1       Running   0          1d        172.16.68.130   master
kube-system   kube-proxy-b54bs                 1/1       Running   0          1d        172.16.68.131   node1
kube-system   kube-scheduler-master            1/1       Running   0          1d        172.16.68.130   master
```

Ngoài ra, riêng thành phần kubelet trên `master node` thì không chạy trong container, thay vào đó thì kubelet chạy như một service trong hệ điều hành. Ta có thể kiểm tra bằng lệnh kiểm tra hoạt động của service kubelet.

```sh
  systemctl status kubelet
```

Kết quả: 

```sh
● kubelet.service - kubelet: The Kubernetes Node Agent
    Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/kubelet.service.d
            └─10-kubeadm.conf
    Active: active (running) since Thu 2018-01-25 23:50:36 +07; 1 day 21h ago
      Docs: http://kubernetes.io/docs/
  Main PID: 11378 (kubelet)
    Tasks: 16
    Memory: 46.7M
      CPU: 1h 45min 52.258s
    CGroup: /system.slice/kubelet.service
            └─11378 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --pod-manifest-path=/etc/kubernetes/manife

Jan 26 00:14:03 master kubelet[11378]: W0126 00:14:03.070593   11378 kubelet.go:1592] Deleting mirror pod "etcd-master_kube-system(2141fb05-01f3-11e8-a135-525400811cc0)" because it i
Jan 26 00:14:03 master kubelet[11378]: W0126 00:14:03.162630   11378 kubelet.go:1592] Deleting mirror pod "kube-apiserver-master_kube-system(217a6f08-01f3-11e8-a135-525400811cc0)" be
Jan 26 00:14:03 master kubelet[11378]: W0126 00:14:03.216007   11378 kubelet.go:1592] Deleting mirror pod "kube-controller-manager-master_kube-system(21b796d0-01f3-11e8-a135-52540081
Jan 26 00:14:03 master kubelet[11378]: W0126 00:14:03.317123   11378 kubelet.go:1592] Deleting mirror pod "kube-scheduler-master_kube-system(21d62e54-01f3-11e8-a135-525400811cc0)" be
Jan 26 00:14:12 master kubelet[11378]: W0126 00:14:12.846969   11378 conversion.go:110] Could not get instant cpu stats: different number of cpus
Jan 26 00:14:29 master kubelet[11378]: I0126 00:14:29.425093   11378 reconciler.go:217] operationExecutor.VerifyControllerAttachedVolume started for volume "kube-dns-config" (UniqueN
Jan 26 00:14:29 master kubelet[11378]: I0126 00:14:29.427162   11378 reconciler.go:217] operationExecutor.VerifyControllerAttachedVolume started for volume "kube-dns-token-tpdkw" (Un
Jan 26 00:14:30 master kubelet[11378]: W0126 00:14:30.147023   11378 pod_container_deletor.go:77] Container "7cb2acf1d1e6fa6183dcde381bbf120ff60308ac77a55921f23de2618130df52" not fou
Jan 26 00:14:53 master kubelet[11378]: W0126 00:14:53.026037   11378 conversion.go:110] Could not get instant cpu stats: different number of cpus
Jan 26 00:15:03 master kubelet[11378]: W0126 00:15:03.045872   11378 conversion.go:110] Could not get instant cpu stats: different number of cpus
lines 1-23/23 (END)
```

# 4. Các khái niệm trong K8S

- Nắm được các khái niệm trong K8S sẽ giúp bạn tìm hiểu K8S một cách chắc chắn và am hiểu hơn khi đọc thêm các tài liệu khác (ngoài tài liệu này)
- Có rất nhiều khái niệm mới khi tiếp cận với Kubernetes (K8S) cần nắm được khi mới bắt đầu tìm hiểu. 
- Trong tài liệu này sẽ giới thiệu một cách đơn giản nhất về các khái niệm này, có thể trong quá trình giới thiệu sẽ kèm theo các hình ảnh hoặc kết quả lệnh.
- Ta nên có một cụm K8S đã được triển khai để cùng thực hành hoặc cùng quan sát khi các ví dụ được minh họa.
- Có các khái niệm chính như sau trong K8S:
  - Pods
  - Labels
  - Replica Controllers
  - Replica Sets
  - Deployments
  - Services
  - Volumes
  - Config Maps
  - Daemons
  - Jobs
  - Cron Jobs
  - Namespaces
  - Quotas and Limits

## 4.1. Pod
- Pod là 1 nhóm (1 trở lên) các container chứa ứng dụng cùng chia sẽ các tài nguyên lưu trữ, địa chỉ ip...
- Pod có thể chạy theo 2 cách sau:
  - **Pods that run a single container.**: 1 container tương ứng với 1 pod.
  - **Pods that run multiple containers that need to work together.**: Một Pod có thể là một ứng dụng bao gồm nhiều container
  được kết nối chặt chẽ và cần phải chia sẻ tài nguyên với nhau giữa các container.

- Pods cung cấp hai loại tài nguyên chia sẻ cho các containers: networking và storage.
- **Networking**: Mỗi pod sẽ được cấp 1 địa chỉ ip. Các container trong cùng 1 Pod cùng chia sẽ network namespace (địa chỉ ip và port).
Các container trong cùng pod có thể giao tiếp với nhau và có thể giao tiếp với các container ở pod khác (use the shared network resources).

- **Storage**: Pod có thể chỉ định một `shared storage volumes`. Các container trong pod có thể truy cập vào volume này.

## 4.2. Replication Controllers
- Replication controller đảm bảo rằng số lượng các pod replicas đã định nghĩa luôn luôn chạy đủ số lượng tại bất kì thời điểm nào. 
- Thông qua Replication controller, Kubernetes sẽ quản lý vòng đời của các pod, bao gồm scaling up and down, rolling deployments, and monitoring.

## 4.3. Services
- Vì pod có tuổi thọ ngắn nên không đảm bảo về địa chỉ IP mà chúng được cung cấp. 
- Service là khái niệm được thực hiện bởi : domain name, và port. Service sẽ tự động "tìm" các pod được đánh label phù hợp (trùng với label của service), rồi chuyển các connection tới đó.
- Nếu tìm được 5 pods thoả mã label, service sẽ thực hiện load-balancing: chia connection tới từng pod theo chiến lược được chọn (VD: round-robin: lần lượt vòng tròn).
- Mỗi service sẽ được gán 1 domain do người dùng lựa chọn, khi ứng dụng cần kết nối đến service, ta chỉ cần dùng domain là xong. Domain được quản lý bởi hệ thống name server SkyDNS nội bộ của k8s - một thành phần sẽ được cài khi ta cài k8s.
- Đây là nơi bạn có thể định cấu hình cân bằng tải cho nhiều pod và `expose` các pod đó.


## 4.4. Volumes
- Volumes thể hiện vị trí nơi mà các container có thể truy cập và lưu trữ thông tin.
- Volumes có thể là local filesystem,local storage, Ceph, Gluster, Elastic Block Storage,..
- Persistent volume (PV)  là khái niệm để đưa ra một dung lượng lưu trữ THỰC TẾ 1GB, 10GB ...
- Persistent volume claim (PVC) là khái niệm ảo, đưa ra một dung lượng CẦN THIẾT, mà ứng dụng yêu cầu.

Khi 1 PV thoả mãn yêu cầu của 1 PVC thì chúng "match" nhau, rồi "bound" (buộc / kết nối) lại với nhạu. 

## 4.5. Namespaces
- Namespace hoạt động như một cơ chế nhóm bên trong Kubernetes.
- Các Services, pods, replication controllers, và volumes có thể dễ dàng cộng tác trong cùng một namespace.
- Namespace cung cấp một mức độ cô lập với các phần khác của cluster.

## 4.6. ConfigMap (cm) - Secret
- ConfigMap là giải pháp để nhét 1 file config / đặt các ENVironment var hay set các argument khi gọi câu lệnh. ConfigMap là một cục config, mà pod nào cần, thì chỉ định là nó cần - giúp dễ dàng chia sẻ file cấu hình.
- secret dùng để lưu trữ các mật khẩu, token, ... hay những gì cần giữ bí mật. Nó nằm bên trong container.

## 4.7. Labels - Annotations
- Labels: Là các cặp  **key-value** được Kubernetes đính kèm vào pods, replication controllers,...
- Annotations: You can use Kubernetes annotations to attach arbitrary non-identifying metadata to objects. Clients such as tools and libraries can retrieve this metadata.
- Labels can be used to select objects and to find collections of objects that satisfy certain conditions. In contrast, annotations are not used to identify and select objects. 