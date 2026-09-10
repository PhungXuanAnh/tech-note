#!/bin/bash

# Timeline Merger v2.0 - GPU Edition
# Merge images AND videos into a single timeline video for YouTube.
#
# v2.0 design principles (see merge_images_video_into_video.md):
#   1. Upscaling does NOT create detail. The canvas is chosen from the SOURCE
#      material, not picked arbitrarily. Default `-r auto`.
#   2. YouTube re-encodes everything and caps its own output bitrate. Uploading
#      at 400 Mbps gives literally the same result as ~2x YouTube's target.
#      So: constant-QUALITY rate control (CQ) with a sane cap, not QP=1.
#   3. No synthetic noise. Noise is the single most expensive thing to encode
#      and it steals bits from real detail in YouTube's re-encode.
#   4. Every clip gets an audio track (silence for stills) so that the final
#      `concat -c copy` keeps the audio of the real videos.

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# CRITICAL FIX: Add NVIDIA libraries to library path
# ═══════════════════════════════════════════════════════════════
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"

# ── Resolution ladder: tier name -> long edge (16:9) ───────────
declare -A LADDER=(["1080p"]=1920 ["1440p"]=2560 ["4k"]=3840 ["8k"]=7680)
LADDER_ORDER=("1080p" "1440p" "4k" "8k")

# Upload bitrate ceiling per tier. These sit comfortably ABOVE YouTube's own
# recommended upload bitrate, so the CQ encoder is never the limiting factor,
# but they stop a single noisy clip from ballooning the file.
declare -A MAXRATE=(["1080p"]="24M" ["1440p"]="40M" ["4k"]="90M" ["8k"]="200M")

# `auto` never picks a tier above this - going past 4K costs 5-10x the size for
# a benefit almost no viewer can see. Pass `-r 8k` explicitly to override.
AUTO_CAP="4k"

DEFAULT_RES="auto"
DEFAULT_FPS="30"
DEFAULT_IMG_DURATION="4"   # 1s is too short: YouTube's encoder needs ~1s after
                           # a cut to sharpen up, so 1s stills look permanently
                           # blurry on YouTube. 3-5s is the sweet spot.
DEFAULT_SCALE_MODE="fit"
DEFAULT_PAD="black"
DEFAULT_ORIENT="landscape"
DEFAULT_CQ="20"
DEFAULT_AUDIO_BR="192k"

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
B='\033[1;34m'
N='\033[0m'

# ═══════════════════════════════════════════════════════════════
# GPU / codec capability detection
# ═══════════════════════════════════════════════════════════════
TMPDIR_WORK=""
USE_GPU=false
NV_PRESET="p4"
HAS_HEVC=false
HAS_MAIN10=false

nvenc_probe() {
    # $@ = encoder args to test against a tiny null source
    ffmpeg -hide_banner -loglevel error \
        -f lavfi -i nullsrc=s=256x256:d=0.1 \
        "$@" -f null - >/dev/null 2>&1
}

detect_gpu() {
    if [[ ! -f "/usr/lib/x86_64-linux-gnu/libnvidia-encode.so" ]] && \
       [[ ! -f "/lib/x86_64-linux-gnu/libnvidia-encode.so" ]]; then
        echo -e "${R}⚠ NVIDIA encode libraries not installed - CPU fallback${N}" >&2
        return
    fi
    command -v nvidia-smi &>/dev/null || {
        echo -e "${Y}⚠ nvidia-smi not found - CPU fallback${N}" >&2; return; }

    local gpu
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1 || true)
    [[ -z "$gpu" ]] && { echo -e "${Y}⚠ No GPU detected - CPU fallback${N}" >&2; return; }

    nvenc_probe -c:v h264_nvenc || {
        echo -e "${R}✗ GPU found but NVENC failed - CPU fallback ($gpu)${N}" >&2; return; }

    USE_GPU=true
    echo -e "${G}✓ NVENC available - GPU: $gpu${N}" >&2

    if   [[ "$gpu" =~ RTX\ (50|40|30) ]]; then NV_PRESET="p7"
    elif [[ "$gpu" =~ RTX\ 20 ]] || [[ "$gpu" =~ GTX\ 16 ]]; then NV_PRESET="p6"
    else NV_PRESET="p4"; fi

    if nvenc_probe -c:v hevc_nvenc; then
        HAS_HEVC=true
        # 10-bit encoding of an 8-bit source is genuinely worth it: it removes
        # banding in skies/skin before YouTube's re-encode compounds it.
        if nvenc_probe -pix_fmt p010le -c:v hevc_nvenc -profile:v main10; then
            HAS_MAIN10=true
        fi
    fi
    echo -e "${G}  preset=$NV_PRESET hevc=$HAS_HEVC main10=$HAS_MAIN10${N}" >&2
}

