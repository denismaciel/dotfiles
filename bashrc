export PS1='\u@\h:\[\e[33m\]\w\[\e[0m\]\$ '
export PATH=/home/denis/.local/bin:$PATH
export VISUAL="vim"
export EDITOR="vim"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# set unlimited history
HISTSIZE= 
HISTFILESIZE=
# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend
set -o vi

# Aliases
alias ts='date +"%Y-%m-%d %H:%M:%S" | pbcopy'
alias tss='date +"%Y-%m-%d" | pbcopy'
alias tw='date +"%Y_%W" | pbcopy'
alias tww='date +"Work-%Y_%W" | pbcopy'
alias bww='date +"Bramondo-%Y_%W" | pbcopy'
alias mux=tmuxinator 
alias vimrc="vim ~/.vim/vimrc"
alias vimf="vim \$(fzf)"
alias t-repo="cd ~/t-repo"
alias airflow="cd ~/t-repo/bi-airflow/"
alias analysis="cd ~/t-repo/bi-analysis"
[ "$(uname)" == "Linux" ] && echo "Hello Free Software" || alias rm=trash
alias l='ls -lah'
alias la='ls -lAhG'
alias ll='ls -lhG'
alias ls='ls -G'
alias lsa='ls -lah'

# scmpuff: numbered shortcuts for git
eval "$(scmpuff init -s)"
export FZF_DEFAULT_COMMAND="fd --type file --color=always --follow --hidden --exclude .git"
export FZF_DEFAULT_OPTS="--ansi"
# fzf: History Search
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
source ~/dotfiles/alias.sh
