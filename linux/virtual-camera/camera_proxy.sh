#!/bin/bash

# Configuration
REAL_CAMERA="/dev/video0"
VIRTUAL_CAMERA="/dev/video3"
LOCK_FILE="/tmp/camera_frozen.lock"
SNAPSHOT_FILE="/tmp/camera_snapshot.jpg"
FFMPEG_PROXY_PID_FILE="/tmp/ffmpeg_camera_proxy.pid"
FFMPEG_FREEZE_PID_FILE="/tmp/ffmpeg_camera_freeze.pid"

# Show help function
show_help() {
    echo "Camera Control Script - Freeze and unfreeze your camera"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  start             Start the camera proxy (streaming from real to virtual camera)"
    echo "  freeze            Freeze the camera on current frame"
    echo "  <no arguments>    Toggle between frozen and unfrozen state"
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
    echo "  $0 freeze         # Freeze the camera on the current frame"
    echo "  $0                # Toggle between frozen and unfrozen"
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
        sudo modprobe v4l2loopback card_label="Virtual Camera" exclusive_caps=1
        
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

# Start proxy - stream from real camera to virtual device
start_camera_proxy() {
    if [ -f "$FFMPEG_PROXY_PID_FILE" ]; then
        echo "Camera proxy is already running."
        return 0
    fi
    
    echo "Starting camera proxy from $REAL_CAMERA to $VIRTUAL_CAMERA..."
    
    # Try to stream from real camera to virtual camera with NVIDIA hardware acceleration
    ffmpeg -f v4l2 \
           -input_format yuv420p \
           -framerate 30 \
           -video_size 1280x720 \
           -i "$REAL_CAMERA" \
           -c:v h264_nvenc \
           -preset p1 \
           -tune ll \
           -rc cbr \
           -zerolatency 1 \
           -f v4l2 \
           -pix_fmt yuv420p \
           -fflags nobuffer \
           -flags low_delay \
           -probesize 32 \
           -analyzeduration 0 \
           -threads 4 \
           "$VIRTUAL_CAMERA" \
           -loglevel error &
    PROXY_PID=$!
    echo $PROXY_PID > "$FFMPEG_PROXY_PID_FILE"
    
    # Wait to ensure the stream is established
    sleep 1
    
    # Verify proxy is actually running
    if ! ps -p $PROXY_PID > /dev/null; then
        echo "Warning: Camera is busy or cannot be accessed. Using placeholder instead."
        rm -f "$FFMPEG_PROXY_PID_FILE"
        # Use direct freeze instead
        direct_freeze_camera
        return 1
    fi
    
    echo "Camera proxy started with NVIDIA hardware acceleration. Use 'Virtual Camera' in your applications."
    echo "Run this script again to freeze the camera."
    return 0
}

# Direct freeze - create/use a placeholder image when camera is busy
direct_freeze_camera() {
    echo "Creating placeholder for virtual camera..."
    
    # Create a timestamp for the image
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Create a nice looking placeholder image
    ffmpeg -f lavfi -i color=c=blue:s=1280x720 -vf "drawtext=text='Virtual Camera - Active':fontcolor=white:fontsize=36:x=(w-text_w)/2:y=(h/2-text_h-40), drawtext=text='$TIMESTAMP':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=(h/2+40)" -frames:v 1 -y "$SNAPSHOT_FILE" -loglevel error
    
    # Stream the placeholder to the virtual device
    ffmpeg -loop 1 -re -i "$SNAPSHOT_FILE" -f v4l2 -pix_fmt yuv420p "$VIRTUAL_CAMERA" -loglevel error &
    echo $! > "$FFMPEG_PROXY_PID_FILE"
    
    echo "Virtual camera activated with placeholder. Use 'Virtual Camera' in your applications."
    return 0
}

# Freeze camera - take a snapshot and display it on virtual device
freeze_camera() {
    if [ ! -f "$FFMPEG_PROXY_PID_FILE" ]; then
        echo "Camera proxy is not running. Starting it first..."
        start_camera_proxy
        return
    fi
    
    echo "Freezing camera..."
    
    # Stop the proxy stream
    kill $(cat "$FFMPEG_PROXY_PID_FILE") 2>/dev/null
    rm "$FFMPEG_PROXY_PID_FILE"
    
    # Wait for the resource to be freed
    sleep 1
    
    # Try different methods to capture a frame
    # Method 1: Try direct ffmpeg capture
    if ffmpeg -f v4l2 -i "$REAL_CAMERA" -frames:v 1 -y "$SNAPSHOT_FILE" -loglevel error; then
        echo "Successfully captured frame from camera."
    # Method 2: Try v4l2-ctl
    elif v4l2-ctl --device="$REAL_CAMERA" --set-fmt-video=width=1280,height=720,pixelformat=YUYV --stream-mmap --stream-to="$SNAPSHOT_FILE" --stream-count=1; then
        echo "Successfully captured frame using v4l2-ctl."
    # Method 3: Generate a placeholder image with text
    else
        echo "Failed to capture a frame. Creating a placeholder image."
        # Create a timestamp for the image
        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        # Create a black image with text showing it's frozen
        ffmpeg -f lavfi -i color=c=black:s=1280x720 -vf "drawtext=text='Camera Frozen at $TIMESTAMP':fontcolor=white:fontsize=36:x=(w-text_w)/2:y=(h-text_h)/2" -frames:v 1 -y "$SNAPSHOT_FILE" -loglevel error
    fi
    
    # Stream the static image to the virtual device
    ffmpeg -loop 1 -re -i "$SNAPSHOT_FILE" -f v4l2 -pix_fmt yuv420p "$VIRTUAL_CAMERA" -loglevel error &
    echo $! > "$FFMPEG_FREEZE_PID_FILE"
    
    # Create lock file
    touch "$LOCK_FILE"
    echo "Camera frozen. Current frame is now fixed on $VIRTUAL_CAMERA"
}

# Unfreeze camera - restart the proxy stream
unfreeze_camera() {
    echo "Unfreezing camera..."
    
    # Stop the frozen image stream
    if [ -f "$FFMPEG_FREEZE_PID_FILE" ]; then
        kill $(cat "$FFMPEG_FREEZE_PID_FILE") 2>/dev/null
        rm "$FFMPEG_FREEZE_PID_FILE"
    fi
    
    # Remove the snapshot file and lock file
    rm -f "$SNAPSHOT_FILE" "$LOCK_FILE"
    
    # Try to restart the proxy stream
    if ! start_camera_proxy; then
        echo "Unable to access real camera. It may be in use by another application."
        echo "Using a placeholder stream instead."
        direct_freeze_camera
    fi
}

# Stop everything
stop_camera_proxy() {
    echo "Stopping camera proxy..."
    
    # Kill any running ffmpeg processes
    if [ -f "$FFMPEG_PROXY_PID_FILE" ]; then
        kill $(cat "$FFMPEG_PROXY_PID_FILE") 2>/dev/null
        rm "$FFMPEG_PROXY_PID_FILE"
    fi
    
    if [ -f "$FFMPEG_FREEZE_PID_FILE" ]; then
        kill $(cat "$FFMPEG_FREEZE_PID_FILE") 2>/dev/null
        rm "$FFMPEG_FREEZE_PID_FILE"
    fi
    
    # Remove temporary files
    rm -f "$SNAPSHOT_FILE" "$LOCK_FILE"
    
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
    if [ -f "$FFMPEG_PROXY_PID_FILE" ] && ps -p $(cat "$FFMPEG_PROXY_PID_FILE") > /dev/null; then
        echo "Camera proxy: Running (PID: $(cat "$FFMPEG_PROXY_PID_FILE"))"
    elif [ -f "$FFMPEG_FREEZE_PID_FILE" ] && ps -p $(cat "$FFMPEG_FREEZE_PID_FILE") > /dev/null; then
        echo "Camera status: Frozen (PID: $(cat "$FFMPEG_FREEZE_PID_FILE"))"
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
    start_camera_proxy || direct_freeze_camera
    exit 0
fi

if [ "$1" = "status" ]; then
    status
    exit 0
fi

if [ "$1" = "freeze" ]; then
    # Force freezing regardless of current state
    if [ -f "$FFMPEG_PROXY_PID_FILE" ]; then
        freeze_camera
    else
        direct_freeze_camera
    fi
    exit 0
fi

# If no arguments, toggle between frozen and normal
if [ ! -f "$FFMPEG_PROXY_PID_FILE" ] && [ ! -f "$FFMPEG_FREEZE_PID_FILE" ]; then
    # If nothing is running, start the proxy or create placeholder
    start_camera_proxy || direct_freeze_camera
elif [ -f "$LOCK_FILE" ]; then
    # If frozen, unfreeze
    unfreeze_camera
else
    # If running normally, freeze
    freeze_camera
fi

exit 0 