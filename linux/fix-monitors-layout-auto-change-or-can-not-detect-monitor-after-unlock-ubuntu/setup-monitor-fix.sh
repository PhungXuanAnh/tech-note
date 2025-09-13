#!/bin/bash

# Multi-Monitor Fix Setup Script for Ubuntu 22.04+
# This script automates the installation and configuration of the monitor detection fix
# after screen lock/unlock cycles for NVIDIA systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
LOG_FILE="$HOME/monitor-fix-setup.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} Multi-Monitor Fix Setup Script${NC}"
echo -e "${BLUE} For Ubuntu 22.04+ with NVIDIA Graphics${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print colored messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if service already exists
check_existing_installation() {
    if systemctl --user is-enabled monitor-fix.service >/dev/null 2>&1; then
        print_status "Existing monitor fix service detected"
        print_warning "This will update the existing configuration with current monitor layout"
        echo ""
        read -p "Continue with update? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_status "Update cancelled by user"
            exit 0
        fi
        return 0
    fi
    return 1
}

# Function to detect current monitors
detect_monitors() {
    print_step "Detecting current monitor configuration..."
    
    if ! command_exists xrandr; then
        print_error "xrandr not found. Please ensure you're running X11 session."
        exit 1
    fi
    
    # Get current xrandr output
    XRANDR_OUTPUT=$(xrandr)
    
    # Extract connected monitors
    CONNECTED_MONITORS=$(echo "$XRANDR_OUTPUT" | grep " connected" | awk '{print $1}')
    PRIMARY_MONITOR=$(echo "$XRANDR_OUTPUT" | grep " connected primary" | awk '{print $1}')
    
    if [ -z "$CONNECTED_MONITORS" ]; then
        print_error "No connected monitors detected!"
        exit 1
    fi
    
    print_status "Connected monitors: $(echo $CONNECTED_MONITORS | tr '\n' ' ')"
    print_status "Primary monitor: $PRIMARY_MONITOR"
    
    # Store current configuration
    CURRENT_CONFIG=$(xrandr --query | grep -E "(Screen 0|connected)")
    
    echo ""
    echo "Current Monitor Configuration:"
    echo "$CURRENT_CONFIG"
    echo ""
}

# Function to generate xrandr command based on current setup
generate_xrandr_command() {
    print_step "Generating xrandr command for current setup..."
    
    XRANDR_CMD="/usr/bin/xrandr"
    
    # Parse current monitor positions and resolutions
    while IFS= read -r monitor; do
        if [ -n "$monitor" ]; then
            # Extract monitor name, resolution, and position
            MONITOR_NAME=$(echo "$monitor" | awk '{print $1}')
            
            # Get current mode and position
            MODE=$(echo "$monitor" | grep -o '[0-9]\+x[0-9]\+' | head -1)
            POSITION=$(echo "$monitor" | grep -o '+[0-9]\++[0-9]\+' | sed 's/+//g; s/+/x/')
            
            if [ -n "$MODE" ] && [ -n "$POSITION" ]; then
                XRANDR_CMD="$XRANDR_CMD --output $MONITOR_NAME --mode $MODE --pos $POSITION"
                
                # Add primary flag if this is the primary monitor
                if [ "$MONITOR_NAME" = "$PRIMARY_MONITOR" ]; then
                    XRANDR_CMD="$XRANDR_CMD --primary"
                fi
            fi
        fi
    done <<< "$CONNECTED_MONITORS"
    
    # Remove extra spaces
    XRANDR_CMD=$(echo "$XRANDR_CMD" | tr -s ' ')
    
    print_status "Generated xrandr command:"
    echo "$XRANDR_CMD"
    echo ""
}

