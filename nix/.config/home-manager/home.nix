{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  xdg.enable = true;
  xdg.mime.enable = true;
  targets.genericLinux.enable = true;
  xsession = {
    enable = true;
    initExtra = ''
      xset r rate 200 40
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.zk
    pkgs.gh
    pkgs.pistol # terminal previewer
    pkgs.firefox
    pkgs.wezterm
    pkgs.ffmpeg
    pkgs.vscode
    pkgs.texlive.combined.scheme-medium
    pkgs.python310Packages.cfn-lint
    pkgs.libreoffice
    pkgs.brave
    pkgs.pgadmin
    pkgs.litecli
    pkgs.gimp
    pkgs.yq-go
    pkgs.delta
    pkgs.awscli2
    pkgs.aws-sam-cli
    pkgs.ngrok
    pkgs.google-cloud-sdk
    pkgs.pandoc
    pkgs.kubernetes-helm
    pkgs.kubectl
    pkgs.pasystray
    pkgs.okular
    pkgs.sqlite
    pkgs.sioyek
    pkgs.redshift
    pkgs.imwheel
    # pkgs.anki-bin
    pkgs.anki
    pkgs.tor-browser-bundle-bin
    pkgs.lazygit
    pkgs.delve
    pkgs.jsonnet
    pkgs.R
    pkgs.hugo
    pkgs._1password-gui
    pkgs.alacritty
    pkgs.arandr
    pkgs.awesome
    pkgs.compton
    pkgs.dbmate
    pkgs.difftastic
    pkgs.direnv
    pkgs.docker
    pkgs.element-desktop
    pkgs.fd
    pkgs.flameshot
    pkgs.fzf
    pkgs.gcc
    pkgs.gnumake
    pkgs.go-swagger
    pkgs.go_1_18
    pkgs.gofumpt
    pkgs.gomi
    pkgs.google-chrome
    pkgs.gopls
    pkgs.haskellPackages.greenclip
    pkgs.htop
    pkgs.jq
    pkgs.keepassxc
    pkgs.lf
    pkgs.lua
    pkgs.mpv
    pkgs.newsboat
    pkgs.gnome.nautilus
    # pkgs.libsForQt5.dolphin
    pkgs.nodejs-16_x
    pkgs.notion-app-enhanced
    pkgs.obs-studio
    pkgs.obsidian
    pkgs.papirus-icon-theme
    pkgs.pgcli
    pkgs.polybar
    pkgs.postgresql
    pkgs.qutebrowser
    pkgs.ripgrep
    pkgs.rnix-lsp
    pkgs.rstudio
    pkgs.scmpuff
    pkgs.slack
    pkgs.spotify-tui
    pkgs.spotify-unwrapped
    pkgs.spotifyd
    pkgs.ssm-session-manager-plugin # Aws Session Manager for executing commands on Fargate tasks
    pkgs.starship
    pkgs.stow
    pkgs.stylua
    pkgs.sumneko-lua-language-server
    pkgs.syncthing
    pkgs.terraform
    pkgs.terraform-ls
    pkgs.tmux
    pkgs.tmuxp
    pkgs.universal-ctags
    pkgs.unzip
    pkgs.visidata
    pkgs.vlc
    /* pkgs.wmctrl */
    pkgs.xclip
    pkgs.xdotool
    pkgs.xorg.xbacklight
    pkgs.yaml-language-server
    pkgs.zathura
    pkgs.zoxide
    pkgs.zsh
    pkgs.zsh-fzf-tab
    pkgs.zsh-syntax-highlighting
    pkgs.comic-mono
    pkgs.zotero
    (pkgs.rofi.override { plugins = [ pkgs.rofi-emoji pkgs.rofi-calc ]; })
    (pkgs.nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
        "JetBrainsMono"
        "Monofur"
        "SpaceMono"
        "Iosevka"
        "ShareTechMono"
        "Terminus"
        "AnonymousPro"
        "IBMPlexMono"
      ];
    })
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[\\$](white)";
        error_symbol = "[●](red)";
        vicmd_symbol = "[\\$](blue)";
      };
      env_var = {
        variable = "ENV";
        format="[$env_value]($style) ";
        symbol = " ";
        style = "white";
      };
      directory = {
        style = "white";
      };
      aws = {
        disabled = true;
      };
      gcloud = {
        disabled = true;
      };
      package = {
        disabled = true;
      };
      git_branch = {
        style = "white";
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };
      git_status = {
        style = "white";
        disabled = true;
      };
      cmd_duration = {
        style = "white";
        format = "[$duration]($style) ";
      };
      python = {
        symbol = " ";
        format = "[\${symbol}\${pyenv_prefix}(\${version} )(\($virtualenv\) )]($style)";
        style = "white";
      };
      golang = {
        disabled = true;
        symbol = "";
        format = "[$symbol($version )]($style)";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Denis Maciel";
    userEmail = "denispmaciel@gmail.com";
    signing = {
      signByDefault = true;
      key = "188DE24A651E34AA";
    };
    ignores = [
      ".DS_Store"
      ".direnv"
      ".envrc"
      ".mypy_cache"
      ".pytest_cache"
      ".python-version"
      ".vim"
      ".vscode"
      "__pycache__"
      "_debug.py"
      "playground"
      "snaps"
      "tags"
      "venv"
    ];
    aliases = {
      last = "for-each-ref --sort=-committerdate --count=20 --format='%(align:70,left)%(refname:short)%(end)%(committerdate:relative)' refs/heads/";
      run = ''
        !f() { \
                watch_gha_runs $@ \
                    \"$(git remote get-url origin)\" \
                    \"$(git rev-parse --abbrev-ref HEAD)\"; \
            }; f
      '';
      lastco = "!git last | fzf | awk '{print $1}' | xargs git checkout";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "nodejs-16.20.0" ];
  nixpkgs.overlays = [
    (
      import (
        let
          rev = "master";
          # rev = "c57746e2b9e3b42c0be9d9fd1d765f245c3827b7";
        in
        builtins.fetchTarball {
          url = "https://github.com/nix-community/neovim-nightly-overlay/archive/${rev}.tar.gz";
        }
      )
    )
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    extraConfig = "
      lua require 'init'
    ";
  };

}
