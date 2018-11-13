# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH 
export PATH=/usr/local/opt/python/libexec/bin:$PATH # Brew Python

export VISUAL="vim"
export EDITOR="vim"
export AIRFLOW_HOME=~/t-projects/bi-airflow/
export ZSH=~/.oh-my-zsh # Path to your oh-my-zsh installation.
export TPLOY_HOME=~/t-repo/

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Theme
ZSH_THEME="avit"

# Plugins
plugins=(git zsh-syntax-highlighting docker vi-mode fzf-zsh)

source $ZSH/oh-my-zsh.sh

# tmuxinator autocompletion
source ~/dotfiles/tmux/tmuxinator.zsh

# Aliases
alias ts='date +"%Y-%m-%d %H:%M:%S" | pbcopy'
alias tss='date +"%Y-%m-%d" | pbcopy'
alias tw='date +"%Y_%W" | pbcopy'
alias tww='date +"Work-%Y_%W" | pbcopy'
alias bww='date +"Bramondo-%Y_%W" | pbcopy'
alias mux=tmuxinator 
alias vimrc="vim ~/.vim/vimrc"
alias zshrc="vim ~/.zshrc"
alias vimf="vim \$(fzf)"
alias rm=trash
. ~/dotfiles/tploy-alias.sh

# scmpuff: numbered shortcuts for git
eval "$(scmpuff init -s)"

## Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
 #export PATH="$PATH:$HOME/.rvm/bin"
#[ -s "/Users/account-vorlage-dev/.scm_breeze/scm_breeze.sh" ] && source "/Users/account-vorlage-dev/.scm_breeze/scm_breeze.sh"
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

