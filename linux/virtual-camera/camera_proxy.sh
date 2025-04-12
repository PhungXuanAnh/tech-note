#!/bin/bash

# Configuration
REAL_CAMERA="/dev/video0"
VIRTUAL_CAMERA="/dev/video3"
LOCK_FILE="/tmp/camera_mode.lock"
FFMPEG_PID_FILE="/tmp/ffmpeg_camera.pid"
CONFIG_FILE="/tmp/camera_config.txt"

# Show help function
show_help() {
    echo "Camera Control Script - Normal and lag simulation for virtual camera"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  start             Start the camera proxy (streaming from real to virtual camera)"
    echo "  lag               Enable lag simulation mode (slow motion and delay)"
    echo "  normal            Return to normal camera mode"
    echo "  <no arguments>    Toggle between normal and lag simulation mode"
    echo "  stop              Stop all processes related to the camera proxy"
    echo "  status            Show the current status of camera proxies"
    echo "  -h, --help        Display this help message and exit"
    echo ""
    echo "Device Configuration:"
    echo "  Real camera:      $REAL_CAMERA"
    echo "  Virtual camera:   $VIRTUAL_CAMERA"
    echo ""
    echo "Examples:"
    echo "  $0 start          # Start streaming from real to virtual camera"
    echo "  $0 lag            # Enable lag simulation mode"
    echo "  $0 normal         # Return to normal mode"
    echo "  $0                # Toggle between normal and lag mode"
    echo "  $0 stop           # Stop all processes"
    echo ""
    exit 0
}

# Check dependencies
check_dependencies() {
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo "Error: ffmpeg is not installed. Please install it with:"
        echo "sudo apt install ffmpeg"
        exit 1
    fi
    
    # Check if v4l2loopback is loaded with proper names
    if ! lsmod | grep -q v4l2loopback; then
        echo "Loading v4l2loopback with a friendly device name..."
        # Unload if it exists with wrong parameters
        sudo modprobe -r v4l2loopback 2>/dev/null
        # Load with card_label parameter for a friendly name
        sudo modprobe v4l2loopback card_label="Virtual Camera" exclusive_caps=1 max_buffers=2
        
        if [ $? -ne 0 ]; then
            echo "Failed to load v4l2loopback module. Please install it first with:"
            echo "sudo apt install v4l2loopback-dkms"
            exit 1
        fi
        
        echo "Please wait a moment for the device to initialize..."
        sleep 2
    fi
}

# Find the virtual camera device
find_virtual_camera() {
    # Try to find the v4l2loopback device by listing video devices
    LOOPBACK_DEVICES=$(v4l2-ctl --list-devices | grep -A1 "Virtual Camera\|Dummy" | grep "/dev/video" | xargs)
    
    if [ -z "$LOOPBACK_DEVICES" ]; then
        echo "Could not find v4l2loopback device. Check if it's properly loaded."
        exit 1
    fi
    
    # Use the first loopback device found
    VIRTUAL_CAMERA="/dev/video3"
    echo "Using virtual camera device: $VIRTUAL_CAMERA"
}

# Check if camera is running
is_camera_running() {
    if [ -f "$FFMPEG_PID_FILE" ]; then
        if ps -p $(cat "$FFMPEG_PID_FILE") > /dev/null; then
            return 0  # Running
        else
            # Stale PID file
            rm -f "$FFMPEG_PID_FILE"
        fi
    fi
    return 1  # Not running
}

# Get current camera mode
get_camera_mode() {
    if [ -f "$LOCK_FILE" ]; then
        echo "lag"
    else
        echo "normal"
    fi
}

# Start camera proxy
start_camera_proxy() {
    # If camera is already running, do nothing
    if is_camera_running; then
        echo "Camera proxy is already running."
        return 0
    fi
    
    echo "Starting camera proxy from $REAL_CAMERA to $VIRTUAL_CAMERA..."
    
    # Check if camera is already in use by something else
    if ! v4l2-ctl --device="$REAL_CAMERA" --all &>/dev/null; then
        echo "Warning: Real camera is busy or cannot be accessed. Starting with test pattern."
        # Use test pattern for busy camera
        ffmpeg -f lavfi -i testsrc=size=1280x720:rate=30 -pix_fmt yuv420p -f v4l2 "$VIRTUAL_CAMERA" -loglevel error &
        echo $! > "$FFMPEG_PID_FILE"
        echo "Camera proxy started with test pattern. Use 'Virtual Camera' in your applications."
        return 0
    fi
    
    # Set initial normal mode
    echo "normal" > "$CONFIG_FILE"
    
    # Start ffmpeg with enhanced smoothness settings
    ffmpeg -f v4l2 \
           -input_format yuv420p \
           -framerate 30 \
           -video_size 1280x720 \
           -thread_queue_size 512 \
           -i "$REAL_CAMERA" \
           -pix_fmt yuv420p \
           -vf "fps=30,mpdecimate,setpts=N/FRAME_RATE/TB" \
           -preset ultrafast \
           -tune zerolatency \
           -bufsize 512k \
           -threads 6 \
           -f v4l2 \
           "$VIRTUAL_CAMERA" \
           -loglevel error &
    
    # Save PID
    echo $! > "$FFMPEG_PID_FILE"
    
    # Wait to ensure the stream is established
    sleep 1
    
    # Verify proxy is actually running
    if ! ps -p $(cat "$FFMPEG_PID_FILE") > /dev/null; then
        rm -f "$FFMPEG_PID_FILE"
        echo "Error: Failed to start camera proxy. Check if camera is in use by another application."
        return 1
    fi
    
    echo "Camera proxy started in normal mode. Use 'Virtual Camera' in your applications."
    echo "Run this script again to toggle between normal and lag modes."
    return 0
}

