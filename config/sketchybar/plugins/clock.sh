#!/bin/bash

# Clock plugin for SketchyBar
# Updates the time display

DATE=$(date '+%H:%M')
WEEKDAY=$(date '+%a')
DAY=$(date '+%d')
MONTH=$(date '+%b')

sketchybar --set $NAME label="$WEEKDAY $DAY $MONTH $DATE"
