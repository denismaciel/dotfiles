# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

case `uname` in 
    Darwin)
        echo "On a Mac!!!"
        export ZSH="/Users/denis/.oh-my-zsh"

        alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
        alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
        alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
        alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1291571794"
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

# ZSH_THEME="trapd00r"
ZSH_THEME="avit"

alias getbib="bash ~/dotfiles/utils-scripts/getbib.sh"
alias VISUAL=nvim
alias vim=nvim
alias vi=vim

eval "$(scmpuff init -s)"

export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 100% --layout=reverse --border"
export FZF_DEFAULT_COMMAND='rg --files --ignore-file $HOME/.ripgrep_ignore'
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh


[ -s "/home/denis/.scm_breeze/scm_breeze.sh" ] && source "/home/denis/.scm_breeze/scm_breeze.sh"

# added by travis gem
[ -f /Users/denis/.travis/travis.sh ] && source /Users/denis/.travis/travis.sh
