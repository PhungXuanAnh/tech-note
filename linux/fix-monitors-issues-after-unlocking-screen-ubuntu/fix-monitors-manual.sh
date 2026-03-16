#!/bin/bash
# Manual monitor fix — run this if the auto service didn't fix the layout
# Usage: fix-monitors-manual
set -euo pipefail

echo "Current layout:"
xrandr --query | grep -E "^\S+ connected"

echo ""
echo "Forcing DPMS on..."
xset dpms force on
sleep 0.5

echo "Applying layout..."
xrandr \
    --output HDMI-0 --mode 1920x1080 --pos 0x0 \
    --output DP-1 --mode 1920x1080 --pos 1920x0 \
    --output DP-4 --primary --mode 2560x1600 --pos 741x1080

echo ""
echo "Verified:"
xrandr --query | grep -E "^\S+ connected"
