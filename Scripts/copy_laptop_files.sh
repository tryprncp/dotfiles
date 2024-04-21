#!/bin/bash

# Set your source and destination directories
source_dir="/home/mcdoughnuts/Music/downloads"
destination_dir="/sdcard/Music/"

# Function to copy all contents in the source directory 
copy_all_contents() {
    find "$source_dir" -type f | while read -r file; do
        filename=$(basename "$file")
        adb_file="$destination_dir$filename"
        
        if [ ! -f "$adb_file" ]; then
            adb push "$file" "$adb_file"
        fi
    done
}

# Function to copy all files in the source directory (exclude both folders and their contents while copying files)
copy_all_files() {
    # List files (excluding folders and their contents) on the laptop and store them in an array
    laptop_files=()
    while IFS=  read -r -d $'\0'; do
        laptop_files+=("$REPLY")
    done < <(find "$source_dir" -type f -print0)

    # Copy files (excluding folders and their contents) from laptop to phone
    for laptop_file in "${laptop_files[@]}"; do
        laptop_file=$(echo "$laptop_file" | tr-d '\r')  # Remove Windows-style carriage return
        filename=$(basename "$laptop_file")
        adb_file="$destination_dir$filename"
        
        if [ ! -f "$adb_file" ]; then
            adb push "$laptop_file" "$adb_file"
        fi
    done
}

# Function to copy audio files only (.MP3, .mp3)
copy_audio_files() {
    find "$source_dir" -type f -iname "*.mp3" -o -iname "*.MP3" | while read -r audio_file; do
        filename=$(basename "$audio_file")
        adb_file="$destination_dir$filename"

        if [ -f "$adb_file" ]; then
            echo "Skipping $filename (already exists)"
        else
            adb push "$audio_file" "$adb_file"
            echo "Copied $filename"
        fi
    done
}

# Display menu and prompt for user choice
echo "What do you want to copy?"
echo "1 - All contents within the source directory (exclude the directory itself)"
echo "2 - All files in the source directory (exclude both folders and their contents while copying files)"
echo "3 - Audio files only (.MP3, .mp3)"
read -p "Enter your choice: " choice

case $choice in
    1) copy_all_contents ;;
    2) copy_all_files ;;
    3) copy_audio_files ;;
    *) echo "Invalid choice" ;;
esac

echo "Done!"
