
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


eval "$(rbenv init -)"

[ -s "/Users/account-vorlage-dev/.scm_breeze/scm_breeze.sh" ] && source "/Users/account-vorlage-dev/.scm_breeze/scm_breeze.sh"
