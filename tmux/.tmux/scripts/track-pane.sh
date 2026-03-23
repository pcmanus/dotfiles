#!/bin/sh
# Track previous window/session for cross-session last-window switching
prev=$(tmux show-environment -g TMUX_CURRENT 2>/dev/null | cut -d= -f2-)
curr="$1:$2"
if [ "$prev" != "$curr" ] && [ -n "$prev" ]; then
    tmux set-environment -g TMUX_PREV "$prev"
fi
tmux set-environment -g TMUX_CURRENT "$curr"
