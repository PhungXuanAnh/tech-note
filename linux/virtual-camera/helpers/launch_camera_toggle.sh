#!/bin/bash

# Ensure script runs in the correct directory
cd "$(dirname "$(dirname "$0")")" || exit 1

# Display status before toggle
echo "========================================"
echo "Camera status BEFORE toggle:"
./camera_proxy.sh status

# Check if the camera proxy is already running
IS_RUNNING=false
if ./camera_proxy.sh status | grep -q "Camera proxy: Running"; then
    IS_RUNNING=true
    CURRENT_MODE=$(./camera_proxy.sh status | grep "Mode:" | awk '{print $NF}' | tr -d ')')
    echo "Current mode detected: $CURRENT_MODE"
fi

# Toggle camera mode 
# Use setsid to create a new session so the process survives terminal closure
if [ "$IS_RUNNING" = false ]; then
    echo "Starting camera proxy (detached)..."
    setsid ./camera_proxy.sh start >/dev/null 2>&1 &
elif [ "$CURRENT_MODE" = "normal" ]; then
    echo "Switching to lag mode (detached)..."
    setsid ./camera_proxy.sh lag >/dev/null 2>&1 &
else
    echo "Switching to normal mode (detached)..."
    setsid ./camera_proxy.sh normal >/dev/null 2>&1 &
fi

# Give it a second to initialize
sleep 1

# Display status after toggle
echo "========================================"
echo "Camera status AFTER toggle:"
./camera_proxy.sh status

# Keep terminal open
echo "========================================"
echo "The camera will remain active after closing this window."
echo "Press Enter to close this window..."
read -r 