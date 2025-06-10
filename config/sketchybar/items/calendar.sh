#!/bin/bash

sketchybar --add item calendar right \
           --set calendar icon="" \
                         icon.color=$BLUE \
                         label.color=$WHITE \
                         script="$PLUGIN_DIR/calendar.sh" \
                         update_freq=30
