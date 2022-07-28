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
    pkgs.nodejs
    pkgs.ripgrep
    pkgs.scmpuff
    pkgs.spotify-tui
    pkgs.spotifyd
    pkgs.spotify-unwrapped
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
    pkgs.gnumake
    pkgs.universal-ctags
    pkgs.newsboat
    /* pkgs.google-chrome */
    pkgs.unzip
    pkgs.rofi
    pkgs.tmuxp
    pkgs.notion-app-enhanced
    pkgs.dbmate
    pkgs.fd
    pkgs.terraform
    pkgs.jq
    /* pkgs.lorri */
    pkgs.yaml-language-server
    pkgs.stylua
    (pkgs.nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
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

      aws = {
        disabled = true;
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Denis Maciel";
    userEmail = "denispmaciel@gmail.com";
    signing = {
      signByDefault = true;
      key = "0136C53C5F7ED3CB";
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
