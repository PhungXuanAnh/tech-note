#!/bin/bash

# Timeline Merger v1.0 - GPU Edition
# Merge images AND videos into a single 8K timeline video for YouTube
# Processes files in alphanumeric order (natural timeline order)
# GPU-accelerated with NVENC support

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# CRITICAL FIX: Add NVIDIA libraries to library path
# ═══════════════════════════════════════════════════════════════
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"

# Configuration
declare -A RESOLUTIONS=(["1080p"]="1920:1080" ["4k"]="3840:2160" ["8k"]="7680:4320")
declare -A BITRATES=(["1080p"]="20M" ["4k"]="60M" ["8k"]="150M")

DEFAULT_RES="8k"
DEFAULT_FPS="30"
DEFAULT_IMG_DURATION="1"  # Default seconds per image
DEFAULT_SCALE_MODE="fit"

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
B='\033[1;34m'
N='\033[0m'

# Detect GPU
detect_gpu() {
    local gpu="" use_gpu=false preset="p7" hevc=false
    
    if [[ ! -f "/usr/lib/x86_64-linux-gnu/libnvidia-encode.so" ]] && [[ ! -f "/lib/x86_64-linux-gnu/libnvidia-encode.so" ]]; then
        echo -e "${R}⚠ NVIDIA encode libraries not installed${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    if ! command -v nvidia-smi &>/dev/null; then
        echo -e "${Y}⚠ nvidia-smi not found - GPU encoding disabled${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1 || true)
    
    if [[ -z "$gpu" ]]; then
        echo -e "${Y}⚠ No GPU detected - using CPU encoding${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    if ffmpeg -hide_banner -loglevel error \
        -f lavfi -i nullsrc=s=256x256:d=0.1 \
        -c:v h264_nvenc -f null - 2>&1 | grep -qi "no capable devices"; then
        echo -e "${R}✗ GPU detected but NVENC failed - using CPU${N}" >&2
        echo -e "${Y}  GPU: $gpu${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    use_gpu=true
    echo -e "${G}✓ GPU detected and NVENC working!${N}" >&2
    echo -e "${G}  GPU: $gpu${N}" >&2
    
    if [[ "$gpu" =~ RTX\ (40|30) ]]; then
        preset="p7"
        hevc=true
    elif [[ "$gpu" =~ RTX\ 20 ]] || [[ "$gpu" =~ GTX\ 16 ]]; then
        preset="p6"
        hevc=true
    else
        preset="p4"
    fi
    
    echo "$use_gpu $preset $hevc"
}

# Build codec params
codec_params() {
    local res="$1" gpu="$2" preset="$3" hevc="$4" br="${BITRATES[$res]}"
    
    if [[ "$gpu" == "true" ]]; then
        if [[ "$res" == "8k" && "$hevc" == "true" ]]; then
            echo "-c:v hevc_nvenc -preset $preset -rc vbr -cq 18 -b:v $br -multipass fullres -profile:v main10 -bf 3 -g 60"
        else
            echo "-c:v h264_nvenc -preset $preset -rc vbr -cq 20 -b:v $br -multipass fullres -profile:v high -bf 3 -g 60"
        fi
    else
        if [[ "$res" == "8k" ]]; then
            echo "-c:v libx265 -preset slow -crf 18 -b:v $br -profile:v high -bf 3 -g 60"
        else
            echo "-c:v libx264 -preset slow -crf 20 -b:v $br -profile:v high -bf 3 -g 60"
        fi
    fi
}

# Check if file is an image
is_image() {
    local f="$1"
    local lower_f="${f,,}"  # Convert to lowercase
    [[ "$lower_f" =~ \.(jpg|jpeg|png|heic|heif)$ ]]
}

# Check if file is a video
is_video() {
    local f="$1"
    local lower_f="${f,,}"  # Convert to lowercase
    [[ "$lower_f" =~ \.(mov|mp4|avi|mkv)$ ]]
}

# Check if HEIC is a Live Photo (has corresponding MOV file)
is_live_photo() {
    local heic_file="$1"
    local base="${heic_file%.*}"  # Remove extension
    local mov_file="${base}.MOV"
    local mov_file_lower="${base}.mov"
    
    # Check if corresponding MOV exists (case-insensitive)
    [[ -f "$mov_file" ]] || [[ -f "$mov_file_lower" ]]
}

