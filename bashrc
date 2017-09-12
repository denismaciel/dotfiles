
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


alias elk-burns='ssh -p 2124 -i ~/.ssh/tploy -N -f -o "ExitOnForwardFailure yes" -L 5612:0.0.0.0:5601 denis@workz-mitch-agent.westeurope.cloudapp.azure.com && open http://localhost:5612'

