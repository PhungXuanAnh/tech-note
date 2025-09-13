#!/bin/bash

# Quick Monitor Fix Installer
# Downloads and runs the full setup script

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} Quick Monitor Fix Installer${NC}"
echo -e "${BLUE} Fixes overlapping coordinates & unlock issues${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're in the right directory or if the script exists
if [ -f "./setup-monitor-fix.sh" ]; then
    echo -e "${GREEN}[INFO]${NC} Found setup script in current directory"
    ./setup-monitor-fix.sh
elif [ -f "/home/$USER/Downloads/fix-detect-monitor-fail/setup-monitor-fix.sh" ]; then
    echo -e "${GREEN}[INFO]${NC} Found setup script in Downloads directory"
    /home/$USER/Downloads/fix-detect-monitor-fail/setup-monitor-fix.sh
else
    echo -e "${GREEN}[INFO]${NC} Setup script not found locally"
    echo "Please ensure setup-monitor-fix.sh is in the current directory or run it directly"
    echo ""
    echo "Usage:"
    echo "1. Download setup-monitor-fix.sh"
    echo "2. chmod +x setup-monitor-fix.sh"
    echo "3. ./setup-monitor-fix.sh"
fi