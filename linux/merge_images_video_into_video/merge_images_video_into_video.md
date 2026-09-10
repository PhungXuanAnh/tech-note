# 🎬 Image to Video Merger - Complete Guide

**GPU-accelerated image to video converter for creating high-quality 4K/8K videos for YouTube**

---

## 📋 Quick Start

### Basic Usage (GPU Version - Recommended)

Merge images AND videos into a single timeline video for YouTube. Processes files in alphanumeric order (natural timeline order)

```bash
cd /path/to/your/images
~/repo/tech-note/linux/merge_images_video_into_video/merge_timeline_to_video_gpu.sh --dry-run   # check the plan first
~/repo/tech-note/linux/merge_images_video_into_video/merge_timeline_to_video_gpu.sh
```

No flags needed. The defaults are the recommended settings: `auto` canvas capped
at 4K, 4s per still, blurred backdrop instead of black bars, CQ 20, 4 clips in
parallel, NVENC preset p5.

> **Do NOT pass `--resolution 8k` by reflex.** See
> [Choosing a resolution](#-choosing-a-resolution-read-this-before-picking-8k) — v2 defaults to
> `--resolution auto`, which reads your source files and picks the canvas for you.

### timeline merger v2.0 - what changed and why

v1 hardcoded 8K + `-rc constqp -qp 1`. On a 175-second wedding timeline that produced a
**9.5 GB file at 436 Mbps with no audio at all**. Three separate problems:

| Problem in v1 | Effect | v2 |
|---|---|---|
| `-rc constqp -qp 1` | Near-lossless intermediate at ~436 Mbps. YouTube re-encodes and caps its own output around 50 Mbps, so ~90% of that file was thrown away on upload. | `-rc vbr -cq 20 -b:v 0 -maxrate <tier>` — constant *quality*, so simple stills cost little and complex motion gets the bits. Same 175s timeline lands around 20 Mbps at 4K / 45 Mbps at 8K. |
| `noise=c0s=2:c0f=t` added deliberately | Injected grain to "force the bitrate up so YouTube processes it as 8K". YouTube assigns its encoding tier by **resolution**, not by upload bitrate — so this only added the most expensive-to-compress signal there is, and YouTube then spent bits reproducing the grain instead of the photo. | Removed entirely. |
| Stills had no audio track; final `concat -c copy` | The first clip determined the output stream layout, so the muxer silently dropped every audio stream. **Output had zero audio.** | Every clip is muxed with an identical AAC 48 kHz stereo track (`anullsrc` silence for stills), and the concat re-encodes audio once to remove AAC frame-boundary DTS gaps. |

Other v2 fixes:

- **`--resolution auto`** picks the smallest ladder tier that covers your largest source, capped at 4K.
- **`--orientation auto`** — with vertical phone clips on a 16:9 canvas, ~2/3 of every frame is black bars that still consume bitrate. `auto` votes by runtime.
- **Per-file colour matrix.** v1 forced `iall=bt709` on everything. iPhone clips tagged Display-P3 / smpte170m were converted from the wrong source space — that was the yellow/red tint. v2 probes `color_space` per file and only converts when it actually differs.
- **Stills convert RGB→YUV with `out_color_matrix=bt709`.** Without it ffmpeg uses the BT.601 matrix while the file is tagged BT.709, which shifts colour on every photo.
- **10-bit (`main10` / `p010le`)** when NVENC supports it — removes banding in skies and skin before YouTube's re-encode compounds it. Probed at startup, falls back to 8-bit.
- **Lanczos scaling** instead of the default bilinear.
- **`--duration` default is now 4s, not 1s.** YouTube's encoder needs roughly a second after a cut to sharpen up, so 1-second stills are blurry for most of their screen time.
- **Previous outputs are skipped** so a re-run does not ingest its own result.
- `--dry-run` prints the canvas decision without encoding.

## ⚡ Why CPU is pegged and the GPU looks idle

Only the **encode** step runs on the GPU (NVENC). Decode and *every* filter -
`scale`, `pad`, `gblur`, `tonemap`, `colorspace`, `format` - run on the CPU, and
swscale is effectively single-threaded here. NVENC encodes 4K HEVC far faster
than one CPU thread can feed it, so the GPU waits. Caught live mid-run:

```
ffmpeg          CPU 110%   <- 1.1 cores out of 32
GPU util          5%
encoder util      0%       <- NVENC idle, waiting on the CPU
```

Three changes fixed it. Full 66-clip folder: **881s -> 110s (8x)**, with the
output unchanged (326.2s duration either way, 549 MB -> 553 MB).

**1. Stills were scaled once per output frame, not once.** `-loop 1` repeats the
image *before* the filter chain, so a 4s still at 30fps ran the whole
lanczos-scale-to-4K chain **120 times** on 120 identical frames. Scaling once and
repeating the finished frame with `loop=loop=-1:size=1` is the same bytes out:

| | one 7008x4672 still, 4s |
|---|---|
| `-loop 1` (scale 120x) | 32.65s |
| scale once, then `loop` | **3.52s** |

Byte-identical output (932685 bytes both). 9.3x less work, zero quality change.

**2. Clips are now encoded `--jobs` at a time** instead of strictly one after
another. This is *not* the core count - see below.

**3. NVENC preset p7 -> p5.** Measured on a 4s 4K still: p7 3.26s, p5 1.73s, for
2.9% more bytes at the same CQ. Same CQ means the same visual quality - the
slower preset just reaches it with fewer bits. Not worth 2x the time for an
intermediate YouTube is going to re-encode anyway. Override with `--preset p7`.

### `--jobs` is not the number of CPU cores

Cores were never the constraint - CPU sat at ~155% (1.5 of 32) even at 6 jobs.
Once stills are scaled only once, **NVENC is the bottleneck**, and it has hard
limits. Measured on 17 large stills:

| jobs | time | result |
|---|---|---|
| 1 | 36.4s | ok |
| 4 | 27.0s | ok (default) |
| 6 | 25.9s | ok, +4% over 4 jobs |
| 10 | - | clips **fail** |
| 16 | - | 9 of 17 clips **fail** |

At high concurrency each NVENC session allocates its own VRAM input buffers and
an 8 GB laptop card shared with a browser runs out:

```
CreateInputBuffer failed: out of memory (10)
OpenEncodeSessionEx failed: incompatible client key (21)   <- driver session cap
```

Default is 4 (2 at 8K). Failed clips are **retried serially** afterwards, so a
transient GPU-side failure can never silently drop a clip from the timeline -
which is exactly how v1 lost six files without saying so.

### What does NOT help: moving the filters to the GPU

`-hwaccel cuda` for GPU decode measured **slower**: 18.33s -> 19.79s. Copying
frames back from VRAM for the CPU filters costs more than the CPU decode saved.

A full GPU pipeline is not possible in this ffmpeg build anyway - it ships
`scale_cuda`, `overlay_cuda` and `yadif_cuda`, but there is no `pad_cuda`,
`gblur_cuda`, `colorspace_cuda` or `tonemap_cuda`. The frame has to come back to
system memory for padding, blurred backdrops, HDR tone-mapping and colour
conversion regardless, and each round trip costs more than it saves. It is also
moot now: NVENC is the limit, so moving filters onto the GPU would only make the
GPU queue behind itself.

## 🎯 Choosing a resolution (read this before picking 8K)

**Upscaling never adds detail.** A 720x1280 phone clip stretched onto an 8K canvas is still a
720x1280 clip — just 12x heavier to store and upload.

**The grain of truth behind "upload in 4K/8K":** YouTube allocates bitrate by resolution, not by
how good the picture actually is. The same footage gets ~8 Mbps VP9 at 1080p but ~20 Mbps at 4K,
so upscaling really does reduce compression artefacts. **That benefit is essentially saturated at
4K.** Going to 8K costs 5-10x the file size, hours of extra upload, 1-3 days of YouTube 8K
processing, and reaches the <0.5% of viewers with an 8K display.

Rule of thumb:

| Your source | Upload at |
|---|---|
| Phone video, max 1080p | **4K** |
| 4K video | **4K** (native) |
| Mostly high-res stills (>4000px), little video | 4K; 8K only if stills are the point and you accept the size |
| Mixed stills + 1080p video (the common case) | **4K** |

Also: a 16:9 canvas full of vertical phone clips wastes most of its pixels on black bars that
still cost bitrate. Try `--orientation auto` or `--pad blur`.

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