# Function to check system requirements
check_requirements() {
    print_step "Checking system requirements..."
    
    # Check if running Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_warning "This script is designed for Ubuntu. Proceeding anyway..."
    fi
    
    # Check if NVIDIA GPU is present
    if ! lspci | grep -i nvidia >/dev/null; then
        print_warning "No NVIDIA GPU detected. This script is optimized for NVIDIA systems."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check if X11 session
    if [ "$XDG_SESSION_TYPE" != "x11" ]; then
        print_warning "Not running X11 session (current: $XDG_SESSION_TYPE)"
        print_warning "The automated script works best with X11. Consider switching to 'Ubuntu on Xorg' at login."
    fi
    
    # Check if nvidia-smi works
    if command_exists nvidia-smi; then
        if nvidia-smi >/dev/null 2>&1; then
            print_status "NVIDIA driver is working properly"
            NVIDIA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
            print_status "NVIDIA driver version: $NVIDIA_VERSION"
        else
            print_warning "NVIDIA driver may not be properly installed"
        fi
    else
        print_warning "nvidia-smi not found. NVIDIA driver may not be installed."
    fi
    
    print_status "System requirements check completed"
    echo ""
}

# Function to create monitor fix script
create_monitor_script() {
    print_step "Creating monitor fix script..."
    
    # Create the directory
    mkdir -p "$HOME/.local/bin"
    
    # Create the script
    cat > "$HOME/.local/bin/fix-monitors.sh" << 'EOF'
#!/bin/bash

# Monitor Fix Script for Multi-Monitor Setup
# This script listens for screen unlock events and restores the correct monitor layout
# Auto-generated by monitor-fix-setup.sh

# Create log directory
mkdir -p "$HOME/.local/share"

# Function to log with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$HOME/.local/share/monitor-fix.log"
}

# Function to restore monitor layout
restore_monitors() {
    log_message "Screen unlocked, restoring monitor layout..."
    
    # Wait for desktop to stabilize
    sleep 2
    
    # Execute the xrandr command (will be replaced by setup script)
    XRANDR_COMMAND_PLACEHOLDER
    
    if [ $? -eq 0 ]; then
        log_message "Monitor layout restored successfully"
    else
        log_message "Failed to restore monitor layout"
    fi
}

# Main monitoring loop
log_message "Monitor fix service started"

dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "member=ActiveChanged" && echo "$line" | grep -q "boolean false"; then
        restore_monitors
    fi
done
EOF
    
    # Replace placeholder with actual xrandr command
    sed -i "s|XRANDR_COMMAND_PLACEHOLDER|$XRANDR_CMD|g" "$HOME/.local/bin/fix-monitors.sh"
    
    # Make script executable
    chmod +x "$HOME/.local/bin/fix-monitors.sh"
    
    print_status "Monitor fix script created at $HOME/.local/bin/fix-monitors.sh"
    echo ""
}

# Function to create systemd service
create_systemd_service() {
    print_step "Creating systemd user service..."
    
    # Create systemd user directory
    mkdir -p "$HOME/.config/systemd/user"
    
    # Create service file
    cat > "$HOME/.config/systemd/user/monitor-fix.service" << EOF
[Unit]
Description=Fix monitor layout after screen unlock
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/fix-monitors.sh
Restart=always
RestartSec=10
Environment=DISPLAY=:1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
    
    print_status "Systemd service file created"
    echo ""
}

# Function to install and enable service
setup_service() {
    print_step "Setting up and enabling the monitor fix service..."
    
    # Reload systemd
    systemctl --user daemon-reload
    
    # Enable the service
    if systemctl --user enable monitor-fix.service; then
        print_status "Service enabled successfully"
    else
        print_error "Failed to enable service"
        exit 1
    fi
    
    # Start the service
    if systemctl --user start monitor-fix.service; then
        print_status "Service started successfully"
    else
        print_error "Failed to start service"
        exit 1
    fi
    
    # Check service status
    sleep 2
    if systemctl --user is-active --quiet monitor-fix.service; then
        print_status "Service is running properly"
    else
        print_warning "Service may not be running correctly"
        systemctl --user status monitor-fix.service
    fi
    
    echo ""
}

# Function to sync monitor configurations
sync_monitor_configs() {
    print_step "Synchronizing monitor configurations..."
    
    if [ -f "$HOME/.config/monitors.xml" ]; then
        if sudo cp "$HOME/.config/monitors.xml" "/var/lib/gdm3/.config/" 2>/dev/null; then
            print_status "Monitor configuration synchronized with GDM3"
        else
            print_warning "Failed to sync monitor config with GDM3 (may require manual intervention)"
        fi
    else
        print_warning "User monitor configuration not found. Configure displays in Settings first."
    fi
    
    echo ""
}

