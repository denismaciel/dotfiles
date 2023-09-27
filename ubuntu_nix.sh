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

# remove stow
nix-env -e stow

home-manager switch

sudo apt remove neovim

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Enter tmux and run Ctrl + b and Shift+I
sudo chsh --shell $(which zsh) $USER

# Python
sudo add-apt-repository -y ppa:deadsnakes/ppa && \
    sudo apt-get update && \
    sudo apt-get install -y python3.11-dev python3.11-distutils python3.11-venv
    
## Bootstrap virtualenv
sudo apt-get install -y curl &&
    curl --location --output virtualenv.pyz https://bootstrap.pypa.io/virtualenv/3.11/virtualenv.pyz && \
    python3.11 virtualenv.pyz ~/venvs/default

python3.11 -m pip install pipx
pipx install git+https://github.com/lervag/apy
pipx install black
pipx install reorder-python-imports
pipx install ruff
    
nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
nix-env -iA nixgl.auto.nixGLDefault   # or replace `nixGLDefault` with your desired wrapper
 
# Docker   
sudo apt-get update sudo apt-get install \ ca-certificates \
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

# pgadmin4
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt install pgadmin4-desktop

# Copy .ssh folder
# cp -r /media/denis/Extreme\ SSD/recap-backup-2022-11-12/.ssh ~/
cd .ssh
chmod 600 id_rsa

cd ~/dotfiles git remote set-url origin git@github.com:denismaciel/dotfiles.git

# Go CLIs
go get -u github.com/open-pomodoro/openpomodoro-cli/cmd/pomodoro
