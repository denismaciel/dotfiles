export PS1='🐷  \u@\h:\[\e[33m\]\w\[\e[0m\]\$ '
export PATH=/usr/local/opt/python/libexec/bin:$PATH # Brew Python
export VISUAL="vim"
export EDITOR="vim"
export AIRFLOW_HOME=~/t-projects/bi-airflow/
export TPLOY_HOME=~/t-repo/
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

set -o vi

# tmuxinator autocompletion
# source ~/dotfiles/tmux/tmuxinator.zsh
# Aliases
alias ts='date +"%Y-%m-%d %H:%M:%S" | pbcopy'
alias tss='date +"%Y-%m-%d" | pbcopy'
alias tw='date +"%Y_%W" | pbcopy'
alias tww='date +"Work-%Y_%W" | pbcopy'
alias bww='date +"Bramondo-%Y_%W" | pbcopy'
alias mux=tmuxinator 
alias vimrc="vim ~/.vim/vimrc"
alias vimf="vim \$(fzf)"
alias rm=trash
. ~/dotfiles/tploy-alias.sh
alias l='ls -lah'
alias la='ls -lAhG'
alias ll='ls -lhG'
alias ls='ls -G'
alias lsa='ls -lah'

# scmpuff: numbered shortcuts for git
eval "$(scmpuff init -s)"
# fzf: History Search
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
