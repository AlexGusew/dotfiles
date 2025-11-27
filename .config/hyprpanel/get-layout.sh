#!/bin/bash

hyprctl devices | awk '
/Keyboard at/ { in_kb = 1; main_kb = 0 }   # new keyboard block, reset main_kb
/^\s*$/ { in_kb = 0; main_kb = 0 }         # empty line resets flags
in_kb {
    if ($1 == "main:" && $2 == "yes") main_kb = 1
    if (main_kb && $1 == "active" && $2 == "keymap:") {
        if ($3 ~ /Russian/) print "ru"; else print "en"
        exit
    }
}
'
