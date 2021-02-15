Stress test CPU, Memory, Network on ubuntu using Stress command line
---

- [1. Install and usage](#1-install-and-usage)
- [4. Reference](#4-reference)

# 1. Install and usage

```shell
sudo apt install stress -y
# then
stress --help
stress --cpu 8 --io 4 --vm 4 --vm-bytes 1024M --timeout 10s
```

# 4. Reference

https://askubuntu.com/a/948865/1077704
