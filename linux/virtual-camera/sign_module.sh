#!/bin/bash

# Script to sign the v4l2loopback kernel module
# This allows loading the module with Secure Boot enabled

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${BOLD}Module Signing for v4l2loopback${RESET}"
echo "This script will sign the v4l2loopback kernel module to work with Secure Boot."
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please do not run this script as root.${RESET}"
    echo "The script will use sudo when necessary."
    exit 1
fi

# Check if Secure Boot is enabled
if ! command -v mokutil &>/dev/null; then
    echo -e "${YELLOW}Installing mokutil...${RESET}"
    sudo apt install -y mokutil
fi

if ! mokutil --sb-state | grep -q "enabled"; then
    echo -e "${YELLOW}NOTE: Secure Boot does not appear to be enabled on your system.${RESET}"
    echo "You may not need to sign the module. Continue anyway? (y/n): "
    read -r answer
    if [[ ! "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Signing cancelled."
        exit 0
    fi
fi

# Install required packages
echo -e "\n${BOLD}Installing required tools...${RESET}"
sudo apt update
sudo apt install -y openssl kmod dkms

# Create directory for keys if it doesn't exist
echo -e "\n${BOLD}Creating a directory for signing keys...${RESET}"
KEYS_DIR="$HOME/module-signing-keys"
mkdir -p "$KEYS_DIR"
cd "$KEYS_DIR" || exit 1

# Generate signing keys if they don't exist
if [ ! -f "$KEYS_DIR/MOK.priv" ] || [ ! -f "$KEYS_DIR/MOK.der" ]; then
    echo -e "\n${BOLD}Generating new signing keys...${RESET}"
    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -days 36500 -subj "/CN=v4l2loopback-module-key/" -nodes
    chmod 600 MOK.priv
    echo -e "${GREEN}Keys generated successfully.${RESET}"
else
    echo -e "${YELLOW}Signing keys already exist. Using existing keys.${RESET}"
fi

# Import the key to the MOK list
echo -e "\n${BOLD}Preparing to import the signing key to the MOK list...${RESET}"
echo "You will be asked to create a one-time password."
echo "Remember this password as you will need it during the next boot."
echo -e "${YELLOW}Press Enter to continue...${RESET}"
read -r

# Import the key
sudo mokutil --import "$KEYS_DIR/MOK.der"

# Find the module location
echo -e "\n${BOLD}Locating the v4l2loopback module...${RESET}"

# Check if the module exists in the kernel module directory
MODULE_PATH=""
KERNEL_VERSION=$(uname -r)

# Check for the module in the current kernel's modules directory
if [ -f "/lib/modules/$KERNEL_VERSION/kernel/drivers/media/platform/v4l2loopback.ko" ]; then
    MODULE_PATH="/lib/modules/$KERNEL_VERSION/kernel/drivers/media/platform/v4l2loopback.ko"
    echo -e "${GREEN}Found v4l2loopback module at: $MODULE_PATH${RESET}"
elif [ -f "/lib/modules/$KERNEL_VERSION/extra/v4l2loopback.ko" ]; then
    MODULE_PATH="/lib/modules/$KERNEL_VERSION/extra/v4l2loopback.ko"
    echo -e "${GREEN}Found v4l2loopback module at: $MODULE_PATH${RESET}"
elif [ -f "/lib/modules/$KERNEL_VERSION/updates/dkms/v4l2loopback.ko" ]; then
    MODULE_PATH="/lib/modules/$KERNEL_VERSION/updates/dkms/v4l2loopback.ko"
    echo -e "${GREEN}Found v4l2loopback module at: $MODULE_PATH${RESET}"
else
    # Try to find the module with find
    MODULE_PATH=$(find /lib/modules/"$KERNEL_VERSION" -name "v4l2loopback.ko" | head -n 1)
    if [ -n "$MODULE_PATH" ]; then
        echo -e "${GREEN}Found v4l2loopback module at: $MODULE_PATH${RESET}"
    else
        echo -e "${RED}Could not find v4l2loopback module in the system.${RESET}"
        echo "Please make sure v4l2loopback is installed. Would you like to install it now? (y/n): "
        read -r install
        if [[ "$install" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Installing v4l2loopback-dkms..."
            sudo apt install -y v4l2loopback-dkms
            # Try to locate the module again
            MODULE_PATH=$(find /lib/modules/"$KERNEL_VERSION" -name "v4l2loopback.ko" | head -n 1)
            if [ -n "$MODULE_PATH" ]; then
                echo -e "${GREEN}Found v4l2loopback module at: $MODULE_PATH${RESET}"
            else
                echo -e "${RED}Still could not find v4l2loopback module. Please check your installation.${RESET}"
                exit 1
            fi
        else
            echo "Signing cancelled."
            exit 1
        fi
    fi
fi

# Sign the module
echo -e "\n${BOLD}Signing the module...${RESET}"
sudo /usr/src/linux-headers-"$KERNEL_VERSION"/scripts/sign-file sha256 "$KEYS_DIR/MOK.priv" "$KEYS_DIR/MOK.der" "$MODULE_PATH" || {
    echo -e "${RED}Failed to sign the module. Attempting alternative method...${RESET}"
    
    # Alternative 1: Using public sign-file
    if [ -f "/usr/lib/linux-kbuild-$(echo "$KERNEL_VERSION" | cut -d'-' -f1)/scripts/sign-file" ]; then
        echo "Trying with linux-kbuild sign-file..."
        sudo "/usr/lib/linux-kbuild-$(echo "$KERNEL_VERSION" | cut -d'-' -f1)/scripts/sign-file" sha256 "$KEYS_DIR/MOK.priv" "$KEYS_DIR/MOK.der" "$MODULE_PATH" || {
            echo -e "${RED}Both signing methods failed.${RESET}"
            exit 1
        }
    else
        echo -e "${RED}Alternative signing method not available.${RESET}"
        echo "Installing linux-kbuild-$(echo "$KERNEL_VERSION" | cut -d'-' -f1)..."
        sudo apt install -y "linux-kbuild-$(echo "$KERNEL_VERSION" | cut -d'-' -f1)"
        
        # Try again with linux-kbuild sign-file
        if [ -f "/usr/lib/linux-kbuild-$(echo "$KERNEL_VERSION" | cut -d'-' -f1)/scripts/sign-file" ]; then
            echo "Trying with linux-kbuild sign-file..."
            sudo "/usr/lib/linux-kbuild-$(echo "$KERNEL_VERSION" | cut -d'-' -f1)/scripts/sign-file" sha256 "$KEYS_DIR/MOK.priv" "$KEYS_DIR/MOK.der" "$MODULE_PATH" || {
                echo -e "${RED}Both signing methods failed.${RESET}"
                exit 1
            }
        else
            echo -e "${RED}Could not find sign-file utility. Please sign the module manually.${RESET}"
            exit 1
        fi
    fi
}

echo -e "${GREEN}Module signed successfully!${RESET}"

# Check if module is already loaded and unload it
if lsmod | grep -q v4l2loopback; then
    echo -e "\n${BOLD}Unloading existing v4l2loopback module...${RESET}"
    sudo modprobe -r v4l2loopback || {
        echo -e "${YELLOW}Warning: Could not unload module. It might be in use.${RESET}"
        echo "You may need to reboot to load the signed module."
    }
fi

# Try to load the signed module
echo -e "\n${BOLD}Attempting to load the signed module...${RESET}"
sudo modprobe v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1 || {
    echo -e "${YELLOW}Warning: Could not load the module immediately.${RESET}"
    echo "This is expected. You need to reboot and enroll the MOK key first."
}

# Verify
if lsmod | grep -q v4l2loopback; then
    echo -e "${GREEN}Module loaded successfully!${RESET}"
    echo "The v4l2loopback module is now signed and loaded."
else
    echo -e "${YELLOW}The module was signed, but needs to be loaded after MOK enrollment.${RESET}"
    echo -e "${BOLD}IMPORTANT: Next Steps${RESET}"
    echo "1. Reboot your computer"
    echo "2. During boot, you will see a blue MOK management screen"
    echo "3. Select 'Enroll MOK'"
    echo "4. Select 'Continue'"
    echo "5. Enter the password you created earlier"
    echo "6. Select 'Yes' to enroll the key"
    echo "7. Your system will continue booting"
    echo "8. After login, the v4l2loopback module should load automatically"
    echo ""
    echo "Would you like to reboot now? (y/n): "
    read -r reboot
    if [[ "$reboot" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Rebooting..."
        sudo reboot
    else
        echo "Please reboot when convenient to complete the MOK enrollment process."
    fi
fi

exit 0 