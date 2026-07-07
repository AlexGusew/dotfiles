#!/usr/bin/env fish

set cache_file ~/.cache/app-index.tsv

set selection (fzf \
    --delimiter="\t" \
    --with-nth=1 \
    --no-sort \
    --reverse \
    --margin=0,1 \
    --prompt="Apps: " \
    < $cache_file)

if test -n "$selection"
    set app_file (echo "$selection" | awk -F'\t' '{print $2}')
    hyprctl dispatch "hl.dsp.exec_cmd(\"dex '$app_file'\")"
end
