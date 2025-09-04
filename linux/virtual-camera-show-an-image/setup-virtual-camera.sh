#!/bin/bash

# ==============================================================================
# Hardened Virtual Camera Setup Script for Ubuntu 22.04+
#
# This script creates a virtual camera compatible with modern sandboxed browsers
# and provides comprehensive system checks and user feedback.
#
# Key Improvements:
#   - Adds `exclusive_caps=1` for Chromium/WebRTC compatibility.
#   - Includes checks for Secure Boot status.
#   - Detects sandboxed browsers (Snap) and provides permission instructions.
#   - Implements robust process management and cleanup.
#   - Enhances status and diagnostic feedback using v4l2-ctl.
# ==============================================================================

set -e  # Exit on any error

# --- Configuration ---
DEFAULT_IMAGE="sun.png"
VIDEO_NR=17
DEFAULT_DEVICE="/dev/video$VIDEO_NR"
DEFAULT_CARD_LABEL="VirtualCamera"
# RESOLUTION="1280x720"
RESOLUTION="1280x1278"
FRAMERATE="30"
PIX_FMT="yuv420p"

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

# --- System Validation and Pre-flight Checks ---

install_dependencies() {
    print_info "Checking and installing dependencies..."
    local packages_to_install=""
    
    if ! dpkg -l | grep -q v4l2loopback-dkms; then packages_to_install+=" v4l2loopback-dkms"; fi
    if ! command_exists ffmpeg; then packages_to_install+=" ffmpeg"; fi
    if ! command_exists v4l2-ctl; then packages_to_install+=" v4l-utils"; fi
    if ! command_exists mokutil; then packages_to_install+=" mokutil"; fi

    if [ -n "$packages_to_install" ]; then
        print_info "Installing required packages:$packages_to_install"
        sudo apt-get update
        sudo apt-get install -y $packages_to_install
    else
        print_success "All dependencies are already installed."
    fi
}

check_secure_boot() {
    print_info "Checking UEFI Secure Boot status..."
    if mokutil --sb-state | grep -q "SecureBoot enabled"; then
        print_warning "Secure Boot is ENABLED."
        print_warning "The v4l2loopback module must be signed to load."
        print_warning "If the module fails to load, check 'dmesg' for signature errors."
        print_warning "You may need to disable Secure Boot in your BIOS/UEFI settings."
    else
        print_success "Secure Boot is disabled. Module signing is not required."
    fi
}

check_snap_permissions() {
    print_info "Checking for sandboxed (Snap) browsers..."
    local snap_browser_found=false
    for browser in chromium firefox google-chrome; do
        if snap list "$browser" >/dev/null 2>&1; then
            if ! snap connections "$browser" | grep -q "camera"; then
                print_warning "Snap browser '$browser' found but lacks camera permission."
                print_warning "Run the following command to grant access:"
                echo -e "  ${YELLOW}sudo snap connect $browser:camera${NC}"
                snap_browser_found=true
            fi
        fi
    done
    if [ "$snap_browser_found" = false ]; then
        print_success "No Snap browsers found requiring special permissions."
    else
        print_warning "After granting permissions, you MUST completely quit and restart the browser."
    fi
}

# --- Core Virtual Camera Functions ---

load_loopback_module() {
    print_info "Loading v4l2loopback kernel module..."
    
    if lsmod | grep -q v4l2loopback; then
        print_warning "Module already loaded. Unloading to apply new settings."
        sudo modprobe -r v4l2loopback
        sleep 1
    fi
    
    # Load the module with `exclusive_caps=1` for browser compatibility.
    # This makes the device report only CAPTURE capabilities once a stream starts.
    print_info "Loading module with: video_nr=$VIDEO_NR, card_label='$DEFAULT_CARD_LABEL', exclusive_caps=1"
    sudo modprobe v4l2loopback video_nr=$VIDEO_NR card_label="$DEFAULT_CARD_LABEL" exclusive_caps=1 max_buffers=2
    
    if [ $? -ne 0 ]; then
        print_error "Failed to load v4l2loopback module. Check 'dmesg' for errors (e.g., Secure Boot issues)."
        exit 1
    fi

    # Give the system a moment to create the device node
    sleep 1

    if [ -e "$DEFAULT_DEVICE" ]; then
        print_success "v4l2loopback module loaded and device $DEFAULT_DEVICE created."
    else
        print_error "Module loaded, but device $DEFAULT_DEVICE was not created. Check for conflicts."
        exit 1
    fi
}

