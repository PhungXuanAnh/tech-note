# 🎬 Image to Video Merger - Complete Guide

**GPU-accelerated image to video converter for creating high-quality 4K/8K videos for YouTube**

---

## 📋 Quick Start

### Basic Usage (GPU Version - Recommended)

Merge images AND videos into a single 8K timeline video for YouTube. Processes files in alphanumeric order (natural timeline order)

```bash
cd /path/to/your/images
~/repo/tech-note/linux/merge_images_video_into_video/merge_timeline_to_video_gpu.sh --resolution 8k --duration 1
```

Merge video only:

```bash
cd /path/to/your/images
./merge_images_to_video_gpu.sh -r 8k -d 3

# Output: merged_8k_20231105_HHMMSS.mp4
```

### CPU Version (Fallback)
```bash
./merge_images_to_video_cpu.sh -r 8k
```

## 🚀 Available Versions

| Version | File | Speed | Best For |
|---------|------|-------|----------|
| **GPU v3.1** | `merge_images_to_video_gpu.sh` | **7-8x faster** | Production (recommended) |
| **CPU v3.0** | `merge_images_to_video_cpu.sh` | Baseline | Backup/compatibility |

**Performance (41 images):**
- GPU: 6-8 seconds (1080p), 15-20s (4K), 30-45s (8K)
- CPU: 50 seconds (1080p), 2-3 min (4K), 5-8 min (8K)

---

## 📦 Installation

### Required Packages
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install ffmpeg imagemagick

# For GPU version (optional but recommended):
sudo apt-get install nvidia-driver-580 libnvidia-encode-580

# Verify installation
ffmpeg -version
nvidia-smi  # GPU only
```

### Supported Image Formats
- **JPG/JPEG** - Direct support
- **PNG** - Direct support
- **HEIC** - Auto-converted (requires ImageMagick)

---

## 💻 Usage Examples

### Create 4K Video (Default)
```bash
cd ~/Pictures/Vacation
../merge_image_to_video/merge_images_to_video_gpu.sh

# Output: merged_4k_YYYYMMDD_HHMMSS.mp4
```

### Create 8K Video for YouTube
```bash
../merge_image_to_video/merge_images_to_video_gpu.sh -r 8k -d 7

# Output: merged_8k_YYYYMMDD_HHMMSS.mp4
# Uses HEVC encoding for 8K
```

### High Frame Rate 1080p
```bash
../merge_image_to_video/merge_images_to_video_gpu.sh -r 1080p -f 60 -d 3

# Output: merged_1080p_YYYYMMDD_HHMMSS.mp4
# 60fps for smooth playback
```

### Custom Output Filename
```bash
../merge_image_to_video/merge_images_to_video_gpu.sh -o my_video.mp4
```

### All Options
```bash
Usage: merge_images_to_video_gpu.sh [OPTIONS]

Options:
  -r, --resolution   1080p|4k|8k (default: 4k)
  -f, --fps          Frame rate (default: 30)
  -d, --duration     Seconds per image (default: 5)
  -o, --output       Custom filename (default: auto-generated)
  -h, --help         Show help

Examples:
  ./merge_images_to_video_gpu.sh                    # 4K default
  ./merge_images_to_video_gpu.sh -r 8k -d 7         # 8K, 7s/image
  ./merge_images_to_video_gpu.sh -r 1080p -f 60     # 1080p 60fps
