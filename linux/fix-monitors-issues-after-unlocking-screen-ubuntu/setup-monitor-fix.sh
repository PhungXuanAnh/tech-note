#!/bin/bash

# Multi-Monitor Fix Setup Script for Ubuntu 22.04+
# This script automates the installation and configuration of the monitor detection fix
# after screen lock/unlock cycles for NVIDIA systems

set -e  # Exit on any error

# Directory containing this setup script (and the source scripts to symlink)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    
    # Detect nvidia-settings MetaMode for USB-C hub signal fix
    # USB-C hubs may drop the DP-to-HDMI signal after DPMS wake.
    # Cycling the MetaMode (remove monitor then re-add) forces NVIDIA to
    # fully tear down and recreate the display pipeline.
    METAMODE_FULL=""
    METAMODE_REDUCED=""
    if command_exists nvidia-settings; then
        METAMODE_FULL=$(nvidia-settings -t -q CurrentMetaMode 2>/dev/null | head -1)
        if [ -n "$METAMODE_FULL" ]; then
            # Strip the "id=XX, switchable=..., source=... :: " prefix if present
            METAMODE_FULL=$(echo "$METAMODE_FULL" | sed 's/^.*:: //')
            print_status "NVIDIA MetaMode detected: $METAMODE_FULL"
            
            # Build a reduced MetaMode by removing any DPY entries for DP-* monitors
            # (these are the ones typically connected via USB-C hubs)
            # Parse monitor names to find DP-* outputs and their DPY mappings
            METAMODE_REDUCED="$METAMODE_FULL"
            METAMODE_DP_OFF_CMDS=""
            for mon in $MONITOR_NAMES_LIST; do
                if [[ "$mon" == DP-* ]]; then
                    # Find the DPY-N identifier for this monitor from nvidia-settings
                    local dpy_id
                    dpy_id=$(nvidia-settings -q dpys 2>/dev/null | grep -B1 "($mon)" | grep -oP 'dpy:\d+' | head -1)
                    if [ -n "$dpy_id" ]; then
                        local dpy_name="DPY-${dpy_id#dpy:}"
                        # Remove this DPY entry from the MetaMode (entry is "DPY-N: ...")
                        # Each entry is separated by ", DPY-" 
                        METAMODE_REDUCED=$(echo "$METAMODE_REDUCED" | sed -E "s/,?\s*${dpy_name}:[^,]*(,|$)/\1/g" | sed 's/^, //' | sed 's/, $//')
                        METAMODE_DP_OFF_CMDS="${METAMODE_DP_OFF_CMDS}xrandr --output $mon --off 2>/dev/null || true\n        "
                        print_status "Will cycle $mon ($dpy_name) via MetaMode for USB-C hub fix"
                    fi
                fi
            done
            
            if [ "$METAMODE_REDUCED" = "$METAMODE_FULL" ]; then
                print_warning "No DP-* monitors found for MetaMode cycling"
                METAMODE_FULL=""
                METAMODE_REDUCED=""
            fi
        fi
    fi
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

# Install the repo scripts into ~/.local/bin as symlinks, so future edits to the
# scripts in this repo apply immediately without re-running setup.
install_scripts() {
    print_step "Installing scripts (symlinks to this repo)..."
    mkdir -p "$HOME/.local/bin"

    local scripts=(fix-monitors-auto.sh monitor-fix-resync.sh fix-monitors-manual.sh)
    local s
    for s in "${scripts[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$s" ]; then
            print_error "Source script not found: $SCRIPT_DIR/$s"
            exit 1
        fi
        chmod +x "$SCRIPT_DIR/$s"
        ln -sf "$SCRIPT_DIR/$s" "$HOME/.local/bin/$s"
        print_status "Symlinked $s -> ~/.local/bin/$s"
    done

    # Global short command so `fix-monitors-manual` works from anywhere.
    # /usr/local/bin is root-owned, so this needs sudo.
    if sudo ln -sf "$SCRIPT_DIR/fix-monitors-manual.sh" /usr/local/bin/fix-monitors-manual 2>/dev/null; then
        print_status "Global command installed: fix-monitors-manual"
    else
        print_warning "Could not create /usr/local/bin/fix-monitors-manual (create it later with sudo if you want the short command)"
    fi

    echo ""
}

