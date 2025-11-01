# Quick Reference Guide

## 🚀 Quick Start

### For New iPhone Backup Folders
```bash
./merge_videos_v4.sh
```
This will:
1. Convert all HEIC images to JPG
2. Create 5-second clips from images
3. Standardize all videos
4. Merge per folder into individual MP4s
5. **Auto-merge** individual MP4s (keeping under 10GB)
6. Delete originals after successful merge

### For Existing Videos Only
```bash
./merge_existing_videos.sh
```
This will:
1. Find all *APPLE.mp4 files
2. Smart-merge them (under 10GB batches)
3. Delete originals after merge

## 📋 What You Get

**Input:** Folders with mixed images (JPG, PNG, HEIC) and videos (MOV, MP4)

**Output:** High-quality merged MP4 videos under 10GB each

## ⚙️ How It Works

### Smart Merging Algorithm

For each video:
  Can I add it to current batch without exceeding 10GB?
  
  YES → Add to batch
  NO  → Finalize current batch, start new one

When batch is ready:
  - Merge all videos (fast stream copy)
  - Delete individual videos
  - Move to next batch

### Example

6 videos totaling 2.55GB:
```
101APPLE (45MB) + 102APPLE (137MB) + ... + 106APPLE (1.54GB) = 2.55GB
✓ Under 10GB → merged_part_1.mp4
✓ All 6 originals deleted
```

## 🛠️ Customization

### Change 10GB Limit

Edit `MAX_SIZE_GB` in the script:
```bash
MAX_SIZE_GB=10  # Change to 5, 20, etc.
```

### Change Image Duration

Edit `-t 5` in the script:
```bash
-t 5   # 5 seconds per image
-t 10  # 10 seconds per image
```

### Change Parallel Jobs

Edit `-j 4` in the script:
```bash
parallel -j 4  # 4 folders at once
parallel -j 8  # 8 folders at once
```

---

## 📊 Output Examples

### Scenario 1: All Fit (Your Case)
```
Input:  6 videos (2.55GB)
Output: merged_part_1.mp4 (2.47GB)
```

### Scenario 2: Two Batches
```
Input:  A(9GB), B(8GB), C(2GB)
Output: merged_part_1.mp4 (9GB) [A only]
        merged_part_2.mp4 (10GB) [B + C]
```

### Scenario 3: Some Too Large
```
Input:  A(2GB), B(2GB), C(15GB), D(1GB)
Output: merged_part_1.mp4 (5GB) [A + B + D]
        103APPLE.mp4 (15GB) [C kept as-is]
```

## ⚡ Performance

- **Folder processing:** ~1 hour (parallel, 4 cores)
- **Merging:** ~30 seconds (stream copy, no re-encoding)
- **Total:** ~1 hour for complete pipeline

---

## ✅ Quality Assurance

- ✅ 1080p resolution
- ✅ H.264 codec (universal compatibility)
- ✅ AAC audio
- ✅ YouTube-ready
- ✅ No quality loss during merge (stream copy)

## 🎯 Use Cases

### Upload to YouTube
```bash
# File is ready as-is
# Upload: merged_part_1.mp4
```

**Quick Reference v4.0** | November 1, 2025
