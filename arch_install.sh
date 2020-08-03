# Alacritty
sudo pacman -Sy alacritty wget

# Git
sudo pacman -Sy git
git config --global user.name "Denis Maciel"
git config --global user.email "denispmaciel@gmail.com"
ln -s dotfiles/gitignore_global ./.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

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

# Vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

sudo pacman -S xsel
sudo yaourt -S google-chrome

sudo pacman -S openssh openssh-runit
sudo ln -s /etc/runit/sv/sshd /run/runit/service
eval $(ssh-agent)
chmod 600 ~/.ssh/id_rsa

# Autojump
sudo pacman -S go
go get github.com/gsamokovarov/jump

## Emoji support

sudo pacman -S noto-fonts-emoji

# Add to ~/.config/fontconfig/fonts.conf

# <?xml version="1.0"?>
# <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
# <fontconfig>
#  <alias>
#    <family>sans-serif</family>
#    <prefer>
#      <family>Noto Sans</family>
#      <family>Noto Color Emoji</family>
#      <family>Noto Emoji</family>
#      <family>DejaVu Sans</family>
#    </prefer> 
#  </alias>

#  <alias>
#    <family>serif</family>
#    <prefer>
#      <family>Noto Serif</family>
#      <family>Noto Color Emoji</family>
#      <family>Noto Emoji</family>
#      <family>DejaVu Serif</family>
#    </prefer>
#  </alias>

#  <alias>
#   <family>monospace</family>
#   <prefer>
#     <family>Noto Mono</family>
#     <family>Noto Color Emoji</family>
#     <family>Noto Emoji</family>
#    </prefer>
#  </alias>
# </fontconfig>

## AY

# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
gcloud init
gcloud auth activate-service-account --key-file=pen-cred.json
