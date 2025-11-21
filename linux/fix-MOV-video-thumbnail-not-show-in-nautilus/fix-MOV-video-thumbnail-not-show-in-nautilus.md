# MOV Video Thumbnail Fix for Ubuntu/GNOME Nautilus

## 🎯 Purpose

This script automatically fixes the common issue where MOV video files (especially from iPhones) don't show thumbnails in Ubuntu's Nautilus file manager.

## ✨ Features

- ✅ Automatic system compatibility check
- ✅ Installs and configures `ffmpegthumbnailer`
- ✅ Disables conflicting `totem` video thumbnailer
- ✅ Configures GNOME/Nautilus settings
- ✅ Optional: Generates thumbnails for existing MOV files
- ✅ Interactive prompts with colored output
- ✅ Comprehensive testing and validation
- ✅ Safe error handling

## 📋 Requirements

- Ubuntu 20.04+ (or other Debian-based distributions)
- GNOME Desktop Environment with Nautilus file manager
- Internet connection (for package installation if needed)

## 🚀 Quick Start

### Option 1: Run the script directly

```bash
./fix-mov-thumbnails.sh
```

### Option 2: Run with bash explicitly

```bash
bash fix-mov-thumbnails.sh
```

The script will:
1. Check your system compatibility
2. Install `ffmpegthumbnailer` (if not already installed)
3. Configure video thumbnailers
4. Set up GNOME settings
5. Optionally clear thumbnail cache
6. Test the configuration
7. Restart Nautilus
8. Optionally generate thumbnails for existing MOV files

## 📝 What the Script Does

### 1. System Check
- Verifies you're running Ubuntu/Debian
- Checks for Nautilus installation
- Displays system information

### 2. Package Installation
- Installs `ffmpegthumbnailer` if not present
- Uses `sudo` for system package installation

### 3. Thumbnailer Configuration
- Creates `~/.local/share/thumbnailers/` directory
- Symlinks `ffmpegthumbnailer.thumbnailer` for priority
- Disables `totem.thumbnailer` to prevent conflicts
- Also configures `~/.config/nautilus/thumbnailers/` for compatibility

### 4. GNOME Settings
- Enables thumbnail generation (set to "always")
- Checks and reports thumbnail size limits
- Provides suggestions for optimization

### 5. Cache Management
- Optionally clears existing thumbnail cache
- Forces regeneration of all thumbnails
- Interactive confirmation before clearing

### 6. Testing
- Searches for MOV files in common locations
- Tests thumbnail generation
- Reports success/failure

### 7. Nautilus Restart
- Gracefully stops Nautilus
- Prepares for clean restart with new settings

### 8. Bulk Thumbnail Generation (Optional)
- Can process all MOV files in a directory
- Shows progress for large batches
- Skips already-generated thumbnails

## 🔧 Manual Usage Examples

### Test thumbnail generation on a specific file:
```bash
ffmpegthumbnailer -i /path/to/video.mov -o output.png -s 256 -f
```

### Increase thumbnail size limit to 200MB:
```bash
gsettings set org.gnome.nautilus.preferences thumbnail-limit $((200 * 1048576))
```

### Check current thumbnail settings:
```bash
gsettings get org.gnome.nautilus.preferences show-image-thumbnails
gsettings get org.gnome.nautilus.preferences thumbnail-limit
```

### Clear thumbnail cache manually:
```bash
rm -rf ~/.cache/thumbnails/*
```

### Restart Nautilus manually:
```bash
nautilus -q
nautilus &
```

## 🐛 Troubleshooting

### Thumbnails still don't appear?

1. **Refresh Nautilus view:**
   - Press `Ctrl+R` in Nautilus
   - Or close and reopen Nautilus completely

2. **Check view mode:**
   - Switch to grid view: `Ctrl+2`
   - Make sure you're not in list view

3. **Verify settings:**
   - Open Nautilus → Preferences (Ctrl+,)
   - Check that "Show image thumbnails" is enabled

4. **Wait for generation:**
   - First-time thumbnail generation can take 10-30 seconds
   - Check `~/.cache/thumbnails/normal/` for PNG files

5. **Check file size:**
   - Large MOV files might exceed the thumbnail size limit
   - Increase the limit using the command shown above

6. **Verify thumbnailer:**
   ```bash
   ls -la ~/.local/share/thumbnailers/
   # Should show ffmpegthumbnailer.thumbnailer symlink
   ```

7. **Test manually:**
   ```bash
   ffmpegthumbnailer -i your-video.mov -o test.png -s 256 -f
   # If this fails, there might be a codec issue
   ```

### Permission errors?

The script uses `sudo` only for system package installation. User configuration files are created with normal permissions.

### Script fails during installation?

Make sure you have:
- Active internet connection
- Sufficient disk space
- Ability to use `sudo` (for package installation)

## 📁 Files Modified/Created

The script creates or modifies these files in your home directory:

```
~/.local/share/thumbnailers/
├── ffmpegthumbnailer.thumbnailer  (symlink)
├── totem.thumbnailer             (override)
└── totem.thumbnailer.disabled    (backup)

~/.config/nautilus/thumbnailers/
└── ffmpegthumbnailer.thumbnailer  (symlink)

~/.cache/thumbnails/
├── normal/                        (generated thumbnails)
└── large/                         (high-res thumbnails)
```

## 🔄 Reverting Changes

To revert the changes made by this script:

```bash
# Remove thumbnailer configuration
rm -rf ~/.local/share/thumbnailers/
rm -rf ~/.config/nautilus/thumbnailers/

# Clear thumbnail cache
rm -rf ~/.cache/thumbnails/*

# Restart Nautilus
nautilus -q
```

The system will fall back to using the default thumbnailers.

## 🆘 Getting Help

### Check log output:
The script provides detailed colored output showing each step. Read the messages carefully.

### Common error messages:

- **"Nautilus file manager not found"**: Install GNOME Nautilus
- **"ffmpegthumbnailer test failed"**: Codec issue with your MOV files
- **"Permission denied"**: Run script from a writable directory

### Still having issues?

1. Run the script again (it's safe to run multiple times)
2. Reboot your computer
3. Check if your MOV files play in other video players
4. Verify MOV file permissions (`ls -l your-file.mov`)

## 📊 Technical Details

### Why MOV thumbnails don't work by default?

Ubuntu's default video thumbnailer (`totem-video-thumbnailer`) has known bugs with:
- MOV files from iPhones
- QuickTime-encoded videos
- Certain H.264/HEVC codecs

### How this script fixes it:

1. **ffmpegthumbnailer** is more reliable and supports more codecs
2. By creating thumbnailer configs in `~/.local/share/`, we override system defaults
3. Disabling totem prevents it from interfering
4. Proper MIME type configuration ensures MOV files are handled correctly

### MIME types handled:

- `video/quicktime` (MOV files)
- `video/mp4` (MP4 files, often used for iPhone videos)
- Plus many other video formats

## 🎓 Learning Resources

- [GNOME Thumbnailer Specification](https://wiki.gnome.org/DraftSpecs/ThumbnailerSpec)
- [ffmpegthumbnailer Documentation](https://github.com/dirkvdb/ffmpegthumbnailer)
- [Nautilus Preferences](https://help.gnome.org/users/nautilus/stable/)

## 📜 License

This script is provided as-is for free use and modification.

## 🙏 Credits

Based on solutions from:
- AskUbuntu community
- GNOME developers
- ffmpegthumbnailer project

---

**Happy thumbnail viewing! 🎬📁**
