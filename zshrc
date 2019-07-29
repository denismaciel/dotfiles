# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

PS1="
🍪 %~
$ "

bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
export PS1
# For whatever reason, this variable is set when I am in tmux
# This prevents venv & pyenv from working together
[ -z $__PYVENV_LAUNCHER__ ] || unset __PYVENV_LAUNCHER__

case `uname` in 
    Darwin)
        export ZSH="$HOME/.oh-my-zsh"
        export PATH=$HOME/Library/Python/3.7/bin:$PATH # User-installed Python executables

        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
        alias tsw="date +'Work_%Y-%W' | pbcopy; pbpaste"
        alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1213603850"
        alias mdb="open -a MacVim ~/Dropbox/nVALT-Notes/Current/Master_Thesis.txt"

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
# source $ZSH/oh-my-zsh.sh
export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh

# [ -s "/home/denis/.scm_breeze/scm_breeze.sh" ] && source "/home/denis/.scm_breeze/scm_breeze.sh"

# added by travis gem
[ -f /Users/denis/.travis/travis.sh ] && source /Users/denis/.travis/travis.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(pyenv init -)"
