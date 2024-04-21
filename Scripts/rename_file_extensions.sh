#!/bin/bash

# Check if the user provided a directory as an argument
if [ $# -eq 0 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Directory containing the files
directory="$1"

# Verify if the directory exists
if [ ! -d "$directory" ]; then
  echo "Directory not found: $directory"
  exit 1
fi

# Navigate to the specified directory
cd "$directory"

# Loop through files in the directory
for file in *; do
  if [ -f "$file" ]; then
    # Check if the file has a .MP3 extension and rename it to .mp3
    if [[ "$file" == *".MP3" ]]; then
      new_name="${file%.MP3}.mp3"
      mv "$file" "$new_name"
      echo "Renamed: $file -> $new_name"
    fi
  fi
done

echo "All done!"
