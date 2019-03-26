# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="/Users/denis/.oh-my-zsh"

ZSH_THEME="trapd00r"

# Aliases
alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
alias tsb="date +'Bramondo_%Y-%W' | pbcopy; pbpaste"
alias tsv="date +'Vida_%Y-%W' | pbcopy; pbpaste"
alias habit="open https://docs.google.com/spreadsheets/d/1nNAWoPD93CSLRWcaj2k4Rdha7QfOXqEIcSemGgNQ-08/edit#gid=1291571794"

export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 80% --layout=reverse --border"
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
