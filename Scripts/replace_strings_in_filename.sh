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
    # Replace underscores with spaces and rename the file
    new_name=$(echo "$file" | tr '_' ' ')
    # You can also use sed for this operation
    # new_name=$(echo "$file" | sed 's/_/ /g')
    if [ "$file" != "$new_name" ]; then
      mv "$file" "$new_name"
      echo "Renamed: $file -> $new_name"
    fi
  fi
done

echo "All done!"
