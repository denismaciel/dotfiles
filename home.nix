{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./modules/autorandr.nix
    ./modules/go.nix
  ];
  go.enable = true;
  autorandr.enable = true;
  home.packages = with pkgs; [
    terraform
    # duckdb
    # zed-editor
    # clang
    gh
    pv
    harper
    nil
    anki
    appimage-run
    arandr
    awesome
    biome
    btop
    bun
    calibre
    cargo
    chromium
    circumflex
    csvlens
    dbmate
    difftastic
    dig
    direnv
    dockerfile-language-server-nodejs
    fd
    feh
    ffmpeg
    flameshot
    fzf
    gcc
    gnumake
    gofumpt
    golden-cheetah
    gomi
    google-chrome
    google-cloud-sdk
    graphviz
    haskellPackages.greenclip
    htop
    hyperfine
    i3lock-fancy-rapid
    jq
    jsonnet
    jsonnet-language-server
    keepassxc
    keyd
    kitty
    kubectl
    lazydocker
    lazygit
    lf
    libinput
    libreoffice
    litecli
    lsof
    lua
    markdownlint-cli
    mpv
    ngrok
    nil
    nixfmt-rfc-style
    nodePackages_latest.bash-language-server
    nodePackages_latest.prettier
    nodePackages_latest.typescript-language-server
    nodejs-18_x
    obs-studio
    openssl
    pandoc
    papirus-icon-theme
    pasystray
    pgcli
    postgresql
    pqrs
    pyright
    python312Full
    # python312Packages.mdformat -- Installed used uv
    # python312Packages.mdformat-gfm
    rclone
    ripgrep
    rust-analyzer
    rustc
    scmpuff
    sioyek
    skim
    slack
    spotify-unwrapped
    sqlite
    sqlitebrowser
    ssm-session-manager-plugin # Aws Session Manager for executing commands on Fargate tasks
    statix
    stow
    stylua
    sumneko-lua-language-server
    tailwindcss-language-server
    terraform-ls
    texlive.combined.scheme-medium
    tor-browser-bundle-bin
    tree
    typescript
    universal-ctags
    unzip
    vlc
    vscode
    vscode-langservers-extracted
    xclip
    xdotool
    xdragon
    xorg.xbacklight
    xorg.xev
    yaml-language-server
    yq-go
    yt-dlp
    zenity
    zk
    zoxide
    (rofi.override {plugins = [pkgs.rofi-emoji pkgs.rofi-calc];})
    (google-fonts.override {fonts = ["Poppins"];})
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
  stylix.targets.neovim.enable = false;
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.file = {
    ".npmrc".source = ./configs/_npmrc;
    ".ipython/profile_default/ipython_config.py".source = ./configs/_ipython/profile_default/ipython_config.py;
    ".ipython/profile_default/custom_init.py".source = ./configs/_ipython/profile_default/custom_init.py;
    ".config/direnv/direnv.toml".source = ./configs/direnv/direnv.toml;
    ".config/fd/ignore".source = ./configs/fd/ignore;
    ".config/greenclip.toml".source = ./configs/greenclip.toml;
    ".config/lf/colors".source = ./configs/lf/colors;
    ".config/lf/icons".source = ./configs/lf/icons;
    ".config/lf/lfrc".source = ./configs/lf/lfrc;
    ".config/pgcli/config".source = ./configs/pgcli/config;
    ".config/sioyek/prefs_user.config".source = ./configs/sioyek/prefs_user.config;
    ".ctags.d/default.ctags".source = ./configs/_ctags.d/default.ctags;
    ".newsboat/config".source = ./configs/_newsboat/config;
    ".newsboat/urls".source = ./configs/_newsboat/urls;
    ".ripgrep_ignore".source = ./configs/_ripgrep_ignore;
    ".tmuxp/core.yml".source = ./configs/_tmuxp/core.yaml;
    ".config/hypr/hyprland.conf".source = ./configs/hypr/hyprland.conf;
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
      "x-scheme-handler/notion" = ["notion-app-enhanced.desktop"];
      "application/zip" = ["org.gnome.FileRoller.desktop"];
      "x-scheme-handler/element" = ["element-desktop.desktop"];
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
      "application/pdf" = ["sioyek.desktop"];
    };
    associations.added = {
      "application/json" = ["org.gnome.gedit.desktop"];
      "text/csv" = ["nvim.desktop"];
      "text/plain" = ["sioyek.desktop"];
      "application/epub+zip" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
    };
  };
  targets.genericLinux.enable = true;
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

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  # };

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
    extraConfig = builtins.readFile ./configs/.tmux.conf;
  };

  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";
    initExtra = builtins.readFile ./configs/_zshrc;
    enableCompletion = true;
    completionInit = "autoload -Uz compinit && compinit -C";
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
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "zsh-autopair";
        file = "zsh-autopair.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        src = pkgs.zsh-syntax-highlighting;
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[\\$](white)";
        error_symbol = "[●](red)";
        vicmd_symbol = "[●](blue)";
      };
      env_var = {
        variable = "ENV";
        format = "[$env_value]($style) ";
        symbol = " ";
        style = "dimmed white";
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
        style = "dimmed white";
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
        format = "[\${symbol}(\($virtualenv\) )]($style)";
        style = "dimmed white";
      };
      golang = {
        disabled = true;
      };
      lua = {
        disabled = true;
      };
      nodejs = {
        disabled = true;
      };
    };
  };

  services.polybar = {
    enable = true;
    extraConfig = builtins.readFile ./configs/polybar/config.ini;
    script = builtins.readFile ./configs/polybar/launch.sh;
  };

  services.screen-locker = {
    enable = true;
    inactiveInterval = 10;
    lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
  };

  services.udiskie.enable = true; # Auto mount devices

  programs.git = {
    enable = true;
    userName = "Denis Maciel";
    userEmail = "denispmaciel@gmail.com";
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
      "snaps"
      "tags"
      "venv"
      "play"
      ".avante_chat_history"
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
      please = "push origin HEAD --force-with-lease";
    };
    extraConfig = {
      diff = {
        tool = "difftastic";
      };
      difftool = {
        prompt = false;
      };
      difftool.difftastic = {
        cmd = "difft \"$LOCAL\" \"$REMOTE\"";
      };
      pager = {
        difftool = true;
      };
    };
  };

  gtk = {
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };
  systemd.user.startServices = true;
  systemd.user.services.flameshot = {
    Install = {
      WantedBy = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.flameshot}/bin/flameshot";
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.pasystray = {
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.pasystray}/bin/pasystray";
      Restart = "always";
      RestartSec = 3;
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
      ExecStart = "/home/denis/.local/bin/dennich-pomodoro start-server";
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.feh = {
    Unit = {
      Description = "Feh";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.feh}/bin/feh --bg-fill --no-xinerama /home/denis/dotfiles/assets/wallpaper.jpg";
    };
  };

  systemd.user.services.greenclip = {
    Unit = {
      Description = "greenclip daemon";
      After = ["graphical-session.target"];
    };
    Install = {WantedBy = ["graphical-session.target"];};
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
      ExecStart = "/home/denis/.local/bin/dennich-danki dump";
    };
  };

  systemd.user.timers.dump-anki = {
    Timer.OnCalendar = "*:0/2";
    Timer.Persistent = true;
    Install.WantedBy = ["timers.target"];
  };

  dconf.settings = {
    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "standard";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      default-sort-order = "type";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };

    "org/gnome/nautilus/window-state" = {
      maximized = false;
      sidebar-width = 200;
      start-with-sidebar = true;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 263;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
    };
  };
}
