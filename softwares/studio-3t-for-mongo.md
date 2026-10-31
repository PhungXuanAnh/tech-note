> Download links point to the private [softwares repository](https://github.com/alexander1307xa/softwares). Sign in to GitHub with an account that has access; otherwise the links may return 404.

# Studio 3T for MongoDB Installation Guide

This guide apply for this version only: `studio-3t-2025.3.0`

## Download Files

Download the required files from the [GitHub Release](https://github.com/alexander1307xa/softwares/releases/tag/studio-3t-2025.3.0).

### Installation Files
- **Linux**: [studio-3t-linux-x64.tar.gz](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/studio-3t-linux-x64.tar.gz)
- **Windows**: [studio-3t-windows-x64.zip](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/studio-3t-windows-x64.zip)
- **macOS (Apple Silicon)**: [Studio-3T-mac-arm.dmg](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/Studio-3T-mac-arm.dmg)
- **macOS (Intel)**: [Studio-3T-mac-intel.dmg](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/Studio-3T-mac-intel.dmg)

### Trial Reset Tools
- **Linux (New Version)**: [Studio3T_ResetTrial_Linux___new_version](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/Studio3T_ResetTrial_Linux___new_version)
- **Linux (Old Version)**: [Studio3T_ResetTrial_Linux___old_version.zip](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/Studio3T_ResetTrial_Linux___old_version.zip)
- **Windows**: [Studio3T-RESET-TRIAL-windows.rar](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/Studio3T-RESET-TRIAL-windows.rar)
- **macOS**: [Studio3T_ResetTrial_macOS.zip](https://github.com/alexander1307xa/softwares/releases/download/studio-3t-2025.3.0/Studio3T_ResetTrial_macOS.zip)

## Installation Instructions

### Linux

1. Extract the archive:
```bash
tar -xzf studio-3t-linux-x64.tar.gz
cd studio-3t-linux-x64
```

2. Run the installer:
```bash
./studio-3t
```

### Windows

1. Extract `studio-3t-windows-x64.zip`
2. Run the installer executable
3. Follow the installation wizard

### macOS

1. Open the appropriate `.dmg` file for your Mac:
   - `Studio-3T-mac-arm.dmg` for Apple Silicon (M1/M2/M3)
   - `Studio-3T-mac-intel.dmg` for Intel processors
2. Drag Studio 3T to Applications folder
3. Launch Studio 3T from Applications

## Trial Reset Instructions

### Linux

1. Close Studio 3T if running
2. Make the reset script executable:
```bash
chmod +x Studio3T_ResetTrial_Linux___new_version
```

3. Run the reset tool:
```bash
./Studio3T_ResetTrial_Linux___new_version
```

4. Restart Studio 3T

### Windows

1. Close Studio 3T if running
2. Extract `Studio3T-RESET-TRIAL-windows.rar`
3. Run the reset tool as Administrator
4. Restart Studio 3T

### macOS

1. Close Studio 3T if running
2. Extract `Studio3T_ResetTrial_macOS.zip`
3. Run the reset script:
```bash
chmod +x Studio3T_ResetTrial_macOS.sh
./Studio3T_ResetTrial_macOS.sh
```

4. Restart Studio 3T

## Notes

- The trial reset tools allow you to extend the trial period
- Make sure Studio 3T is completely closed before running the reset tool
- For Linux, if the new version doesn't work, try the old version from `reset/Studio3T_ResetTrial_Linux___old_version.zip`