# ═══════════════════════════════════════════════════════════════
# Media classification & probing
# ═══════════════════════════════════════════════════════════════
is_image() { local f="${1,,}"; [[ "$f" =~ \.(jpg|jpeg|png|heic|heif|tif|tiff|webp)$ ]]; }
is_video() { local f="${1,,}"; [[ "$f" =~ \.(mov|mp4|m4v|avi|mkv)$ ]]; }

# HEIC that has a sibling .MOV is the still half of a Live Photo -> skip it,
# the MOV carries the same moment with motion.
is_live_photo() {
    local base="${1%.*}"
    [[ -f "${base}.MOV" ]] || [[ -f "${base}.mov" ]]
}

# Echo "W H" (display dimensions) for any supported file
probe_dims() {
    local f="$1" out=""
    if is_image "$f" && command -v identify &>/dev/null; then
        out=$(identify -format "%w %h" "${f}[0]" 2>/dev/null || true)
    fi
    if [[ -z "$out" ]]; then
        out=$(ffprobe -v error -select_streams v:0 \
                -show_entries stream=width,height -of csv=p=0 "$f" 2>/dev/null \
              | head -n1 | tr ',' ' ' || true)
    fi
    [[ -z "$out" ]] && out="0 0"
    echo "$out"
}

probe_duration() {
    ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null || echo "0"
}

has_audio() {
    local n
    n=$(ffprobe -v error -select_streams a -show_entries stream=index \
            -of csv=p=0 "$1" 2>/dev/null | wc -l)
    [[ "$n" -gt 0 ]]
}

# Echo "<matrix> <hdr>" for a video.
#
# <matrix> is the input colour matrix translated into a name the `colorspace`
# filter actually accepts - ffprobe reports e.g. `bt2020nc` but the filter only
# knows `bt2020`, and feeding it the raw name is a hard error, not a warning.
# Anything unmappable degrades to bt709, which makes the conversion a no-op.
#
# <hdr> is "hlg", "pq" or "sdr". HDR transfers cannot go through the
# `colorspace` filter at all and need a zscale tone-map instead.
probe_colour() {
    local cs trc
    cs=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_space \
            -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null || true)
    trc=$(ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer \
            -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null || true)

    local matrix hdr="sdr"
    case "$cs" in
        bt2020nc|bt2020_ncl|bt2020c|bt2020_cl|bt2020) matrix="bt2020" ;;
        smpte170m)   matrix="smpte170m" ;;
        smpte240m)   matrix="smpte240m" ;;
        bt470bg)     matrix="bt470bg" ;;
        bt601-6-525) matrix="bt601-6-525" ;;
        bt601-6-625) matrix="bt601-6-625" ;;
        *)           matrix="bt709" ;;   # bt709, unknown, gbr, ycgco, fcc, ...
    esac
    case "$trc" in
        arib-std-b67) hdr="hlg" ;;
        smpte2084)    hdr="pq"  ;;
    esac
    echo "$matrix $hdr"
}

# ffmpeg cannot decode HEIC/HEIF (no libheif in most builds), so those stills are
# pre-converted with ImageMagick. Echoes the path ffmpeg should actually read.
HAS_ZSCALE=false
HAS_MAGICK=false
detect_filters() {
    ffmpeg -hide_banner -filters 2>/dev/null | grep -q " zscale " && HAS_ZSCALE=true
    command -v convert &>/dev/null && HAS_MAGICK=true
}

decodable_input() {
    local f="$1" tag="$2"
    if [[ "${f,,}" =~ \.(heic|heif)$ ]]; then
        if [[ "$HAS_MAGICK" != "true" ]]; then
            echo -e "${R}  HEIC needs ImageMagick: sudo apt install imagemagick${N}" >&2
            echo ""; return
        fi
        local png="$TMPDIR_WORK/src_${tag}.png"
        if convert "${f}[0]" -colorspace sRGB "$png" 2>/dev/null && [[ -s "$png" ]]; then
            echo "$png"; return
        fi
        echo ""; return
    fi
    echo "$f"
}

