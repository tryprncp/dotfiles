#!/bin/bash

# Specify the source directory where the torrent files are located
source_dir="$HOME/Downloads"

# Specify the download directory
download_dir="/home/mcdoughnuts/Videos/movies"

# Change to the source directory
cd "$source_dir" || exit 1

# Function to wait for download completion
wait_for_download_completion() {
    while [ -n "$(pgrep -f 'aria2c')" ]; do
        sleep 10
    done
}

# Function to mark a torrent as processed
mark_as_processed() {
    local torrent="$1"
    echo "$torrent" >> "$download_dir/processed_torrents.txt"
}

# Check if the processed torrents file exists, create it if not
processed_torrents_file="$download_dir/processed_torrents.txt"
touch "$processed_torrents_file"

# Find all .torrent files in the source directory
torrent_files=("$source_dir"/*.torrent)

# Loop through each torrent file and start the download
for torrent in "${torrent_files[@]}"; do
    # Extract the filename without the path
    torrent_file="$(basename "$torrent")"
    
    # Check if the torrent file exists and if it has not been processed
    if [ -f "$torrent" ] && ! grep -qFx "$torrent_file" "$processed_torrents_file"; then
        # Start the download using aria2c and stop seeding after download
        aria2c --dir="$download_dir" --seed-time=0 "$torrent"
        
        # Wait for the download to complete
        wait_for_download_completion
        
        # Mark the torrent as processed
        mark_as_processed "$torrent_file"
    fi
done

echo "All downloads completed."

