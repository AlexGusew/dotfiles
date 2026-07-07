#!/usr/bin/fish

# Read pinned items (2>/dev/null prevents errors if the file doesn't exist yet)
set pinned (cat ~/.config/cliphist/pinned 2>/dev/null)

# 1. Get cliphist list and combine it with pinned items
set clip_list (cliphist list)
set all_list $clip_list $pinned

# Print the combined list line-by-line and pipe it into fzf
set result (string join \n $all_list | fzf \
    --no-sort \
    --reverse \
    --margin=0,1 \
    --prompt="󰅍 " \
    --header="Enter: Copy | Alt-D: Delete" \
    --preview="echo {} | cliphist decode 2>/dev/null" \
    --preview-window="down:30%:wrap" \
    --bind "alt-d:execute-silent(echo {} | cliphist delete)+reload(cat ~/.config/cliphist/pinned 2>/dev/null; cliphist list)")

# 2. If a choice was made, decode it and copy it
if test -n "$result"
    echo -n "$result" | { cliphist decode 2>/dev/null || echo -n "$result"; } | wl-copy
end
