- [1. Camera Control Script for Ubuntu](#1-camera-control-script-for-ubuntu)
  - [1.1. Features](#11-features)
  - [1.2. Prerequisites](#12-prerequisites)
  - [1.3. Quick Setup (Recommended)](#13-quick-setup-recommended)
    - [1.3.1. Important Note on Secure Boot](#131-important-note-on-secure-boot)
  - [1.4. Manual Installation](#14-manual-installation)
    - [1.4.1. Install Base Packages](#141-install-base-packages)
    - [1.4.2. Install v4l2loopback](#142-install-v4l2loopback)
      - [1.4.2.1. Option A: Build from source (Recommended)](#1421-option-a-build-from-source-recommended)
      - [1.4.2.2. Option B: Using DKMS package (May not work with all kernels)](#1422-option-b-using-dkms-package-may-not-work-with-all-kernels)
    - [1.4.3. Verify the Module is Loaded](#143-verify-the-module-is-loaded)
    - [1.4.4. Identifying Your Camera Devices](#144-identifying-your-camera-devices)
    - [1.4.5. Set Up the Script](#145-set-up-the-script)
    - [1.4.6. Signing the Module (if Secure Boot is enabled)](#146-signing-the-module-if-secure-boot-is-enabled)
  - [1.5. Setting Up Autostart (Manual Method)](#15-setting-up-autostart-manual-method)
    - [1.5.1. Configure Module Loading at Boot](#151-configure-module-loading-at-boot)
    - [1.5.2. Create Autostart Entry](#152-create-autostart-entry)
    - [1.5.3. Create Application Menu Entry](#153-create-application-menu-entry)
  - [1.6. Usage](#16-usage)
    - [1.6.1. Getting Help](#161-getting-help)
    - [1.6.2. Starting the Camera Proxy](#162-starting-the-camera-proxy)
    - [1.6.3. Freezing the Camera](#163-freezing-the-camera)
    - [1.6.4. Unfreezing the Camera](#164-unfreezing-the-camera)
    - [1.6.5. Checking Status](#165-checking-status)
    - [1.6.6. Stopping the Camera Proxy](#166-stopping-the-camera-proxy)
  - [1.7. Using with Applications](#17-using-with-applications)
  - [1.8. Troubleshooting](#18-troubleshooting)
    - [1.8.1. Camera Device Not Found](#181-camera-device-not-found)
    - [1.8.2. Module Loading Issues](#182-module-loading-issues)
    - [1.8.3. DKMS Build Errors](#183-dkms-build-errors)
    - [1.8.4. Multiple Camera Devices](#184-multiple-camera-devices)
    - [1.8.5. Busy Camera](#185-busy-camera)
    - [1.8.6. Virtual Camera Not Showing in Applications](#186-virtual-camera-not-showing-in-applications)
    - [1.8.7. Virtual Camera Not Created After Reboot](#187-virtual-camera-not-created-after-reboot)
    - [1.8.8. Camera Freeze Toggle Not in Applications Menu](#188-camera-freeze-toggle-not-in-applications-menu)
    - [1.8.9. MOK Enrollment Failed](#189-mok-enrollment-failed)


# 1. Camera Control Script for Ubuntu

This script allows you to control your webcam in Ubuntu, specifically to freeze and unfreeze your camera feed using a virtual camera proxy. Perfect for video conferences when you need to temporarily pause your video without disconnecting.

## 1.1. Features

- Create a virtual camera that can be used in any application (Google Meet, Zoom, etc.)
- Freeze the camera on the current frame
- Resume live streaming with one command
- Works even when the real camera is busy/in use by another application
- Automatically creates a nice placeholder when the camera can't be accessed

## 1.2. Prerequisites

The script requires several packages to function:

- **v4l2loopback**: For creating a virtual video device
- **ffmpeg**: For video processing
- **v4l-utils**: For video device control

## 1.3. Quick Setup (Recommended)

For a quick and easy setup, use the provided setup script:

```bash
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Install all required packages
2. Configure v4l2loopback to load at boot
3. Set up camera control in the applications menu
4. Configure autostart for the camera proxy
5. Configure the virtual camera as /dev/video3

After running the setup script, reboot your system to complete the installation.

### 1.3.1. Important Note on Secure Boot

If you have Secure Boot enabled in your BIOS/UEFI settings (common on newer computers), the v4l2loopback module will not load. You'll see an error like:

```
modprobe: ERROR: could not insert 'v4l2loopback': Key was rejected by service
```

You have two options to resolve this:

1. **Option A: Disable Secure Boot** (simplest approach)
   - Restart your computer
   - Enter your BIOS/UEFI settings (usually by pressing F2, F12, or Del during startup)
   - Find the Secure Boot option (usually under "Security" or "Boot" sections)
   - Disable it
   - Save changes and reboot

2. **Option B: Sign the module** (keep Secure Boot enabled)
   - Use the provided signing script:
   ```bash
   chmod +x sign_module.sh
   ./sign_module.sh
   ```
   - Follow the on-screen instructions to create a signing key and enroll it
   - Reboot when prompted to complete the MOK enrollment process
   - Select "Enroll MOK" at the blue UEFI screen during boot
   - Enter the password you created during the signing process
   - The module should now load with Secure Boot still enabled

The setup script will check for Secure Boot and warn you if it's enabled.

## 1.4. Manual Installation

If you prefer to set things up manually, follow these steps:

### 1.4.1. Install Base Packages

First, install ffmpeg and v4l-utils:

```bash
sudo apt update
sudo apt install ffmpeg v4l-utils -y
```

### 1.4.2. Install v4l2loopback

There are two ways to install v4l2loopback:

#### 1.4.2.1. Option A: Build from source (Recommended)

This method is more reliable, especially for newer kernels:

```bash
# Clone the repository
git clone https://github.com/v4l2loopback/v4l2loopback.git
cd v4l2loopback

# Build the module
make

# Install the module
sudo make install

# Load the module with a friendly name
sudo modprobe v4l2loopback card_label="Virtual Camera" exclusive_caps=1
```

#### 1.4.2.2. Option B: Using DKMS package (May not work with all kernels)

```bash
sudo apt install v4l2loopback-dkms -y
sudo modprobe v4l2loopback card_label="Virtual Camera" exclusive_caps=1
```

Note: If you encounter errors with the DKMS method, use Option A instead.

### 1.4.3. Verify the Module is Loaded

To verify it's loaded:

```bash
lsmod | grep v4l2loopback
```

You should see v4l2loopback in the output.

### 1.4.4. Identifying Your Camera Devices

Before proceeding, you need to identify your real camera and the virtual camera:

```bash
v4l2-ctl --list-devices
```

You'll see output similar to this:

```
Virtual Camera (platform:v4l2loopback-000):
        /dev/video3

Integrated Camera: Integrated C (usb-0000:00:14.0-11):
        /dev/video0
        /dev/video1
        /dev/media0
```

Here's how to identify which is which:

1. **Real camera**: 
   - Look for names like "Integrated Camera", "Webcam", "HD Camera", or manufacturer names
   - These typically have USB identifiers (e.g., "usb-0000:00:14.0-11")
   - Most laptops have `/dev/video0` as the main camera
   - In the example above, `/dev/video0` and `/dev/video1` are the real camera

2. **Virtual camera**: 
   - Has "Virtual Camera" or "Dummy" in the name
   - Shows "platform:v4l2loopback" in the identifier
   - In the example above, `/dev/video3` is the virtual camera

Update the `REAL_CAMERA` and `VIRTUAL_CAMERA` variables in the script if needed.

### 1.4.5. Set Up the Script

1. Save the script as `camera_proxy.sh`
2. Make the script executable:
   ```bash
   chmod +x camera_proxy.sh
   ```
3. Edit the script if your camera device paths differ from the defaults:
   ```bash
   # Open the script in a text editor
   nano camera_proxy.sh
   
   # Find and update these lines near the top if needed:
   REAL_CAMERA="/dev/video0"          # Real camera
   VIRTUAL_CAMERA="/dev/video3"       # v4l2loopback device
   ```

### 1.4.6. Signing the Module (if Secure Boot is enabled)

If you have Secure Boot enabled and prefer not to disable it, you'll need to sign the v4l2loopback module:

1. Create a directory for your signing keys:
   ```bash
   mkdir -p ~/module-signing-keys
   cd ~/module-signing-keys
   ```

2. Generate signing keys:
   ```bash
   openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -days 36500 -subj "/CN=v4l2loopback-module-key/" -nodes
   chmod 600 MOK.priv
   ```

3. Register the key with the system:
   ```bash
   sudo mokutil --import MOK.der
   ```
   You'll be asked to create a one-time password. Remember this for the next boot.

4. Find the module path and sign it:
   ```bash
   KERNEL_VERSION=$(uname -r)
   MODULE_PATH=$(find /lib/modules/"$KERNEL_VERSION" -name "v4l2loopback.ko" | head -n 1)
   sudo /usr/src/linux-headers-"$KERNEL_VERSION"/scripts/sign-file sha256 MOK.priv MOK.der "$MODULE_PATH"
   ```

5. Reboot your system:
   ```bash
   sudo reboot
   ```

6. During boot, you'll see a blue MOK management screen:
   - Select "Enroll MOK"
   - Select "Continue"
   - Enter the password you created
   - Select "Yes" to enroll the key
   - Your system will continue booting

7. After login, the module should load automatically or can be loaded with:
   ```bash
   sudo modprobe v4l2loopback card_label="Virtual Camera" exclusive_caps=1
   ```

Alternatively, use the provided `sign_module.sh` script which automates these steps.

## 1.5. Setting Up Autostart (Manual Method)

To make the camera control script start automatically at login:

### 1.5.1. Configure Module Loading at Boot

First, ensure the v4l2loopback module loads at boot with the correct parameters:

```bash
# Create module load configuration
echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf

# Create module parameters configuration
echo 'options v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf

# Update initramfs
sudo update-initramfs -u
```

### 1.5.2. Create Autostart Entry

Create an autostart desktop entry for automatic startup:

```bash
mkdir -p ~/.config/autostart

cat > ~/.config/autostart/Camera_Control.desktop << EOL
[Desktop Entry]
Name=Camera Control
Comment=Start Virtual Camera Proxy (video3)
Exec=bash -c "cd $(pwd) && ./camera_proxy.sh start"
Icon=camera-web
Terminal=false
Type=Application
Categories=Utility;
Keywords=camera;webcam;virtual;
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOL

chmod +x ~/.config/autostart/Camera_Control.desktop
```

### 1.5.3. Create Application Menu Entry

Create an entry in the applications menu for toggling the camera freeze:

```bash
mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/Camera_Freeze_Toggle.desktop << EOL
[Desktop Entry]
Name=Camera Freeze Toggle
Comment=Toggle between freezing and unfreezing the camera
Exec=bash -c "cd $(pwd) && ./camera_proxy.sh"
Icon=camera-photo
Terminal=true
Type=Application
Categories=Utility;
Keywords=camera;webcam;virtual;freeze;toggle;
StartupNotify=true
EOL

chmod +x ~/.local/share/applications/Camera_Freeze_Toggle.desktop
```

## 1.6. Usage

### 1.6.1. Getting Help

For a quick overview of all available commands and options:

```bash
./camera_proxy.sh -h
# or
./camera_proxy.sh --help
```

This displays a help message with usage instructions, device configuration, and examples.

### 1.6.2. Starting the Camera Proxy

```bash
./camera_proxy.sh start
```

This will create a virtual camera that you can select in applications like Google Meet, Zoom, etc.

### 1.6.3. Freezing the Camera

```bash
./camera_proxy.sh freeze
```

This captures the current frame and displays it on the virtual camera.

### 1.6.4. Unfreezing the Camera

```bash
./camera_proxy.sh
```

Running the script without arguments toggles between frozen and unfrozen states.

### 1.6.5. Checking Status

```bash
./camera_proxy.sh status
```

Shows the current status of the camera proxy and virtual device.

### 1.6.6. Stopping the Camera Proxy

```bash
./camera_proxy.sh stop
```

Stops all processes related to the camera proxy.

## 1.7. Using with Applications

1. The camera proxy starts automatically at login
2. Open your video conferencing app (Google Meet, Zoom, etc.)
3. In the camera settings, select "Virtual Camera" instead of your regular webcam
4. To freeze/unfreeze the camera, search for "Camera Freeze Toggle" in your applications menu or run the script directly

## 1.8. Troubleshooting

### 1.8.1. Camera Device Not Found

If the script can't find your camera, check available devices:

```bash
v4l2-ctl --list-devices
```

Then edit the script to update the `REAL_CAMERA` variable with your camera's path.

### 1.8.2. Module Loading Issues

If the v4l2loopback module fails to load:

1. Check if it's already loaded:
   ```bash
   lsmod | grep v4l2loopback
   ```

2. Try unloading and reloading:
   ```bash
   sudo modprobe -r v4l2loopback
   sudo modprobe v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1
   ```

3. If you're still having issues with the DKMS package, switch to building from source (Option A).

### 1.8.3. DKMS Build Errors

If you see errors like:
```
ERROR: Cannot create report: [Errno 17] File exists: '/var/crash/v4l2loopback-dkms.0.crash'
Error! Bad return status for module build on kernel: 6.8.0-57-generic (x86_64)
```

This indicates the DKMS build failed. Use the source code installation method (Option A) instead.

### 1.8.4. Multiple Camera Devices

If you have multiple cameras or video input devices:

1. List all devices: `v4l2-ctl --list-devices`
2. Identify your actual webcam (usually `/dev/video0`)
3. Update the script with the correct device paths

### 1.8.5. Busy Camera

If your camera is already in use by another application, the script will automatically create a blue placeholder image with the current date/time.

### 1.8.6. Virtual Camera Not Showing in Applications

Some applications might need to be restarted to detect the new virtual camera. If the virtual camera still doesn't appear, try:

```bash
sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1
```

### 1.8.7. Virtual Camera Not Created After Reboot

If your virtual camera isn't created after reboot:

1. Check if Secure Boot is enabled:
   ```bash
   mokutil --sb-state
   ```
   
   If it shows "SecureBoot enabled", you need to either disable Secure Boot in your BIOS/UEFI settings or sign the module using the instructions in section 1.3.1 or 1.4.6.

2. Check that the module load configuration exists:
   ```bash
   cat /etc/modules-load.d/v4l2loopback.conf
   cat /etc/modprobe.d/v4l2loopback.conf
   ```

3. Manually load the module to check for errors:
   ```bash
   sudo modprobe v4l2loopback video_nr=3 card_label="Virtual Camera" exclusive_caps=1
   ```
   
   If you see `modprobe: ERROR: could not insert 'v4l2loopback': Key was rejected by service`, this confirms the Secure Boot issue.

4. Rebuild the initramfs and reboot:
   ```bash
   sudo update-initramfs -u
   sudo reboot
   ```

### 1.8.8. Camera Freeze Toggle Not in Applications Menu

If the Camera Freeze Toggle shortcut doesn't appear in your applications menu:

1. Verify it exists in the correct location:
   ```bash
   ls -la ~/.local/share/applications/Camera_Freeze_Toggle.desktop
   ```

2. Make sure it's executable:
   ```bash
   chmod +x ~/.local/share/applications/Camera_Freeze_Toggle.desktop
   ```

3. Wait a few moments for the system to detect the new application, or try logging out and back in.

### 1.8.9. MOK Enrollment Failed

If you tried to sign the module but the MOK enrollment process failed:

1. Verify the signing key exists:
   ```bash
   ls -la ~/module-signing-keys/MOK.der
   ```

2. Re-import the key and try again:
   ```bash
   sudo mokutil --import ~/module-signing-keys/MOK.der
   sudo reboot
   ```

3. During the MOK enrollment screen, carefully follow all steps and ensure you enter the correct password.

4. If all else fails, consider the simpler option of disabling Secure Boot temporarily.
