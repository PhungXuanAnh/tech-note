#!/bin/bash
# this is sample how to debug shell scripts

# add 2 below lines for debug shell scripts
set -x
trap read debug

echo 1
echo 2
echo 3
echo 4
echo 5