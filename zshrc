# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH=$HOME/bin:$PATH

export PS1="
🍪 %~
$ "
export LC_ALL=en_US.UTF-8 # Fix problem when opening nvim
export HOMEBREW_AUTO_UPDATE_SECS=604800 # Autoupdate on weekly basis
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'
alias lsa='ls -lah' 


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

# # Change cursor shape for different vi modes.
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] ||
#      [[ $1 = 'block' ]]; then
#     echo -ne '\e[1 q'
#   elif [[ ${KEYMAP} == main ]] ||
#        [[ ${KEYMAP} == viins ]] ||
#        [[ ${KEYMAP} = '' ]] ||
#        [[ $1 = 'beam' ]]; then
#     echo -ne '\e[5 q'
#   fi
# }
# zle -N zle-keymap-select

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
        export ZSH="$HOME/.oh-my-zsh"
        # export PATH=$HOME/Library/Python/3.7/bin:$PATH # User-installed Python executables

        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
        alias tsw="date +'Work_%Y-%W' | pbcopy; pbpaste"
        alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1213603850"
        alias mdb="open -a MacVim ~/Dropbox/nVALT-Notes/Current/Master_Thesis.txt"
        alias pydss=$HOME/pythings/py-installation/bin/python3.6


    ;;
    Linux)
        # export ZSH="/home/denis/.oh-my-zsh"
        export PATH=$PATH:/home/denis/.local/bin

        alias tss="date +'%Y-%m-%d %H:%M:%S' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsd="date +'%Y-%m-%d' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsv="date +'Vida_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o "
    ;;
esac

eval "$(scmpuff init -s)"

export VISUAL=vim
export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 100% --layout=reverse --border"
export FZF_DEFAULT_COMMAND="rg --files --ignore-file ~/.ripgrep_ignore"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=($HOME/.zsh/zsh-completions/src $fpath)

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Dont record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Dont record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Dont write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Dont execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

eval "$(jump shell)"
eval "$(pyenv init -)"
export PATH="/usr/local/opt/node@10/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
