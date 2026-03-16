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
    MONITOR_LAYOUTS=""  # Store layout data for the fix script
    MONITOR_NAMES_LIST=""  # Space-separated list of monitor names
    
    # Parse current monitor positions and resolutions from full xrandr output
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # Extract monitor name
            MONITOR_NAME=$(echo "$line" | awk '{print $1}')
            
            # Get current mode and position from full xrandr connected line
            MODE=$(echo "$line" | grep -oP '\d+x\d+(?=\+)' | head -1)
            POS_RAW=$(echo "$line" | grep -oP '\d+x\d+\+\K\d+\+\d+' | head -1)
            
            if [ -n "$MODE" ] && [ -n "$POS_RAW" ]; then
                POSITION=$(echo "$POS_RAW" | sed 's/+/x/')
                XRANDR_CMD="$XRANDR_CMD --output $MONITOR_NAME --mode $MODE --pos $POSITION"
                
                # Store layout data: name:WxH+X+Y
                POS_FORMATTED=$(echo "$POS_RAW" | sed 's/+/+/')
                MONITOR_LAYOUTS="${MONITOR_LAYOUTS}${MONITOR_NAME}:${MODE}+${POS_RAW}\n"
                MONITOR_NAMES_LIST="${MONITOR_NAMES_LIST}${MONITOR_NAME} "
                
                # Add primary flag if this is the primary monitor
                if [ "$MONITOR_NAME" = "$PRIMARY_MONITOR" ]; then
                    XRANDR_CMD="$XRANDR_CMD --primary"
                fi
            fi
        fi
    done <<< "$(echo "$XRANDR_OUTPUT" | grep " connected " | grep -E '\d+x\d+\+')"
    
    # Remove trailing space
    MONITOR_NAMES_LIST=$(echo "$MONITOR_NAMES_LIST" | sed 's/ $//')
    
    # Remove extra spaces
    XRANDR_CMD=$(echo "$XRANDR_CMD" | tr -s ' ')
    
    print_status "Generated xrandr command:"
    echo "$XRANDR_CMD"
    print_status "Monitor layouts detected:"
    echo -e "$MONITOR_LAYOUTS"
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
    
    # Build the expected layout declarations for the script
    LAYOUT_DECLARATIONS=""
    while IFS= read -r entry; do
        if [ -n "$entry" ]; then
            local mon_name="${entry%%:*}"
            local mon_geom="${entry#*:}"
            LAYOUT_DECLARATIONS="${LAYOUT_DECLARATIONS}EXPECTED_LAYOUT[${mon_name}]=\"${mon_geom}\"\n"
        fi
    done <<< "$(echo -e "$MONITOR_LAYOUTS" | grep -v '^$')"
    
    # Build the per-output xrandr --auto commands
    AUTO_CMDS=""
    for mon in $MONITOR_NAMES_LIST; do
        AUTO_CMDS="${AUTO_CMDS}    xrandr --output \"${mon}\" --auto 2>/dev/null\n    sleep 0.5\n"
    done
    
    # Create the script
    cat > "$HOME/.local/bin/fix-monitors.sh" << 'MAINEOF'
#!/bin/bash

# Monitor Fix Script for Multi-Monitor Setup
# Listens for screen unlock events and restores the correct monitor layout
# Auto-generated by setup-monitor-fix.sh

LOG_FILE="$HOME/.local/share/monitor-fix.log"
LAST_RESTORE_FILE="/tmp/monitor-fix-last-$(id -u)"
COOLDOWN_SECONDS=30

# Expected layout: output_name => "WxH+X+Y"
declare -A EXPECTED_LAYOUT
LAYOUT_DECLARATIONS_PLACEHOLDER
PRIMARY_OUTPUT="PRIMARY_PLACEHOLDER"
MONITOR_NAMES="MONITOR_NAMES_PLACEHOLDER"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

check_layout() {
    # Returns "ok" if layout is correct, or a description of the issue
    local xrandr_output
    xrandr_output=$(xrandr --query 2>/dev/null)

    for output in "${!EXPECTED_LAYOUT[@]}"; do
        local expected="${EXPECTED_LAYOUT[$output]}"

        local line
        line=$(echo "$xrandr_output" | grep "^${output} connected")
        if [ -z "$line" ]; then
            echo "not_connected:${output}"
            return 1
        fi

        local current_geom
        current_geom=$(echo "$line" | grep -oP '\d+x\d+\+\d+\+\d+')
        if [ -z "$current_geom" ]; then
            echo "no_active_mode:${output}"
            return 1
        fi

        if [ "$current_geom" != "$expected" ]; then
            echo "wrong_layout:${output}:current=${current_geom}:expected=${expected}"
            return 1
        fi
    done

    echo "ok"
    return 0
}