# ═══════════════════════════════════════════════════════════════
# Canvas selection
# ═══════════════════════════════════════════════════════════════
tier_for_long_edge() {
    local need="$1"
    for t in "${LADDER_ORDER[@]}"; do
        if [[ ${LADDER[$t]} -ge $need ]]; then echo "$t"; return; fi
    done
    echo "8k"
}

tier_index() {
    local i=0
    for t in "${LADDER_ORDER[@]}"; do
        [[ "$t" == "$1" ]] && { echo "$i"; return; }
        i=$((i+1))
    done
    echo 0
}

# ═══════════════════════════════════════════════════════════════
# Encoder arguments (constant quality, NOT constant QP=1)
# ═══════════════════════════════════════════════════════════════
build_codec_args() {
    local res="$1" fps="$2" cq="$3"
    local gop="$fps"                 # keyframe every 1s -> YouTube thumbnails work
    local max="${MAXRATE[$res]}"
    local buf="${max%M}"; buf="$((buf * 2))M"

    CODEC_ARGS=()
    PIX_FMT="yuv420p"

    if [[ "$USE_GPU" == "true" ]] && [[ "$HAS_HEVC" == "true" ]]; then
        CODEC_ARGS=(-c:v hevc_nvenc -preset "$NV_PRESET"
                    -rc vbr -cq "$cq" -b:v 0 -maxrate "$max" -bufsize "$buf"
                    -bf 3 -g "$gop" -keyint_min "$gop")
        if [[ "$HAS_MAIN10" == "true" ]]; then
            CODEC_ARGS+=(-profile:v main10)
            PIX_FMT="p010le"
        else
            CODEC_ARGS+=(-profile:v main)
        fi
        # Level 6.1 is required for 8K (level 6.0 caps out at 60 Mbps).
        if [[ "$res" == "8k" ]]; then CODEC_ARGS+=(-tier high -level 6.1); fi
    elif [[ "$USE_GPU" == "true" ]]; then
        # H.264 cannot legally carry 8K; caller already guards against that.
        CODEC_ARGS=(-c:v h264_nvenc -preset "$NV_PRESET"
                    -rc vbr -cq "$cq" -b:v 0 -maxrate "$max" -bufsize "$buf"
                    -multipass fullres -profile:v high
                    -bf 3 -g "$gop" -keyint_min "$gop")
    else
        # CPU fallback. CRF maps roughly 1:1 onto NVENC's CQ here.
        CODEC_ARGS=(-c:v libx265 -preset medium -crf "$cq"
                    -profile:v main -bf 3 -g "$gop" -keyint_min "$gop")
    fi
}

# ═══════════════════════════════════════════════════════════════
# Filtergraph
# ═══════════════════════════════════════════════════════════════
# $1 = kind (image|video)  $2 = input matrix (videos only)
build_filter() {
    local kind="$1" imatrix="${2:-bt709}"
    local pre="" fit="" out=""

    local hdr="${3:-sdr}"
    if [[ "$kind" == "video" ]]; then
        if [[ "$hdr" != "sdr" ]] && [[ "$HAS_ZSCALE" == "true" ]]; then
            # HLG/PQ. The `colorspace` filter has no idea what these transfers
            # are, so it must not be used here. Tone-map to SDR BT.709 through
            # linear light instead, otherwise the clip comes out grey and flat.
            local itrc="arib-std-b67"
            [[ "$hdr" == "pq" ]] && itrc="smpte2084"
            pre="zscale=tin=${itrc}:min=${imatrix}:pin=bt2020:t=linear:npl=100,\
format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,\
zscale=t=bt709:m=bt709:r=tv,"
        elif [[ "$imatrix" != "bt709" ]]; then
            # Only pay for the conversion when the source is actually not bt709.
            pre="colorspace=all=bt709:iall=${imatrix}:fast=1,"
        fi
        fit="flags=lanczos"
    else
        # Stills decode as RGB. Without out_color_matrix ffmpeg converts with the
        # BT.601 matrix while we tag the file BT.709 -> visible colour shift.
        fit="flags=lanczos:out_color_matrix=bt709:out_range=tv"
    fi

    case "$SCALE_MODE" in
        stretch) out="${pre}scale=${W}:${H}:${fit}" ;;
        crop)    out="${pre}scale=${W}:${H}:force_original_aspect_ratio=increase:${fit},crop=${W}:${H}" ;;
        fit)
            if [[ "$PAD_MODE" == "blur" ]]; then
                # Blurred fill instead of black bars. Blur at 1/8 scale - a real
                # gblur at 4K/8K is unusably slow and looks identical.
                local bw=$((W/8)) bh=$((H/8))
                out="${pre}split=2[bg][fg];\
[bg]scale=${bw}:${bh}:force_original_aspect_ratio=increase,crop=${bw}:${bh},gblur=sigma=8,scale=${W}:${H}:${fit},eq=brightness=-0.06[bgo];\
[fg]scale=${W}:${H}:force_original_aspect_ratio=decrease:${fit}[fgo];\
[bgo][fgo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2"
            else
                out="${pre}scale=${W}:${H}:force_original_aspect_ratio=decrease:${fit},pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black"
            fi
            ;;
        *) echo -e "${R}Invalid scale mode: $SCALE_MODE${N}" >&2; exit 1 ;;
    esac

    echo "${out},setsar=1,fps=${FPS},format=${PIX_FMT}"
}

