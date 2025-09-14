# Multi-Monitor Fix for Ubuntu 22.04+ 

## Quick Setup (Automated)

This repository contains scripts to automatically fix multi-monitor detection issues that occur after screen lock/unlock cycles on Ubuntu systems with NVIDIA graphics. For example after lock/unlock screen these issues can happen:
- Can not detect monitor
- Monitor's layout is changed automatically

### 🚀 One-Line Installation

```bash
# Download and run the setup script
wget https://raw.githubusercontent.com/your-repo/monitor-fix/main/setup-monitor-fix.sh && chmod +x setup-monitor-fix.sh && ./setup-monitor-fix.sh
```

Or if you have the files locally:

```bash
# Make executable and run
chmod +x setup-monitor-fix.sh && ./setup-monitor-fix.sh
```

### 📋 What the Script Does

1. **System Check**: Verifies NVIDIA GPU, driver status, and session type
2. **Monitor Detection**: Automatically detects your current monitor configuration
3. **Script Generation**: Creates a custom monitor fix script for your specific setup
4. **Service Installation**: Sets up a systemd user service to run automatically
5. **Configuration Sync**: Synchronizes monitor settings between user and GDM3
6. **Testing Tools**: Creates test scripts for troubleshooting

### 🎯 Features

- ✅ **Automatic Detection**: Analyzes your current monitor setup
- ✅ **Zero Configuration**: No manual editing of monitor positions required
- ✅ **Service Management**: Full systemd integration with auto-restart
- ✅ **Logging**: Comprehensive logging for troubleshooting
- ✅ **Testing Tools**: Built-in test scripts and diagnostics
- ✅ **Safety Checks**: Validates system requirements before installation

### 🖥️ System Requirements

- Ubuntu 22.04+ (or similar Linux distribution)
- NVIDIA Graphics Card with proprietary drivers
- X11 session (recommended over Wayland)
- Multi-monitor setup

### 📁 Files Created

After running the setup script, the following files will be created:

```
~/.local/bin/fix-monitors.sh           # Main monitor fix script
~/.config/systemd/user/monitor-fix.service  # Systemd service
~/.local/bin/test-monitor-fix.sh       # Test and diagnostic script
~/monitor-fix-setup.log                # Installation log
~/.local/share/monitor-fix.log         # Runtime logs
```

### 🔧 Manual Installation Steps

If you prefer to understand what's happening or need to customize:

1. **Download the setup script**:
   ```bash
   wget setup-monitor-fix.sh
   chmod +x setup-monitor-fix.sh
   ```

2. **Run the setup**:
   ```bash
   ./setup-monitor-fix.sh
   ```

3. **Follow the prompts** and review the detected configuration

4. **Test the setup**:
   ```bash
   ~/.local/bin/test-monitor-fix.sh
   ```

### 🧪 Testing the Fix

1. **Lock your screen**: `Super+L` or via the system menu
2. **Unlock your screen** and verify all monitors are detected
3. **Check the logs**:
   ```bash
   # View recent monitor fix activity
   tail -f ~/.local/share/monitor-fix.log
   
   # Check service status
   systemctl --user status monitor-fix.service
   
   # View service logs
   journalctl --user -u monitor-fix.service -f
   ```

### 🛠️ Troubleshooting

#### Service Not Running
```bash
# Check service status
systemctl --user status monitor-fix.service

# Restart the service
systemctl --user restart monitor-fix.service

# Check for errors
journalctl --user -u monitor-fix.service --since "10 minutes ago"
```

#### Monitors Not Restoring
```bash
# Test the xrandr command manually
~/.local/bin/test-monitor-fix.sh

# Check if X11 session is active
echo $XDG_SESSION_TYPE

# Verify monitor names haven't changed
xrandr --query | grep connected
```

#### After System Updates
```bash
# Re-run the setup script to update configuration
./setup-monitor-fix.sh
```

#### Monitor Layout Changes
If you've rearranged your physical monitors or changed display settings:

**🚀 Option 1: Automatic (Recommended)**
```bash
# Re-run the setup script to auto-detect and update configuration
./setup-monitor-fix.sh
```

