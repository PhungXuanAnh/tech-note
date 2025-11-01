#!/bin/bash

# Script to merge all images and videos from each APPLE folder into separate MP4 files
# Then merge individual videos together while keeping each merged file under 10GB
# Version 4: With auto-merging feature
# Created: November 1, 2025

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   iPhone Media Merger v4.0             ║${NC}"
echo -e "${GREEN}║   HEIC + Parallel + Auto-Merge         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
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

# Function to process a single folder
process_folder() {
    local FOLDER=$1
    
    if [ ! -d "$FOLDER" ]; then
        echo -e "${YELLOW}⚠️  [$FOLDER] Folder not found, skipping...${NC}"
        return
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📁 [$FOLDER] Starting processing...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Create temporary working directory
    TEMP_DIR="${FOLDER}_temp"
    rm -rf "$TEMP_DIR" 2>/dev/null
    mkdir -p "$TEMP_DIR"
    
    # Enable null glob (don't expand if no matches)
    shopt -s nullglob
    
    # Count total files first
    TOTAL_FILES=$(find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.heic" -o -iname "*.mov" -o -iname "*.mp4" \) | wc -l)
    echo -e "${BLUE}📊 [$FOLDER] Found $TOTAL_FILES media files${NC}"
    
    if [ $TOTAL_FILES -eq 0 ]; then
        echo -e "${YELLOW}⚠️  [$FOLDER] No media files found, skipping...${NC}"
        rm -rf "$TEMP_DIR"
        shopt -u nullglob
        return
    fi
    
    FILE_COUNT=0
    
    # Process HEIC files - convert to JPG first, then to video
    echo -e "${CYAN}🔄 [$FOLDER] Converting HEIC images to JPG...${NC}"
    for IMG in "$FOLDER"/*.{HEIC,heic}; do
        [ -f "$IMG" ] || continue
        
        BASENAME=$(basename "$IMG")
        FILENAME="${BASENAME%.*}"
        JPG_FILE="${TEMP_DIR}/${FILENAME}.jpg"
        
        ((FILE_COUNT++))
        echo -ne "    [$FILE_COUNT/$TOTAL_FILES] $BASENAME → JPG\r"
        
        # Convert HEIC to JPG using ImageMagick
        convert "$IMG" "$JPG_FILE" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo -e "\n${YELLOW}    ⚠️  Warning: Failed to convert $BASENAME to JPG${NC}"
        fi
    done
    
    # Process all images (JPG, PNG, and converted HEIC)
    echo -e "\n${BLUE}🖼️  [$FOLDER] Converting images to 5-second video clips...${NC}"
    for IMG in "$FOLDER"/*.{JPG,jpg,PNG,png} "$TEMP_DIR"/*.jpg; do
        [ -f "$IMG" ] || continue
        
        BASENAME=$(basename "$IMG")
        FILENAME="${BASENAME%.*}"
        OUTPUT="${TEMP_DIR}/${FILENAME}.mp4"
        
        # Skip if already processed
        [ -f "$OUTPUT" ] && continue
        
        ((FILE_COUNT++))
        echo -ne "    [$FILE_COUNT/$TOTAL_FILES] Converting: $BASENAME\r"
        
        ffmpeg -loop 1 -t 5 -i "$IMG" \
            -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p,fps=30" \
            -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p \
            -y "$OUTPUT" -hide_banner -loglevel error 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo -e "\n${YELLOW}    ⚠️  Warning: Failed to convert $BASENAME${NC}"
        fi
    done
    
    # Process all videos
    echo -e "\n${BLUE}🎬 [$FOLDER] Converting videos to standard format...${NC}"
    for VIDEO in "$FOLDER"/*.{MOV,mov,MP4,mp4}; do
        [ -f "$VIDEO" ] || continue
        
        BASENAME=$(basename "$VIDEO")
        FILENAME="${BASENAME%.*}"
        OUTPUT="${TEMP_DIR}/${FILENAME}.mp4"
        
        # Skip if already converted from image
        [ -f "$OUTPUT" ] && continue
        
        ((FILE_COUNT++))
        echo -ne "    [$FILE_COUNT/$TOTAL_FILES] Converting: $BASENAME\r"
        
        ffmpeg -i "$VIDEO" \
            -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p,fps=30" \
            -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p \
            -c:a aac -b:a 192k \
            -y "$OUTPUT" -hide_banner -loglevel error 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo -e "\n${YELLOW}    ⚠️  Warning: Failed to convert $BASENAME${NC}"
        fi
    done
    
    echo -e "\n${GREEN}✓ [$FOLDER] Conversion complete!${NC}"
    
    # Count converted files
    CONVERTED_COUNT=$(ls -1 "$TEMP_DIR"/*.mp4 2>/dev/null | wc -l)
    
    if [ $CONVERTED_COUNT -eq 0 ]; then
        echo -e "${RED}❌ [$FOLDER] Error: No files were successfully converted${NC}"
        rm -rf "$TEMP_DIR"
        shopt -u nullglob
        return
    fi
    
    echo -e "${BLUE}📝 [$FOLDER] Creating input list (sorted by filename)...${NC}"
    INPUT_LIST="${TEMP_DIR}/input_list.txt"
    (cd "$TEMP_DIR" && ls -1 *.mp4 2>/dev/null | sort | awk '{print "file \x27" $0 "\x27"}') > "$INPUT_LIST"
    
    # Merge all clips
    echo -e "${BLUE}🎞️  [$FOLDER] Merging $CONVERTED_COUNT clips into final video...${NC}"
    OUTPUT_VIDEO="${FOLDER}.mp4"
    
    ffmpeg -f concat -safe 0 -i "$INPUT_LIST" \
        -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p \
        -c:a aac -b:a 192k \
        -movflags +faststart \
        -y "$OUTPUT_VIDEO" -hide_banner -loglevel error 2>&1
    
    if [ -f "$OUTPUT_VIDEO" ]; then
        FILE_SIZE=$(du -h "$OUTPUT_VIDEO" | cut -f1)
        DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT_VIDEO" 2>/dev/null | cut -d. -f1)
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        echo -e "${GREEN}✅ [$FOLDER] SUCCESS: Created $OUTPUT_VIDEO${NC}"
        echo -e "${GREEN}   📦 Size: $FILE_SIZE | ⏱️  Duration: ${MINUTES}m ${SECONDS}s${NC}"
    else
        echo -e "${RED}❌ [$FOLDER] Error: Failed to create $OUTPUT_VIDEO${NC}"
    fi
    
    # Clean up
    echo -e "${BLUE}🧹 [$FOLDER] Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}✓ [$FOLDER] Processing complete!${NC}"
    echo ""
    
    shopt -u nullglob
}

# Function to merge videos together
merge_videos_smart() {
    echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║   Smart Video Merging (Max 10GB)      ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get all APPLE videos sorted by name
    shopt -s nullglob
    VIDEOS=(*APPLE.mp4)
    shopt -u nullglob
    
    if [ ${#VIDEOS[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No videos found to merge${NC}"
        return
    fi
    
    echo -e "${CYAN}📹 Found ${#VIDEOS[@]} videos to process${NC}"
    
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
                echo -e "${BLUE}🎞️  Merging videos...${NC}"
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
        
        echo -e "${BLUE}🎞️  Merging videos...${NC}"
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
}

# Export the function so parallel processes can use it
export -f process_folder get_file_size format_size
export RED GREEN YELLOW BLUE CYAN MAGENTA NC

# Get all APPLE folders dynamically
FOLDERS=($(ls -d *APPLE 2>/dev/null | sort))

if [ ${#FOLDERS[@]} -eq 0 ]; then
    echo -e "${RED}❌ No APPLE folders found!${NC}"
    exit 1
fi

echo -e "${CYAN}📂 Found ${#FOLDERS[@]} folders to process: ${FOLDERS[*]}${NC}"
echo -e "${CYAN}🚀 Processing folders in parallel (using GNU parallel)...${NC}"
echo ""

# Check if GNU parallel is available
if command -v parallel &> /dev/null; then
    echo -e "${GREEN}✓ Using GNU parallel for maximum speed${NC}"
    echo ""
    # Process all folders in parallel
    printf '%s\n' "${FOLDERS[@]}" | parallel -j 4 --line-buffer process_folder {}
else
    echo -e "${YELLOW}⚠️  GNU parallel not found, processing sequentially${NC}"
    echo -e "${YELLOW}   Install with: sudo apt install parallel (for faster processing)${NC}"
    echo ""
    # Process folders one by one
    for FOLDER in "${FOLDERS[@]}"; do
        process_folder "$FOLDER"
    done
fi

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Folder Processing Complete!          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Now merge videos intelligently
merge_videos_smart

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   All Processing Complete!             ║${NC}"
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

if ! ls *.mp4 &>/dev/null; then
    echo -e "${YELLOW}   No videos were created${NC}"
fi
