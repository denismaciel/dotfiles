sudo apt update --quiet &&
  sudo apt install -y -q vim sudo 
 
sudo apt update -qq -y && 
  sudo apt upgrade -qq -y &&
  sudo apt-get install -qq vim sudo

sudo apt install -y -qq curl make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev git


git config --global user.name "Denis Maciel"
git config --global user.email "denispmaciel@gmail.com"


# ZSH
sudo apt install -y zsh zsh-syntax-highlighting
sudo chsh -s /bin/zsh

# Acitvate ZSH === !
zsh

# Syncthing
sudo apt install -y curl apt-transport-https &&
    curl -s https://syncthing.net/release-key.txt | sudo apt-key add - &&
    sudo su -c "echo 'deb https://apt.syncthing.net/ syncthing release' > /etc/apt/sources.list.d/syncthing.list" &&
    sudo apt-get update &&
    sudo apt-get install -y syncthing
    
# KeePassXC
sudo add-apt-repository -y ppa:phoerious/keepassxc &&
    sudo apt-get update &&
    sudo apt-get install -y keepassxc


curl -L https://nixos.org/nix/install | sh && 
  source /home/denis/.nix-profile/etc/profile.d/nix.sh

nix-env -i neovim tmux ripgrep
nix-env -i fd

nix-env -i stow
stow nvim
stow python
stow zsh
stow tmux
stow tools


# Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Nvim Plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim -c 'PlugInstall'

# Jump
wget https://github.com/gsamokovarov/jump/releases/download/v0.30.1/jump_0.30.1_amd64.deb && sudo dpkg -i jump_0.30.1_amd64.deb

# SCMPUFF
RAND_FOLDER=/tmp/folder-$RANDOM
mkdir $RAND_FOLDER
cd $RAND_FOLDER
wget https://github.com/mroth/scmpuff/releases/download/v0.3.0/scmpuff_0.3.0_linux_x64.tar.gz
tar -xzvf scmpuff_0.3.0_linux_x64.tar.gz
[ -d $HOME/bin ] || mkdir $HOME/bin
mv scmpuff $HOME/bin/
cd

# Docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" &&
    sudo apt-get update &&
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io &&
    sudo usermod -aG docker $USER &&
    sudo docker run hello-world

# NodeJs
sudo apt-get install -y nodejs npm

# Alacritty
sudo add-apt-repository -y ppa:mmstick76/alacritty &&
    sudo apt-get install -y alacritty

mkdir -p ~/.local/share/fonts
RAND_FOLDER=/tmp/folder-$RANDOM
mkdir $RAND_FOLDER
cd $RAND_FOLDER
wget "https://github.com/microsoft/cascadia-code/releases/download/v2106.17/CascadiaCode-2106.17.zip"
unzip CascadiaCode-2106.17.zip
cp $(find . -type f -name "*.otf")  ~/.local/share/fonts
cd
