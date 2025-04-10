#!/bin/bash

# Ensure script runs in the correct directory
cd "$(dirname "$(dirname "$0")")" || exit 1

# Check current status
CURRENT_STATUS=$(./camera_proxy.sh status)

# Detect current mode
if echo "$CURRENT_STATUS" | grep -q "Camera proxy: Running"; then
    CURRENT_MODE=$(echo "$CURRENT_STATUS" | grep "Mode:" | awk '{print $NF}' | tr -d ')')
    echo "Current mode: $CURRENT_MODE"
    
    # Toggle mode
    if [ "$CURRENT_MODE" = "normal" ]; then
        echo "Switching to lag mode..."
        echo "This will create a more intense lag simulation (4 fps, 2.5x slower)"
        ./camera_proxy.sh stop
        nohup ./camera_proxy.sh lag >/dev/null 2>&1 &
    else
        echo "Switching to normal mode..."
        echo "This will restore normal video speed and framerate"
        ./camera_proxy.sh stop
        nohup ./camera_proxy.sh normal >/dev/null 2>&1 &
    fi
else
    # Not running, start in normal mode
    echo "Starting camera in normal mode..."
    nohup ./camera_proxy.sh start >/dev/null 2>&1 &
fi

# Report status after change
sleep 1
./camera_proxy.sh status

echo "Camera will continue running after terminal closes."
echo "Status saved to: $(pwd)/nohup.out"
