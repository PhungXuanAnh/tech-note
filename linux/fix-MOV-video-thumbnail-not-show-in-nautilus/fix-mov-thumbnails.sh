#!/bin/bash

################################################################################
# MOV Video Thumbnail Fix Script for Ubuntu/GNOME Nautilus
# 
# This script fixes the common issue where MOV video files (especially from
# iPhones) don't show thumbnails in Nautilus file manager.
#
# Author: Auto-generated
# Date: November 2, 2025
# Tested on: Ubuntu 22.04 (Jammy)
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

################################################################################
# Step 1: Check system compatibility
################################################################################
check_system() {
    print_header "Step 1: Checking System Compatibility"
    
    # Check if running Ubuntu/Debian
    if [ ! -f /etc/debian_version ]; then
        log_error "This script is designed for Ubuntu/Debian systems"
        exit 1
    fi
    log_success "Debian-based system detected"
    
    # Check if GNOME/Nautilus is installed
    if ! command -v nautilus &> /dev/null; then
        log_error "Nautilus file manager not found"
        log_info "This script requires GNOME Nautilus file manager"
        exit 1
    fi
    log_success "Nautilus file manager found"
    
    # Check Ubuntu version
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        log_info "System: $NAME $VERSION"
    fi
}

################################################################################
# Step 2: Check and install ffmpegthumbnailer
################################################################################
install_ffmpegthumbnailer() {
    print_header "Step 2: Installing ffmpegthumbnailer"
    
    if dpkg -l | grep -q "^ii.*ffmpegthumbnailer"; then
        log_success "ffmpegthumbnailer is already installed"
    else
        log_warning "ffmpegthumbnailer not found. Installing..."
        
        if [ "$EUID" -ne 0 ]; then
            log_info "Installing with sudo..."
            sudo apt update
            sudo apt install -y ffmpegthumbnailer
        else
            apt update
            apt install -y ffmpegthumbnailer
        fi
        
        log_success "ffmpegthumbnailer installed successfully"
    fi
    
    # Verify installation
    if command -v ffmpegthumbnailer &> /dev/null; then
        version=$(ffmpegthumbnailer -v 2>&1 | head -n1 || echo "Unknown")
        log_info "Version: $version"
    fi
}

################################################################################
# Step 3: Configure thumbnailers
################################################################################
configure_thumbnailers() {
    print_header "Step 3: Configuring Video Thumbnailers"
    
    # Create thumbnailers directory
    THUMBNAILER_DIR="$HOME/.local/share/thumbnailers"
    mkdir -p "$THUMBNAILER_DIR"
    log_success "Created directory: $THUMBNAILER_DIR"
    
    # Check if system ffmpegthumbnailer exists
    if [ ! -f /usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer ]; then
        log_error "System ffmpegthumbnailer.thumbnailer not found!"
        log_error "Please reinstall ffmpegthumbnailer package"
        exit 1
    fi
    
    # Create symbolic link to ffmpegthumbnailer
    FFMPEG_LINK="$THUMBNAILER_DIR/ffmpegthumbnailer.thumbnailer"
    if [ -L "$FFMPEG_LINK" ] || [ -f "$FFMPEG_LINK" ]; then
        rm -f "$FFMPEG_LINK"
        log_info "Removed existing ffmpegthumbnailer configuration"
    fi
    
    ln -s /usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer "$FFMPEG_LINK"
    log_success "Created ffmpegthumbnailer symbolic link"
    
    # Disable totem thumbnailer by creating an override with empty MIME types
    TOTEM_OVERRIDE="$THUMBNAILER_DIR/totem.thumbnailer"
    
    # Backup existing totem configuration if it exists and is not our override
    if [ -f "$TOTEM_OVERRIDE" ] && [ ! "$(grep -c "^MimeType=$" "$TOTEM_OVERRIDE" 2>/dev/null || echo 0)" -eq 1 ]; then
        mv "$TOTEM_OVERRIDE" "$TOTEM_OVERRIDE.backup.$(date +%s)"
        log_info "Backed up existing totem configuration"
    fi
    
    # Create totem override with empty MIME types to disable it
    cat > "$TOTEM_OVERRIDE" << 'EOF'
[Thumbnailer Entry]
TryExec=totem-video-thumbnailer
Exec=totem-video-thumbnailer -s %s %u %o
MimeType=
EOF
    
    log_success "Disabled totem video thumbnailer (prevents conflicts)"
    
    # Also create config in alternative location for compatibility
    ALT_THUMBNAILER_DIR="$HOME/.config/nautilus/thumbnailers"
    if [ ! -d "$ALT_THUMBNAILER_DIR" ]; then
        mkdir -p "$ALT_THUMBNAILER_DIR"
        ln -s /usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer "$ALT_THUMBNAILER_DIR/ffmpegthumbnailer.thumbnailer"
        log_info "Also configured alternative thumbnailer location"
    fi
}

