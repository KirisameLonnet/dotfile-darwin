#!/bin/bash

if [ "$SENDER" = "media_change" ]; then
  if command -v nowplaying-cli &> /dev/null; then
    STATE="$(echo "$INFO" | jq -r '.state')"
    if [ "$STATE" = "playing" ]; then
      MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
      sketchybar --set $NAME label="$MEDIA" drawing=on
    else
      sketchybar --set $NAME drawing=off
    fi
  else
    sketchybar --set $NAME drawing=off
  fi
fi
