#!/bin/bash

max_map_count=$(cat /etc/sysctl.conf | grep vm.max_map_count)
if [ -n "$max_map_count" ]
then
    echo "Current $max_map_count"
else
    echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi