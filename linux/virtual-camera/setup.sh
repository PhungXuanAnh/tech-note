#!/bin/bash

# Camera Control Setup Script
# This script automates the installation and configuration of the camera control system

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${BOLD}Camera Control Setup${RESET}"
echo "This script will set up the camera control system for freezing and unfreezing your webcam."
echo ""

# Get current directory (for creating correct paths in desktop files)
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Current directory: $CURRENT_DIR"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Secure Boot is enabled
SECURE_BOOT_ENABLED=false
if command_exists mokutil; then
    if mokutil --sb-state | grep -q "enabled"; then
        SECURE_BOOT_ENABLED=true
        echo -e "${RED}WARNING: Secure Boot is enabled on your system!${RESET}"
        echo -e "${YELLOW}This will prevent the v4l2loopback kernel module from loading.${RESET}"
        echo "You have three options:"
        echo "1. Sign the kernel module (keep Secure Boot enabled)"
        echo "2. Continue setup without signing (you'll need to disable Secure Boot later)"
        echo "3. Exit and disable Secure Boot manually before running this script again"
        echo ""
        echo -e "Please choose an option (1-3): "
        read -r secure_boot_option
        
        case $secure_boot_option in
            1)
                echo "You chose to sign the module."
                # Check if sign_module.sh exists and is executable
                if [ -f "$CURRENT_DIR/sign_module.sh" ]; then
                    if [ ! -x "$CURRENT_DIR/sign_module.sh" ]; then
                        chmod +x "$CURRENT_DIR/sign_module.sh"
                    fi
                    echo -e "${YELLOW}Running module signing script...${RESET}"
                    "$CURRENT_DIR/sign_module.sh"
                    
                    # Check if the module is now loaded
                    if lsmod | grep -q v4l2loopback; then
                        echo -e "${GREEN}Module signed and loaded successfully!${RESET}"
                    else
                        echo -e "${YELLOW}Module was signed but not loaded yet.${RESET}"
                        echo "You'll need to reboot after this setup completes to enroll the MOK key."
                    fi
                else
                    echo -e "${RED}Error: sign_module.sh not found in $CURRENT_DIR${RESET}"
                    echo "Would you like to continue setup anyway? (y/n): "
                    read -r continue_anyway
                    if [[ ! "$continue_anyway" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                        echo "Setup cancelled."
                        exit 0
                    fi
                fi
                ;;
            2)
                echo "Continuing setup without signing the module."
                echo -e "${YELLOW}Note: You'll need to disable Secure Boot or sign the module later for the virtual camera to work.${RESET}"
                ;;
            3)
                echo "Exiting setup. Please disable Secure Boot and run this script again."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Continuing with setup, but the virtual camera may not work until Secure Boot is addressed.${RESET}"
                ;;
        esac
    fi
fi

# Step 1: Install required packages
echo -e "${BOLD}Step 1: Installing required packages...${RESET}"
if sudo apt update; then
    echo -e "${GREEN}Repository information updated successfully.${RESET}"
else
    echo -e "${RED}Failed to update repository information. Continuing anyway...${RESET}"
fi

echo "Installing ffmpeg and v4l-utils..."
if ! sudo apt install -y ffmpeg v4l-utils; then
    echo -e "${YELLOW}Warning: There might have been issues with package installation, but we'll continue.${RESET}"
fi

# Step 2: Install/configure v4l2loopback
echo -e "\n${BOLD}Step 2: Setting up v4l2loopback...${RESET}"

# Check if v4l2loopback is already installed (as module)
if lsmod | grep -q v4l2loopback; then
    echo -e "${YELLOW}v4l2loopback module is already loaded.${RESET}"
    # Unload it so we can reload with our parameters
    echo "Unloading existing module..."
    sudo modprobe -r v4l2loopback || true
fi

# Try to install with DKMS first (easier method)
echo "Attempting to install v4l2loopback-dkms..."
DKMS_SUCCESS=false
if sudo apt install -y v4l2loopback-dkms; then
    if lsmod | grep -q v4l2loopback || sudo modprobe v4l2loopback; then
        echo -e "${GREEN}v4l2loopback-dkms installed and loaded successfully.${RESET}"
        DKMS_SUCCESS=true
    else
        echo -e "${YELLOW}v4l2loopback-dkms installed but module could not be loaded.${RESET}"
    fi
else
    echo -e "${YELLOW}DKMS installation failed. This is common on newer kernels.${RESET}"
fi

