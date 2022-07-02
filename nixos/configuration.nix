# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  programs.zsh.enable = true;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.utf8";
    LC_IDENTIFICATION = "de_DE.utf8";
    LC_MEASUREMENT = "de_DE.utf8";
    LC_MONETARY = "de_DE.utf8";
    LC_NAME = "de_DE.utf8";
    LC_NUMERIC = "de_DE.utf8";
    LC_PAPER = "de_DE.utf8";
    LC_TELEPHONE = "de_DE.utf8";
    LC_TIME = "de_DE.utf8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # TODO: remove when this gets merged:
  # https://github.com/NixOS/nixpkgs/blob/ba0e1d31f9c28342c0eb9007e5609e56ed76697d/nixos/modules/services/networking/cloudflare-warp.nix
  systemd.services.miservicio = {
    enable = true;
    description = "Warp Daemon";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "/home/denis/.nix-profile/bin/warp-svc";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services = {
    syncthing = {
      enable = true;
      user = "denis";
      # dataDir = "/home/ccmyusername/Documents";    # Default folder for new synced folders
      # configDir = "/home/myusername/Documents/.config/syncthing";   # Folder for Syncthing's settings and keys
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    vim
    git
    firefox
    kate
    gnupg
    pinentry-qt
    docker
  ];

  home-manager.users.denis = {
    home.username = "denis";
    home.homeDirectory = "/home/denis";
    home.stateVersion = "22.05";
    fonts.fontconfig.enable = true;

    home.packages = [
      pkgs.alacritty
      pkgs.direnv
      pkgs.element-desktop
      pkgs.fzf
      pkgs.gcc
      pkgs.go_1_18
      pkgs.htop
      pkgs.keepassxc
      pkgs.mpv
      pkgs.vlc
      pkgs.newsboat
      pkgs.python310
      pkgs.python310Packages.pip
      pkgs.ripgrep
      pkgs.scmpuff
      pkgs.spotify-tui
      pkgs.spotifyd
      pkgs.starship
      pkgs.stow
      pkgs.syncthing
      pkgs.tmux
      pkgs.xclip
      pkgs.obs-studio
      pkgs.cloudflare-warp
      pkgs.rnix-lsp
      pkgs._1password-gui
      pkgs.slack
      pkgs.zsh-fzf-tab
      pkgs.zsh-syntax-highlighting
      pkgs.neovim
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];

    programs.home-manager.enable = true;
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;

        character = {
          success_symbol = "[\\$](white)";
          error_symbol = "[\\$](red)";
          vicmd_symbol = "[\\$](blue)";
        };

        aws = {
          disabled = true;
        };
      };
    };
    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      plugins = [{ name = "fzf-tab"; src = "${pkgs.zsh-fzf-tab}/share/fzf-tab"; }];
      initExtra = ''
        [[ "$(uname)" = "Linux" ]] && xset r rate 200 80 && setxkbmap -layout us -option ctrl:nocaps


        function gb() {
            branch=$(git branch -a | sed "s|remotes/origin/||" | tr -d "*+ " | uniq | fzf)
            [ $status -eq 0 ] && git checkout $branch || echo "cancelling"
        }

        function check_syncthing() {
            running=`ps ax | grep -v grep | grep syncthing | wc -l`
            if [ $running -le 1 ]; then
                echo "🚨 syncthing is not running 🚨"
            fi
        }

        # ----------------------------------
        # --------- Warnings ---------------
        # ----------------------------------
        git -C $HOME/dotfiles diff --exit-code > /dev/null || echo " === Commit the changes to your dotfiles, my man! ==="
        check_syncthing

        eval "$(starship init zsh)"

        function togglep() {
            if [[ -f playground/p.go ]]; then 
                echo "==> gopher"
                mv playground/p.go playground/p.gopher
            elif [[ -f playground/p.gopher ]]; then
                echo "==> go"
                mv playground/p.gopher playground/p.go
            else
                echo "No gopher, no go"
                return 1
            fi
        }
        function open() {
            nohup xdg-open "$*" >> /dev/null &
        }

        function open-zathura() {
            nohup zathura "$*" >> /dev/null & exit
        }

        function addin() {
            printf "Addressed in $(git rev-parse HEAD)" | xclip -selection clipboard 
            git push origin HEAD
        }

        export R_LIBS_USER="$HOME/r/x86_64-pc-linux-gnu-library/4.1" # Custom location for R packages
        export LC_ALL=en_US.UTF-8 # Fix problem when opening nvim
        export VISUAL=nvim
        export FZF_DEFAULT_OPTS="--height 100%"
        export FZF_DEFAULT_COMMAND="rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does
        export XDG_CONFIG_HOME=$HOME/.config

        alias act='source venv/bin/activate'
        alias l='ls -lah'
        alias la='ls -lAh'
        alias ll='ls -lh'
        alias lsa='ls -lah' 
        alias R='R --no-save'
        alias diary='nvim "$HOME/Sync/Notes/Current/Diary/$(date +'%Y-%m-%d').md"'
        alias research='nvim -c "Research"'
        alias gp="git push origin HEAD"

        alias pdf='open-zathura "$(fd "pdf|epub" | fzf)"'
        alias clip='xclip -selection clipboard'

        setopt autocd               # .. is shortcut for cd .. 

        # vi mode
        bindkey -v
        export KEYTIMEOUT=1
        # bindkey -e #Emacs keybinding
        bindkey "^E" backward-word
        bindkey "^F" forward-word
        bindkey "^P" up-line-or-search
        bindkey "^N" down-line-or-search
        # Enable Ctrl-x-e to edit command line
        autoload -U edit-command-line
        # Emacs style
        zle -N edit-command-line
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line

        case `uname` in 
            Darwin)
                export HOMEBREW_AUTO_UPDATE_SECS=604800 # Autoupdate on weekly basis
                alias tss="date +'%Y-%m-%d %H:%M:%S' | pbcopy; pbpaste"
                alias tsd="date +'%Y-%m-%d' | pbcopy; pbpaste"
                alias tsw="date +'Work_%Y-%W' | pbcopy; pbpaste"
                alias ls='ls -G'
            ;;
            Linux)
                alias tss="date +'%Y-%m-%d %H:%M:%S' | xclip -selection clipboard && xclip -selection clipboard -o"
                alias tsd="date +'%Y-%m-%d' | xclip -selection clipboard && xclip -selection clipboard -o"
                alias tsw="date +'Work_%Y-%W' | xclip -selection clipboard && xclip -selection clipboard -o"
                alias ls='ls -G --color=auto'
            ;;
        esac

        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
        [ -f ~/key-bindings.zsh ] && source ~/key-bindings.zsh

        if [ -n "$\{commands[fzf-share]\}" ]; then
          source "$(fzf-share)/key-bindings.zsh"
          source "$(fzf-share)/completion.zsh"
        fi

        HISTFILE="$HOME/.zsh_history"
        HISTSIZE=10000000
        SAVEHIST=10000000
        setopt BANG_HIST                 # Treat the '!' character specially during expansion.
        setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
        setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
        setopt SHARE_HISTORY             # Share history between all sessions.
        setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
        setopt HIST_SAVE_NO_DUPS         # Dont write duplicate entries in the history file.
        setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
        setopt HIST_VERIFY               # Dont execute immediately upon history expansion.
        setopt INTERACTIVE_COMMENTS       # Allow for comments
        export PATH=$HOME/bin:$PATH
        export PATH=$PATH:/usr/local/go/bin
        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/scripts:$PATH"
        export PATH="$HOME/go/bin/:$PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
        export PATH="$HOME/node/bin:$PATH"
        export PATH="$HOME/venvs/default/bin:$PATH"
        export GOPATH=$(go env GOPATH)

        eval "$(scmpuff init -s)"

        export PYTHONBREAKPOINT=ipdb.set_trace
        [[ -d $HOME/applications/zsh-syntax-highlighting ]] && source $HOME/applications/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        if [ -e /home/denis/.recap.sh ]; then . /home/denis/.recap.sh; fi

        # Fix annoying warning: 
        #     - https://nixos.wiki/wiki/Locales
        #     - https://www.reddit.com/r/NixOS/comments/oj4kmd/every_time_i_run_a_program_installed_with_nix_i/
        export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

        export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

        eval "$(direnv hook zsh)"
      '';
    };

    programs.git = {
      enable = true;
      userName = "Denis Maciel";
      userEmail = "denispmaciel@gmail.com";
      signing = {
        signByDefault = true;
        key = "B9E1A568A1128EC6";
      };
    };

    nixpkgs.overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];

    # programs.neovim = {
    #   enable = true;
    #   package = pkgs.neovim-nightly;
    #   extraConfig = "
    #   source <sfile>:h/entry.vim
    # ";
    # };
  };
  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
