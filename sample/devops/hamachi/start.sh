#!/bin/bash

/etc/init.d/logmein-hamachi force-reload

while pgrep hamachid >/dev/null; do
	sleep 10
done