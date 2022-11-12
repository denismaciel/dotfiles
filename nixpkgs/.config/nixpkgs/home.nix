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
    pkgs._1password-gui
    pkgs.difftastic
    pkgs.alacritty
    pkgs.dbmate
    pkgs.direnv
    pkgs.docker
    pkgs.element-desktop
    pkgs.fd
    pkgs.flameshot
    pkgs.fzf
    pkgs.gcc
    pkgs.gnumake
    pkgs.go_1_18
    pkgs.gomi
    pkgs.google-chrome
    pkgs.htop
    pkgs.jq
    pkgs.keepassxc
    pkgs.mpv
    pkgs.newsboat
    pkgs.nodejs
    pkgs.notion-app-enhanced
    pkgs.obs-studio
    pkgs.obsidian
    pkgs.pgcli
    pkgs.qutebrowser
    pkgs.ripgrep
    pkgs.rnix-lsp
    pkgs.rofi
    pkgs.scmpuff
    pkgs.slack
    pkgs.spotify-tui
    pkgs.spotify-unwrapped
    pkgs.spotifyd
    pkgs.starship
    pkgs.stow
    pkgs.stylua
    pkgs.syncthing
    pkgs.terraform
    pkgs.terraform-ls
    pkgs.tmux
    pkgs.tmuxp
    pkgs.universal-ctags
    pkgs.unzip
    pkgs.vlc
    pkgs.xclip
    pkgs.yaml-language-server
    pkgs.zsh
    pkgs.zsh-fzf-tab
    pkgs.zsh-syntax-highlighting
    (pkgs.nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
        "JetBrainsMono"
        "Monofur"
        "SpaceMono"
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
        error_symbol = "[\\$](red)";
        vicmd_symbol = "[\\$](blue)";
      };
      directory = {
        style = "white";
      };
      aws = {
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
        style  = "white";
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
    };
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    extraConfig = "
      source <sfile>:h/entry.vim
    ";
  };

}
