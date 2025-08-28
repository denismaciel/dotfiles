{
  config,
  inputs,
  pkgs,
  lib,
  dennichPkg,
  processedConfigPath,
  processedScriptPath,
  ...
}: let
  color = import ../../modules/color.nix;
in {
  imports = [
    ./autorandr.nix
    ../../modules/unfree.nix
    ../../modules/go.nix
    ../../modules/firefox.nix
    ../../modules/git.nix
    ../../modules/fzf.nix
    ../../modules/ghostty.nix
    ../../modules/starship.nix
    ../../modules/pageshot.nix
  ];
  go.enable = true;
  autorandr.enable = true;
  firefox.enable = true;
  git.enable = true;
  ghostty.enable = true;
  starship.enable = true;
  pageshot.enable = true;
  home.packages = with pkgs; [
    # calibre
    # anki
    # kdePackages.dolphin
    # cargo
    age
    alejandra
    arandr
    biome
    bitwarden
    btop
    bun
    dbmate
    dig
    duckdb
    fd
    gcc
    gh
    ghostty
    gnumake
    gofumpt
    gomi
    google-chrome
    haskellPackages.greenclip
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
    sumneko-lua-language-server
    tailwindcss-language-server
    terraform
    terraform-ls
    typescript
    universal-ctags
    unzip
    vscode-langservers-extracted
    xclip
    xdragon
    xorg.xbacklight
    xorg.xev
    yaml-language-server
    yt-dlp
    zenity
    zoxide
    (rofi.override {
      plugins = [
        pkgs.rofi-emoji
        pkgs.rofi-calc
      ];
    })
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
  ];

  xdg.userDirs = let
    top = config.home.homeDirectory;
    home = "${top}/dirs";
  in {
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
    ".config/greenclip.toml".source = ../../configs/greenclip.toml;
    ".config/pgcli/config".source = ../../configs/pgcli/config;
    ".config/sioyek/prefs_user.config".source = ../../configs/sioyek/prefs_user.config;
    ".ctags.d/default.ctags".source = ../../configs/_ctags.d/default.ctags;
    ".newsboat/config".source = ../../configs/_newsboat/config;
    ".newsboat/urls".source = ../../configs/_newsboat/urls;
    ".ripgrep_ignore".source = ../../configs/_ripgrep_ignore;
    ".tmuxp/core.yml".source = ../../configs/_tmuxp/core.yaml;
    # Awesome WM configuration
    ".config/awesome/rc.lua".text =
      builtins.replaceStrings
      ["@dennichTodoPath@"]
      ["${dennichPkg}/bin/dennich-todo"]
      (builtins.readFile ../../configs/awesome/rc.lua);
    ".config/awesome/main/utils.lua".source = ../../configs/awesome/main/utils.lua;
    ".config/awesome/main/dkjson.lua".source = ../../configs/awesome/main/dkjson.lua;
  };
  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["google-chrome.desktop"];
      "x-scheme-handler/http" = ["google-chrome.desktop"];
      "x-scheme-handler/https" = ["google-chrome.desktop"];
      "x-scheme-handler/about" = ["google-chrome.desktop"];
      "x-scheme-handler/unknown" = ["google-chrome.desktop"];
      "application/pdf" = ["sioyek.desktop"];
    };
    associations.added = {
      "text/plain" = ["sioyek.desktop"];
    };
  };
  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
    };
    # These two lines are needed so xdg-open doesn't
    # get confused and can correctly open links in a browser
    # Source: https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/3
    initExtra = ''
      unset XDG_CURRENT_DESKTOP
      unset DESKTOP_SESSION
      export NODE_OPTIONS="--max-old-space-size=8192"
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

  services.flameshot = {
    enable = true;
  };
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

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

  services.polybar = {
    enable = true;
    extraConfig = builtins.readFile processedConfigPath;
    script = builtins.readFile processedScriptPath;
  };

  services.screen-locker = {
    enable = false;
    inactiveInterval = 15;
    lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
  };

  services.pasystray.enable = true;
  services.udiskie.enable = true; # Auto mount devices

  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };
  systemd.user.startServices = true;

  systemd.user.services.feh = {
    Unit = {
      Description = "Feh";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.feh}/bin/feh --bg-scale ${../../assets/black.png}";
    };
  };

  systemd.user.services.pomodoro-server = {
    Unit = {
      Description = "Pomodoro Server";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${dennichPkg}/bin/dennich-pomodoro start-server";
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.greenclip = {
    Unit = {
      Description = "greenclip daemon";
      After = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.haskellPackages.greenclip}/bin/greenclip daemon";
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
    Install.WantedBy = ["timers.target"];
  };
}
