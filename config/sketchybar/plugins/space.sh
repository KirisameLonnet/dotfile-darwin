#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  yabai -m space --focus $SID
fi

source "$CONFIG_DIR/colors/catppuccin.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set $NAME background.drawing=on \
                   background.color=$ACCENT_COLOR \
                   label.color=$BLACK \
                   icon.color=$BLACK
else
  sketchybar --set $NAME background.drawing=off \
                   label.color=$WHITE \
                   icon.color=$WHITE
fi