apply_exact_layout() {
    XRANDR_COMMAND_PLACEHOLDER 2>&1
}

restore_monitors() {
    # Cooldown check using timestamp file
    local now
    now=$(date +%s)
    if [ -f "$LAST_RESTORE_FILE" ]; then
        local last_time
        last_time=$(cat "$LAST_RESTORE_FILE" 2>/dev/null)
        if [ -n "$last_time" ] && [ $((now - last_time)) -lt $COOLDOWN_SECONDS ]; then
            log_msg "Skipping (cooldown: last restore was $((now - last_time))s ago)"
            return
        fi
    fi
    echo "$now" > "$LAST_RESTORE_FILE"

    log_msg "Screen unlocked, polling monitor layout..."

    # Poll layout multiple times over 5 seconds to catch delayed resets
    # Mutter may report correct layout initially, then reset it after DPMS wake
    local status
    local poll_interval=1
    local poll_count=5
    local issue_found=false
    local last_status=""

    for i in $(seq 1 $poll_count); do
        sleep $poll_interval
        status=$(check_layout)
        if [ "$status" != "ok" ]; then
            issue_found=true
            last_status="$status"
            log_msg "Poll $i/$poll_count: issue detected: $status"
            break
        fi
    done

    if [ "$issue_found" = "false" ]; then
        log_msg "Layout stable after ${poll_count}s polling, no fix needed"
        date +%s > "$LAST_RESTORE_FILE"
        return
    fi

    status="$last_status"
    log_msg "Issue confirmed: $status — starting fix..."

    # Step 1: Force DPMS on to wake all monitors
    xset dpms force on 2>/dev/null
    log_msg "DPMS forced on"
    sleep 0.5

    # Step 2: Try applying exact layout directly (fast path, skip --auto)
    local max_retries=5
    local retry=1
    while [ $retry -le $max_retries ]; do
        log_msg "Applying exact layout (attempt $retry)..."
        local output
        output=$(apply_exact_layout)
        local rc=$?

        if [ $rc -eq 0 ] && [ -z "$output" ]; then
            sleep 0.5
            status=$(check_layout)
            if [ "$status" = "ok" ]; then
                log_msg "Layout restored and verified on attempt $retry"
                date +%s > "$LAST_RESTORE_FILE"
                return
            else
                log_msg "xrandr succeeded but verification failed: $status"
            fi
        else
            log_msg "Attempt $retry failed (rc=$rc): $output"
        fi

        # On first failure, initialize CRTCs with --auto before next retry
        if [ $retry -eq 1 ]; then
            log_msg "Initializing outputs with --auto..."
AUTO_COMMANDS_PLACEHOLDER
            sleep 1
        else
            sleep $((retry * 1))
        fi
        retry=$((retry + 1))
    done

    log_msg "WARNING: All $max_retries attempts failed. Final state:"
    xrandr --query 2>/dev/null | grep -E "^\S+ connected" >> "$LOG_FILE"
    date +%s > "$LAST_RESTORE_FILE"
}

# Main monitoring loop
log_msg "Monitor fix service started"
unlock_detected=false

dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "member=ActiveChanged"; then
        unlock_detected=true
    fi

    if [[ "$unlock_detected" == "true" ]] && echo "$line" | grep -q "boolean false"; then
        restore_monitors
        unlock_detected=false
    fi

    if echo "$line" | grep -q "member=" && ! echo "$line" | grep -q "member=ActiveChanged"; then
        unlock_detected=false
    fi
done
MAINEOF
    
    # Replace placeholders with actual values
    sed -i "s|XRANDR_COMMAND_PLACEHOLDER|$XRANDR_CMD|g" "$HOME/.local/bin/fix-monitors.sh"
    sed -i "s|PRIMARY_PLACEHOLDER|$PRIMARY_MONITOR|g" "$HOME/.local/bin/fix-monitors.sh"
    sed -i "s|MONITOR_NAMES_PLACEHOLDER|$MONITOR_NAMES_LIST|g" "$HOME/.local/bin/fix-monitors.sh"
    
    # Replace layout declarations placeholder
    local escaped_layouts
    escaped_layouts=$(echo -e "$LAYOUT_DECLARATIONS" | sed 's/[&/\]/\\&/g')
    sed -i "/LAYOUT_DECLARATIONS_PLACEHOLDER/c\\$escaped_layouts" "$HOME/.local/bin/fix-monitors.sh"
    
    # Replace auto commands placeholder
    local escaped_auto
    escaped_auto=$(echo -e "$AUTO_CMDS" | sed 's/[&/\]/\\&/g')
    sed -i "/AUTO_COMMANDS_PLACEHOLDER/c\\$escaped_auto" "$HOME/.local/bin/fix-monitors.sh"
    
    # Make script executable
    chmod +x "$HOME/.local/bin/fix-monitors.sh"
    
    # Validate script syntax
    if bash -n "$HOME/.local/bin/fix-monitors.sh"; then
        print_status "Monitor fix script created and validated at $HOME/.local/bin/fix-monitors.sh"
    else
        print_error "Script syntax validation failed!"
        exit 1
    fi
    
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

