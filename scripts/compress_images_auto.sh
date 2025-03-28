#!/bin/bash

IFS=$'\n'  # Handle files with spaces properly

# Read file paths from the temporary file
files=()
while IFS= read -r line || [ -n "$line" ]; do
    files+=("$line")
done < /Users/sergiortellez/scripts/temp_file_list.txt

# Log the files received
echo "Files received by the script:" > ~/scripts/compression_log.txt
for file in "${files[@]}"; do
    echo "$file" >> ~/scripts/compression_log.txt
done
echo "End of file list" >> ~/scripts/compression_log.txt


# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Use standard arrays instead of associative arrays for compatibility
original_sizes=()
compressed_sizes=()
file_paths=()

# Function to get file size in bytes
get_file_size() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

# Function to show progress bar with animation
show_progress() {
    local progress=$1
    local total=$2
    local bar_width=40
    local completed=$(( (progress * bar_width) / total ))
    local remaining=$(( bar_width - completed ))
    local spinner=("/" "-" "\\" "|")

    printf "\r[%-*s] %d/%d Files Processed - Auto Mode %s" "$bar_width" "$(printf '#%.0s' $(seq 1 $completed))" "$progress" "$total" "${spinner[$((progress % 4))]}"
}

# Function to show a beautiful summary
show_summary() {
    echo -e "\n\n${BLUE}=== Compression Summary ===${NC}"

    total_original=0
    total_compressed=0

    for index in "${!file_paths[@]}"; do
        file=${file_paths[$index]}
        original_size=${original_sizes[$index]}
        compressed_size=${compressed_sizes[$index]}

        total_original=$((total_original + original_size))
        total_compressed=$((total_compressed + compressed_size))

        if [ "$original_size" -gt 0 ]; then
            reduction=$(( 100 - (compressed_size * 100 / original_size) ))
        else
            reduction=0
        fi

        if (( reduction > 50 )); then
            color=$GREEN
        elif (( reduction > 20 )); then
            color=$YELLOW
        else
            color=$RED
        fi

        echo -e "${color}File: $file${NC}"
        echo -e "Original Size: ${YELLOW}$((original_size / 1024)) KB${NC}"
        echo -e "Compressed Size: ${YELLOW}$((compressed_size / 1024)) KB${NC}"
        echo -e "Reduction: ${color}$reduction%${NC}"
        echo -e "${BLUE}-------------------------------------${NC}"
    done

    if [ "$total_original" -gt 0 ]; then
        total_reduction=$(( 100 - (total_compressed * 100 / total_original) ))
    else
        total_reduction=0
    fi

    echo -e "${GREEN}Total Files Processed:${NC} ${#file_paths[@]}"
    echo -e "${GREEN}Total Original Size:${NC} $((total_original / 1024)) KB"
    echo -e "${GREEN}Total Compressed Size:${NC} $((total_compressed / 1024)) KB"
    echo -e "${GREEN}Total Reduction:${NC} $total_reduction%"
    echo -e "${BLUE}=====================================${NC}"
}

# Process each file
total_files=${#files[@]}
processed_files=0

echo "Starting compression process (Auto Mode)..."

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        processed_files=$((processed_files + 1))
        show_progress $processed_files $total_files

        ext="${file##*.}"
        dir=$(dirname "$file")
        base=$(basename "$file" ."$ext")

        original_size=$(get_file_size "$file")
        original_sizes+=("$original_size")
        file_paths+=("$file")

        # Preserve original by renaming
        mv "$file" "$dir/$base@old.$ext"

        case "$ext" in
            png)
                /usr/local/bin/pngquant --quality=70-85 --force --output="$dir/$base.png" "$dir/$base@old.png"
                ;;
            jpg|jpeg)
                /usr/local/bin/jpegoptim --strip-all --max=85 --dest="$dir" "$dir/$base@old.$ext"
                ;;
            webp)
                /usr/local/bin/cwebp -q 80 "$dir/$base@old.webp" -o "$dir/$base.webp"
                ;;
            *)
                echo "Unsupported file format: $file"
                ;;
        esac

        compressed_size=$(get_file_size "$dir/$base.$ext")
        compressed_sizes+=("$compressed_size")
    fi

done

# Show final summary
show_summary

# Clean up
rm /Users/sergiortellez/scripts/temp_file_list.txt

# ============================== INSTRUCTIONS ==============================
# To use this script on a new computer:
# 1. Install Homebrew: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 2. Install Required Tools:
#    - brew install pngquant
#    - brew install jpegoptim
#    - brew install webp
# 3. Save this script as 'compress_images_auto.sh' in ~/scripts/
# 4. Make the script executable:
#    - chmod +x ~/scripts/compress_images_auto.sh
# 5. Create an Alfred Workflow (file action) with the following command:
#    - for file in "$@"; do echo "$file" >> /Users/sergiortellez/scripts/temp_file_list.txt; done
#    - osascript -e 'tell application "Terminal" to do script "/Users/sergiortellez/scripts/compress_images_auto.sh"'
# 6. Test the workflow with image files.
# ===========================================================================