usage() {
    cat <<EOF
Usage: $0 [options]

Timeline merger v2.0 - merge images AND videos into one YouTube-ready video.

Options:
  -r, --resolution   auto | 1080p | 1440p | 4k | 8k    (default: auto)
                     auto = smallest tier that covers the largest source,
                     capped at ${AUTO_CAP}. Pass 8k explicitly to force it.
  -O, --orientation  landscape | portrait | auto        (default: ${DEFAULT_ORIENT})
                     auto = whichever orientation holds more of the runtime.
  -f, --fps          Frame rate                         (default: ${DEFAULT_FPS})
  -d, --duration     Seconds per still image            (default: ${DEFAULT_IMG_DURATION})
  -s, --scale        fit | crop | stretch               (default: ${DEFAULT_SCALE_MODE})
  -p, --pad          black | blur   (fit mode only)     (default: ${DEFAULT_PAD})
  -q, --quality      CQ/CRF, lower = better & bigger    (default: ${DEFAULT_CQ})
                     18 = archival, 20 = excellent, 23 = fine for YouTube
  -o, --output       Output filename
  -n, --dry-run      Print the plan and size estimate, encode nothing
  -h, --help         This help

Why the defaults are what they are:
  * Upscaling adds NO detail. A 720x1280 phone clip stretched to 8K is still a
    720x1280 clip - just 12x heavier. auto picks the canvas from your files.
  * YouTube re-encodes every upload and caps its own bitrate. Uploading at
    400 Mbps looks identical to uploading at 80 Mbps. v1 used QP=1 (~436 Mbps),
    which is where the 9.5 GB came from.
  * No synthetic noise is added. Noise is the most expensive thing to encode and
    it steals bits from real detail in YouTube's re-encode.
  * Stills get a silent audio track so the final concat keeps your videos' sound.

Examples:
  $0                          # auto canvas, 4s per photo, sound preserved
  $0 -r 4k -p blur            # 4K, blurred backdrop instead of black bars
  $0 -O auto -n               # show what it would do for vertical-heavy sets
  $0 -r 8k -q 22              # force 8K, still ~1/8 the size of v1
EOF
}

