- [1. Install java](#1-install-java)
  - [1.1. Java 8 oracle](#11-java-8-oracle)
  - [1.2. Java 8 jdk](#12-java-8-jdk)
- [2. Install spark](#2-install-spark)
- [3. Boot up spark](#3-boot-up-spark)
  - [3.1. Standalone mode](#31-standalone-mode)
  - [3.2. Multiple nodes cluster](#32-multiple-nodes-cluster)
    - [3.2.1. Edit hosts file](#321-edit-hosts-file)
    - [3.2.2. Config ssh key](#322-config-ssh-key)
    - [3.2.3. Config spark](#323-config-spark)
    - [3.2.4. Start/stop spark](#324-startstop-spark)
    - [3.2.5. Check](#325-check)
    - [3.2.6. Reference](#326-reference)

# 1. Install java

You can install `java 8 jdk` or `java 8 oracle`

**NOTE**: It must install java on all nodes

## 1.1. Java 8 oracle

Download `jdk-8u211-linux-x64.tar.gz` from this link: https://download.oracle.com/otn/java/jdk/8u211-b12/478a62b7d4e34b78b671c754eaaf38ab/jdk-8u211-linux-x64.tar.gz (it requires login for download)

```shell
tar -xvf jdk-8u211-linux-x64.tar.gz
sudo mkdir -p /usr/lib/jvm
sudo mv ./jdk1.8.0_211 /usr/lib/jvm/
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_211/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_211/bin/javac" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0_211/bin/javaws" 1
sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac
sudo chmod a+x /usr/bin/javaws
sudo chown -R root:root /usr/lib/jvm/jdk1.8.0_211
# export PATH=$PATH:/usr/lib/jvm/jdk1.8.0_211/bin/
sudo update-alternatives --config java
java -version

# sudo apt install openjdk-8-jre-headless 
# https://stackoverflow.com/questions/50064646/py4j-protocol-py4jjavaerror-occurred-while-calling-zorg-apache-spark-api-python/50098044
```

Reference: https://askubuntu.com/questions/56104/how-can-i-install-sun-oracles-proprietary-java-jdk-6-7-8-or-jre

## 1.2. Java 8 jdk

```shell
sudo apt-get install software_properties_common
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install openjdk-11-jdk
java -version
```


# 2. Install spark

**NOTE**: this step must be done on all nodes

```shell
rm -rf /opt/spark
wget https://archive.apache.org/dist/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
tar xvf spark-2.2.0-bin-hadoop2.7.tgz
sudo mv spark-2.2.0-bin-hadoop2.7 /opt/spark

vim ~/.bashrc
# add below lines
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
```

# 3. Boot up spark

## 3.1. Standalone mode

```shell
YOUR_IP=167.71.204.181  # this is your external ip
SPARK_LOCAL_IP=${YOUR_IP} SPARK_MASTER_HOST=${YOUR_IP} start-master.sh
SPARK_LOCAL_IP=${YOUR_IP} start-slave.sh spark://${YOUR_IP}:7077

# check master is on
ss -tunelp | grep 8080

# check slave is on
ss -tunelp | grep 8081
```

To stop master and slave, run: 

```shell
stop-slave.sh
stop-mastwer.sh
```

## 3.2. Multiple nodes cluster

### 3.2.1. Edit hosts file

For example:

    master: 192.168.205.10
    slave1: 192.168.205.11
    slave2: 192.168.205.12

On master, edit hosts file:

```shell
sudo vim /etc/hosts

# add below lines
192.168.205.10  master
192.168.205.11  slave1
192.168.205.12  slave2

# reboot if need to apply new change
```

### 3.2.2. Config ssh key

We need to add ssh public key of `master` node to all nodes (inlude master)

On all nodes

```shell
sudo apt-get install openssh-server openssh-client
```

On master

```shell
ssh-keygen -t rsa -P ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

Copy master public key to all slave nodes

```shell
ssh-copy-id user@pd-master
ssh-copy-id user@pd-slave1
ssh-copy-id user@pd-slave2
```

Check

```shell
ssh master
ssh slave01
ssh slave02
```

### 3.2.3. Config spark

On master, config spark env

```shell
cd /usr/local/spark/conf
cp spark-env.sh.template spark-env.sh
sudo vim spark-env.sh

# add below lines
export SPARK_MASTER_HOST='<MASTER-IP>'
export JAVA_HOME=<Path_of_JAVA_installation>

# example in this instruction
export SPARK_MASTER_HOST=192.168.205.10
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_211
```

On master, add worker

```shell
cd /usr/local/spark/conf
sudo vim slaves

# add below, same values you have declared on /etc/hosts
master
slave01
slave02
```

### 3.2.4. Start/stop spark

On master

Start spark:

```shell
cd /usr/local/spark
./sbin/start-all.sh
```

Stop spark:

```shell
./sbin/stop-all.sh
```

### 3.2.5. Check

On master :

```shell
jps
```

Access web:

http://<MASTER-IP>:8080/

### 3.2.6. Reference

https://medium.com/@jootorres_11979/how-to-install-and-set-up-an-apache-spark-cluster-on-hadoop-18-04-b4d70650ed42