################################################################################
# Step 4: Check and configure GNOME settings
################################################################################
configure_gnome_settings() {
    print_header "Step 4: Configuring GNOME Settings"
    
    # Check if gsettings is available
    if ! command -v gsettings &> /dev/null; then
        log_warning "gsettings not found, skipping GNOME configuration"
        return
    fi
    
    # Enable thumbnails
    current_setting=$(gsettings get org.gnome.nautilus.preferences show-image-thumbnails 2>/dev/null || echo "")
    if [ "$current_setting" != "'always'" ]; then
        gsettings set org.gnome.nautilus.preferences show-image-thumbnails 'always'
        log_success "Enabled thumbnail generation (set to 'always')"
    else
        log_info "Thumbnails already set to 'always'"
    fi
    
    # Check thumbnail size limit
    size_limit=$(gsettings get org.gnome.nautilus.preferences thumbnail-limit 2>/dev/null || echo "")
    size_limit_mb=$((size_limit / 1048576))
    
    if [ "$size_limit_mb" -lt 100 ]; then
        log_info "Current thumbnail size limit: ${size_limit_mb}MB"
        log_warning "Consider increasing if you have large video files"
        log_info "To increase to 200MB, run:"
        echo "  gsettings set org.gnome.nautilus.preferences thumbnail-limit $((200 * 1048576))"
    else
        log_success "Thumbnail size limit: ${size_limit_mb}MB"
    fi
}

################################################################################
# Step 5: Clear thumbnail cache
################################################################################
clear_thumbnail_cache() {
    print_header "Step 5: Clearing Thumbnail Cache"
    
    CACHE_DIR="$HOME/.cache/thumbnails"
    
    if [ -d "$CACHE_DIR" ]; then
        # Count existing thumbnails
        thumb_count=$(find "$CACHE_DIR" -type f -name "*.png" 2>/dev/null | wc -l)
        log_info "Found $thumb_count existing thumbnails"
        
        # Ask user for confirmation
        read -p "Clear thumbnail cache to force regeneration? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "${CACHE_DIR:?}"/*
            log_success "Thumbnail cache cleared"
            log_info "Thumbnails will be regenerated when you browse files"
        else
            log_info "Keeping existing thumbnail cache"
        fi
    else
        log_info "No thumbnail cache found (will be created automatically)"
    fi
}

################################################################################
# Step 6: Test thumbnailer
################################################################################
test_thumbnailer() {
    print_header "Step 6: Testing Thumbnailer"
    
    # Find a MOV file to test with
    log_info "Searching for MOV files to test..."
    
    # Common locations for videos
    test_locations=(
        "$HOME/Videos"
        "$HOME/Pictures"
        "$HOME/Downloads"
    )
    
    test_file=""
    for location in "${test_locations[@]}"; do
        if [ -d "$location" ]; then
            test_file=$(find "$location" -maxdepth 3 -type f -iname "*.mov" 2>/dev/null | head -n1)
            if [ -n "$test_file" ]; then
                break
            fi
        fi
    done
    
    if [ -n "$test_file" ]; then
        log_info "Testing with: $test_file"
        
        # Test ffmpegthumbnailer
        test_output="/tmp/test_thumbnail_$$.png"
        if ffmpegthumbnailer -i "$test_file" -o "$test_output" -s 256 -f 2>/dev/null; then
            if [ -f "$test_output" ]; then
                size=$(stat -f%z "$test_output" 2>/dev/null || stat -c%s "$test_output" 2>/dev/null)
                log_success "Thumbnail generated successfully (${size} bytes)"
                rm -f "$test_output"
            else
                log_error "Thumbnail generation failed"
            fi
        else
            log_error "ffmpegthumbnailer test failed"
        fi
    else
        log_warning "No MOV files found for testing"
        log_info "Thumbnailer will work automatically when you view MOV files"
    fi
}

################################################################################
# Step 7: Restart Nautilus
################################################################################
restart_nautilus() {
    print_header "Step 7: Restarting Nautilus"
    
    # Check if Nautilus is running
    if pgrep -x nautilus > /dev/null; then
        log_info "Stopping Nautilus..."
        nautilus -q 2>/dev/null || killall nautilus 2>/dev/null || true
        sleep 1
        log_success "Nautilus stopped"
    else
        log_info "Nautilus was not running"
    fi
    
    log_info "Nautilus will restart automatically when you open it"
    log_info "Or run: nautilus &"
}

