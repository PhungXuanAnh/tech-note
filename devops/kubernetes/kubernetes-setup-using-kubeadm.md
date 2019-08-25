- [1. Giới thiệu](#1-giới-thiệu)
- [2. Server info](#2-server-info)
- [3. Prepare](#3-prepare)
  - [3.1. Disable swap](#31-disable-swap)
  - [3.2. Setup hostname](#32-setup-hostname)
  - [3.3. Install docker](#33-install-docker)
  - [3.4. Install kubernetes](#34-install-kubernetes)
- [4. Thiết lập cluster](#4-thiết-lập-cluster)
- [5. Chạy thử ứng dụng](#5-chạy-thử-ứng-dụng)
  - [5.1. Tạo ứng dụng bằng lệnh kubectl](#51-tạo-ứng-dụng-bằng-lệnh-kubectl)
    - [5.1.1. Bước 1: Tạo container](#511-bước-1-tạo-container)
    - [5.1.2. Bước 2: Thực hiện deploy ứng dụng trên](#512-bước-2-thực-hiện-deploy-ứng-dụng-trên)
  - [5.2. Tạo các ứng dụng với file yaml](#52-tạo-các-ứng-dụng-với-file-yaml)
- [6. Cài đặt Kubernetes Dashboard](#6-cài-đặt-kubernetes-dashboard)
  - [6.1. setup](#61-setup)
  - [6.2. cấu hình](#62-cấu-hình)

# 1. Giới thiệu

Kubeadm là một công cụ giúp tự động hóa quá trình cài đặt và triển khai kubernetes trên môi trường Linux, do chính kubernetes hỗ trợ.

# 2. Server info

| hostname | ip              |
| -------- | --------------- |
| master   | 188.166.238.211 |
| node     | 178.128.212.142 |

# 3. Prepare

Chạy các lệnh sau trên tất cả các node

## 3.1. Disable swap

` swapoff -a`

## 3.2. Setup hostname


```shell
vim /etc/hosts

188.166.238.211       k8s-master
178.128.212.142       k8s-node
```

## 3.3. Install docker

Install using command [here](https://gist.github.com/PhungXuanAnh/ed5750833dfaf39b9044396cb6ab227e)

## 3.4. Install kubernetes

Trên tất cả các node sẽ cài các thành phần: docker, kubelet, kubeadm và kubectl. Trong đó:

- kubeadm: Được sử dụng để thiết lập cụm cluster cho K8S. (Cluster là một cụm máy thực hiện chung một mục đích). Các tài liệu chuyên môn gọi kubeadm là bột bootstrap (bootstrap tạm hiểu một tools đóng gói để tự động làm việc gì đó)
- kubelet: Là thành phần chạy trên các host, có nhiệm vụ kích hoạt các pod và container trong cụm Cluser của K8S.
- kubectl: Là công cụ cung cấp CLI (Giao diện dòng lệnh) để tương tác với K8S.

```shell
apt-get update && apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add 

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update  -y
apt-get install -y kubelet kubeadm kubectl
```

# 4. Thiết lập cluster

On **k8s-master**:

```shell
kubeadm init --apiserver-advertise-address 188.166.238.211 --pod-network-cidr=10.244.0.0/16
```

output:

```shell
➜  ~ kubeadm init --apiserver-advertise-address 188.166.238.211 --pod-network-cidr=10.244.0.0/16
[init] Using Kubernetes version: v1.15.3
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
        [WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.1. Latest validated version: 18.09
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [sender kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 188.166.238.211]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [sender localhost] and IPs [188.166.238.211 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [sender localhost] and IPs [188.166.238.211 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 23.004481 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node sender as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node sender as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: wqx8uf.uh9mcsp2t4p9wz3l
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 188.166.238.211:6443 --token wqx8uf.uh9mcsp2t4p9wz3l \
    --discovery-token-ca-cert-hash sha256:bb8de2584add531ee5effb0ae8a4dd5998e0f6b6d930edd4869cbdfeabf090ff 
➜  ~ 
```

Theo output ở trên thì tiếp tục chạy commands:

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Sau đó là cái đặt network, K8S có nhiều lựa chọn cho giải pháp network để kết nối các container, trong hướng dẫn này chúng ta sử dụng flannel

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

output:

```shell
➜  ~ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created
```

Sau đó dùng token bên trên để  cài đặt worker node join vào cluster này của master, hoặc nếu không nhớ token thì gen ra bằng lệnh:

```shell
kubeadm token create --print-join-command
```

output:

```shell
kubeadm join 188.166.238.211:6443 --token 9oiok2.6i1k4iwr826cycn1     --discovery-token-ca-cert-hash sha256:bb8de2584add531ee5effb0ae8a4dd5998e0f6b6d930edd4869cbdfeabf090ff 
```

Chạy lệnh trên ở các node, ouput:

```shell
➜  ~ kubeadm join 188.166.238.211:6443 --token 9oiok2.6i1k4iwr826cycn1     --discovery-token-ca-cert-hash sha256:bb8de2584add531ee5effb0ae8a4dd5998e0f6b6d930edd4869cbdfeabf090ff 
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

Quay lại master chạy lệnh kiểm tra:

```shell
➜  ~ kubectl get nodes
NAME           STATUS   ROLES    AGE     VERSION
k8s-node       Ready    <none>   2m58s   v1.15.3
k8s-master     Ready    master   17m     v1.15.3
```

Chúng ta có thể thấy ở cột STATUS đã có trạng thái Ready. Tiếp tục thực hiện hiện lệnh dưới để download hoặc kiểm tra trạng thái của các thành phần trong K8S trên các node đã hoạt động hay chưa.

```shell
➜  ~ kubectl get pod --all-namespaces
NAMESPACE     NAME                             READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c98db65d4-2w8cc         1/1     Running   0          18m
kube-system   coredns-5c98db65d4-s8brg         1/1     Running   0          18m
kube-system   etcd-sender                      1/1     Running   0          17m
kube-system   kube-apiserver-sender            1/1     Running   0          17m
kube-system   kube-controller-manager-sender   1/1     Running   0          17m
kube-system   kube-flannel-ds-amd64-99jlz      1/1     Running   0          4m28s
kube-system   kube-flannel-ds-amd64-z77zz      1/1     Running   0          7m58s
kube-system   kube-proxy-5lsrc                 1/1     Running   0          18m
kube-system   kube-proxy-kz64z                 1/1     Running   0          4m28s
kube-system   kube-scheduler-sender            1/1     Running   0          17m
```

Trong một vài trường hợp cột STATUS sẽ có trạng thái Pending, ContainerCreating,ImagePullBackOf đối với một số thành phần, có thể chờ hoặc kiểm tra bằng lệnh `kubectl describe pod <ten_pod> --namespace=kube-system` , ở đây tên pod được lấy từ cột NAME.

```shell
kubectl describe pod kube-scheduler-k8s-master --namespace=kube-system
```

output:

```shell
Name:                 kube-scheduler-sender
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 sender/188.166.238.211
Start Time:           Sat, 24 Aug 2019 14:23:08 +0000
Labels:               component=kube-scheduler
                      tier=control-plane
Annotations:          kubernetes.io/config.hash: 7d5d3c0a6786e517a8973fa06754cb75
                      kubernetes.io/config.mirror: 7d5d3c0a6786e517a8973fa06754cb75
                      kubernetes.io/config.seen: 2019-08-24T14:23:07.061867253Z
                      kubernetes.io/config.source: file
Status:               Running
IP:                   188.166.238.211
Containers:
  kube-scheduler:
    Container ID:  docker://9e7305a0c7cef9745736e13559770568552babb669d72ef8bb3ac53e0c67df00
    Image:         k8s.gcr.io/kube-scheduler:v1.15.3
    Image ID:      docker-pullable://k8s.gcr.io/kube-scheduler@sha256:e365d380e57c75ee35f7cda99df5aa8c96e86287a5d3b52847e5d67d27ed082a
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-scheduler
      --bind-address=127.0.0.1
      --kubeconfig=/etc/kubernetes/scheduler.conf
      --leader-elect=true
    State:          Running
      Started:      Sat, 24 Aug 2019 14:23:10 +0000
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:        100m
    Liveness:     http-get http://127.0.0.1:10251/healthz delay=15s timeout=15s period=10s #success=1 #failure=8
    Environment:  <none>
    Mounts:
      /etc/kubernetes/scheduler.conf from kubeconfig (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kubeconfig:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/scheduler.conf
    HostPathType:  FileOrCreate
QoS Class:         Burstable
Node-Selectors:    <none>
Tolerations:       :NoExecute
Events:
  Type    Reason   Age   From             Message
  ----    ------   ----  ----             -------
  Normal  Pulled   21m   kubelet, sender  Container image "k8s.gcr.io/kube-scheduler:v1.15.3" already present on machine
  Normal  Created  21m   kubelet, sender  Created container kube-scheduler
  Normal  Started  21m   kubelet, sender  Started container kube-scheduler
```

Tới đây chúng ta đã có môi trường để bắt đầu thực hành với K8S rồi.

# 5. Chạy thử ứng dụng

Có 2 cách để tạo ra các tài nguyên để phục vụ các ứng dụng trên cụm cluster K8S:

- Cách 1: Sử dụng trực tiếp lệnh kubectl
- Cách 2: Sử dụng file cấu hình (file yml) và thực thi chúng bằng lệnh kube apply. Có nghĩa là ta sẽ soạn các file theo cú pháp của yml và thực hiện lệnh kubectl apply để thực thi các tác vụ.

Trong phạm vi phần này, sẽ giới thiệu cách 1, cách 2 sẽ được đề cập trong phần nâng cao sau.

- Sau đây, chúng ta sẽ học cách tạo ra một ứng dụng là web server trên K8S, chúng ta sẽ thực hiện lần lượt qua các bước và dần tiếp cận với các khái niệm trong quá trình thực hiện. Trong quá trình thực hiện các bước để tạo ra ứng dụng như người dùng mong muốn, chúng ta sẽ thực hiện thêm các lệnh để quan sát và kiểm chứng lại kết quả.

- Khi các ứng dụng được tạo xong, ta sẽ thử truy cập từ các môi trường như local (chính các máy trong cụm cluster, từ bên ngoài từ máy tính khác các cụm cluster - có thể là laptop hoặc các máy trong mạng LAN với laptop của chúng ta).

- Cuối cùng, ta sẽ thực hiện xóa hoặc hủy các ứng dụng để sẵn sàng cho phần tiếp theo

## 5.1. Tạo ứng dụng bằng lệnh kubectl

Chúng ta sẽ tạo ra một ứng dụng với vai trò là web server với image là nginx trên K8S, sau đó sẽ thực hiện các thao tác quản trị các container, truy cập vào ứng dụng đó từ các môi trường bên trong vào bên ngoài để kiểm tra hoạt động

### 5.1.1. Bước 1: Tạo container

Tạo 02 container với images là nginx, 2 container này chạy dự phòng cho nhau, port của các container là 80

```shell
kubectl run test-nginx --image=nginx --replicas=2 --port=80 
```

output:

```shell
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
```

Tới đây, ta mới tạo ra các container và chỉ có thể truy cập từ các máy trong cụm cluster, bởi vì các container này chưa được mở các port để ánh xạ với các IP của các máy trọng cụm K8S.

Ta có thể kiểm tra lại các container nằm trong các POD bằng lệnh:

```shell
➜  ~  kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
test-nginx-59968fb744-8wr74   1/1     Running   0          4m12s   10.244.1.3   k8s-node   <none>           <none>
test-nginx-59968fb744-9t4g7   1/1     Running   0          4m12s   10.244.1.2   k8s-node   <none>           <none>
```

Trong kết quả trên, ta có thể quan sát thấy trạng thái các container ở cột STATUS và ở cột NODE - nời mà các container được phân phối, số lượng là container sẽ là 2 vì chúng ta đã có tùy chọn --replicas=2, việc phân phố số lượng container này một phần là do thành phần scheduler trong K8S thực hiện. Ngoài ra, trong các phần nâng cao sau của tài liệu này, chúng ta sẽ thực hành thêm việc thay đổi số lượng replicas (tạm hiểu là số lượng container) sau khi đã tạo chúng hoặc sau khi deploy các ứng dụng (điểm khá hay ho của container nói chung và K8S nói riêng).

Ngoài ra ta có thể sử dụng lệnh để dưới để xem các service nào đã sẵn sàng để deployment.

```shell
➜  ~  kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
test-nginx   2/2     2            2           7m57s
```

### 5.1.2. Bước 2: Thực hiện deploy ứng dụng trên

Chính là bước phơi các port của container ra.

Tới bước này, chúng ta chưa thể truy cập vào các container được, cần thực hiện thêm bước deploy các container với các tùy chọn phù hợp, cụ thể như sau

```shell
kubectl expose deploy test-nginx --port 80 --target-port 80 --type NodePort
```

output:

`service/test-nginx exposed`

Ngoài các tùy chọn --port 80 và --target-port 80 thì ta lưu ý tùy chọn --type NodePort, đây là tùy chọn để ánh xạ port của máy cài K8S vào container vừa tạo, sử dụng các lệnh dưới để biết được port mà host ánh xạ là bao nhiêu ở bên dưới.

Quan sát kỹ hơn ứng dụng web server vừa tạo ở trên bằng lệnh

`kubectl describe service test-nginx`

output:

```shell
root@k8s-master:~# kubectl describe service test-nginx
 Name:                     test-nginx
 Namespace:                default
 Labels:                   run=test-nginx
 Annotations:              <none>
 Selector:                 run=test-nginx
 Type:                     NodePort
 IP:                       10.107.71.150
 Port:                     <unset>  80/TCP
 TargetPort:               80/TCP
 NodePort:                 <unset>  30315/TCP
 Endpoints:                10.244.1.5:80,10.244.2.5:80
 Session Affinity:         None
 External Traffic Policy:  Cluster
 Events:                   <none>
 root@k8s-master:~#
```

Trong kết quả này, chúng ta có thể thấy các tham số quan trọng và cần lưu ý như sau:

- IP: 10.107.71.150: là địa chỉ được cấp phát cho ứng dụng test-nginx vừa tạo ở trên, địa chỉ này có ý nghĩa local.

- Endpoints: 10.244.1.5:80,10.244.2.5:80: Đây là địa chỉ của dải mạng nội tại và liên kết các container khi chúng thuộc một POD. Ta có thể đứng trên một trong các node của cụm cluster K8S và thực hiện lệnh curl để truy cập web, ví dụ: curl 10.244.1.5 hoặc curl 10.244.2.5. Kết quả trả về html của web server.

- Port và TargetPort: là các port nằm trong chỉ định ở lệnh khi ta deploy ứng dụng.

- NodePort: <unset> 30315/TCP: Đây chính là port mà ta dùng để truy cập vào web server được tạo ở trên thông qua một trong các IP của các máy trong cụm cluser. Ta sẽ có các kiểm chứng dưới.

Đứng trên node k8s-master thực hiện curl vào một trong các IP sau:

```shell
curl 10.107.71.150 

 hoặc 

 curl 10.244.1.5

 hoặc 

 curl 10.244.2.5
```

Kết quả:

```shell
root@k8s-master:~# curl  10.244.1.5
 <!DOCTYPE html>
 <html>
 <head>
 <title>Welcome to nginx!</title>
 <style>
 		body {
 				width: 35em;
 				margin: 0 auto;
 				font-family: Tahoma, Verdana, Arial, sans-serif;
 		}
 </style>
 </head>
 <body>
 <h1>Welcome to nginx!</h1>
 <p>If you see this page, the nginx web server is successfully installed and
 working. Further configuration is required.</p>

 <p>For online documentation and support please refer to
 <a href="http://nginx.org/">nginx.org</a>.<br/>
 Commercial support is available at
 <a href="http://nginx.com/">nginx.com</a>.</p>

 <p><em>Thank you for using nginx.</em></p>
 </body>
 </html>
```

Đứng trên node k8s-master và thực hiện kiểm tra port được ánh xạ với container (trong kết quả trên là port 30315/TCP)


```shell
root@k8s-master:~# ss -lan | grep 30315
tcp    LISTEN     0      128      :::30315                :::*
root@k8s-master:~#
```

Đứng trên máy Laptop hoặc máy khác cùng dải mạng với dải IP của các node trong cụ K8S, mở trình duyệt web và truy cập với địa chỉ: http://188.166.238.211:30315 hoặc http://178.128.212.142:30315, chúng ta sẽ thấy kết quả:

```shell
Welcome to nginx!
If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

For online documentation and support please refer to nginx.org.
Commercial support is available at nginx.com.

Thank you for using nginx.
```

Sử dụng các lệnh `kubectl get services` để biết được các vices được deploy với việc ánh xạ port là bao nhiêu (đây có thể là cách xem port được ánh xạ với các node).

```shell
➜  ~ kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        59m
test-nginx   NodePort    10.109.78.198   <none>        80:30315/TCP   18m
```

Trước khi kết thúc phần này ta sẽ thực hiện một số lệnh để xóa các service và Pod (các container thuộc Pod) để chuẩn bị cho phần sau.

Thực hiện xóa các service vừa tạo ở trên.

```shell
 kubectl delete service test-nginx
 kubectl delete deployment test-nginx
```

Sau đó kiểm tra lại bằng các lệnh đã dùng ở bên trên

```shell
➜  ~  kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   62m
➜  ~  kubectl get deployments
No resources found.
```

Tới đây, ta đã kết thúc bước cơ bản để thực hiện tạo và quản lý một ứng dụng cơ bản trên cụm cluster K8S

## 5.2. Tạo các ứng dụng với file yaml

Tạo 1 file tên là apache-app.yaml

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: apache2
spec:
  template:
    metadata:
      labels:
        name: apache2
    spec:
      containers:
      - name: apache2
        image: httpd
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: apache2
spec:
  selector:
    name: apache2
  ports:
    - port: 5555
      targetPort: 80
  type: NodePort
```

Sau đó thực hiện lệnh dưới để deploy ứng dụng

```shell
root@k8s-master:~# kubectl create -f apache-app.yaml
deployment.apps "apache-app" created
service "apache-app" created
```

Kiểm tra thêm bằng các lệnh

```shell
➜  ~ kubectl get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
apache2      NodePort    10.103.162.162   <none>        5555:30301/TCP   55s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          70m
➜  ~ kubectl get deployments
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
apache2   1/1     1            1           63s
```

Sử dụng port ở kết quả để truy cập bằng curl hoặc bằng trình duyệt

```shell
curl http://188.166.238.211:30301
curl http://178.128.212.142:30301
```

Như vậy ta đã hoàn tất bước sử dụng file để triển khai các container

# 6. Cài đặt Kubernetes Dashboard

## 6.1. setup

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
# or 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
```

output:

```shell
secret/kubernetes-dashboard-certs created
serviceaccount/kubernetes-dashboard created
role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
deployment.apps/kubernetes-dashboard created
service/kubernetes-dashboard created
```

container này sẽ chạy trong namespace của k8s là kube-system.

## 6.2. cấu hình

Bạn chạy lệnh sau để bắt đầu vào giao diện website:

`kubectl proxy`

Bây giờ, có thể đứng trên Master Node và truy cập vào địa chỉ http://localhost:8001 hoặc http://127.0.0.1:8001 để vào.

Làm cách nào để truy cập từ nơi khác thông qua IP của Master node.

Đầu tiên, bạn phải chỉnh sửa lại một chút trong cấu hình của service kubernetes-dashboard. Chạy lệnh sau:

```shell
kubectl -n kube-system get service kubernetes-dashboard
```

Có một giao diện chỉnh sửa file được mở ra (chắc xài vim). Bạn tìm tới dòng `type: ClusterIP` và đổi nó thành type: `NodePort`. Sau đó nhấn phím `ES`C và `:x` để lưu lại.

Lúc này, service kubernetes-dashboard đã lấy một port trên Master Node để NAT vào port 443 của service. Kiểm tra

```shell
➜  ~ kubectl -n kube-system get service kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.97.92.188   <none>        443:31738/TCP   8m43s
```

Từ trình duyệt trên máy cá nhân, bạn vào đường dẫn sau:

https://188.166.238.211:31738

Nhớ là phải xài HTTPS và thay IP, port tương ứng của Master node.

Tới đây, bạn thêm exception ssl cho trình duyệt. Sẽ hiển thị một màn hình đăng nhập có 02 tùy chọn **Kubeconfig** và **Token**.

Thông thường, sẽ xài token để login. Vậy **token** lấy ở đâu. Bạn làm như sau.

Chạy lệnh liệt kê toàn bộ **secret** đang có trên Master node

`kubectl -n kube-system get secret`

Kết quả của lệnh trên như sau:

```shell
NAME                                             TYPE                                  DATA      AGE
attachdetach-controller-token-2qzmx              kubernetes.io/service-account-token   3         8d
bootstrap-signer-token-4xf4c                     kubernetes.io/service-account-token   3         8d
bootstrap-token-mp1gba                           bootstrap.kubernetes.io/token         6         17h
certificate-controller-token-hp4pb               kubernetes.io/service-account-token   3         8d
clusterrole-aggregation-controller-token-82525   kubernetes.io/service-account-token   3         8d
cronjob-controller-token-h4r4q                   kubernetes.io/service-account-token   3         8d
daemon-set-controller-token-7jnmg                kubernetes.io/service-account-token   3         8d
default-token-vbq5r                              kubernetes.io/service-account-token   3         8d
deployment-controller-token-hw9z6                kubernetes.io/service-account-token   3         8d
disruption-controller-token-w88np                kubernetes.io/service-account-token   3         8d
endpoint-controller-token-c7kd7                  kubernetes.io/service-account-token   3         8d
flannel-token-znjq2                              kubernetes.io/service-account-token   3         8d
generic-garbage-collector-token-jcswb            kubernetes.io/service-account-token   3         8d
heapster-token-7sk58                             kubernetes.io/service-account-token   3         18h
horizontal-pod-autoscaler-token-2gwqd            kubernetes.io/service-account-token   3         8d
job-controller-token-h58gr                       kubernetes.io/service-account-token   3         8d
kube-dns-token-nlsm9                             kubernetes.io/service-account-token   3         8d
kube-proxy-token-zwsp7                           kubernetes.io/service-account-token   3         8d
kubernetes-dashboard-certs                       Opaque                                1         17h
kubernetes-dashboard-key-holder                  Opaque                                2         3d
kubernetes-dashboard-token-6vwnt                 kubernetes.io/service-account-token   3         19h
metrics-server-token-zntp6                       kubernetes.io/service-account-token   3         18h
namespace-controller-token-h9t47                 kubernetes.io/service-account-token   3         8d
node-controller-token-qlct6                      kubernetes.io/service-account-token   3         8d
persistent-volume-binder-token-69h9d             kubernetes.io/service-account-token   3         8d
pod-garbage-collector-token-j9d9f                kubernetes.io/service-account-token   3         8d
pv-protection-controller-token-m8zvk             kubernetes.io/service-account-token   3         8d
pvc-protection-controller-token-2xm8w            kubernetes.io/service-account-token   3         8d
replicaset-controller-token-h92xk                kubernetes.io/service-account-token   3         5m
replication-controller-token-dtf66               kubernetes.io/service-account-token   3         8d
resourcequota-controller-token-nkc65             kubernetes.io/service-account-token   3         8d
service-account-controller-token-dtg8c           kubernetes.io/service-account-token   3         8d
service-controller-token-mq55l                   kubernetes.io/service-account-token   3         8d
statefulset-controller-token-54fwx               kubernetes.io/service-account-token   3         8d
token-cleaner-token-grlqf                        kubernetes.io/service-account-token   3         8d
ttl-controller-token-59tgf                       kubernetes.io/service-account-token   3         8d
```

Mỗi **secret** sẽ chứa một **token** với quyền hạn khác nhau, bạn chạy lệnh sau để xem được **token** đang chứa trong **secret** tương ứng. Tôi lấy một **secret** bất kỳ

```shell
kubectl -n kube-system describe secret cluster-admin-dashboard-sa-token-r4x48
```

output:

```shell
Name:         cluster-admin-dashboard-sa-token-r4x48
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=cluster-admin-dashboard-sa
              kubernetes.io/service-account.uid=b0264e18-5c9a-11e8-874a-525400fd9cfb

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImNsdXN0ZXItYWRtaW4tZGFzaGJvYXJkLXNhLXRva2VuLXI0eDQ4Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImNsdXN0ZXItYWRtaW4tZGFzaGJvYXJkLXNhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYjAyNjRlMTgtNWM5YS0xMWU4LTg3NGEtNTI1NDAwZmQ5Y2ZiIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6Y2x1c3Rlci1hZG1pbi1kYXNoYm9hcmQtc2EifQ.mHpm3XZd5NWA8KAp3gmj3Zi5TnNlwnw7JwG-aqE9mMtleBr-a4aBzbIE2KR-1TaNR7daNqZ0SOb7lv8577PVAdM-pwBwFCHc1rJW6kzaNLywnuuSzmlkRG_3VgNA2j4hifaK0kSqClp3m6XW9YQdGXi89-ClNZl1YtUsFfInniUCBlR3Fj5uxsrIXZl8BivCT0jGDLvNgUGRC5Uau334phRYQsFpnSdg1iRbUaG9QO6IvOPTtn-dFPmMyJcNiDcN4_wMBii_LaVKTdLnRmTLw_gZyThkyCKh9216GAUTK-hgoGmE98L_GdA8gaQCO0urriNYkXUNK803t2_Y_eBnZg
```

Bạn copy lấy đoạn token bắt đầu từ chữ ey..., sau đó trên giao diện, bạn chọn vào Token, paste đoạn token vừa xong vào và SIGN IN

![k8s-dashboard](../../images/devops/kubernetes/k8s-dashboard.png)


Chúc mừng bạn đã đăng nhập thành công. Lưu ý là mỗi token của secret là có quyền khác nhau nhé.

Ngoài ra, bạn còn có thể tạo riêng secret với các quyền hạn riêng. Đây là phần phân quyền cho người dùng. Tham khảo cách tạo ở [link](https://docs.giantswarm.io/guides/install-kubernetes-dashboard/)