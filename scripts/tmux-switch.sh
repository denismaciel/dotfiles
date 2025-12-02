#! /usr/bin/env bash

CURRENT_SESSION="$(tmux display-message -p '#{session_name}')"
CURRENT_WINDOW="$(tmux display-message -p '#{window_id}')"

LIST_DATA="#{session_name}:#{window_id}:#{pane_id}:#{session_name} [#{window_name}]"
FZF_COMMAND=(fzf-tmux -p --delimiter=: --with-nth=4 --ansi --color=hl:2)
HIGHLIGHT_ON=$'\033[1;33m'
HIGHLIGHT_OFF=$'\033[0m'
DEBUG_LOG="${TMPDIR:-/tmp}/tmux-switch-debug.log"

log() {
  printf '%s\n' "$*" >>"$DEBUG_LOG"
}

# Fall back to plain fzf if fzf-tmux is missing
if ! command -v fzf-tmux >/dev/null 2>&1; then
  FZF_COMMAND=(fzf --delimiter=: --with-nth=4 --ansi --color=hl:2)
fi

RAW_LIST="$(tmux list-windows -a -F "$LIST_DATA" 2>/dev/null)"
{
  printf '\n[%s] current session=%s window=%s\n' "$(date -Is)" "$CURRENT_SESSION" "$CURRENT_WINDOW"
  printf 'fzf cmd: %s\n' "${FZF_COMMAND[*]}"
  printf 'raw list:\n%s\n' "$RAW_LIST"
} >>"$DEBUG_LOG"

if [ -z "$RAW_LIST" ]; then
  tmux display-message "tmux-switch: no windows found (see $DEBUG_LOG)"
  exit 0
fi

# Highlight the current window so it stands out in fzf
HIGHLIGHTED="$(printf '%s\n' "$RAW_LIST" |
  awk -v cur_s="$CURRENT_SESSION" -v cur_w="$CURRENT_WINDOW" -v on="$HIGHLIGHT_ON" -v off="$HIGHLIGHT_OFF" 'BEGIN{FS=OFS=":"} {if ($1==cur_s && $2==cur_w) $4=on "> " $4 off; print}')"
{
  printf 'highlighted list:\n%s\n' "$HIGHLIGHTED"
} >>"$DEBUG_LOG"

LINE=$(printf '%s\n' "$HIGHLIGHTED" | "${FZF_COMMAND[@]}") || exit 0
{
  printf 'selected line:\n%s\n' "$LINE"
} >>"$DEBUG_LOG"

IFS=: read -r session window pane _ <<< "$LINE"
{
  printf 'parsed -> session=%s window=%s pane=%s\n' "$session" "$window" "$pane"
} >>"$DEBUG_LOG"

tmux select-pane -t "$pane" && tmux select-window -t "$window" && tmux switch-client -t "$session"