**🔧 Option 2: Manual Update**
```bash
# Check current monitor configuration
xrandr --query | grep connected

# Manually edit the fix script
nano ~/.local/bin/fix-monitors.sh

# Update the xrandr command, then restart service
systemctl --user restart monitor-fix.service
```

**🧪 Option 3: Test First**
```bash
# Test current xrandr command to see if it still works
~/.local/bin/test-monitor-fix.sh
```

**⚡ Option 4: Quick Update (Experimental)**
```bash
# Use the experimental quick update script
./quick-update-monitors.sh
```
This attempts to auto-detect and apply layout changes quickly. Use with caution for complex layouts.

#### Overlapping Monitor Coordinates
If monitors have conflicting positions (common after layout changes):
```bash
# Check for overlapping coordinates
xrandr --query | grep -E "connected.*[0-9]+x[0-9]+\+[0-9]+\+[0-9]+"

# Fix by re-running setup or manually editing the script
vim ~/.local/bin/fix-monitors.sh
systemctl --user restart monitor-fix.service
```

### 🔄 Service Management

```bash
# Start service
systemctl --user start monitor-fix.service

# Stop service
systemctl --user stop monitor-fix.service

# Restart service
systemctl --user restart monitor-fix.service

# Enable service (auto-start)
systemctl --user enable monitor-fix.service

# Disable service
systemctl --user disable monitor-fix.service

# View logs
journalctl --user -u monitor-fix.service -f
```

### 📊 Monitoring and Logs

The system creates several log files for monitoring:

- **Setup Log**: `~/monitor-fix-setup.log` - Installation and configuration details
- **Runtime Log**: `~/.local/share/monitor-fix.log` - Monitor fix events and errors
- **Service Log**: Via `journalctl --user -u monitor-fix.service` - Systemd service logs

### 🔍 Advanced Configuration

#### Diagnosing Monitor Configuration Issues
```bash
# Check current monitor layout for conflicts
xrandr --query | grep -E "(Screen 0|connected)"

# Verify monitor fix script configuration
cat ~/.local/bin/fix-monitors.sh | grep -A5 -B5 xrandr

# Compare with actual current layout
echo "=== Current Layout ===" && xrandr --query | grep connected
echo "=== Script Configuration ===" && grep -A3 "Execute the xrandr command" ~/.local/bin/fix-monitors.sh
```

#### Custom Monitor Layout
If you need to modify the monitor layout after installation:

1. Edit the script: `vim ~/.local/bin/fix-monitors.sh`
2. Update the xrandr command in the script
3. Restart the service: `systemctl --user restart monitor-fix.service`

#### Different Display Arrangement
To change your display arrangement:

1. Configure displays in Settings → Displays
2. Re-run the setup script: `./setup-monitor-fix.sh`
3. Choose to update the existing configuration

### 🆘 Common Issues

**Issue**: Script doesn't detect monitors correctly
**Solution**: Ensure you're in an X11 session and monitors are properly connected

**Issue**: Service fails to start
**Solution**: Check that dbus-monitor is available and X11 session is active

**Issue**: Monitors restore but in wrong positions
**Solution**: Re-run setup script after configuring displays in System Settings

**Issue**: Script works manually but not automatically
**Solution**: Check service logs for D-Bus permission issues

**Issue**: Monitor fix service running but monitors still not restoring correctly
**Solution**: Check if monitor layout has changed since initial setup. Monitor positions may have shifted causing overlapping coordinates. Use `xrandr --query | grep connected` to verify current layout matches the script configuration.

**Issue**: Service running but no log entries or activity detected
**Solution**: The monitor fix script may have syntax errors. Common issues:
- Missing `done` statement in while loop
- Incorrect D-Bus parsing (looking for multi-line output on single line)
Check script syntax: `bash -n ~/.local/bin/fix-monitors.sh`

**Issue**: D-Bus events not being detected by the service
**Solution**: The script may be using incorrect pattern matching for D-Bus output. D-Bus signals put `member=ActiveChanged` and `boolean false` on separate lines. The script needs to use state-based parsing, not single-line pattern matching.

**Issue**: Overlapping monitor coordinates (e.g., multiple monitors at position 0,0)
**Solution**: This is a common cause of display conflicts. Re-run the setup script or manually edit `~/.local/bin/fix-monitors.sh` to fix monitor positioning. Ensure each monitor has unique, non-overlapping coordinates.

