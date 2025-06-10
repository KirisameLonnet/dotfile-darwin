#!/bin/bash

WIFI_SSID=$(networksetup -getairportnetwork en0 | cut -d ' ' -f 4-)

if [ "$WIFI_SSID" = "You are not associated with an AirPort network." ]; then
  sketchybar --set $NAME icon="󰖪" label="Disconnected" icon.color=$RED
else
  sketchybar --set $NAME icon="󰖩" label="$WIFI_SSID" icon.color=$GREEN
fi
