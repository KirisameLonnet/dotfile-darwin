#!/bin/bash

sketchybar --add item front_app left \
           --set front_app background.color=$ACCENT_COLOR \
                          background.corner_radius=6 \
                          background.height=24 \
                          icon.color=$BLACK \
                          icon.font="sketchybar-app-font:Regular:16.0" \
                          label.color=$BLACK \
                          label.font="JetBrainsMono Nerd Font:Bold:14.0" \
                          script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
