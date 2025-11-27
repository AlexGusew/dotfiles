
#!/bin/bash

# Check if wofi is running
if pgrep -x rofi >/dev/null; then
    # If running, kill it to close
    pkill -x rofi
else
    # If not running, launch wofi drun menu
    rofi -show drun &
fi