# If DKMS failed, build from source
if [ "$DKMS_SUCCESS" != "true" ]; then
    echo -e "${YELLOW}Trying to build v4l2loopback from source...${RESET}"
    
    # Install build dependencies
    echo "Installing build dependencies..."
    sudo apt install -y build-essential linux-headers-$(uname -r) git
    
    # Clone and build v4l2loopback
    if [ ! -d "v4l2loopback" ]; then
        echo "Cloning v4l2loopback repository..."
        git clone https://github.com/v4l2loopback/v4l2loopback.git
    else
        echo "v4l2loopback directory already exists, using it."
        cd v4l2loopback
        git pull
        cd ..
    fi
    
    cd v4l2loopback
    echo "Building v4l2loopback..."
    if make; then
        echo "Installing v4l2loopback..."
        if sudo make install; then
            echo -e "${GREEN}v4l2loopback built and installed successfully.${RESET}"
            # Try to load the module
            if sudo depmod -a && sudo modprobe v4l2loopback; then
                echo -e "${GREEN}v4l2loopback module loaded successfully.${RESET}"
            else
                echo -e "${RED}Failed to load v4l2loopback module. Continuing anyway...${RESET}"
            fi
        else
            echo -e "${RED}Failed to install v4l2loopback.${RESET}"
            cd ..
            echo "We'll continue setup, but the virtual camera might not work properly."
        fi
    else
        echo -e "${RED}Failed to build v4l2loopback.${RESET}"
        cd ..
        echo "We'll continue setup, but the virtual camera might not work properly."
    fi
    cd ..
fi

# Step 3: Configure v4l2loopback to load at boot
echo -e "\n${BOLD}Step 3: Configuring system boot settings...${RESET}"

# Create the module load file
echo "Creating module load configuration..."
echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf > /dev/null

# Create the module options file
echo "Setting module parameters..."
echo 'options v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1 max_buffers=2' | sudo tee /etc/modprobe.d/v4l2loopback.conf > /dev/null

# Update initramfs
echo "Updating initramfs..."
sudo update-initramfs -u

# Load the module now
echo "Loading v4l2loopback module..."
sudo modprobe v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1 max_buffers=2 || true

# Verify if loaded
if lsmod | grep -q v4l2loopback; then
    echo -e "${GREEN}v4l2loopback module loaded successfully.${RESET}"
else
    echo -e "${YELLOW}Could not load v4l2loopback module. It may load properly after a reboot.${RESET}"
    echo "We'll continue with the setup anyway."
fi

# Step 4: Check camera devices
echo -e "\n${BOLD}Step 4: Checking camera devices...${RESET}"
echo "Available video devices:"
v4l2-ctl --list-devices || echo "Could not list devices. Continuing anyway."
echo ""

# Step 5: Create shortcuts
echo -e "\n${BOLD}Step 5: Creating shortcuts...${RESET}"

# Create helper scripts directory
echo "Creating helper scripts directory..."
mkdir -p "${CURRENT_DIR}/helpers"

# Create the persistent camera toggle script
echo "Creating persistent camera toggle script..."
cat > "${CURRENT_DIR}/helpers/persistent_camera.sh" << EOL
#!/bin/bash

# Ensure script runs in the correct directory
cd "\$(dirname "\$(dirname "\$0")")" || exit 1

# Check current status
CURRENT_STATUS=\$(./camera_proxy.sh status)

# Detect current mode
if echo "\$CURRENT_STATUS" | grep -q "Camera proxy: Running"; then
    CURRENT_MODE=\$(echo "\$CURRENT_STATUS" | grep "Mode:" | awk '{print \$NF}' | tr -d ')')
    echo "Current mode: \$CURRENT_MODE"
    
    # Toggle mode
    if [ "\$CURRENT_MODE" = "normal" ]; then
        echo "Switching to lag mode..."
        ./camera_proxy.sh stop
        nohup ./camera_proxy.sh lag >/dev/null 2>&1 &
    else
        echo "Switching to normal mode..."
        ./camera_proxy.sh stop
        nohup ./camera_proxy.sh normal >/dev/null 2>&1 &
    fi
else
    # Not running, start in normal mode
    echo "Starting camera in normal mode..."
    nohup ./camera_proxy.sh start >/dev/null 2>&1 &
fi

# Report status after change
sleep 1
./camera_proxy.sh status

echo "Camera will continue running after terminal closes."
echo "Status saved to: \$(pwd)/nohup.out"
EOL

# Make the script executable
chmod +x "${CURRENT_DIR}/helpers/persistent_camera.sh"