# Main
main() {
    local res="$DEFAULT_RES" fps="$DEFAULT_FPS" out="" img_dur="$DEFAULT_IMG_DURATION" scale_mode="$DEFAULT_SCALE_MODE"
    
    # Parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--resolution) res="$2"; shift 2 ;;
            -f|--fps) fps="$2"; shift 2 ;;
            -d|--duration) img_dur="$2"; shift 2 ;;
            -o|--output) out="$2"; shift 2 ;;
            -s|--scale) scale_mode="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: $0 [-r 1080p|4k|8k] [-f FPS] [-d DURATION] [-o OUTPUT] [-s fit|crop|stretch]"
                echo ""
                echo "Timeline merger - Merge images AND videos into one timeline video (v1.0)"
                echo ""
                echo "Options:"
                echo "  -r, --resolution   Video resolution: 1080p, 4k, or 8k (default: 8k)"
                echo "  -f, --fps          Frame rate (default: 30)"
                echo "  -d, --duration     Seconds per image (default: 1)"
                echo "  -o, --output       Output filename (default: auto-generated)"
                echo "  -s, --scale        Scaling mode: fit (letterbox), crop, or stretch (default: fit)"
                echo "  -h, --help         Show this help"
                echo ""
                echo "Features:"
                echo "  • Processes both images (JPG/PNG/HEIC) and videos (MOV/MP4/AVI/MKV)"
                echo "  • Maintains alphanumeric order (natural timeline order)"
                echo "  • GPU-accelerated encoding (NVENC)"
                echo "  • Preserves aspect ratios with letterboxing"
                echo "  • YouTube-ready output"
                echo ""
                echo "Examples:"
                echo "  $0                           # Merge all media to 8K (5s per image)"
                echo "  $0 -d 3                      # 3 seconds per image"
                echo "  $0 -r 4k -s crop             # 4K output, crop to fill"
                echo "  $0 -r 1080p -f 60 -d 2       # 1080p at 60fps, 2s per image"
                echo ""
                echo "Output filename format: timeline_<resolution>_<timestamp>.mp4"
                exit 0 ;;
            *) echo -e "${R}Unknown option: $1${N}"; exit 1 ;;
        esac
    done
    
    [[ -z "$out" ]] && out="timeline_${res}_$(date +%Y%m%d_%H%M%S).mp4"
    
    # Get dimensions
    IFS=':' read -r w h <<< "${RESOLUTIONS[$res]}"
    
    echo -e "${C}╔════════════════════════════════════════╗${N}"
    echo -e "${C}║   Timeline Merger v1.0 GPU            ║${N}"
    echo -e "${C}╚════════════════════════════════════════╝${N}"
    
    # GPU detection
    echo -e "${Y}Detecting GPU and testing NVENC...${N}"
    read -r gpu preset hevc <<< $(detect_gpu)
    
    # Build codec
    codec=$(codec_params "$res" "$gpu" "$preset" "$hevc")
    
    echo -e "${C}Configuration:${N}"
    echo -e "  Resolution: ${G}$res ($w x $h)${N}"
    echo -e "  FPS: ${G}$fps${N}"
    echo -e "  Image duration: ${G}${img_dur}s${N}"
    echo -e "  Scale mode: ${G}$scale_mode${N}"
    echo -e "  GPU Encoding: ${G}$([[ "$gpu" == "true" ]] && echo "Yes (NVENC $preset)" || echo "No (CPU fallback)")${N}"
    echo -e "  Output: ${G}$out${N}"
    echo ""
    
    # Find all media files (images and videos) and sort them
    mapfile -d '' -t all_files < <(find . -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" -o -iname "*.heif" -o \
        -iname "*.mov" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" \
        \) -print0 | sort -z)
    
    total=${#all_files[@]}
    [[ $total -eq 0 ]] && { echo -e "${R}No image or video files found!${N}"; exit 1; }
    
    # Count images and videos (skip Live Photo HEIC files)
    img_count=0
    vid_count=0
    live_photo_count=0
    for f in "${all_files[@]}"; do
        if is_image "$f"; then
            # Skip HEIC files that are Live Photos (have corresponding MOV)
            if [[ "$f" =~ \.(heic|HEIC)$ ]] && is_live_photo "$f"; then
                live_photo_count=$((live_photo_count + 1))
                continue
            fi
            img_count=$((img_count + 1))
        elif is_video "$f"; then
            vid_count=$((vid_count + 1))
        fi
    done
    
    echo -e "${C}Found $total media files:${N}"
    echo -e "  📸 Images: ${B}$img_count${N}"
    echo -e "  🎬 Videos: ${B}$vid_count${N}"
    if [[ $live_photo_count -gt 0 ]]; then
        echo -e "  📷 Live Photos (skipped): ${Y}$live_photo_count${N}"
    fi
    echo ""
    
    # Create temp dir
    tmp="temp_timeline_$$"
    mkdir -p "$tmp"
    
    # Build scale filter based on mode
    case "$scale_mode" in
        fit)
            scale_filter="scale=$w:$h:force_original_aspect_ratio=decrease,pad=$w:$h:(ow-iw)/2:(oh-ih)/2:black"
            ;;
        crop)
            scale_filter="scale=$w:$h:force_original_aspect_ratio=increase,crop=$w:$h"
            ;;
        stretch)
            scale_filter="scale=$w:$h"
            ;;
        *)
            echo -e "${R}Invalid scale mode: $scale_mode${N}"
            exit 1
            ;;
    esac
    
    # Process all files in order
    echo -e "${Y}Processing timeline in order...${N}"
    idx=1
    start_time=$(date +%s)
    
    for media_in in "${all_files[@]}"; do
        bn=$(basename "$media_in")
        clip_out="$tmp/clip_$(printf "%05d" $idx).mp4"
        
        if is_image "$media_in"; then
            # Skip HEIC files that are Live Photos (have corresponding MOV)
            if [[ "$media_in" =~ \.(heic|HEIC)$ ]] && is_live_photo "$media_in"; then
                echo -e "${Y}[$idx/$total]${N} 📷 $bn ${C}(Live Photo - skipping, using MOV instead)${N}"
                idx=$((idx + 1))
                continue
            fi
            
            # Process image
            echo -e "${Y}[$idx/$total]${N} 📸 $bn ${C}(image → ${img_dur}s clip)${N}"
            
            ffmpeg -hide_banner -loglevel error \
                -loop 1 -framerate "$fps" -i "$media_in" -t "$img_dur" \
                -vf "$scale_filter,format=yuv420p" \
                $codec \
                -y "$clip_out" 2>&1 | grep -v "^$" || true
                
        elif is_video "$media_in"; then
            # Process video
            duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$media_in" 2>/dev/null || echo "0")
            dur_fmt=$(printf "%.1f" "$duration")
            echo -e "${Y}[$idx/$total]${N} 🎬 $bn ${C}(video ${dur_fmt}s)${N}"
            
            ffmpeg -hide_banner -loglevel error \
                -i "$media_in" \
                -vf "$scale_filter,format=yuv420p,fps=$fps" \
                $codec \
                -c:a aac -b:a 320k -ar 48000 -ac 2 \
                -y "$clip_out" 2>&1 | grep -v "^$" || true
        fi
        
        if [[ -f "$clip_out" ]]; then
            sz=$(du -h "$clip_out" | cut -f1)
            echo -e "${G}✓ Done ($sz)${N}"
        else
            echo -e "${R}✗ Failed${N}"
        fi
        idx=$((idx + 1))
    done
    
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    echo ""
    echo -e "${C}Processing completed in ${elapsed}s${N}"
    
    # Concatenate all clips
    echo -e "${Y}Concatenating timeline...${N}"
    concat="$tmp/concat.txt"
    find "$tmp" -name "clip_*.mp4" | sort | while read c; do
        echo "file '$(realpath "$c")'"
    done > "$concat"
    
    ffmpeg -hide_banner -loglevel warning -stats \
        -f concat -safe 0 -i "$concat" \
        -c copy -movflags +faststart \
        -y "$out"
    
    # Cleanup
    rm -rf "$tmp"
    
    echo ""
    if [[ -f "$out" ]]; then
        sz=$(du -h "$out" | cut -f1)
        echo -e "${G}✓ Success! Created: $out ($sz)${N}"
        
        echo -e "${C}Timeline information:${N}"
        total_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$out" 2>/dev/null || echo "0")
        total_dur_fmt=$(printf "%.1f" "$total_duration")
        
        echo -e "  Total items: ${G}$total${N} (${B}$img_count${N} images + ${B}$vid_count${N} videos)"
        echo -e "  Total duration: ${G}${total_dur_fmt}s${N}"
        echo -e "  Resolution: ${G}$res ($w x $h)${N}"
        echo -e "  File size: ${G}$sz${N}"
        
        echo ""
        echo -e "${C}Performance:${N}"
        echo -e "  Total time: ${G}${elapsed}s${N}"
        avg_time=$(awk "BEGIN {printf \"%.2f\", $elapsed / $total}")
        echo -e "  Average per item: ${G}${avg_time}s${N}"
        
        echo ""
        echo -e "${G}✓ YouTube Upload Ready!${N}"
        echo -e "${C}Your complete timeline video is ready to upload!${N}"
    else
        echo -e "${R}✗ Failed to create output${N}"
        exit 1
    fi
}

main "$@"
