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

https://portswigger.net/burp/documentation/desktop/getting-started/proxy-setup/certificate

### 2.1.1. android

**NOTE**: to get certificates, android devices must be connected to burp proxy, as guide here : https://portswigger.net/support/configuring-an-android-device-to-work-with-burp

how to get certificates here : https://portswigger.net/support/installing-burp-suites-ca-certificate-in-an-android-device

#### 2.1.1.1. Facebook app

To intercept request from facebook, first, you have to patch `so` file of facebook as guide here [sample/devops/ssl/FBUnpinner/README.md](sample/devops/ssl/FBUnpinner/README.md) or here : https://github.com/tsarpaul/FBUnpinner (**require ROOTED device**)

summary command : 

```shell
# mobile
cp /data/data/com.facebook.katana/lib-xzs/libcoldstart.so /data/local/tmp/libcoldstart.so
# pc
adb pull /data/local/tmp/libcoldstart.so .
python patch.py libliger.so libliger-patched.so
adb push libliger-patched.so /data/local/tmp/libliger-patched.so
# mobile
rm -rf /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
cp /data/local/tmp/libliger-patched.so /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
chmod 777 /data/data/com.facebook.katana/lib-xzs/libcoldstart.so
```

restart facebook app
