# Load version control information
autoload -Uz vcs_info
autoload -U colors && colors
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '[%b]'

[[ "$(uname)" = "Linux" ]] && xset r rate 200 80 && setxkbmap -layout us -option ctrl:nocaps

function check_syncthing() {
    running=`ps ax | grep -v grep | grep syncthing | wc -l`
    if [ $running -le 1 ]; then
        echo "🚨 syncthing is not running 🚨"
    fi
}

# ----------------------------------
# --------- Warnings ---------------
# ----------------------------------
git -C $HOME/dotfiles diff --exit-code > /dev/null || echo " === Commit the changes to your dotfiles, my man! ==="
check_syncthing

eval "$(starship init zsh)"

function togglep() {
    if [[ -f playground/p.go ]]; then 
        echo "==> gopher"
        mv playground/p.go playground/p.gopher
    elif [[ -f playground/p.gopher ]]; then
        echo "==> go"
        mv playground/p.gopher playground/p.go
    else
        echo "No gopher, no go"
        return 1
    fi
}
function open() {
    nohup xdg-open "$*" >> /dev/null &
}

function open-zathura() {
    nohup zathura "$*" >> /dev/null & exit
}

function pydeps() {
    pip install jedi-language-server ipdb ipython 
}

function clean-downloads() {
    mv ~/downloads/*.pdf ~/downloads/docs
    mv ~/downloads/*.epub ~/downloads/docs
    mv ~/downloads/*.mobi ~/downloads/docs
}

function addin() {
    printf "Addressed in $(git rev-parse HEAD)" | xclip -selection clipboard 
    git push origin HEAD
}

export R_LIBS_USER="$HOME/r/x86_64-pc-linux-gnu-library/4.1" # Custom location for R packages
export LC_ALL=en_US.UTF-8 # Fix problem when opening nvim
export VISUAL=nvim
export FZF_DEFAULT_OPTS="--height 100%"
export FZF_DEFAULT_COMMAND="rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does

alias act='source venv/bin/activate'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias lsa='ls -lah' 
alias R='R --no-save'
alias diary='nvim "$HOME/Sync/Notes/Current/Diary/$(date +'%Y-%m-%d').md"'
alias research='nvim -c "Research"'

alias pdf='open-zathura "$(fd "pdf|epub" | fzf)"'

setopt autocd               # .. is shortcut for cd .. 

# Basic auto/tab complete:
autoload bashcompinit && bashcompinit
autoload -Uz compinit 
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.
# Fuzzy completion!!!
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

complete -C '$HOME/.local/bin/aws_completer' aws

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
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

case `uname` in 
    Darwin)
        export HOMEBREW_AUTO_UPDATE_SECS=604800 # Autoupdate on weekly basis
        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsw="date +'Work_%Y-%W' | pbcopy; pbpaste"
        alias ls='ls -G'
    ;;
    Linux)
        alias tss="date +'%Y-%m-%d %H:%M:%S' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsd="date +'%Y-%m-%d' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsw="date +'Work_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias ls='ls -G --color=auto'
    ;;
esac

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh

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
setopt INTERACTIVE_COMMENTS       # Allow for comments
export PATH=$HOME/bin:$PATH
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/go/bin/:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/node/bin:$PATH"
export PATH="$HOME/venvs/default/bin:$PATH"
export GOPATH=$(go env GOPATH)

eval "$(scmpuff init -s)"
# eval "$(jump shell zsh)"

export PYTHONBREAKPOINT=ipdb.set_trace
[[ -d $HOME/applications/zsh-syntax-highlighting ]] && source $HOME/applications/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [ -e /home/denis/.nix-profile/etc/profile.d/nix.sh ]; then . /home/denis/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
if [ -e /home/denis/.recap.sh ]; then . /home/denis/.recap.sh; fi

# Fix annoying warning: 
#     - https://nixos.wiki/wiki/Locales
#     - https://www.reddit.com/r/NixOS/comments/oj4kmd/every_time_i_run_a_program_installed_with_nix_i/
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

eval "$(direnv hook zsh)"
