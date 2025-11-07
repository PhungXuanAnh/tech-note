#!/bin/bash

# Image to Video Merger v3.1 - GPU Edition with NVENC Fix
# GPU-accelerated image to video converter for YouTube uploads
# Includes library path fix for NVENC on Ubuntu

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# CRITICAL FIX: Add NVIDIA libraries to library path
# ═══════════════════════════════════════════════════════════════
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"

# Configuration
declare -A RESOLUTIONS=(["1080p"]="1920:1080" ["4k"]="3840:2160" ["8k"]="7680:4320")
declare -A BITRATES=(["1080p"]="15M" ["4k"]="45M" ["8k"]="100M")

DEFAULT_RES="8k"
DEFAULT_FPS="30"
DEFAULT_DUR="1"

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
N='\033[0m'

# Detect GPU with library path fix
detect_gpu() {
    local gpu="" use_gpu=false preset="p7" hevc=false
    
    # NVIDIA libraries should already be in LD_LIBRARY_PATH from line 11
    # Just verify they exist
    if [[ ! -f "/usr/lib/x86_64-linux-gnu/libnvidia-encode.so" ]] && [[ ! -f "/lib/x86_64-linux-gnu/libnvidia-encode.so" ]]; then
        echo -e "${R}⚠ NVIDIA encode libraries not installed${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    # Check for nvidia-smi
    if ! command -v nvidia-smi &>/dev/null; then
        echo -e "${Y}⚠ nvidia-smi not found - GPU encoding disabled${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    # Get GPU info
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1 || true)
    
    if [[ -z "$gpu" ]]; then
        echo -e "${Y}⚠ No GPU detected - using CPU encoding${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    # Test NVENC with a quick encode
    if ffmpeg -hide_banner -loglevel error \
        -f lavfi -i nullsrc=s=256x256:d=0.1 \
        -c:v h264_nvenc -f null - 2>&1 | grep -qi "no capable devices"; then
        echo -e "${R}✗ GPU detected but NVENC failed - using CPU${N}" >&2
        echo -e "${Y}  GPU: $gpu${N}" >&2
        echo "$use_gpu $preset $hevc"
        return
    fi
    
    # Success! GPU is working
    use_gpu=true
    echo -e "${G}✓ GPU detected and NVENC working!${N}" >&2
    echo -e "${G}  GPU: $gpu${N}" >&2
    
    # Determine best preset based on GPU generation
    if [[ "$gpu" =~ RTX\ (40|30) ]]; then
        preset="p7"  # Ada/Ampere generation (best quality)
        hevc=true    # Support 8K with HEVC
    elif [[ "$gpu" =~ RTX\ 20 ]] || [[ "$gpu" =~ GTX\ 16 ]]; then
        preset="p6"  # Turing generation
        hevc=true
    else
        preset="p4"  # Older GPUs
    fi
    
    echo "$use_gpu $preset $hevc"
}

# Build codec params
codec_params() {
    local res="$1" gpu="$2" preset="$3" hevc="$4" br="${BITRATES[$res]}"
    
    if [[ "$gpu" == "true" ]]; then
        if [[ "$res" == "8k" && "$hevc" == "true" ]]; then
            # 8K with HEVC NVENC
            echo "-c:v hevc_nvenc -preset $preset -rc vbr -cq 18 -b:v $br -multipass fullres -profile:v main10 -bf 3 -g 60"
        else
            # 1080p/4K with H.264 NVENC
            echo "-c:v h264_nvenc -preset $preset -rc vbr -cq 20 -b:v $br -multipass fullres -profile:v high -bf 3 -g 60"
        fi
    else
        # CPU fallback
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
                echo ""
                echo "GPU-accelerated image to video converter (v3.1)"
                echo ""
                echo "Options:"
                echo "  -r, --resolution   Video resolution: 1080p, 4k, or 8k (default: 8k)"
                echo "  -f, --fps          Frame rate (default: 30)"
                echo "  -d, --duration     Seconds per image (default: 1)"
                echo "  -o, --output       Output filename (default: auto-generated)"
                echo "  -h, --help         Show this help"
                echo ""
                echo "Examples:"
                echo "  $0                           # 4K video with GPU acceleration"
                echo "  $0 -r 8k -d 7                # 8K video, 7 seconds per image"
                echo "  $0 -r 1080p -f 60            # 1080p at 60fps"
                echo ""
                echo "Output filename format: merged_<resolution>_<timestamp>.mp4"
                echo "  Example: merged_4k_20231105_143025.mp4"
                exit 0 ;;
            *) echo -e "${R}Unknown option: $1${N}"; exit 1 ;;
        esac
    done
    
    [[ -z "$out" ]] && out="merged_${res}_$(date +%Y%m%d_%H%M%S).mp4"
    
    # Get dimensions
    IFS=':' read -r w h <<< "${RESOLUTIONS[$res]}"
    
    echo -e "${C}╔════════════════════════════════════════╗${N}"
    echo -e "${C}║  Image to Video Merger v3.1 GPU       ║${N}"
    echo -e "${C}╚════════════════════════════════════════╝${N}"
    
    # GPU detection
    echo -e "${Y}Detecting GPU and testing NVENC...${N}"
    read -r gpu preset hevc <<< $(detect_gpu)
    
    # Build codec
    codec=$(codec_params "$res" "$gpu" "$preset" "$hevc")
    
    echo -e "${C}Configuration:${N}"
    echo -e "  Resolution: ${G}$res ($w x $h)${N}"
    echo -e "  FPS: ${G}$fps${N}"
    echo -e "  Duration: ${G}${dur}s per image${N}"
    echo -e "  GPU Encoding: ${G}$([[ "$gpu" == "true" ]] && echo "Yes (NVENC $preset)" || echo "No (CPU fallback)")${N}"
    echo -e "  Output: ${G}$out${N}"
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
    start_time=$(date +%s)
    
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
        
        if [[ -f "$vid" ]]; then
            sz=$(du -h "$vid" | cut -f1)
            echo -e "${G}✓ Done ($sz)${N}"
        else
            echo -e "${R}✗ Failed${N}"
        fi
        ((idx++))
    done
    
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    echo ""
    echo -e "${C}Encoding completed in ${elapsed}s${N}"
    
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
        echo -e "${G}✓ Success! Created: $out ($sz)${N}"
        
        echo -e "${C}Video information:${N}"
        ffprobe -v error -select_streams v:0 \
            -show_entries stream=width,height,codec_name,duration,bit_rate \
            -of default=noprint_wrappers=1 "$out" 2>/dev/null | sed 's/^/  /'
        
        echo ""
        echo -e "${C}Performance:${N}"
        echo -e "  Total time: ${G}${elapsed}s${N}"
        echo -e "  Images: ${G}$total${N}"
        echo -e "  Speed: ${G}$(bc <<< "scale=2; $total / $elapsed") images/sec${N}"
        
        echo ""
        echo -e "${G}✓ YouTube Upload Ready!${N}"
    else
        echo -e "${R}✗ Failed to create output${N}"
        exit 1
    fi
}

main "$@"
