#!/bin/bash

# Create an array of directory paths to shred
directories_to_shred=(
  "/home/mcdoughnuts/test"
)

# Function to shred a directory
shred_directory() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f -exec shred -uzn 3 {} \;
    rm -rf "$dir"
    echo "The directory $dir has been securely shredded."
  else
    echo "The directory $dir does not exist."
  fi
}

# Iterate through the array and shred each directory
for dir in "${directories_to_shred[@]}"; do
  shred_directory "$dir"
done

# Self-delete the script using 'shred'
shred -uzn 3 --remove "$0"