# Function to check kernel parameters
check_kernel_params() {
    print_step "Checking kernel parameters..."
    
    if grep -q "nvidia-drm.modeset=1" /proc/cmdline; then
        print_status "nvidia-drm.modeset=1 kernel parameter is already set"
    else
        print_warning "nvidia-drm.modeset=1 kernel parameter is not set"
        print_warning "This parameter improves NVIDIA driver stability"
        echo "To add it manually:"
        echo "1. sudo nano /etc/default/grub"
        echo "2. Add 'nvidia-drm.modeset=1' to GRUB_CMDLINE_LINUX_DEFAULT"
        echo "3. sudo update-grub"
        echo "4. Reboot"
    fi
    
    echo ""
}

# Function to create test script
create_test_script() {
    print_step "Creating test script..."
    
    cat > "$HOME/.local/bin/test-monitor-fix.sh" << EOF
#!/bin/bash

echo "Testing monitor fix setup..."
echo "Current monitor configuration:"
xrandr --query | grep -E "(Screen 0|connected)"
echo ""

echo "Testing xrandr command:"
$XRANDR_CMD
echo "Command executed with exit code: \$?"
echo ""

echo "Service status:"
systemctl --user status monitor-fix.service
echo ""

echo "Recent service logs:"
journalctl --user -u monitor-fix.service --since "5 minutes ago" --no-pager
echo ""

echo "Monitor fix log:"
if [ -f "\$HOME/.local/share/monitor-fix.log" ]; then
    tail -10 "\$HOME/.local/share/monitor-fix.log"
else
    echo "No monitor fix log found yet"
fi
EOF
    
    chmod +x "$HOME/.local/bin/test-monitor-fix.sh"
    print_status "Test script created at $HOME/.local/bin/test-monitor-fix.sh"
    echo ""
}

# Function to display summary
display_summary() {
    echo -e "${GREEN}================================================${NC}"
    if [[ "$UPDATING_EXISTING" == "true" ]]; then
        echo -e "${GREEN} Update Complete!${NC}"
    else
        echo -e "${GREEN} Setup Complete!${NC}"
    fi
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "✅ Monitor fix script created and configured"
    echo "✅ Systemd service installed and running"
    echo "✅ Automated monitoring for screen unlock events"
    echo ""
    echo -e "${BLUE}Files created:${NC}"
    echo "📁 $HOME/.local/bin/fix-monitors.sh (main script)"
    echo "📁 $HOME/.config/systemd/user/monitor-fix.service (systemd service)"
    echo "📁 $HOME/.local/bin/test-monitor-fix.sh (test script)"
    echo "📁 $LOG_FILE (setup log)"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "🔍 Check service status: systemctl --user status monitor-fix.service"
    echo "📋 View service logs: journalctl --user -u monitor-fix.service -f"
    echo "🧪 Test setup: ~/.local/bin/test-monitor-fix.sh"
    echo "🔄 Restart service: systemctl --user restart monitor-fix.service"
    echo ""
    echo -e "${BLUE}Monitor configuration:${NC}"
    echo "$CURRENT_CONFIG"
    echo ""
    echo -e "${BLUE}Generated xrandr command:${NC}"
    echo "$XRANDR_CMD"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Test by locking and unlocking your screen (Super+L)"
    echo "2. Check logs to verify the script is working"
    echo "3. If needed, run the test script to troubleshoot"
    echo ""
    echo "Log file: $LOG_FILE"
}

# Main execution
main() {
    echo "Starting setup at $(date)"
    echo ""
    
    # Check for existing installation
    UPDATING_EXISTING=$(check_existing_installation && echo "true" || echo "false")
    
    check_requirements
    detect_monitors
    generate_xrandr_command
    
    # Confirm with user
    echo -e "${YELLOW}The following xrandr command will be used:${NC}"
    echo "$XRANDR_CMD"
    echo ""
    read -p "Proceed with setup? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_status "Setup cancelled by user"
        exit 0
    fi
    
    create_monitor_script
    create_systemd_service
    setup_service
    sync_monitor_configs
    check_kernel_params
    create_test_script
    
    display_summary
    
    print_status "Setup completed successfully!"
}

# Run main function
main "$@"