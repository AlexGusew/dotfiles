#!/usr/bin/env fish
# Invoked detached (via systemd-run --user, to fully escape the picker pane's
# process tree/cgroup) by pane-switcher.fish, after its floating pane has closed --
# doing the actual focus switch while that floating pane is still alive/focused
# does not work reliably (see pane-switcher.fish for details).

set session $argv[1]
set tab_id $argv[2]
set pane_id $argv[3]
set total_panes $argv[4]
set target "terminal_$pane_id"

sleep 0.3

zellij --session "$session" action go-to-tab-by-id "$tab_id"

for i in (seq 1 (math $total_panes + 1))
    set current (zellij --session "$session" action list-clients | tail -n +2 | awk '{print $2}')
    if test "$current" = "$target"
        break
    end
    zellij --session "$session" action focus-next-pane
end