```

---

## 🎯 Output Specifications

### Filename Format
**Auto-generated:** `merged_<resolution>_<YYYYMMDD_HHMMSS>.mp4`

Examples:
- `merged_4k_20231105_143520.mp4`
- `merged_1080p_20231105_150230.mp4`
- `merged_8k_20231105_153045.mp4`

### Video Specifications (YouTube-Ready)

| Spec | GPU Version | CPU Version | YouTube Requirement |
|------|-------------|-------------|---------------------|
| **Codec** | H.264/HEVC NVENC | H.264/H.265 | ✅ Compatible |
| **Audio** | AAC 320kbps stereo | AAC 320kbps stereo | ✅ Perfect |
| **1080p** | 15 Mbps, CQ 20 | 15 Mbps, CRF 20 | ✅ Excellent |
| **4K** | 45 Mbps, CQ 20 | 45 Mbps, CRF 20 | ✅ Excellent |
| **8K** | 100 Mbps, CQ 18 | 100 Mbps, CRF 18 | ✅ Excellent |
| **FPS** | 30 (configurable) | 30 (configurable) | ✅ Perfect |
| **Format** | MP4 (H.264/HEVC) | MP4 (H.264/H.265) | ✅ Perfect |

---

## 🔧 Troubleshooting

### GPU Version Falls Back to CPU

**Check output for reason:**
```
⚠ NVIDIA encode libraries not installed  → Install nvidia drivers
⚠ nvidia-smi not found                    → Install nvidia-utils
⚠ No GPU detected                         → Check GPU hardware
✗ GPU detected but NVENC failed           → Check library path
```

**Solution for NVENC issues:** FFmpeg shows NVENC encoders but can't use them

```
Error: [h264_nvenc @ 0x...] No capable devices found
```

Root Cause: FFmpeg can't find NVIDIA libraries at runtime

```bash
# Verify NVIDIA libraries
ls /usr/lib/x86_64-linux-gnu/libnvidia-encode*

# Check GPU
nvidia-smi

# Test NVENC
ffmpeg -encoders | grep nvenc
```

**Solution:** GPU script exports library path (line 11):
```bash
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
```

This lets FFmpeg find `libnvidia-encode.so` properly! ✅

### Video Won't Upload to YouTube
```bash
# Verify video specs
ffprobe merged_4k_*.mp4

# Should show:
# - Video codec: h264 or hevc
# - Audio codec: aac
# - Sample rate: 48000 Hz
```

## ⚡ Performance Tips

### For Large Image Collections (100+ images)
- Use **GPU version** - 7-8x faster
- Start with **1080p** for quick preview
- Increase to **4K/8K** for final output

### For Best Quality
- Use **8K** resolution with `-d 7` (7 seconds per image)
- GPU automatically uses HEVC for 8K (better compression)
- CPU uses H.265 for 8K

### For Faster Processing
- Use **1080p** resolution
- Reduce duration: `-d 2` or `-d 3`
- Close other GPU-intensive apps

---

## 🎬 YouTube Upload Guide

Recommended Settings by Use Case

**Vlogs/Slideshows:**
```bash
./merge_images_to_video_gpu.sh -r 1080p -d 5
# Fast processing, excellent quality
```

**Professional/Travel Videos:**
```bash
./merge_images_to_video_gpu.sh -r 4k -d 7
# High quality, reasonable file size
```

**Maximum Quality/Archival:**
```bash
./merge_images_to_video_gpu.sh -r 8k -d 10
# Ultimate quality, large files
```

**Your videos are 100% YouTube-compatible!**

## 📊 Technical Details

### GPU Version (NVENC Settings)

| Resolution | Encoder | Preset | Quality | Bitrate | Profile |
|------------|---------|--------|---------|---------|---------|
| 1080p | H.264 NVENC | p7 | CQ 20 | 15 Mbps | High |
| 4K | H.264 NVENC | p7 | CQ 20 | 45 Mbps | High |
| 8K | HEVC NVENC | p7 | CQ 18 | 100 Mbps | Main10 |

**GPU Support:**
- RTX 40/30 series: p7 preset (best quality)
- RTX 20 series: p6 preset
- GTX 16 series: p6 preset
- Older GPUs: p4 preset

### CPU Version Settings

| Resolution | Encoder | Preset | Quality | Bitrate | Profile |
|------------|---------|--------|---------|---------|---------|
| 1080p | libx264 | slow | CRF 20 | 15 Mbps | High |
| 4K | libx264 | slow | CRF 20 | 45 Mbps | High |
| 8K | libx265 | slow | CRF 18 | 100 Mbps | High |
