#!/bin/bash

# Icon mapping for applications
case "$1" in
  "Finder") echo "󰀶";;
  "Safari") echo "";;
  "Chrome" | "Google Chrome") echo "";;
  "Firefox") echo "";;
  "Arc") echo "";;
  "Code" | "Visual Studio Code") echo "󰨞";;
  "Terminal") echo "";;
  "Alacritty") echo "";;
  "iTerm2") echo "";;
  "Activity Monitor") echo "";;
  "System Preferences" | "System Settings") echo "";;
  "Raycast") echo "󰯴";;
  "Music") echo "󰎈";;
  "Spotify") echo "";;
  "Discord") echo "󰙯";;
  "Slack") echo "󰒱";;
  "WhatsApp") echo "󰖣";;
  "Telegram") echo "";;
  "Messages") echo "󰍦";;
  "Mail") echo "󰇮";;
  "Calendar") echo "";;
  "Notes") echo "󱞎";;
  "Notion") echo "󰈄";;
  "Obsidian") echo "󰞋";;
  "Figma") echo "";;
  "Sketch") echo "";;
  "Adobe Photoshop 2024") echo "";;
  "Illustrator") echo "";;
  "Docker Desktop") echo "";;
  "Postman") echo "";;
  "TablePlus") echo "";;
  *) echo "";;
esac
