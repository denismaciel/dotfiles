# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="/Users/denis/.oh-my-zsh"

ZSH_THEME="trapd00r"

export FZF_DEFAULT_OPTS="--preview 'head -100 {}' --height 80% --layout=reverse --border"
source $ZSH/oh-my-zsh.sh

# export FZF_DEFAULT_COMMAND='fd --type f'
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND'"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
