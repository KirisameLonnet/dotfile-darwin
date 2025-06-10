#!/bin/bash

CPU_USAGE=$(top -l 1 | grep -E "^CPU" | grep -Eo '[0-9]+\.[0-9]+%' | head -1 | sed 's/%//')

# Color based on CPU usage
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
  COLOR=$RED
elif (( $(echo "$CPU_USAGE > 50" | bc -l) )); then
  COLOR=$ORANGE
else
  COLOR=$GREEN
fi

sketchybar --set $NAME label="${CPU_USAGE}%" icon.color=$COLOR
