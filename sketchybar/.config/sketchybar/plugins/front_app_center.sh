#!/usr/bin/env sh

if [ "$SENDER" = "front_app_switched" ]; then
  # $INFO contains the new app name
  sketchybar --set "$NAME" label="$INFO"
fi
