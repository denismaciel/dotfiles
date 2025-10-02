{
  config,
  inputs,
  pkgs,
  lib,
  dennichPkg,
  ...
}:
let
  color = import ../../modules/color.nix;
in
{
  imports = [

    ../../modules/unfree.nix
    ../../modules/go.nix
    ../../modules/firefox.nix
    ../../modules/git.nix
    ../../modules/fzf.nix
    ../../modules/ghostty.nix
    ../../modules/starship.nix
    ../../modules/pageshot.nix
    ../../modules/niri.nix

  ];
  go.enable = true;

  firefox.enable = true;
  git.enable = true;
  ghostty.enable = true;
  starship.enable = true;
  pageshot.enable = true;
  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    tray = true;
    temperature = {
      day = 6500;
      night = 5100;
    };
    settings = {
      general = {
        adjustment-method = "wayland";
        brightness-day = "1.0";
        brightness-night = "0.97";
      };
    };
  };
  niri.enable = true;
  niri.dennichPkg = dennichPkg;

  home.packages = with pkgs; [
    # calibre
    # anki
    # kdePackages.dolphin
    # cargo
    mise
    zeroad
    age
    nixfmt-rfc-style

    biome
    bitwarden
    btop
    bun
    cliphist
    dbmate
    dig
    duckdb
    fd
    foot
    gcc
    gh
    ghostty
    gnumake
    grim
    slurp
    satty
    gofumpt
    gomi
    google-chrome
    jq
    keepassxc
    kubectl
    lazydocker
    lazygit
    litecli
    lsof
    lua
    markdownlint-cli
    nerd-fonts.comic-shanns-mono
    nil
    nixfmt-rfc-style
    nodejs
    openssl
    pgcli
    pgsync
    postgresql
    ripgrep
    sioyek
    slack
    sops
    spotify-unwrapped
    sqlite
    statix
    stow
    stripe-cli
    stylua
    lua-language-server
    tailwindcss-language-server
    terraform
    terraform-ls
    typescript
    universal-ctags
    unzip
    vscode-langservers-extracted
    waybar
    wl-clipboard

    yaml-language-server
    yt-dlp
    zenity
    zoxide
    fuzzel
    swayidle
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
  ];

  xdg.userDirs =
    let
      top = config.home.homeDirectory;
      home = "${top}/dirs";
    in
    {
      enable = true;
      desktop = "${home}/desktop";
      documents = "${home}/documents";
      download = "${home}/downloads";
      music = "${home}/music";
      pictures = "${home}/pictures";
      publicShare = "${home}/public";
      templates = "${home}/templates";
      videos = "${home}/videos";
    };
  stylix.targets.neovim.enable = false;
  stylix.targets.fzf.enable = true;
  stylix.targets.starship.enable = false;
  stylix.targets.ghostty.enable = false;
  stylix.targets.firefox.profileNames = [ "default" ];

  # Explicitly disable Qt theming since we're not using a Qt-based desktop
  stylix.targets.qt.enable = false;

  # Or alternatively, set Qt platform theme explicitly to avoid plasma5 detection
  # qt.enable = true;
  # qt.platformTheme.name = "gtk";
  # qt.style.name = "adwaita-dark";
  home.username = "denis";
  home.homeDirectory = "/home/denis";

  # Fix PATH for all spawned processes from window manager
  # home.sessionPath = [
  #   "/run/current-system/sw/bin"
  #   "${config.home.homeDirectory}/.nix-profile/bin"
  #   "${config.home.homeDirectory}/.local/bin"
  # ];

  # Ensure user systemd and DBus know the environment
  # systemd.user.sessionVariables = {
  #   PATH = lib.mkForce "/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin:${config.home.homeDirectory}/.local/bin:$PATH";
  # };
  home.file = {
    ".config/dennich-colorscheme".text = color.theme;
    ".npmrc".source = ../../configs/_npmrc;
    ".ipython/profile_default/ipython_config.py".source =
      ../../configs/_ipython/profile_default/ipython_config.py;
    ".ipython/profile_default/custom_init.py".source =
      ../../configs/_ipython/profile_default/custom_init.py;
    ".config/fd/ignore".source = ../../configs/fd/ignore;
    ".config/pgcli/config".source = ../../configs/pgcli/config;
    ".config/sioyek/prefs_user.config".source = ../../configs/sioyek/prefs_user.config;
    ".ctags.d/default.ctags".source = ../../configs/_ctags.d/default.ctags;
    ".newsboat/config".source = ../../configs/_newsboat/config;
    ".newsboat/urls".source = ../../configs/_newsboat/urls;
    ".ripgrep_ignore".source = ../../configs/_ripgrep_ignore;
    ".tmuxp/core.yml".source = ../../configs/_tmuxp/core.yaml;

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
      "application/pdf" = [ "sioyek.desktop" ];
    };
    associations.added = {
      "text/plain" = [ "sioyek.desktop" ];
    };
  };
  # Environment variables for applications
  home.sessionVariables = {
    NODE_OPTIONS = "--max-old-space-size=8192";
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraLuaConfig = "require('init')";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      font = {
        # normal.family = "Blex Mono Nerd Font";
        # size = 10.0;
      };
      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
      };
      colors = {
        cursor = {
          text = lib.mkForce "#F1F1F1"; # Light background from lumiere theme
          cursor = lib.mkForce "#800013"; # Red from lumiere theme
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      tmux-fzf
    ];
    extraConfig = builtins.readFile ../../configs/.tmux.conf;
  };

  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

  services.cliphist = {
    enable = true;
  };

  programs.fuzzel.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "BlexMono Nerd Font Mono:size=14";
      };
      cursor = {
        style = "block";
        blink = "no";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        log_filter = "^$"; # Silence all direnv output
        load_dotenv = true; # Keep existing setting from configs/direnv/direnv.toml
      };
    };
  };
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = builtins.readFile ../../configs/_zshrc;
    enableCompletion = true;
    plugins = [
      {
        name = "zsh-defer";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "zsh-defer";
          rev = "master";
          sha256 = "/rcIS2AbTyGw2HjsLPkHtt50c2CrtAFDnLuV5wsHcLc=";
        };
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      # {
      #   name = "zsh-autopair";
      #   file = "zsh-autopair.plugin.zsh";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "hlissner";
      #     repo = "zsh-autopair";
      #     rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
      #     sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
      #   };
      # }
      # {
      #   name = "zsh-completions";
      #   src = "${pkgs.zsh-completions}/share/zsh/site-functions";
      # }
      # {
      #   name = "zsh-syntax-highlighting";
      #   file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      #   src = pkgs.zsh-syntax-highlighting;
      # }
    ];
  };

  services.pasystray.enable = true;
  services.udiskie.enable = true; # Auto mount devices

  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };
  systemd.user.startServices = true;

  systemd.user.services.pomodoro-server = {
    Unit = {
      Description = "Pomodoro Server";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${dennichPkg}/bin/dennich-pomodoro start-server";
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.dump-anki = {
    Unit = {
      Description = "Dump Anki Notes to index.json";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${dennichPkg}/bin/dennich-danki dump";
    };
  };

  systemd.user.timers.dump-anki = {
    Timer.OnCalendar = "*:0/2";
    Timer.Persistent = true;
    Install.WantedBy = [ "timers.target" ];
  };

  # Idle management: lock after 10 minutes, sleep after 15 minutes
  systemd.user.services.swayidle = {
    Unit = {
      Description = "Idle manager for Wayland";
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' timeout 900 '${pkgs.systemd}/bin/systemctl suspend' before-sleep '${pkgs.swaylock}/bin/swaylock -f'";
      Restart = "always";
      RestartSec = 3;
    };
  };

}
