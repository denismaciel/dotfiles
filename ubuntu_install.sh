sudo apt update --quiet &&
  sudo apt install -y -q vim sudo 
 
sudo apt update -qq -y && 
  sudo apt upgrade -qq -y

sudo apt install -y -qq curl make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev git


git config --global user.name "Denis Maciel"
git config --global user.email "denispmaciel@gmail.com"


mkdir ~/applications
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/applications/zsh-syntax-highlighting
# ZSH
sudo apt install -y zsh zsh-syntax-highlighting
sudo chsh --shell $(which zsh) $USER

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
stow node

# Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm



# Neovim from source
cd ~/applications
git clone git@github.com:neovim/neovim
cd neovim
sudo apt-get install ninja-build gettext libtool \
    libtool-bin autoconf automake cmake g++ pkg-config unzip curl
make CMAKE_BUILD_TYPE=Release
sudo make install
cd

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
wget https://github.com/mroth/scmpuff/releases/download/v0.5.0/scmpuff_0.5.0_linux_x64.tar.gz
tar -xzvf scmpuff_0.5.0_linux_x64.tar.gz
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

# Python
sudo add-apt-repository -y ppa:deadsnakes/ppa && \
    sudo apt-get update && \
    sudo apt-get install -y python3.9-dev python3.9-distutils python3.9-venv

## Bootstrap virtualenv
sudo apt-get install -y curl &&
    curl --location --output virtualenv.pyz https://bootstrap.pypa.io/virtualenv/3.9/virtualenv.pyz && \
    python3.9 virtualenv.pyz ~/venvs/default

curl --location --output get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python3.9 get-pip.py

# Go
GO_VERSION=1.18
curl -L --output go$GO_VERSION.linux-amd64.tar.gz https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz && \
    sudo \rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

## Install Lsp
GO111MODULE=on go install golang.org/x/tools/gopls@latest

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

# RAND_FOLDER=/tmp/folder-$RANDOM
# mkdir $RAND_FOLDER
# cd $RAND_FOLDER
# wget "https://github.com/i-tu/Hasklig/releases/download/v1.2/Hasklig-1.2.zip"
# unzip Hasklig-1.2.zip.zip
# cp $(find . -type f -name "*.otf")  ~/.local/share/fonts
# cd


# Apps ===
# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
    sudo apt install ./google-chrome-stable_current_amd64.deb

# Brave
sudo apt install -y apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

# Spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client

# Latex
sudo apt install -y texlive-latex-extra texlive-bibtex-extra biber

# Install R
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt install -y r-base
## Tidyverse deps
sudo apt install -y libcurl4-openssl-dev libxml2-dev
Rscript -e "install.packages('tidyverse')"

# NodeJS
mkdir $HOME/node
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install -y nodejs


# Terraform LSP
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform-ls
