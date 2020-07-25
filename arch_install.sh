
# Alacritty
sudo pacman -Sy alacritty

# Git
sudo pacman -Sy git
git config --global user.name "Denis Maciel"
git config --global user.email "denispmaciel@gmail.com"

# Python
curl https://pyenv.run | bash

export PATH=$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"

pyenv install 3.8.4
pyenv global 3.8.4

# FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Ripgrep
sudo pacman -S ripgrep

# SCMPUFF
wget https://github.com/mroth/scmpuff/releases/download/v0.3.0/scmpuff_0.3.0_linux_x64.tar.gz
tar -xzvf scmpuff_0.3.0_linux_x64.tar.gz
mv scmpuff ./bin/

sudo pacman -S tmux
ln dotfiles/tmux/tmux.conf .tmux.conf -s
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Node
sudo pacman -S nodejs

## SF Mono
git clone https://github.com/ZulwiyozaPutra/SF-Mono-Font.git
mkdir -p .local/share/fonts
cp SF-Mono-Font/*.otf ~/.local/share/fonts/
fc-cache
