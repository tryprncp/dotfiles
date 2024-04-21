#!/bin/bash

# Set the source directory
phone_music_dir="/sdcard/Music/Browser/new/"

# Connect to the phone using adb and request temporary root access
adb root
adb wait-for-device

# List files in the source directory and preserve filenames with spaces
phone_files=$(adb shell "find \"$phone_music_dir\" -type f -name '*.mp3' -exec echo -n '{}\n' \;")

# Loop through and rename files by replacing underscores with spaces
while read -r phone_file; do
    phone_file=$(echo "$phone_file" | tr -d '\r')  # Remove Windows-style carriage return
    filename=$(basename "$phone_file")

    # Check if the filename contains underscores
    if [[ "$filename" == *_* ]]; then
        new_filename=$(echo "$filename" | sed 's/_/ /g')  # Replace underscores with spaces
        new_phone_file="$(dirname "$phone_file")/$new_filename"

        # Rename the file on the phone
        adb shell "mv \"$phone_file\" \"$new_phone_file\""

        echo "Renamed: $filename -> $new_filename"
    fi
done <<< "$phone_files"

# Disconnect from root access
adb unroot

echo "Done!"