# Create Camera Lag Toggle (Persistent) desktop file
echo "Creating Camera Lag Toggle (Persistent) shortcut..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/Camera_Persistent.desktop << EOL
[Desktop Entry]
Name=Camera Lag Toggle
Comment=Toggle between normal and lag modes (stays running after closing)
Exec=gnome-terminal -- ${CURRENT_DIR}/helpers/persistent_camera.sh
Icon=camera-photo
Terminal=false
Type=Application
Categories=Utility;
Keywords=camera;webcam;virtual;lag;toggle;persistent;
StartupNotify=true
EOL

chmod +x ~/.local/share/applications/Camera_Persistent.desktop

# Step 6: Add user to video group for camera access
echo -e "\n${BOLD}Step 6: Setting up permissions...${RESET}"
echo "Adding current user to the video group for camera access..."
if groups | grep -q video; then
    echo -e "${GREEN}User already belongs to the video group.${RESET}"
else
    sudo usermod -a -G video $USER
    echo -e "${YELLOW}Added user to the video group. This change requires logging out and back in to take effect.${RESET}"
    echo "You may need to restart your system or log out and back in for the changes to take effect."
fi

# Step 7: Update script configuration
echo -e "\n${BOLD}Step 7: Updating script configuration...${RESET}"

# Get real camera device
REAL_CAMERA=$(v4l2-ctl --list-devices 2>/dev/null | grep -A2 "Integrated Camera\|Webcam" | grep "/dev/video" | head -n1 | xargs) || true
if [ -z "$REAL_CAMERA" ]; then
    # Try a simpler detection method
    for dev in /dev/video*; do
        if v4l2-ctl -d "$dev" --all 2>/dev/null | grep -q "Camera"; then
            REAL_CAMERA="$dev"
            break
        fi
    done
    
    # Still not found, fallback to default
    if [ -z "$REAL_CAMERA" ]; then
        REAL_CAMERA="/dev/video0"  # Fallback to default
        echo -e "${YELLOW}Could not automatically detect real camera. Using default: ${REAL_CAMERA}${RESET}"
    else
        echo -e "${GREEN}Detected real camera at: ${REAL_CAMERA}${RESET}"
    fi
else
    echo -e "${GREEN}Detected real camera at: ${REAL_CAMERA}${RESET}"
fi

# Virtual camera should be at video3 based on our module parameters
VIRTUAL_CAMERA="/dev/video3"

# Update the script configuration
echo "Updating camera paths in the script..."
sed -i "s|REAL_CAMERA=.*|REAL_CAMERA=\"${REAL_CAMERA}\"|" "${CURRENT_DIR}/camera_proxy.sh"
sed -i "s|VIRTUAL_CAMERA=.*|VIRTUAL_CAMERA=\"${VIRTUAL_CAMERA}\"|" "${CURRENT_DIR}/camera_proxy.sh"

# Make the script executable
chmod +x "${CURRENT_DIR}/camera_proxy.sh"

# Done!
echo -e "\n${BOLD}${GREEN}Setup completed successfully!${RESET}"
echo ""
echo -e "The virtual camera has been configured as ${BOLD}${VIRTUAL_CAMERA}${RESET}"
echo -e "The real camera is configured as ${BOLD}${REAL_CAMERA}${RESET}"
echo ""
echo -e "${YELLOW}Important:${RESET}"
echo "1. To use the virtual camera, click the 'Camera Lag Toggle' shortcut in your applications menu"
echo "2. The camera will continue running even if you close the terminal window"
echo "3. When using video conferencing apps, select 'Virtual Camera' from the camera list"
echo "4. You may need to log out and log back in for the video group permissions to take effect"
echo "5. If your camera doesn't work in web browsers, try restarting the virtual camera service"
echo ""

# Show additional warning if Secure Boot is enabled
if [ "$SECURE_BOOT_ENABLED" = true ]; then
    if [ "$secure_boot_option" != "1" ]; then
        echo -e "${RED}IMPORTANT: Secure Boot is enabled on your system!${RESET}"
        echo -e "${YELLOW}The v4l2loopback module will NOT load until you address this issue.${RESET}"
        echo "You have two options:"
        echo "1. Disable Secure Boot in your BIOS/UEFI settings"
        echo "2. Sign the module by running: ./sign_module.sh"
        echo ""
    else
        echo -e "${YELLOW}Remember: You need to complete the MOK enrollment process after reboot for the signed module to load.${RESET}"
        echo "1. At the blue MOK management screen, select 'Enroll MOK'"
        echo "2. Select 'Continue'"
        echo "3. Enter the password you created during the signing process"
        echo "4. Select 'Yes' to enroll the key"
        echo ""
    fi
fi

echo -e "${YELLOW}For the changes to fully take effect, a reboot is recommended.${RESET}"
echo "Would you like to reboot now? (y/n): "
read -r answer

if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Please reboot when convenient to ensure all changes take effect."
fi

exit 0 