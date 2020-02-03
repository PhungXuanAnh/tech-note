- [1. Global and local variable](#1-global-and-local-variable)
- [2. shell command](#2-shell-command)
- [3. awk in makefile](#3-awk-in-makefile)

# 1. Global and local variable

```Makefile
VAR_GLOBAL=global
global-local-variable:
	$(eval VAR_LOCAL := local)
	echo ${VAR_GLOBAL}
	echo ${VAR_LOCAL}
```

# 2. shell command

```Makefile
HOST_NAME=$(shell cat /etc/hostname)

shell-command:
	echo "this is test" > /tmp/test-shell-command
	$(eval VAR_LOCAL1 := $(shell cat /tmp/test-shell-command))
	echo ${HOST_NAME}
	echo ${VAR_LOCAL1}
```

# 3. awk in makefile

It must add change `$` to `$$`, for below example `print $7;` must change to `print $$7;`

```Makefile
awk-sample:
	echo Your ip which can connect to internet $(shell ip route get 8.8.8.8 | awk '{print $$7; exit}')
```