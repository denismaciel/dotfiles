source ~/.profile

# THE FOLLOWING WAS SLOWING DOWN THE STARTUP OF THE TERMINAL =========
# export NVM_DIR="$HOME/.nvm"
#   . "/usr/local/opt/nvm/nvm.sh"
# ========================================================================
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/miniconda3/bin":$PATH
PATH="$PATH:$HOME/miniconda3/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export AIRFLOW_HOME=~/t-projects/bi-airflow/
export ZSH=~/.oh-my-zsh # Path to your oh-my-zsh installation.

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Theme
ZSH_THEME="avit"

# Plugins
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases
alias oc="sh ~/r_scripts/open_urls.sh"
alias ts='date +"%Y-%m-%d %H:%M:%S" | pbcopy'
alias tss='date +"%Y-%m-%d" | pbcopy'
alias infra="cd ~/t-repo/tploy-infrastructure"
alias dia='touch ~/Google\ Drive/nVALT-Notes/$(date +"%Y-%m-%d").md && mvim ~/Google\ Drive/nVALT-Notes/$(date +"%Y-%m-%d").md'
alias sv='Rscript ~/r_scripts/to-read.R $("pbpaste")'
alias td='Rscript r_scripts/todo-gsheets/add-todo.R'
. ~/dotfiles/tploy-alias.sh
. ~/dotfiles/tploy-scripts.sh

[ -s "/Users/account-vorlage-dev/.scm_breeze/scm_breeze.sh" ] && source "/Users/account-vorlage-dev/.scm_breeze/scm_breeze.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
