{ config, pkgs, ... }:

{
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.file = {
    ".npmrc".source = ./_npmrc;
    ".ipython/profile_default/ipython_config.py".source = ./_ipython/profile_default/ipython_config.py;
  };
  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      "x-scheme-handler/notion" = [ "notion-app-enhanced.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "x-scheme-handler/element" = [ "element-desktop.desktop" ];
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "application/pdf" = [ "sioyek.desktop" ];
    };

    associations.added = {
      "application/json" = [ "org.gnome.gedit.desktop" ];
      "text/csv" = [ "nvim.desktop" ];
      "text/plain" = [ "sioyek.desktop" ];
      "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
    };
  };
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
  home.packages = with pkgs; [
    arp-scan
    bun
    imagemagick
    sqlitebrowser
    brightnessctl
    just
    golden-cheetah
    calibre
    zk
    glow
    gh
    pistol # terminal previewer
    firefox
    wezterm
    ffmpeg
    vscode
    texlive.combined.scheme-medium
    python310Packages.cfn-lint
    libreoffice
    brave
    pgadmin
    litecli
    gimp
    yq-go
    delta
    # awscli2
    # aws-sam-cli
    ngrok
    google-cloud-sdk
    pandoc
    kubernetes-helm
    kubectl
    pasystray
    okular
    sqlite
    sioyek
    redshift
    imwheel
    anki
    tor-browser-bundle-bin
    lazygit
    delve
    jsonnet
    R
    _1password-gui
    alacritty
    arandr
    awesome
    picom
    dbmate
    difftastic
    direnv
    docker
    element-desktop
    fd
    flameshot
    fzf
    gcc
    gnumake
    golangci-lint
    go-swagger
    go_1_20
    gofumpt
    gomi
    google-chrome
    gopls
    gotools # for goimports
    haskellPackages.greenclip
    htop
    jq
    keepassxc
    lf
    lua
    mpv
    newsboat
    gnome.nautilus
    nodejs-18_x
    notion-app-enhanced
    obs-studio
    obsidian
    papirus-icon-theme
    pgcli
    mycli
    polybar
    postgresql
    qutebrowser
    ripgrep
    rnix-lsp
    rstudio
    scmpuff
    slack
    spotify-tui
    spotify-unwrapped
    spotifyd
    ssm-session-manager-plugin # Aws Session Manager for executing commands on Fargate tasks
    starship
    stow
    stylua
    sumneko-lua-language-server
    syncthing
    terraform
    terraform-ls
    tmux
    tmuxp
    universal-ctags
    unzip
    vlc
    xclip
    xdotool
    xorg.xbacklight
    yaml-language-server
    zathura
    zoxide
    zsh
    zsh-fzf-tab
    zsh-syntax-highlighting
    comic-mono
    (rofi.override { plugins = [ pkgs.rofi-emoji pkgs.rofi-calc ]; })
    (nerdfonts.override {
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
        format = "[$env_value]($style) ";
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
    # signing = { signByDefault = true;
    #   key = "188DE24A651E34AA";
    # };
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
  # nixpkgs.overlays = [
  #   (
  #     import (
  #       let
  #         # rev = "master";
  #         rev = "29b5f1c2aef88e2b6f41a9d529e50b24802fdb7d";
  #       in
  #       builtins.fetchTarball {
  #         url = "https://github.com/nix-community/neovim-nightly-overlay/archive/${rev}.tar.gz";
  #       }
  #     )
  #   )
  # ];

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-nightly;
    extraConfig = "
      lua require 'init'
    ";
  };

}