# Generate the layout config from the current display layout. The auto/manual
# scripts read this file; it is also regenerated automatically whenever you
# change Display Settings (see monitor-fix-resync.path).
generate_layout_config() {
    print_step "Generating layout config from current display layout..."
    if [ -x "$HOME/.local/bin/monitor-fix-resync.sh" ]; then
        "$HOME/.local/bin/monitor-fix-resync.sh" || true
    fi
    if [ -f "$HOME/.local/share/monitor-fix/layout.env" ]; then
        print_status "Layout config written to ~/.local/share/monitor-fix/layout.env"
    else
        print_warning "Layout config not created; scripts will use built-in defaults"
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
ExecStart=%h/.local/bin/fix-monitors-auto.sh
Restart=always
RestartSec=10
Environment=DISPLAY=:1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

    # Resync service: regenerates layout.env from the current display layout
    cat > "$HOME/.config/systemd/user/monitor-fix-resync.service" << 'EOF'
[Unit]
Description=Regenerate monitor-fix layout config from current display layout

[Service]
Type=oneshot
ExecStart=%h/.local/bin/monitor-fix-resync.sh
EOF

    # Path unit: triggers the resync whenever monitors.xml changes (i.e. you
    # rearrange displays in Settings -> Displays), so the fix always targets
    # your current layout without re-running this setup.
    cat > "$HOME/.config/systemd/user/monitor-fix-resync.path" << 'EOF'
[Unit]
Description=Watch monitors.xml and resync monitor-fix layout when displays change

[Path]
PathModified=%h/.config/monitors.xml
Unit=monitor-fix-resync.service

[Install]
WantedBy=default.target
EOF

    print_status "Systemd service files created (monitor-fix + resync path/service)"
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

    # Enable the resync path watcher so layout.env auto-updates on display changes
    if systemctl --user enable --now monitor-fix-resync.path >/dev/null 2>&1; then
        print_status "Resync path watcher enabled (auto-updates on Display Settings change)"
    else
        print_warning "Failed to enable monitor-fix-resync.path"
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
    echo -e "${BLUE}Files (symlinked from this repo):${NC}"
    echo "📁 ~/.local/bin/fix-monitors-auto.sh -> repo (unlock service)"
    echo "📁 ~/.local/bin/monitor-fix-resync.sh -> repo (layout auto-updater)"
    echo "📁 ~/.local/bin/fix-monitors-manual.sh -> repo (manual fix)"
    echo "📁 /usr/local/bin/fix-monitors-manual -> repo (global manual command)"
    echo "📁 ~/.local/share/monitor-fix/layout.env (auto-generated layout config)"
    echo "📁 ~/.config/systemd/user/monitor-fix.service + monitor-fix-resync.path/.service"
    echo "📁 $LOG_FILE (setup log)"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "🔍 Check service status: systemctl --user status monitor-fix.service"
    echo "📋 View service logs: journalctl --user -u monitor-fix.service -f"
    echo "🧪 Test setup: ~/.local/bin/test-monitor-fix.sh"
    echo "🔧 Manual fix (no args): fix-monitors-manual"
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
    echo -e "${YELLOW}Detected current layout (will be captured into the config):${NC}"
    echo "$XRANDR_CMD"
    echo ""
    read -p "Proceed with setup? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_status "Setup cancelled by user"
        exit 0
    fi
    
    create_test_script
    install_scripts
    generate_layout_config
    create_systemd_service
    setup_service
    sync_monitor_configs
    check_kernel_params
    
    display_summary
    
    print_status "Setup completed successfully!"
}

# Run main function
main "$@"