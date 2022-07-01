{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "denis";
  home.homeDirectory = "/home/denis";

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
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
  };

  programs.git = {
    enable = true;
    userName  = "Denis Maciel";
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

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    extraConfig = "
      source <sfile>:h/entry.vim
    ";
  };
}