start_streaming() {
    local image_path="$1"
    
    if [ ! -f "$image_path" ]; then
        print_error "Image file '$image_path' not found. Please provide a valid path."
        exit 1
    fi
    
    if pgrep -f "ffmpeg.*$DEFAULT_DEVICE" >/dev/null; then
        print_warning "A stream to $DEFAULT_DEVICE is already running. Stopping it first."
        pkill -f "ffmpeg.*$DEFAULT_DEVICE"
        sleep 1
    fi

    print_info "Starting to stream '$image_path' to $DEFAULT_DEVICE..."
    print_info "Resolution: $RESOLUTION, Framerate: $FRAMERATE, Pixel Format: $PIX_FMT"
    
    # Use nohup and '&' to run ffmpeg in the background, detaching it from the terminal.
    nohup ffmpeg -loop 1 -re -i "$image_path" \
        -vf "scale=$RESOLUTION" -vcodec rawvideo -pix_fmt "$PIX_FMT" \
        -r "$FRAMERATE" -f v4l2 "$DEFAULT_DEVICE" >/dev/null 2>&1 &

    # Store the PID of the backgrounded ffmpeg process for clean shutdown
    FFMPEG_PID=$!
    echo $FFMPEG_PID > /tmp/virtualcam.pid

    sleep 2 # Wait for ffmpeg to initialize

    if ! ps -p $FFMPEG_PID > /dev/null; then
        print_error "Failed to start ffmpeg stream. Check ffmpeg installation and image format."
        exit 1
    fi
    
    print_success "Streaming is now active!"
    print_info "You can now select '$DEFAULT_CARD_LABEL' in Google Meet, Zoom, etc."
    print_info "To stop, run: $0 stop"
}

stop_virtual_camera() {
    print_info "Stopping virtual camera..."
    
    if [ -f /tmp/virtualcam.pid ]; then
        FFMPEG_PID=$(cat /tmp/virtualcam.pid)
        if ps -p $FFMPEG_PID > /dev/null; then
            print_info "Stopping ffmpeg process (PID: $FFMPEG_PID)..."
            kill $FFMPEG_PID
            rm /tmp/virtualcam.pid
        else
            print_warning "PID file found, but no matching ffmpeg process is running."
        fi
    else
        # Fallback for manually started processes
        pkill -f "ffmpeg.*$DEFAULT_DEVICE" 2>/dev/null || true
    fi
    
    if lsmod | grep -q v4l2loopback; then
        print_info "Unloading v4l2loopback module..."
        sudo modprobe -r v4l2loopback
    fi
    
    print_success "Virtual camera stopped and resources released."
}

# --- Utility and Diagnostic Functions ---

check_status() {
    print_info "--- Virtual Camera Status ---"
    
    # 1. Check Module
    if lsmod | grep -q v4l2loopback; then
        print_success "Kernel module 'v4l2loopback' is loaded."
    else
        print_warning "Kernel module 'v4l2loopback' is NOT loaded."
        exit 1
    fi
    
    # 2. Check Device Node
    if [ -e "$DEFAULT_DEVICE" ]; then
        print_success "Device node '$DEFAULT_DEVICE' exists."
        # 3. Check Device Capabilities
        print_info "Device details from v4l2-ctl:"
        v4l2-ctl --device="$DEFAULT_DEVICE" --info
    else
        print_error "Device node '$DEFAULT_DEVICE' does NOT exist."
        exit 1
    fi
    
    # 4. Check Producer Stream
    if pgrep -f "ffmpeg.*$DEFAULT_DEVICE" >/dev/null; then
        print_success "FFmpeg producer is streaming to the device."
        print_info "Current stream format:"
        v4l2-ctl --device="$DEFAULT_DEVICE" --get-fmt-video
    else
        print_warning "No active ffmpeg stream to the device."
    fi

    # 5. Check Snap Permissions
    check_snap_permissions
    echo "---------------------------"
}

list_cameras() {
    print_info "Available video devices:"
    v4l2-ctl --list-devices
}

show_usage() {
    echo "Usage: $0"
    echo ""
    echo "Commands:"
    echo "  setup                 Run all pre-flight checks and install dependencies."
    echo "  start    Load module and start streaming image (default: $DEFAULT_IMAGE)."
    echo "  stop                  Stop streaming and unload the module."
    echo "  status                Show detailed status of the virtual camera."
    echo "  list                  List all V4L2 devices on the system."
    echo "  --help                Show this help message."
    echo ""
    echo "Example Workflow:"
    echo "  1. $0 setup"
    echo "  2. $0 start my_photo.jpg"
    echo "  3. (Use in browser)"
    echo "  4. $0 stop"
}

# --- Main Script Logic ---
main() {
    case "${1:-}" in
        "setup")
            install_dependencies
            check_secure_boot
            check_snap_permissions
            print_success "Setup complete. You are ready to start the camera."
            ;;
        "start")
            image_path="${2:-$DEFAULT_IMAGE}"
            load_loopback_module
            start_streaming "$image_path"
            ;;
        "stop")
            stop_virtual_camera
            ;;
        "status")
            check_status
            ;;
        "list")
            list_cameras
            ;;
        "--help"|"help")
            show_usage
            ;;
        "")
            print_error "No command specified."
            show_usage
            exit 1
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"