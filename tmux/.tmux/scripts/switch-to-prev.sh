#!/bin/sh
# Switch to the previously tracked window/session
target=$(tmux show-environment -g TMUX_PREV 2>/dev/null | cut -d= -f2-)
if [ -n "$target" ]; then
    tmux switch-client -t "$target"
fi