################################################################################
# Step 8: Generate thumbnails for existing MOV files (optional)
################################################################################
generate_existing_thumbnails() {
    print_header "Step 8: Generate Thumbnails for Existing MOV Files (Optional)"
    
    read -p "Generate thumbnails for all MOV files in a specific directory? [y/N] " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping thumbnail generation for existing files"
        return
    fi
    
    # Ask for directory
    echo -n "Enter directory path (or press Enter for ~/Pictures): "
    read target_dir
    
    if [ -z "$target_dir" ]; then
        target_dir="$HOME/Pictures"
    fi
    
    # Expand ~ to home directory
    target_dir="${target_dir/#\~/$HOME}"
    
    if [ ! -d "$target_dir" ]; then
        log_error "Directory not found: $target_dir"
        return
    fi
    
    log_info "Searching for MOV files in: $target_dir"
    
    # Find all MOV files
    mapfile -t mov_files < <(find "$target_dir" -type f -iname "*.mov" 2>/dev/null)
    
    if [ ${#mov_files[@]} -eq 0 ]; then
        log_warning "No MOV files found in $target_dir"
        return
    fi
    
    log_info "Found ${#mov_files[@]} MOV files"
    
    mkdir -p "$HOME/.cache/thumbnails/normal"
    
    generated=0
    skipped=0
    failed=0
    
    for mov_file in "${mov_files[@]}"; do
        # Generate URI and hash (same way Nautilus does it)
        uri="file://$(echo "$mov_file" | sed 's/ /%20/g')"
        hash=$(echo -n "$uri" | md5sum | cut -d' ' -f1)
        thumb_path="$HOME/.cache/thumbnails/normal/${hash}.png"
        
        # Skip if thumbnail already exists
        if [ -f "$thumb_path" ]; then
            ((skipped++))
            continue
        fi
        
        # Generate thumbnail
        if ffmpegthumbnailer -i "$mov_file" -o "$thumb_path" -s 256 -f 2>/dev/null; then
            ((generated++))
            echo -ne "\r${GREEN}✓${NC} Generated: $generated | Skipped: $skipped | Failed: $failed"
        else
            ((failed++))
            echo -ne "\r${GREEN}✓${NC} Generated: $generated | Skipped: $skipped | ${RED}Failed: $failed${NC}"
        fi
    done
    
    echo  # New line after progress
    log_success "Thumbnail generation complete!"
    log_info "Generated: $generated | Skipped: $skipped | Failed: $failed"
}

################################################################################
# Step 9: Summary and next steps
################################################################################
print_summary() {
    print_header "Setup Complete!"
    
    echo -e "${GREEN}✓ MOV thumbnail support has been configured successfully!${NC}\n"
    
    echo "What was done:"
    echo "  • Installed/verified ffmpegthumbnailer"
    echo "  • Configured ffmpegthumbnailer as default video thumbnailer"
    echo "  • Disabled conflicting totem thumbnailer"
    echo "  • Configured GNOME/Nautilus settings"
    echo "  • Restarted Nautilus file manager"
    
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo "  1. Open Nautilus and navigate to a folder with MOV files"
    echo "  2. Switch to grid view (Ctrl+2)"
    echo "  3. Thumbnails will generate automatically"
    echo "  4. First-time generation may take a few seconds"
    
    echo -e "\n${YELLOW}Troubleshooting:${NC}"
    echo "  • If thumbnails don't appear, press Ctrl+R to refresh"
    echo "  • Close and reopen Nautilus completely"
    echo "  • Check View → Preferences → Show thumbnails is enabled"
    
    echo -e "\n${BLUE}To manually test the thumbnailer:${NC}"
    echo "  ffmpegthumbnailer -i /path/to/video.mov -o output.png -s 256 -f"
    
    echo -e "\n${GREEN}Enjoy your MOV thumbnails! 🎬${NC}\n"
}

################################################################################
# Main execution
################################################################################
main() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  MOV Video Thumbnail Fix for Ubuntu/GNOME Nautilus        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    
    check_system
    install_ffmpegthumbnailer
    configure_thumbnailers
    configure_gnome_settings
    clear_thumbnail_cache
    test_thumbnailer
    restart_nautilus
    generate_existing_thumbnails
    print_summary
}

# Run main function
main "$@"