# ═══════════════════════════════════════════════════════════════
main() {
    local res="$DEFAULT_RES" orient="$DEFAULT_ORIENT" out="" dry=false
    FPS="$DEFAULT_FPS"
    IMG_DUR="$DEFAULT_IMG_DURATION"
    SCALE_MODE="$DEFAULT_SCALE_MODE"
    PAD_MODE="$DEFAULT_PAD"
    local cq="$DEFAULT_CQ"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--resolution)  res="$2"; shift 2 ;;
            -O|--orientation) orient="$2"; shift 2 ;;
            -f|--fps)         FPS="$2"; shift 2 ;;
            -d|--duration)    IMG_DUR="$2"; shift 2 ;;
            -s|--scale)       SCALE_MODE="$2"; shift 2 ;;
            -p|--pad)         PAD_MODE="$2"; shift 2 ;;
            -q|--quality)     cq="$2"; shift 2 ;;
            -o|--output)      out="$2"; shift 2 ;;
            -n|--dry-run)     dry=true; shift ;;
            -h|--help)        usage; exit 0 ;;
            *) echo -e "${R}Unknown option: $1${N}"; exit 1 ;;
        esac
    done

    echo -e "${C}╔════════════════════════════════════════╗${N}"
    echo -e "${C}║   Timeline Merger v2.0 GPU             ║${N}"
    echo -e "${C}╚════════════════════════════════════════╝${N}"

    # ── Collect media ──────────────────────────────────────────
    mapfile -d '' -t all_files < <(find . -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \
        -o -iname "*.heif" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.webp" -o \
        -iname "*.mov" -o -iname "*.mp4" -o -iname "*.m4v" -o -iname "*.avi" -o -iname "*.mkv" \
        \) -print0 | sort -zV)

    # Build the working list (Live-Photo stills dropped) plus per-file metadata.
    # Never feed a previous run's output back in as a source - it is the single
    # easiest way to end up with a huge upscaled canvas and a duplicated timeline.
    local out_real=""
    [[ -e "$out" ]] && out_real=$(realpath "$out" 2>/dev/null || true)
    local -a items=() kinds=()
    local img_count=0 vid_count=0 live_count=0
    local max_long=0 port_time=0 land_time=0 est_video_secs=0

    echo -e "${Y}Scanning sources...${N}"
    for f in "${all_files[@]}"; do
        local kind="" f_real
        f_real=$(realpath "$f" 2>/dev/null || echo "$f")
        if [[ -n "$out_real" && "$f_real" == "$out_real" ]] || \
           [[ "$(basename "$f")" == timeline_*.mp4 ]]; then
            echo -e "${Y}  ⚠ skipping previous output: $(basename "$f")${N}"
            continue
        fi
        if is_image "$f"; then
            if [[ "${f,,}" =~ \.heic$ ]] && is_live_photo "$f"; then
                live_count=$((live_count+1)); continue
            fi
            kind="image"; img_count=$((img_count+1))
        elif is_video "$f"; then
            kind="video"; vid_count=$((vid_count+1))
        else
            continue
        fi

        local w h dur
        read -r w h <<< "$(probe_dims "$f")"
        [[ "$w" -eq 0 ]] && { echo -e "${Y}  ⚠ unreadable, skipping: $(basename "$f")${N}"; continue; }

        if [[ "$kind" == "video" ]]; then
            dur=$(probe_duration "$f")
            est_video_secs=$(awk "BEGIN{print $est_video_secs + $dur}")
        else
            dur="$IMG_DUR"
        fi

        local long=$w; [[ $h -gt $w ]] && long=$h
        [[ $long -gt $max_long ]] && max_long=$long
        if [[ $h -gt $w ]]; then
            port_time=$(awk "BEGIN{print $port_time + $dur}")
        else
            land_time=$(awk "BEGIN{print $land_time + $dur}")
        fi

        items+=("$f"); kinds+=("$kind")
    done

    local total=${#items[@]}
    [[ $total -eq 0 ]] && { echo -e "${R}No usable media found!${N}"; exit 1; }

    # ── Decide orientation ─────────────────────────────────────
    if [[ "$orient" == "auto" ]]; then
        if awk "BEGIN{exit !($port_time > $land_time)}"; then
            orient="portrait"
        else
            orient="landscape"
        fi
    fi

    # ── Decide resolution tier ─────────────────────────────────
    local auto_note=""
    if [[ "$res" == "auto" ]]; then
        local want; want=$(tier_for_long_edge "$max_long")
        if [[ $(tier_index "$want") -gt $(tier_index "$AUTO_CAP") ]]; then
            auto_note="source long edge ${max_long}px would need ${want}; capped at ${AUTO_CAP} (use -r ${want} to force)"
            res="$AUTO_CAP"
        else
            auto_note="largest source long edge is ${max_long}px"
            res="$want"
        fi
    fi
    [[ -z "${LADDER[$res]:-}" ]] && { echo -e "${R}Invalid resolution: $res${N}"; exit 1; }

    local long_edge=${LADDER[$res]} short_edge
    short_edge=$(( (LADDER[$res] * 9 / 16 / 2) * 2 ))
    if [[ "$orient" == "portrait" ]]; then
        W=$short_edge; H=$long_edge
    else
        W=$long_edge;  H=$short_edge
    fi

    [[ -z "$out" ]] && out="timeline_${res}_${orient}_$(date +%Y%m%d_%H%M%S).mp4"

    # ── Encoder setup ──────────────────────────────────────────
    echo -e "${Y}Detecting GPU and testing NVENC...${N}"
    detect_gpu
    detect_filters
    if [[ "$res" == "8k" && "$USE_GPU" == "true" && "$HAS_HEVC" != "true" ]]; then
        echo -e "${R}✗ 8K requires HEVC, which this encoder does not offer. Use -r 4k.${N}"
        exit 1
    fi
    build_codec_args "$res" "$FPS" "$cq"

    local est_total_secs
    est_total_secs=$(awk "BEGIN{printf \"%.0f\", $est_video_secs + $img_count * $IMG_DUR}")

    echo ""
    echo -e "${C}Plan:${N}"
    echo -e "  Canvas:          ${G}${res} ${orient} (${W}x${H})${N}"
    [[ -n "$auto_note" ]] && echo -e "                   ${C}auto: ${auto_note}${N}"
    echo -e "  Orientation vote:${N} portrait $(printf '%.0f' "$port_time")s vs landscape $(printf '%.0f' "$land_time")s"
    echo -e "  FPS / GOP:       ${G}${FPS} / ${FPS} (1s keyframes)${N}"
    echo -e "  Still duration:  ${G}${IMG_DUR}s${N}"
    echo -e "  Scale / pad:     ${G}${SCALE_MODE} / ${PAD_MODE}${N}"
    echo -e "  Rate control:    ${G}CQ ${cq}, cap ${MAXRATE[$res]}${N}"
    echo -e "  Encoder:         ${G}${CODEC_ARGS[1]} (${PIX_FMT})${N}"
    echo -e "  Content:         ${B}${img_count}${N} images + ${B}${vid_count}${N} videos"
    [[ $live_count -gt 0 ]] && echo -e "                   ${Y}${live_count} Live Photo stills skipped (MOV used instead)${N}"
    echo -e "  Est. duration:   ${G}${est_total_secs}s${N}"
    echo -e "  Output:          ${G}${out}${N}"
    echo ""

    if [[ "$dry" == "true" ]]; then
        echo -e "${Y}Dry run - nothing encoded.${N}"
        exit 0
    fi

    # ── Encode each clip to a common canvas / codec / audio layout ──
    TMPDIR_WORK="temp_timeline_$$"
    mkdir -p "$TMPDIR_WORK"
    trap 'rm -rf "${TMPDIR_WORK:-}"' EXIT
    local tmp="$TMPDIR_WORK"

    echo -e "${Y}Encoding clips...${N}"
    local idx=1 failed=0
    local start_time; start_time=$(date +%s)

    local i
    for ((i=0; i<total; i++)); do
        local f="${items[$i]}" kind="${kinds[$i]}"
        local bn; bn=$(basename "$f")
        local clip_out; clip_out="$tmp/clip_$(printf "%05d" "$idx").mp4"
        local -a cmd

        if [[ "$kind" == "image" ]]; then
            echo -ne "${Y}[$idx/$total]${N} 📸 $bn ${C}(still → ${IMG_DUR}s)${N} ... "
            local src; src=$(decodable_input "$f" "$(printf "%05d" "$idx")")
            if [[ -z "$src" ]]; then
                echo -e "${R}✗ cannot decode${N}"; failed=$((failed+1)); idx=$((idx+1)); continue
            fi
            cmd=(ffmpeg -hide_banner -loglevel error
                 -loop 1 -framerate "$FPS" -i "$src"
                 -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=48000"
                 -t "$IMG_DUR"
                 -filter_complex "$(build_filter image)[vout]"
                 -map "[vout]" -map 1:a:0)
        else
            local dur; dur=$(probe_duration "$f")
            printf -v dur "%.1f" "$dur"
            echo -ne "${Y}[$idx/$total]${N} 🎬 $bn ${C}(video ${dur}s)${N} ... "
            local mtx hdr; read -r mtx hdr <<< "$(probe_colour "$f")"
            [[ "$hdr" != "sdr" ]] && echo -ne "${C}[${hdr^^}→SDR] ${N}"
            if has_audio "$f"; then
                cmd=(ffmpeg -hide_banner -loglevel error -i "$f"
                     -filter_complex "$(build_filter video "$mtx" "$hdr")[vout]"
                     -map "[vout]" -map 0:a:0)
            else
                cmd=(ffmpeg -hide_banner -loglevel error -i "$f"
                     -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=48000"
                     -filter_complex "$(build_filter video "$mtx" "$hdr")[vout]"
                     -map "[vout]" -map 1:a:0)
            fi
        fi

        # Identical audio layout on EVERY clip is what makes `concat -c copy`
        # keep the sound instead of silently dropping it.
        cmd+=("${CODEC_ARGS[@]}"
              -color_primaries bt709 -color_trc bt709 -colorspace bt709
              -c:a aac -b:a "$DEFAULT_AUDIO_BR" -ar 48000 -ac 2
              -af "aresample=async=1:first_pts=0,apad" -shortest
              -r "$FPS" -video_track_timescale 90000
              -y "$clip_out")

        if "${cmd[@]}" 2>&1 | grep -v '^$' >&2; then :; fi

        if [[ -s "$clip_out" ]]; then
            echo -e "${G}✓ $(du -h "$clip_out" | cut -f1)${N}"
        else
            echo -e "${R}✗ failed${N}"
            failed=$((failed+1))
            rm -f "$clip_out"
        fi
        idx=$((idx+1))
    done

    local elapsed=$(( $(date +%s) - start_time ))
    echo ""
    echo -e "${C}Encoded in ${elapsed}s${N}"
    [[ $failed -gt 0 ]] && echo -e "${Y}⚠ $failed clip(s) failed and were left out${N}"

    # ── Concatenate ────────────────────────────────────────────
    echo -e "${Y}Concatenating timeline...${N}"
    local concat="$tmp/concat.txt"
    : > "$concat"
    while IFS= read -r c; do
        printf "file '%s'\n" "$(realpath "$c")" >> "$concat"
    done < <(find "$tmp" -name "clip_*.mp4" | sort)

    [[ ! -s "$concat" ]] && { echo -e "${R}Nothing to concatenate${N}"; exit 1; }

    # Video is stream-copied (no quality loss, no re-encode time). Audio IS
    # re-encoded: AAC frames are 1024 samples, so per-clip audio never lands
    # exactly on the video boundary and a straight copy leaves DTS gaps at every
    # join. One pass of AAC at 192k costs seconds and is inaudible - and YouTube
    # re-encodes to Opus anyway.
    ffmpeg -hide_banner -loglevel warning -stats \
        -f concat -safe 0 -i "$concat" \
        -c:v copy -c:a aac -b:a "$DEFAULT_AUDIO_BR" -ar 48000 -ac 2 \
        -movflags +faststart -fflags +genpts -avoid_negative_ts make_zero \
        -y "$out"

    # ── Report ─────────────────────────────────────────────────
    echo ""
    [[ ! -s "$out" ]] && { echo -e "${R}✗ Failed to create output${N}"; exit 1; }

    local sz dur_s br astreams
    sz=$(du -h "$out" | cut -f1)
    dur_s=$(probe_duration "$out"); printf -v dur_s "%.1f" "$dur_s"
    br=$(ffprobe -v error -show_entries format=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "$out" 2>/dev/null || echo 0)
    br=$(awk "BEGIN{printf \"%.1f\", $br/1000000}")
    astreams=$(ffprobe -v error -select_streams a -show_entries stream=index \
                  -of csv=p=0 "$out" 2>/dev/null | wc -l)

    echo -e "${G}✓ Success: $out${N}"
    echo -e "  Resolution:  ${G}${W}x${H} (${res} ${orient})${N}"
    echo -e "  Duration:    ${G}${dur_s}s${N}"
    echo -e "  Size:        ${G}${sz}${N}"
    echo -e "  Bitrate:     ${G}${br} Mbps${N}"
    if [[ "$astreams" -gt 0 ]]; then
        echo -e "  Audio:       ${G}present (${astreams} stream)${N}"
    else
        echo -e "  Audio:       ${R}MISSING - this is a bug, please report${N}"
    fi
    echo -e "  Encode time: ${G}${elapsed}s${N}"
    echo ""
    echo -e "${G}✓ YouTube upload ready.${N}"
    echo -e "${C}Note: YouTube re-encodes and caps its own bitrate. A bigger upload${N}"
    echo -e "${C}than this would look identical on YouTube.${N}"
}

main "$@"
