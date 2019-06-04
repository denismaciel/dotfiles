# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

case `uname` in 
    Darwin)
        echo "macOS"

        export ZSH="$HOME/.oh-my-zsh"
        # User-installed Python executables
        export PATH=$HOME/Library/Python/3.7/bin:$PATH

        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
        alias tsw="date +'Work_%Y-%W' | pbcopy; pbpaste"
        alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1213603850"
        alias mdb="open -a MacVim ~/Dropbox/nVALT-Notes/Current/Master_Thesis.txt"

    ;;
    Linux)
        echo "Hello, free software!"
        export ZSH="/home/denis/.oh-my-zsh"
        export PATH=$PATH:/home/denis/.local/bin

        alias tss="date +'%Y-%m-%d %H:%M:%S' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsd="date +'%Y-%m-%d' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsv="date +'Vida_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o "
    ;;
esac

export PAPERS="$HOME/Dropbox/master-thesis/literature"
export THESIS="$HOME/Dev/master-thesis"

ZSH_THEME="avit"

alias getbib="bash ~/dotfiles/utils-scripts/getbib.sh"
alias vim=nvim
alias vi=vim

eval "$(scmpuff init -s)"

export VISUAL=nvim
export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 100% --layout=reverse --border"
export FZF_DEFAULT_COMMAND="rg --files --ignore-file ~/.ripgrep_ignore"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
source $ZSH/oh-my-zsh.sh
export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh

[ -s "/home/denis/.scm_breeze/scm_breeze.sh" ] && source "/home/denis/.scm_breeze/scm_breeze.sh"

# added by travis gem
[ -f /Users/denis/.travis/travis.sh ] && source /Users/denis/.travis/travis.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
