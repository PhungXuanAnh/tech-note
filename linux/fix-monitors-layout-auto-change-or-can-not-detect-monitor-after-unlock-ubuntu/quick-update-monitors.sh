#!/bin/bash

# Quick Update Script for Monitor Layout Changes
# Use this when you rearrange your monitors and need to update the fix script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() { echo -e "${BLUE}=== $1 ===${NC}"; }
print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

print_header "Monitor Layout Update Script"

# Check if monitor fix service exists
if ! systemctl --user is-enabled monitor-fix.service >/dev/null 2>&1; then
    print_error "Monitor fix service not found. Please run the full setup script first."
    exit 1
fi

print_status "Current monitor configuration:"
xrandr --query | grep -E "(connected|disconnected)" | head -10

echo ""
print_status "Current monitor fix script configuration:"
if [ -f "$HOME/.local/bin/fix-monitors.sh" ]; then
    grep "xrandr" "$HOME/.local/bin/fix-monitors.sh" | grep -v "log_message" | head -5
else
    print_error "Monitor fix script not found!"
    exit 1
fi

echo ""
print_warning "Options to update the configuration:"
echo "1. Run the full setup script: ./setup-monitor-fix.sh"
echo "2. Manually edit: $HOME/.local/bin/fix-monitors.sh"
echo "3. Use this quick update (experimental)"

echo ""
read -p "Use quick update? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Please use option 1 or 2 for manual update"
    exit 0
fi

# Quick detection and update
print_step "Detecting current layout..."

# Get current monitor configuration
CURRENT_CONFIG=$(xrandr --query | grep " connected" | grep -E "[0-9]+x[0-9]+\+[0-9]+\+[0-9]+")

if [ -z "$CURRENT_CONFIG" ]; then
    print_error "Could not detect current monitor layout"
    exit 1
fi

# Generate new xrandr command
XRANDR_CMD="xrandr"
echo "$CURRENT_CONFIG" | while read -r line; do
    MONITOR=$(echo "$line" | awk '{print $1}')
    RESOLUTION=$(echo "$line" | grep -o '[0-9]\+x[0-9]\+' | head -1)
    POSITION=$(echo "$line" | grep -o '+[0-9]\++[0-9]\+')
    
    if [[ "$line" == *"primary"* ]]; then
        XRANDR_CMD="$XRANDR_CMD --output $MONITOR --mode $RESOLUTION --pos ${POSITION#+} --primary"
    else
        XRANDR_CMD="$XRANDR_CMD --output $MONITOR --mode $RESOLUTION --pos ${POSITION#+}"
    fi
done

# Show the command that would be used
print_status "New xrandr command would be:"
echo "$XRANDR_CMD"

echo ""
print_warning "This is experimental. For reliable updates, use the full setup script."
read -p "Apply this update? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create backup
    cp "$HOME/.local/bin/fix-monitors.sh" "$HOME/.local/bin/fix-monitors.sh.backup"
    
    # Update the script (this is a simplified version)
    print_status "Updating monitor fix script..."
    print_warning "Complex layouts may need manual adjustment"
    
    # This is a basic update - for complex scenarios, use the full setup script
    sed -i "s|xrandr.*|    $XRANDR_CMD|" "$HOME/.local/bin/fix-monitors.sh"
    
    # Validate script syntax
    if bash -n "$HOME/.local/bin/fix-monitors.sh"; then
        print_status "Script syntax validated successfully"
        
        # Restart service
        systemctl --user restart monitor-fix.service
        
        print_status "Update completed. Test with lock/unlock cycle."
        print_status "Backup saved as: $HOME/.local/bin/fix-monitors.sh.backup"
    else
        print_error "Script syntax validation failed! Restoring backup..."
        cp "$HOME/.local/bin/fix-monitors.sh.backup" "$HOME/.local/bin/fix-monitors.sh"
        print_error "Update failed. Use the full setup script for reliable updates."
    fi
else
    print_status "Update cancelled. Use the full setup script for reliable updates."
fi