#!/bin/bash

# Set your source and destination directories
source_dir="/sdcard/Music/Browser/new/"
destination_dir="/home/mcdoughnuts/Music/new"

# Function to copy all contents in the source directory 
copy_all_contents() {
    adb shell ls "$source_dir" | while read -r file; do
        adb_file="$source_dir$file"
        laptop_file="$destination_dir/$file"
        
        if [ ! -f "$laptop_file" ]; then
            adb pull "$adb_file" "$laptop_file"
        fi
    done
}

# Function to copy all files in the source directory (exclude both folders and their contents while copying files)
copy_all_files() {
    # List files (excluding folders and their contents) on the phone and store them in an array
    phone_files=()
    while IFS=  read -r -d $'\0'; do
        phone_files+=("$REPLY")
    done < <(adb shell find "$source_dir" -type f -print0)

    # Copy files (excluding folders and their contents) from phone to laptop
    for phone_file in "${phone_files[@]}"; do
        phone_file=$(echo "$phone_file" | tr -d '\r')  # Remove Windows-style carriage return
        filename=$(basename "$phone_file")
        laptop_file="$destination_dir/$filename"
        
        if [ ! -f "$laptop_file" ]; then
            adb pull "$phone_file" "$laptop_file"
        fi
    done
}

# Function to copy audio files only (.MP3, .mp3)
copy_audio_files() {
    adb shell find "$source_dir" -type f -iname "*.mp3" -o -iname "*.MP3" | while read -r audio_file; do
        audio_file=$(echo "$audio_file" | tr -d '\r')  # Remove Windows-style carriage return
        filename=$(basename "$audio_file")
        laptop_file="$destination_dir/$filename"
        
        if [ ! -f "$laptop_file" ]; then
            adb pull "$audio_file" "$laptop_file"
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
