sudo apt install curl neovim git

curl -L https://nixos.org/nix/install | sh && 
  source /home/denis/.nix-profile/etc/profile.d/nix.sh

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
 nix-shell '<home-manager>' -A install
 
 
git clone https://github.com/denismaciel/dotfiles
cd dotfiles
 
nix-env -i stow
rm -rf ~/.config/nixpkgs
stow nixpkgs

stow python tmux tools nvim node zsh


# Run it ~3 times
nvim -c 'PackerSync'

# Enter tmux and run Ctrl + b and Shift+I

sudo chsh --shell $(which zsh) $USER

# Python
sudo add-apt-repository -y ppa:deadsnakes/ppa && \
    sudo apt-get update && \
    sudo apt-get install -y python3.9-dev python3.9-distutils python3.9-venv
    
    ## Bootstrap virtualenv
sudo apt-get install -y curl &&
    curl --location --output virtualenv.pyz https://bootstrap.pypa.io/virtualenv/3.9/virtualenv.pyz && \
    python3.9 virtualenv.pyz ~/venvs/default
    
    # Alacritty
sudo add-apt-repository -y ppa:mmstick76/alacritty &&
    sudo apt-get install -y alacritty
 
 # Docker   
 sudo apt-get update
 sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER


# === Alacritty ===
sudo add-apt-repository ppa:aslatter/ppa
sudo apt update
sudo apt install alacritty

# pgadmin4
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt install pgadmin4-desktop


