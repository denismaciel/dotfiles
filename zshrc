# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '[%b]'

export insert_mode="
🐣 %~   
$ "

export PS1=$insert_mode

function zle-line-init zle-keymap-select {
    if [ -z ${VIRTUAL_ENV+x} ]
    then 
        VENV=""
    else
        full_repo_path=$(dirname $VIRTUAL_ENV)
        repo_name=${full_repo_path##*/}
        VENV="($repo_name) "
    fi

    insert_mode="
🐣 ${VENV}%~ ${vcs_info_msg_0_}
$ "
    visual_mode="
🥚 ${VENV}%~ ${vcs_info_msg_0_}
$ "    
    PS1="${${KEYMAP/vicmd/$visual_mode}/(main|viins)/$insert_mode}"
    zle reset-prompt
}
zle -N zle-line-init 
zle -N zle-keymap-select

export LC_ALL=en_US.UTF-8 # Fix problem when opening nvim
export HOMEBREW_AUTO_UPDATE_SECS=604800 # Autoupdate on weekly basis
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G --color=auto'
alias lsa='ls -lah' 
alias R='R --no-save'
alias diary='nvim "$HOME/Dropbox/Notes/Diary/$(date +'%Y-%m-%d').md"'
alias renamewin='tmux rename-window -t $(tmux display-message -p "#{window_index}") ${PWD##*/}'
alias v=nvim
alias p=ptipython

alias dl="bash ~/.screenlayout/laptop.sh"
alias dd="bash ~/.screenlayout/desktop.sh"
alias db="bash ~/.screenlayout/both.sh"
alias dq="bash ~/.screenlayout/quartinho-desktop.sh"

alias q="nvim ~/Code/pen-platform/dump/queries/default.sql"
setopt autocd               # .. is shortcut for cd .. (etc)

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char


# bindkey -e #Emacs keybinding
bindkey "^E" backward-word
bindkey "^F" forward-word
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# # Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# For whatever reason, this variable is set when I am in tmux
# This prevents venv & pyenv from working together
[ -z $__PYVENV_LAUNCHER__ ] || unset __PYVENV_LAUNCHER__

case `uname` in 
    Darwin)
        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
        alias tsw="date +'Work_%Y-%W' | pbcopy; pbpaste"
    ;;
    Linux)
        export PATH=$PATH:$HOME/.local/bin
        alias tss="date +'%Y-%m-%d %H:%M:%S' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsd="date +'%Y-%m-%d' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsv="date +'Vida_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsw="date +'Work_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o"
    ;;
esac

eval "$(scmpuff init -s)"

export VISUAL=nvim
# export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 100% --layout=reverse --border"
export FZF_DEFAULT_OPTS="--height 100% --layout=reverse"
export FZF_DEFAULT_COMMAND="rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh

# Fuzzy completion !!!
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

fpath=($HOME/.zsh/zsh-completions/src $fpath)

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_SAVE_NO_DUPS         # Dont write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Dont execute immediately upon history expansion.

export PATH=$HOME/.pyenv/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH="/usr/local/opt/node@10/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval "$(jump shell)"
eval "$(pyenv init -)"

[[ -f $HOME/aboutyou.sh ]] && source $HOME/aboutyou.sh
[[ -d $HOME/zsh-syntax-highlighting ]] && source $HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/denis/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/denis/Downloads/google-cloud-sdk/path.zsh.inc'; fi