# Set lag mode
set_lag_mode() {
    echo "Enabling lag simulation mode..."
    
    # If camera is not running, start it first
    if ! is_camera_running; then
        start_camera_proxy
    fi
    
    # Restart camera with lag settings, but same device
    stop_camera_proxy
    
    # Start ffmpeg with lag settings
    ffmpeg -f v4l2 \
           -input_format yuv420p \
           -framerate 30 \
           -video_size 1280x720 \
           -i "$REAL_CAMERA" \
           -vf "fps=4,setpts=2.5*PTS" \
           -pix_fmt yuv420p \
           -f v4l2 \
           -threads 2 \
           "$VIRTUAL_CAMERA" \
           -loglevel error &
    
    # Save PID
    echo $! > "$FFMPEG_PID_FILE"
    
    # Mark as lag mode
    touch "$LOCK_FILE"
    
    echo "Camera set to lag simulation mode. Video will appear delayed and slow."
}

# Set normal mode
set_normal_mode() {
    echo "Returning to normal video mode..."
    
    # If camera is not running, just start it
    if ! is_camera_running; then
        start_camera_proxy
        return
    fi
    
    # Restart camera with normal settings, but same device
    stop_camera_proxy
    
    # Start ffmpeg with normal settings
    ffmpeg -f v4l2 \
           -input_format yuv420p \
           -framerate 30 \
           -video_size 1280x720 \
           -i "$REAL_CAMERA" \
           -pix_fmt yuv420p \
           -f v4l2 \
           -fflags nobuffer \
           -flags low_delay \
           -threads 4 \
           "$VIRTUAL_CAMERA" \
           -loglevel error &
    
    # Save PID
    echo $! > "$FFMPEG_PID_FILE"
    
    # Remove lag mode marker
    rm -f "$LOCK_FILE"
    
    echo "Camera returned to normal mode with full frame rate."
}

# Toggle between modes
toggle_camera_mode() {
    # Check if camera is running
    if ! is_camera_running; then
        start_camera_proxy
        return
    fi
    
    # Toggle mode
    if [ -f "$LOCK_FILE" ]; then
        set_normal_mode
    else
        set_lag_mode
    fi
}

# Stop everything
stop_camera_proxy() {
    echo "Stopping camera proxy..."
    
    # Kill ffmpeg process
    if [ -f "$FFMPEG_PID_FILE" ]; then
        kill $(cat "$FFMPEG_PID_FILE") 2>/dev/null
        rm -f "$FFMPEG_PID_FILE"
    fi
    
    # Remove other files
    rm -f "$LOCK_FILE" "$CONFIG_FILE"
    
    echo "Camera proxy stopped."
}

# Display status
status() {
    echo "Camera Proxy Status:"
    echo "---------------------"
    
    # Check if v4l2loopback is loaded
    if lsmod | grep -q v4l2loopback; then
        echo "v4l2loopback module: Loaded"
        # Show available video devices
        echo "Available video devices:"
        v4l2-ctl --list-devices | cat
    else
        echo "v4l2loopback module: Not loaded"
    fi
    
    # Check if proxy is running
    if is_camera_running; then
        mode=$(get_camera_mode)
        echo "Camera proxy: Running (PID: $(cat "$FFMPEG_PID_FILE"), Mode: $mode)"
    else
        echo "Camera proxy: Not running"
    fi
}

# Main
# Check for help flag first
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

check_dependencies
find_virtual_camera

# Check command line arguments
if [ "$1" = "stop" ]; then
    stop_camera_proxy
    exit 0
fi

if [ "$1" = "start" ]; then
    start_camera_proxy
    exit 0
fi

if [ "$1" = "status" ]; then
    status
    exit 0
fi

if [ "$1" = "lag" ]; then
    set_lag_mode
    exit 0
fi

if [ "$1" = "normal" ]; then
    set_normal_mode
    exit 0
fi

# No arguments, toggle mode
toggle_camera_mode

exit 0 