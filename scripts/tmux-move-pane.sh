#! /usr/bin/env bash

set -euo pipefail

LOG_FILE="${TMPDIR:-/tmp}/tmux-move-pane.log"
LIST_DUMP="${TMPDIR:-/tmp}/tmux-move-pane-windows.txt"
log() { printf '[%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S')" "$*" >>"$LOG_FILE"; }

if ! tmux info &>/dev/null; then
  log "Not running inside tmux; aborting."
  exit 0
fi

CURRENT_PANE="${TMUX_PANE:-$(tmux display -p '#{pane_id}')}"
CURRENT_WINDOW="$(tmux display -p '#{window_id}')"

LIST_FORMAT="#{session_name}\t#{window_id}\t#{window_index}\t#{window_name}"

FZF_COLORS="bg+:#1e1e2e,fg:#cdd6f4,hl:#89dceb,hl+:#89dceb,pointer:#f38ba8,marker:#f38ba8"

if command -v fzf-tmux >/dev/null 2>&1; then
  FZF_COMMAND=(fzf-tmux -p --delimiter=$'\t' --with-nth=3,4 --prompt 'Send pane to > ' --color=hl:2)
  log "Using fzf-tmux for selection."
else
  FZF_COMMAND=(fzf --height=80% --border --delimiter=$'\t' --with-nth=3,4 --prompt 'Send pane to > ' --color=hl:2)
  log "fzf-tmux not found; falling back to fzf."
fi

FZF_COMMAND+=("--ansi" "--color=$FZF_COLORS")

WINDOWS="$(tmux list-windows -a -F "$LIST_FORMAT")"
printf '%s\n' "$WINDOWS" >"$LIST_DUMP"
log "Captured window list to $LIST_DUMP"

CHOICE=$(printf '%s\n' "$WINDOWS" | awk -F'\t' -v cw="$CURRENT_WINDOW" '$2 != cw' | "${FZF_COMMAND[@]}") || {
  log "Selection cancelled."
  exit 0
}

if [ -z "$CHOICE" ]; then
  log "No choice returned."
  exit 0
fi

IFS=$'\t' read -r target_session target_window_id _target_index _target_name <<<"$CHOICE"

log "Moving pane $CURRENT_PANE to window $target_window_id in session $target_session"
if tmux join-pane -s "$CURRENT_PANE" -t "$target_window_id"; then
  tmux select-window -t "$target_window_id"
  tmux switch-client -t "$target_session"
  log "Pane moved successfully."
else
  log "tmux join-pane failed."
  tmux display-message "Failed to move pane. See $LOG_FILE"
fi
