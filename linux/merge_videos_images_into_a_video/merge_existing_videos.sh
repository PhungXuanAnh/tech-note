#!/bin/bash

# Standalone script to merge existing APPLE videos
# Keeps merged files under 10GB limit
# Deletes original videos after successful merge

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   Smart Video Merger (Max 10GB)       ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
echo ""

# Maximum file size in GB (10GB limit)
MAX_SIZE_GB=10
MAX_SIZE_BYTES=$((MAX_SIZE_GB * 1024 * 1024 * 1024))

# Function to get file size in bytes
get_file_size() {
    stat -c%s "$1" 2>/dev/null || echo "0"
}

# Function to format bytes to human readable
format_size() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt $((1024*1024)) ]; then
        echo "$((bytes/1024))KB"
    elif [ $bytes -lt $((1024*1024*1024)) ]; then
        echo "$((bytes/1024/1024))MB"
    else
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1024/1024/1024}")GB"
    fi
}

# Get all APPLE videos sorted by name
shopt -s nullglob
VIDEOS=(*APPLE.mp4)
shopt -u nullglob

if [ ${#VIDEOS[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No *APPLE.mp4 videos found to merge${NC}"
    exit 1
fi

echo -e "${CYAN}📹 Found ${#VIDEOS[@]} videos to process:${NC}"
for V in "${VIDEOS[@]}"; do
    SIZE=$(format_size $(get_file_size "$V"))
    echo -e "   • $V ($SIZE)"
done
echo ""

MERGE_COUNT=1
CURRENT_BATCH=()
CURRENT_SIZE=0

for VIDEO in "${VIDEOS[@]}"; do
    VIDEO_SIZE=$(get_file_size "$VIDEO")
    VIDEO_SIZE_HUMAN=$(format_size $VIDEO_SIZE)
    
    echo -e "${BLUE}Checking: $VIDEO ($VIDEO_SIZE_HUMAN)${NC}"
    
    # Check if adding this video would exceed limit
    POTENTIAL_SIZE=$((CURRENT_SIZE + VIDEO_SIZE))
    
    if [ $POTENTIAL_SIZE -le $MAX_SIZE_BYTES ] && [ ${#CURRENT_BATCH[@]} -gt 0 ]; then
        # Can add to current batch
        echo -e "${GREEN}  ➕ Adding to current batch${NC}"
        CURRENT_BATCH+=("$VIDEO")
        CURRENT_SIZE=$POTENTIAL_SIZE
    else
        # Need to finalize current batch first (if it has items)
        if [ ${#CURRENT_BATCH[@]} -gt 0 ]; then
            echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${MAGENTA}🔗 Merging batch $MERGE_COUNT (${#CURRENT_BATCH[@]} videos)${NC}"
            
            # Create output filename
            OUTPUT_NAME="merged_part_${MERGE_COUNT}.mp4"
            
            # Create concat file
            CONCAT_FILE="merge_list_${MERGE_COUNT}.txt"
            rm -f "$CONCAT_FILE"
            for V in "${CURRENT_BATCH[@]}"; do
                echo "file '$V'" >> "$CONCAT_FILE"
            done
            
            echo -e "${BLUE}📝 Videos in this batch:${NC}"
            for V in "${CURRENT_BATCH[@]}"; do
                SIZE=$(format_size $(get_file_size "$V"))
                echo -e "   • $V ($SIZE)"
            done
            
            TOTAL_SIZE_HUMAN=$(format_size $CURRENT_SIZE)
            echo -e "${CYAN}📦 Total batch size: $TOTAL_SIZE_HUMAN${NC}"
            
            # Merge videos
            echo -e "${BLUE}🎞️  Merging videos (using stream copy - very fast!)...${NC}"
            ffmpeg -f concat -safe 0 -i "$CONCAT_FILE" \
                -c copy \
                -y "$OUTPUT_NAME" -hide_banner -loglevel error 2>&1
            
            if [ -f "$OUTPUT_NAME" ]; then
                FINAL_SIZE=$(format_size $(get_file_size "$OUTPUT_NAME"))
                DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT_NAME" 2>/dev/null | cut -d. -f1)
                MINUTES=$((DURATION / 60))
                SECONDS=$((DURATION % 60))
                
                echo -e "${GREEN}✅ Created: $OUTPUT_NAME${NC}"
                echo -e "${GREEN}   📦 Size: $FINAL_SIZE | ⏱️  Duration: ${MINUTES}m ${SECONDS}s${NC}"
                
                # Remove original videos that were merged
                echo -e "${BLUE}🗑️  Removing original videos...${NC}"
                for V in "${CURRENT_BATCH[@]}"; do
                    rm -f "$V"
                    echo -e "   ✓ Removed: $V"
                done
                
                # Clean up concat file
                rm -f "$CONCAT_FILE"
            else
                echo -e "${RED}❌ Failed to create $OUTPUT_NAME${NC}"
                rm -f "$CONCAT_FILE"
            fi
            
            echo ""
            ((MERGE_COUNT++))
        fi
        
        # Start new batch with current video
        echo -e "${GREEN}  🆕 Starting new batch${NC}"
        CURRENT_BATCH=("$VIDEO")
        CURRENT_SIZE=$VIDEO_SIZE
    fi
done

# Handle remaining batch
if [ ${#CURRENT_BATCH[@]} -gt 1 ]; then
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🔗 Merging final batch $MERGE_COUNT (${#CURRENT_BATCH[@]} videos)${NC}"
    
    OUTPUT_NAME="merged_part_${MERGE_COUNT}.mp4"
    CONCAT_FILE="merge_list_${MERGE_COUNT}.txt"
    rm -f "$CONCAT_FILE"
    
    for V in "${CURRENT_BATCH[@]}"; do
        echo "file '$V'" >> "$CONCAT_FILE"
    done
    
    echo -e "${BLUE}📝 Videos in this batch:${NC}"
    for V in "${CURRENT_BATCH[@]}"; do
        SIZE=$(format_size $(get_file_size "$V"))
        echo -e "   • $V ($SIZE)"
    done
    
    TOTAL_SIZE_HUMAN=$(format_size $CURRENT_SIZE)
    echo -e "${CYAN}📦 Total batch size: $TOTAL_SIZE_HUMAN${NC}"
    
    echo -e "${BLUE}🎞️  Merging videos (using stream copy - very fast!)...${NC}"
    ffmpeg -f concat -safe 0 -i "$CONCAT_FILE" \
        -c copy \
        -y "$OUTPUT_NAME" -hide_banner -loglevel error 2>&1
    
    if [ -f "$OUTPUT_NAME" ]; then
        FINAL_SIZE=$(format_size $(get_file_size "$OUTPUT_NAME"))
        DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT_NAME" 2>/dev/null | cut -d. -f1)
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        
        echo -e "${GREEN}✅ Created: $OUTPUT_NAME${NC}"
        echo -e "${GREEN}   📦 Size: $FINAL_SIZE | ⏱️  Duration: ${MINUTES}m ${SECONDS}s${NC}"
        
        echo -e "${BLUE}🗑️  Removing original videos...${NC}"
        for V in "${CURRENT_BATCH[@]}"; do
            rm -f "$V"
            echo -e "   ✓ Removed: $V"
        done
        
        rm -f "$CONCAT_FILE"
    else
        echo -e "${RED}❌ Failed to create $OUTPUT_NAME${NC}"
        rm -f "$CONCAT_FILE"
    fi
elif [ ${#CURRENT_BATCH[@]} -eq 1 ]; then
    echo -e "${YELLOW}ℹ️  Last video (${CURRENT_BATCH[0]}) kept as-is (only one in batch)${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Merging Complete!                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📹 Final videos:${NC}"

shopt -s nullglob
for vid in *.mp4; do
    if [ -f "$vid" ]; then
        SIZE=$(format_size $(get_file_size "$vid"))
        DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" 2>/dev/null | cut -d. -f1)
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        echo -e "   ${GREEN}✓${NC} $vid ($SIZE, ${MINUTES}m ${SECONDS}s)"
    fi
done
shopt -u nullglob