# Function to clean monitors.xml - remove stale configurations
clean_monitors_xml() {
    print_step "Cleaning monitors.xml (removing stale configurations)..."

    local monitors_xml="$HOME/.config/monitors.xml"
    if [ ! -f "$monitors_xml" ]; then
        print_warning "No monitors.xml found — will be created by GNOME when you change display settings"
        return
    fi

    # Get current connected monitors (connector names)
    local current_connectors
    current_connectors=$(xrandr --query 2>/dev/null | grep " connected " | awk '{print $1}' | sort)
    local num_current
    num_current=$(echo "$current_connectors" | wc -l)

    print_status "Current connected monitors: $(echo $current_connectors | tr '\n' ' ')"

    # Back up before cleaning
    cp "$monitors_xml" "${monitors_xml}.bak.$(date +%Y%m%d-%H%M%S)"

    # Use Python to parse and clean the XML (bash XML parsing is fragile)
    python3 << 'CLEANEOF'
import xml.etree.ElementTree as ET
import sys, os

monitors_xml = os.path.expanduser("~/.config/monitors.xml")
current_connectors = set()

# Get current connected monitors from xrandr
import subprocess
xrandr = subprocess.check_output(["xrandr", "--query"], text=True)
for line in xrandr.split("\n"):
    if " connected " in line:
        current_connectors.add(line.split()[0])

try:
    tree = ET.parse(monitors_xml)
    root = tree.getroot()
except ET.ParseError as e:
    print(f"ERROR: Failed to parse monitors.xml: {e}", file=sys.stderr)
    sys.exit(1)

configs = root.findall("configuration")
original_count = len(configs)
kept = []

for config in configs:
    connectors_in_config = set()
    for monitor in config.iter("monitor"):
        spec = monitor.find("monitorspec")
        if spec is not None:
            connector = spec.find("connector")
            if connector is not None and connector.text:
                connectors_in_config.add(connector.text)

    # Keep config if ALL its connectors match current ones
    if connectors_in_config and connectors_in_config.issubset(current_connectors):
        kept.append(config)

if not kept:
    print(f"WARNING: No configs match current connectors {current_connectors}. Keeping all.")
    sys.exit(0)

# Keep only the LAST matching config (most recent)
# Remove all configs, then add back only the last match
for config in configs:
    root.remove(config)
root.append(kept[-1])

tree.write(monitors_xml, xml_declaration=False)

# Add XML header manually (ET doesn't write the version attribute correctly)
with open(monitors_xml, "r") as f:
    content = f.read()
if not content.startswith("<monitors"):
    with open(monitors_xml, "w") as f:
        f.write(content)

removed = original_count - 1
print(f"Cleaned: kept 1 config, removed {removed} stale config(s) (from {original_count} total)")
CLEANEOF

    local rc=$?
    if [ $rc -eq 0 ]; then
        print_status "monitors.xml cleaned successfully"
    else
        print_warning "monitors.xml cleanup had issues (backup preserved)"
    fi
    echo ""
}

# Function to sync monitor configurations
sync_monitor_configs() {
    print_step "Synchronizing monitor configurations..."

    # Clean stale configs first
    clean_monitors_xml

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

# Create manual fix script
create_manual_fix_script() {
    print_step "Creating manual fix script..."

    cat > "$HOME/.local/bin/fix-monitors-manual" << EOF
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
$XRANDR_CMD

echo ""
echo "Verified:"
xrandr --query | grep -E "^\S+ connected"
EOF

    chmod +x "$HOME/.local/bin/fix-monitors-manual"
    print_status "Manual fix script created at $HOME/.local/bin/fix-monitors-manual"
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
    echo "📁 $HOME/.local/bin/fix-monitors-manual (manual fix)"
    echo "📁 $LOG_FILE (setup log)"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "🔍 Check service status: systemctl --user status monitor-fix.service"
    echo "📋 View service logs: journalctl --user -u monitor-fix.service -f"
    echo "🧪 Test setup: ~/.local/bin/test-monitor-fix.sh"
    echo "� Manual fix: fix-monitors-manual"
    echo "�🔄 Restart service: systemctl --user restart monitor-fix.service"
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
    create_manual_fix_script
    
    display_summary
    
    print_status "Setup completed successfully!"
}

# Run main function
main "$@"