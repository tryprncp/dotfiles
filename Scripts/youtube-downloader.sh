#!/bin/bash

# Function to get a valid YouTube URL
get_url() {
  read -p "Enter YouTube video/playlist URL: " link
  if [[ $link =~ ^https:// ]]; then
    echo "$link"
  else
    echo "Invalid URL!"
    sleep 1
    get_url
  fi
}

# Function to choose download format
download_format() {
  echo "Choose download format:"
  echo "1) Download YouTube video in .mp3 format"
  echo "2) Download YouTube video in .webm format"
  read -p "Enter your choice (1 or 2): " choice
  case $choice in
    1|2) echo "$choice" ;;
    *) echo "Invalid input!"; sleep 1; download_format ;;
  esac
}

# Function to choose download quality
download_quality() {
  echo "Choose download quality:"
  echo "1) 480p"
  echo "2) 720p"
  echo "3) 1080p"
  echo "4) 1440p"
  echo "5) 2160p"
  read -p "Enter your choice (1-5): " choice
  case $choice in
    1) echo "480" ;;
    2) echo "720" ;;
    3) echo "1080" ;;
    4) echo "1440" ;;
    5) echo "2160" ;;
    *) echo "Invalid input!"; sleep 1; download_quality ;;
  esac
}

# Function to get download directory
download_directory() {
  default_path="$HOME/Videos/downloads"
  echo "Default download directory: $default_path"
  read -p "Enter new download directory (or press Enter to use default): " new_path
  if [[ -z "$new_path" ]]; then
    echo "$default_path"
  else
    echo "$HOME/$new_path"
  fi
}

# Function to download MP3
download_mp3() {
  url="$1"
  output_dir="$2"
  yt-dlp -x --audio-format mp3 -o "$output_dir/%(title)s.%(ext)s" -f 'bestaudio/best' "$url"
}

# Function to download MP4
download_mp4() {
  url="$1"
  quality="$2"
  output_dir="$3"
  yt-dlp -o "$output_dir/%(title)s.%(ext)s" -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" "$url"
}

# Main program
main() {
  echo "#################################################"
  echo "#####  YOUTUBE VIDEO AND AUDIO DOWNLOADER  ######"
  echo "#################################################"

  link=$(get_url)
  format=$(download_format)
  case $format in
    1) 
      download_mp3 "$link" "$(download_directory)" 
      ;;
    2) 
      quality=$(download_quality)
      directory=$(download_directory)
      download_mp4 "$link" "$quality" "$directory" 
      ;;
  esac
}

main
