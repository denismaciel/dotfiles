# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

case `uname` in 
    Darwin)
        echo "On a Mac!!"
        export ZSH="/Users/denis/.oh-my-zsh"
        #
        # Aliases
        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
        alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1291571794"
    ;;
    Linux)
        echo "Hello, free software!"
        export ZSH="/home/denis/.oh-my-zsh"
        export PATH=$PATH:/home/denis/.local/bin
        alias tss="date +'%Y-%m-%d %H:%M:%S' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsd="date +'%Y-%m-%d' | xclip -selection clipboard && xclip -selection clipboard -o"
        alias tsv="date +'Vida_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o "
        alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1291571794"
    ;;
esac

# ZSH_THEME="trapd00r"
ZSH_THEME="avit"

alias getbib="bash ~/dotfiles/utils-scripts/getbib.sh"

export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 80% --layout=reverse --border"
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh


[ -s "/home/denis/.scm_breeze/scm_breeze.sh" ] && source "/home/denis/.scm_breeze/scm_breeze.sh"
