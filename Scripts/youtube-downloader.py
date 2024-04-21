#!/usr/bin/env python3

import subprocess
from time import sleep

art_text = """
┏┓━━┏┓━━━━━━━━┏━━━━┓━━━━┏┓━━━━━━━━━━━━┏┓━━━━━━━━━━━━━━┏┓━━━━━━━━━━━━┏┓━━━━━━━
┃┗┓┏┛┃━━━━━━━━┃┏┓┏┓┃━━━━┃┃━━━━━━━━━━━━┃┃━━━━━━━━━━━━━━┃┃━━━━━━━━━━━━┃┃━━━━━━━
┗┓┗┛┏┛┏━━┓┏┓┏┓┗┛┃┃┗┛┏┓┏┓┃┗━┓┏━━┓━━━━┏━┛┃┏━━┓┏┓┏┓┏┓┏━┓━┃┃━┏━━┓┏━━┓━┏━┛┃┏━━┓┏━┓
━┗┓┏┛━┃┏┓┃┃┃┃┃━━┃┃━━┃┃┃┃┃┏┓┃┃┏┓┃━━━━┃┏┓┃┃┏┓┃┃┗┛┗┛┃┃┏┓┓┃┃━┃┏┓┃┗━┓┃━┃┏┓┃┃┏┓┃┃┏┛
━━┃┃━━┃┗┛┃┃┗┛┃━┏┛┗┓━┃┗┛┃┃┗┛┃┃┃━┫━━━━┃┗┛┃┃┗┛┃┗┓┏┓┏┛┃┃┃┃┃┗┓┃┗┛┃┃┗┛┗┓┃┗┛┃┃┃━┫┃┃━
━━┗┛━━┗━━┛┗━━┛━┗━━┛━┗━━┛┗━━┛┗━━┛━━━━┗━━┛┗━━┛━┗┛┗┛━┗┛┗┛┗━┛┗━━┛┗━━━┛┗━━┛┗━━┛┗┛━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""

def main():
    print(art_text)
    link = get_url()

    match download_format():
            case "1":
                download_mp3(link, download_directory())
            case "2":
                download_mp4(link, download_quality(), download_directory())

def get_url():
    link = input("\nEnter YouTube video/playlist URL: ").strip()
    if link.startswith("https://"):
        return link
    else:
        print("Invalid URL!")
        sleep(1)
        return get_url()

def download_format(): 
    print("\nChoose download format")
    print("(1) Download YouTube video in .mp3 format")
    print("(2) Download YouTube video in .webm format")
    choice =  input("\nEnter the number corresponding to your choice: ")
    if choice == "1" or choice == "2":
        return choice
    else:
        print("Invalid input!")
        sleep(1)
        return download_format()

def download_quality():
    print("\nChoose download quality")
    print("(1) 480p")
    print("(2) 720p")
    print("(3) 1080p")
    print("(4) 1440p")
    print("(5) 2160p")
    choice = input("\nEnter the number corresponding to your choice: ")

    match choice:
        case '1':
            return '480'
        case '2':
            return '720'
        case '3':
            return '1080'
        case '4':
            return '1440'
        case '5':
            return '2160'
        case _:
            print("Invalid input!")
            sleep(1)
            return download_quality()

def download_directory():
    default_path = "~/Videos/downloads"
    print(f"\nDefault download directory: {default_path}")

    print("Enter new download directory to override the default directory, otherwise skip")
    home = "~/"
    new_path = input(f"\nNew directory: {home}")
    if new_path == "":
        return default_path
    else:
        return home + new_path

def download_mp3(url, output_directory):
    command = f"yt-dlp -x --audio-format mp3 --embed-thumbnail --embed-metadata -o \"{output_directory}/%(title)s.%(ext)s\" -f 'bestaudio/best' {url}"
    execute_ytdlp_command(command)

def download_mp4(url, quality, output_directory):
    command = f"yt-dlp -o \"{output_directory}/%(title)s.%(ext)s\" -f 'bestvideo[height<={quality}]+bestaudio/best[height<={quality}]' {url}"
    execute_ytdlp_command(command)

def execute_ytdlp_command(command):
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")

if __name__ == "__main__":
    main()
