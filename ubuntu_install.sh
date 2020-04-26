apt update --quiet
sudo apt install -y -q vim sudo 
 

sudo apt update -qq -y && apt upgrade -qq -y
sudo apt-get install -qq vim sudo

sudo apt install -y -qq curl make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev git > /dev/null

git config --global user.name "Denis Maciel"
git config --global user.email "denispmaciel@gmail.com"

# Python
curl https://pyenv.run | bash

export PATH=$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"

pyenv install 3.8.1
pyenv global 3.8.1

# FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Neovim
cd $HOME
git clone https://github.com/denismaciel/dotfiles

mkdir -p .config/nvim
ln $HOME/dotfiles/init.vim $HOME/.config/nvim/init.vim -s
pip install -Uq pynvim
sudo apt install -yq neovim > /dev/null

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
sudo apt-get install -y ripgrep

# Jump
wget https://github.com/gsamokovarov/jump/releases/download/v0.30.1/jump_0.30.1_amd64.deb && sudo dpkg -i jump_0.30.1_amd64.deb

# SCMPUFF
wget https://github.com/mroth/scmpuff/releases/download/v0.3.0/scmpuff_0.3.0_linux_x64.tar.gz
tar -xzvf scmpuff_0.3.0_linux_x64.tar.gz
mkdir bin
mv scmpuff ./bin/

# ZSH
sudo apt install -y zsh zsh-syntax-highlighting
sudo chsh -s /bin/zsh
ln $HOME/dotfiles/zshrc $HOME/.zshrc -s

# Tmux
sudo apt install -y tmux
ln dotfiles/tmux/tmux.conf .tmux.conf -s
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Docker
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
sudo docker run hello-world

# NodeJs
sudo apt-get install -y nodejs npm

# Alacritty
sudo add-apt-repository ppa:mmstick76/alacritty && sudo apt-get alacritty
mkdir -p $HOME/.config/alacritty
ln $HOME/dotfiles/alacritty.yml $HOME/.config/alacritty/alacritty.yml -s

## SF Mono
git clone https://github.com/ZulwiyozaPutra/SF-Mono-Font.git
mkdir .local/share/fonts
cp SF-Mono-Font/*.otf ~/.local/share/fonts/
