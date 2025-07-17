#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures"

RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)

[ -n "$RANDOM_WALLPAPER" ] && feh --bg-fill "$RANDOM_WALLPAPER"

