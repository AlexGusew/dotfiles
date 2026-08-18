#!/usr/bin/env fish

set self $ZELLIJ_PANE_ID

set output (zellij action list-panes --json | python3 -c "
import json, sys

self_id = '$self'
panes = json.load(sys.stdin)
print(len(panes))
for p in panes:
    if p['is_plugin']:
        continue
    if self_id and str(p['id']) == self_id:
        continue
    tag = ' (floating)' if p['is_floating'] else ''
    print(f\"{p['tab_id']}\t{p['id']}\t{p['tab_name']} > {p['title']}{tag}\")
")

set total_panes $output[1]
set data $output[2..-1]

if test (count $data) -eq 0
    exit 0
end

set selection (printf '%s\n' $data | fzf --delimiter="\t" --with-nth=3 --prompt="Focus pane: " --reverse)

if test -z "$selection"
    exit 0
end

set tab_id (echo "$selection" | awk -F'\t' '{print $1}')
set pane_id (echo "$selection" | awk -F'\t' '{print $2}')

# The actual focus switch has to happen AFTER this floating pane closes --
# while it's still open/focused, zellij's focus-changing actions don't reliably
# affect the underlying tiled panes. `setsid ... &; disown` is not enough to
# survive that close (zellij appears to tear down the whole process tree/cgroup
# on pane exit), so escape it properly via a transient systemd --user unit.
systemd-run --user --quiet --collect -- fish --no-config /home/alex/.config/zellij/scripts/pane-switch-apply.fish "$ZELLIJ_SESSION_NAME" "$tab_id" "$pane_id" "$total_panes"
