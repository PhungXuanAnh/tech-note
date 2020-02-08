VAR_GLOBAL=global
global-local-variable:
	$(eval VAR_LOCAL := local)
	echo ${VAR_GLOBAL}
	echo ${VAR_LOCAL}

HOST_NAME=$(shell cat /etc/hostname)
shell-command:
	echo "abc" > /tmp/test-shell-command
	$(eval VAR_LOCAL1 := $(shell cat /tmp/test-shell-command))
	echo "Host name is ${HOST_NAME}"
	echo "This is content of test file ${VAR_LOCAL1}"