#!/bin/bash

if [ "$SENDER" = "space_windows_change" ]; then
  source "$CONFIG_DIR/colors/catppuccin.sh"
  
  apps=$(yabai -m query --windows --space | jq -r '.[].app')
  
  icon_strip=""
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "${app}")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --set space_separator label="${icon_strip}"
fi