### 📚 Understanding the Solution

This fix addresses a common issue where NVIDIA drivers fail to properly restore multi-monitor configurations after screen lock/unlock cycles. The solution:

1. **Monitors D-Bus Events**: Listens for screen unlock signals
2. **Restores Configuration**: Applies the correct xrandr command after unlock
3. **Handles Timing**: Waits for desktop stabilization before applying changes
4. **Provides Logging**: Tracks all events for troubleshooting

### 🤝 Contributing

If you encounter issues or have improvements:

1. Check existing logs and test scripts
2. Run the diagnostic tools provided
3. Submit issues with log files and system information

### 📄 License

This script is provided as-is for solving multi-monitor issues on Ubuntu systems. Use at your own discretion.

---

**Quick Commands Reference:**
```bash
# Install
./setup-monitor-fix.sh

# Test
~/.local/bin/test-monitor-fix.sh

# Check status
systemctl --user status monitor-fix.service

# View logs
tail -f ~/.local/share/monitor-fix.log
```

# Tested laptops

- Lenovo Legion 5 (RTX 4070 Laptop GPU)

## Real-World Issue Resolution

### Case Study: Service Running But Not Working
**Detected Issue**: Monitor fix service was running but monitors weren't restoring correctly after unlock, with overlapping coordinates persisting.

**Root Cause**: Two critical script errors were preventing automatic functionality:
1. **Missing `done` statement**: The monitor fix script was missing the closing `done` for the while loop, causing script malfunction
2. **Incorrect D-Bus parsing**: Script was looking for both `member=ActiveChanged` and `boolean false` on the same line, but D-Bus output puts them on separate lines

**Resolution Steps**:
1. Identified overlapping monitors using `xrandr --query | grep connected`
2. Discovered script syntax error - missing `done` statement in while loop
3. Found D-Bus parsing issue - single-line pattern matching failed for multi-line D-Bus output
4. Fixed script with proper while loop closure and state machine for D-Bus parsing
5. Updated monitor fix script with correct xrandr command
6. Restarted service to apply changes

**Technical Details**:
- **Before**: `dbus-monitor | while read line; do ... fi` (missing `done`)
- **After**: Added proper `done` statement and improved D-Bus parsing with state tracking
- **D-Bus Fix**: Used flag-based approach to handle `ActiveChanged` and `boolean false` on separate lines

**Key Lesson**: The service may appear to be running correctly but fail silently due to script syntax errors or incorrect D-Bus event parsing. Always verify the actual script logic, not just service status.

---

## Available Scripts Summary

### 📦 `setup-monitor-fix.sh`
**Main installation and update script**
- Detects current monitor layout automatically  
- Generates optimized xrandr commands
- Creates and configures systemd service
- Updates existing installations intelligently
- **Use for**: Fresh installs, major layout changes, reliable updates

### ⚡ `quick-update-monitors.sh`  
**Experimental quick update tool**
- Rapid detection and update of monitor layouts
- Minimal user interaction required
- Creates backup before changes
- **Use for**: Minor position adjustments, quick fixes
- **Caution**: May need manual adjustment for complex layouts

### 🧪 `test-monitor-fix.sh`
**Diagnostic and testing tool** (created automatically)
- Shows current service status
- Displays recent logs  
- Tests monitor configuration
- **Use for**: Troubleshooting, verifying setup

### 🔧 Manual Files
- `~/.local/bin/fix-monitors.sh` - Main monitor restoration script
- `~/.config/systemd/user/monitor-fix.service` - Service configuration  
- `~/.local/share/monitor-fix.log` - Activity logs

---

### Case Study: User Rearranged Physical Monitors
**Situation**: User physically rearranged monitors and asked what to do next.

**Current Layout After Rearrangement**:
- DP-1: 1920×1080 at (0,0) - Left monitor
- HDMI-0: 1920×1080 at (1920,0) - Right monitor  
- DP-4: 2560×1600 at (605,1080) - Primary (bottom center)

**Resolution**: Updated the fix script configuration to match new layout and restarted service.

**Recommendation**: When rearranging monitors, always run `./setup-monitor-fix.sh` to automatically detect and update the configuration.
