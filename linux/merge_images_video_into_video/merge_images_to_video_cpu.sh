#!/bin/bash

# Image to Video Merger v3.0 - 4K/8K GPU Edition
# GPU-accelerated image to video converter for YouTube uploads

set -euo pipefail

# Configuration
declare -A RESOLUTIONS=(["1080p"]="1920:1080" ["4k"]="3840:2160" ["8k"]="7680:4320")
declare -A BITRATES=(["1080p"]="15M" ["4k"]="45M" ["8k"]="100M")

DEFAULT_RES="4k"
DEFAULT_FPS="30"
DEFAULT_DUR="5"

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
N='\033[0m'

# Detect GPU
detect_gpu() {
    local gpu="" use_gpu=false preset="medium" hevc=false
    
    # Note: FFmpeg NVENC not working on this system (shows encoders but can't access GPU)
    # Forcing CPU encoding for reliability
    if command -v nvidia-smi &>/dev/null; then
        gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1 || true)
        if [[ -n "$gpu" ]]; then
            echo -e "${Y}⚠ GPU detected: $gpu${N}" >&2
            echo -e "${Y}⚠ But FFmpeg NVENC not available - using CPU encoding${N}" >&2
            # Keep use_gpu=false to force CPU encoding
        fi
    fi
    echo "$use_gpu $preset $hevc"
}

# Build codec params
codec_params() {
    local res="$1" gpu="$2" preset="$3" hevc="$4" br="${BITRATES[$res]}"
    
    if [[ "$gpu" == "true" ]]; then
        if [[ "$res" == "8k" && "$hevc" == "true" ]]; then
            echo "-c:v hevc_nvenc -preset $preset -rc vbr -cq 18 -b:v $br -multipass fullres -profile:v high -bf 3 -g 60"
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

# Main
main() {
    local res="$DEFAULT_RES" fps="$DEFAULT_FPS" dur="$DEFAULT_DUR" out=""
    
    # Parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--resolution) res="$2"; shift 2 ;;
            -f|--fps) fps="$2"; shift 2 ;;
            -d|--duration) dur="$2"; shift 2 ;;
            -o|--output) out="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: $0 [-r 1080p|4k|8k] [-f FPS] [-d DURATION] [-o OUTPUT]"
                echo "Examples:"
                echo "  $0                           # 4K video with defaults"
                echo "  $0 -r 8k -d 7                # 8K video, 7 seconds per image"
                echo "  $0 -r 1080p -f 60            # 1080p at 60fps"
                exit 0 ;;
            *) echo -e "${R}Unknown: $1${N}"; exit 1 ;;
        esac
    done
    
    [[ -z "$out" ]] && out="merged_${res}_$(date +%Y%m%d_%H%M%S).mp4"
    
    # Get dimensions
    IFS=':' read -r w h <<< "${RESOLUTIONS[$res]}"
    
    echo -e "${C}╔════════════════════════════════════════╗${N}"
    echo -e "${C}║  Image to Video Merger v3.0 (4K/8K)   ║${N}"
    echo -e "${C}╚════════════════════════════════════════╝${N}"
    
    # GPU detection
    echo -e "${Y}Detecting GPU...${N}"
    read -r gpu preset hevc <<< $(detect_gpu)
    
    # Build codec
    codec=$(codec_params "$res" "$gpu" "$preset" "$hevc")
    
    echo -e "${C}Config:${N}"
    echo -e "  Resolution: ${G}$res ($w x $h)${N}"
    echo -e "  FPS: ${G}$fps${N}"
    echo -e "  Duration: ${G}${dur}s${N}"
    echo -e "  GPU: ${G}$([[ "$gpu" == "true" ]] && echo "Yes ($preset)" || echo "No")${N}"
    echo ""
    
    # Find images
    mapfile -d '' -t images < <(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \) -print0 | sort -z)
    total=${#images[@]}
    
    [[ $total -eq 0 ]] && { echo -e "${R}No images found!${N}"; exit 1; }
    
    echo -e "${C}Found $total images${N}"
    echo ""
    
    # Create temp dir
    tmp="temp_$$"
    mkdir -p "$tmp"
    
    # Process images
    echo -e "${Y}Processing images...${N}"
    idx=1
    for img in "${images[@]}"; do
        bn=$(basename "$img")
        vid="$tmp/vid_$(printf "%05d" $idx).mp4"
        echo -e "${Y}[$idx/$total]${N} $bn"
        
        ffmpeg -hide_banner -loglevel error \
            -loop 1 -t "$dur" -i "$img" \
            -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 \
            -vf "scale=$w:$h:force_original_aspect_ratio=decrease,pad=$w:$h:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p,fps=$fps" \
            $codec \
            -c:a aac -b:a 320k \
            -shortest -y "$vid" 2>&1 | grep -v "^$" || true
        
        [[ -f "$vid" ]] && echo -e "${G}✓ Done${N}" || echo -e "${R}✗ Failed${N}"
        ((idx++))
    done
    
    echo ""
    
    # Merge
    echo -e "${Y}Merging videos...${N}"
    concat="$tmp/concat.txt"
    find "$tmp" -name "vid_*.mp4" | sort | while read v; do
        echo "file '$(realpath "$v")'"
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
        echo -e "${G}✓ Created: $out ($sz)${N}"
        
        echo -e "${C}Video info:${N}"
        ffprobe -v error -select_streams v:0 \
            -show_entries stream=width,height,codec_name,duration \
            -of default=noprint_wrappers=1 "$out" 2>/dev/null | sed 's/^/  /'
        
        echo ""
        echo -e "${C}YouTube Upload Ready!${N}"
    else
        echo -e "${R}✗ Failed${N}"
        exit 1
    fi
}

main "$@"
