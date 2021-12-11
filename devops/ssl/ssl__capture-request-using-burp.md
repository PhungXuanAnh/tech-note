- [1. Install](#1-install)
- [2. Capture https](#2-capture-https)
  - [2.1. Installing Burp's CA certificate](#21-installing-burps-ca-certificate)
    - [2.1.1. android](#211-android)
      - [2.1.1.1. Facebook app](#2111-facebook-app)

# 1. Install

Download from this link : https://portswigger.net/burp/releases/community/latest

```shell
chmod +x burpsuite_community_linux_v*.sh
./burpsuite_community_linux_v*.sh
```

# 2. Capture https

## 2.1. Installing Burp's CA certificate


### 2.1.1. android

**NOTE**: to get certificates, android devices must be connected to burp proxy, as guide here : https://portswigger.net/support/configuring-an-android-device-to-work-with-burp

how to get certificates here : https://portswigger.net/support/installing-burp-suites-ca-certificate-in-an-android-device


sample setup burp suite certificates for android genymotion and bypass ssl pinning here

[sample/devops/ssl/frida-ssl-pinning-bypass/Readme.md](sample/devops/ssl/frida-ssl-pinning-bypass/Readme.md)

#### 2.1.1.1. Facebook app

**NOTE: require ROOTED device or you can using device run on Genymotion**

To intercept request from facebook, first, you have to patch `so` file of facebook as guide here [../../sample/devops/ssl/FBUnpinner/README.md](../../sample/devops/ssl/FBUnpinner/README.md) or here : https://github.com/tsarpaul/FBUnpinner

summary command : 

```shell
# below command using android vm run on Genymotion
alias adb=/opt/genymobile/genymotion/tools/adb

# mobile
adb devices
adb shell
ls /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
cp /data/data/com.facebook.katana/lib-xzs/libcoldstart.so /data/local/tmp/libcoldstart.so

# pc
cd ~/repo/tech-note/sample/devops/ssl/FBUnpinner/
pip install pyelftools

adb pull /data/local/tmp/libcoldstart.so .
python patch.py libcoldstart.so libcoldstart-patched.so
adb push libcoldstart-patched.so /data/local/tmp/libliger-patched.so

# mobile
rm -rf /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
cp /data/local/tmp/libliger-patched.so /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
chmod 777 /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
```

restart facebook app or restart your virtual device
