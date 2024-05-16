#! /usr/bin/env bash

tmux select-pane "$1"

if tmux list-panes -F "#{pane_active} #{pane_current_command}" | grep "^1" | grep -q "nvim"; then
    tmux resize-pane -Z
fi
