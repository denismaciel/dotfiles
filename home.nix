{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # aws-sam-cli
    # awscli2
    # go_1_20
    droidcam
    hyperfine
    graphviz
    sqlcipher
    python312
    python311Packages.mdformat
    slides
    ruff # must be installed here because it requires some dynamically linked libs (I guess)
    skim
    # neovide
    rust-analyzer
    xdragon
    R
    openai-whisper
    # _1password-gui
    # _1password
    alacritty
    anki
    arandr
    arp-scan
    awesome
    brave
    brightnessctl
    btop
    bun
    calibre
    cargo
    comic-mono
    dbmate
    delta
    delve
    difftastic
    direnv
    discord
    docker
    element-desktop
    exercism
    fd
    ffmpeg
    firefox
    flameshot
    fzf
    gcc
    gh
    gimp
    glow
    gnome.nautilus
    gnome.zenity
    gnumake
    go-swagger
    go_1_21
    gofumpt
    golangci-lint
    golden-cheetah
    gomi
    google-chrome
    google-cloud-sdk
    gopls
    gotools # for goimports
    haskellPackages.greenclip
    htop
    imagemagick
    imwheel
    jdk17
    jq
    jsonnet
    just
    keepassxc
    keyd
    kubectl
    kubernetes-helm
    lazygit
    lf
    libinput
    libreoffice
    litecli
    lsof
    lua
    mpv
    mycli
    neovim-nightly
    newsboat
    ngrok
    nil
    nodePackages.prettier
    nodePackages.pyright
    nodePackages_latest.bash-language-server
    nodePackages_latest.typescript-language-server
    nodejs-18_x
    notion-app-enhanced
    obs-studio
    obsidian
    okular
    pandoc
    papirus-icon-theme
    pasystray
    # pgadmin4-desktopmode
    pgcli
    picom
    polybar
    postgresql
    pulseaudio
    pulsemixer
    python311Packages.cfn-lint
    qutebrowser
    redshift
    ripgrep
    # rnix-lsp
    rstudio
    rustc
    scmpuff
    sioyek
    slack
    # spotify-tui
    spotify-unwrapped
    # spotifyd
    sqlite
    sqlitebrowser
    ssm-session-manager-plugin # Aws Session Manager for executing commands on Fargate tasks
    starship
    statix
    stow
    stylua
    sumneko-lua-language-server
    syncthing
    tailwindcss-language-server
    termusic
    terraform
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
    wezterm
    xclip
    xdotool
    xorg.xbacklight
    xorg.xev
    yaml-language-server
    yq-go
    zathura
    zk
    zoxide
    zsh
    zsh-fzf-tab
    zsh-syntax-highlighting
    # (pkgs.callPackage ./dennich.nix {})
    (rofi.override {plugins = [pkgs.rofi-emoji pkgs.rofi-calc];})
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
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.file = {
    ".npmrc".source = ./configs/_npmrc;
    ".ipython/profile_default/ipython_config.py".source = ./configs/_ipython/profile_default/ipython_config.py;
    ".config/awesome/rc.lua".source = ./configs/awesome/rc.lua;
    ".config/awesome/main/utils.lua".source = ./configs/awesome/main/utils.lua;
    ".config/awesome/main/dkjson.lua".source = ./configs/awesome/main/dkjson.lua;
    ".config/alacritty/alacritty.toml".source = ./configs/alacritty/alacritty.toml;
    ".config/alacritty/rose-pine.toml".source = ./configs/alacritty/rose-pine.toml;
    ".config/alacritty/rose-pine-moon.toml".source = ./configs/alacritty/rose-pine-moon.toml;
    ".config/alacritty/rose-pine-dawn.toml".source = ./configs/alacritty/rose-pine-dawn.toml;
    ".config/alacritty/nord.toml".source = ./configs/alacritty/nord.toml;
    ".config/direnv/direnv.toml".source = ./configs/direnv/direnv.toml;
    ".config/fd/ignore".source = ./configs/fd/ignore;
    ".config/greenclip.toml".source = ./configs/greenclip.toml;
    ".config/lf/colors".source = ./configs/lf/colors;
    ".config/lf/icons".source = ./configs/lf/icons;
    ".config/lf/lfrc".source = ./configs/lf/lfrc;
    ".config/pgcli/config".source = ./configs/pgcli/config;
    ".config/redshift/redshift.conf".source = ./configs/redshift/redshift.conf;
    ".config/rofi/config.rasi".source = ./configs/rofi/config.rasi;
    ".config/sioyek/prefs_user.config".source = ./configs/sioyek/prefs_user.config;
    ".ctags.d/default.ctags".source = ./configs/_ctags.d/default.ctags;
    ".newsboat/config".source = ./configs/_newsboat/config;
    ".newsboat/urls".source = ./configs/_newsboat/urls;
    ".ripgrep_ignore".source = ./configs/_ripgrep_ignore;
    ".tmuxp/core.yml".source = ./configs/_tmuxp/core.yaml;
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
    # These two lines are needed so xdg-open doesn't
    # get confused and can correctly open links in a browser
    # Source: https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/3
    initExtra = ''
      unset XDG_CURRENT_DESKTOP
      unset DESKTOP_SESSION
      export NODE_OPTIONS="--max-old-space-size=8192"
    '';
    enable = true;
    windowManager.awesome = {
      enable = true;
    };
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
  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      tmux-fzf
    ];
    extraConfig = ''
      # Pane and windows indexes start with one
      # set -g base-index 1
      # setw -g pane-base-index 1
      set -g mouse on
      set -sg escape-time 1
      setw -g mode-keys vi

      # Get rid of confimation
      bind-key & kill-window
      bind-key x kill-pane

      bind-key f last-window

      # bind -n DoubleClick1Pane run-shell "dragon -x '#{pane_current_path}/#{mouse_word}'"

      bind-key u display-popup -h 90% -w 90% -E "weekly_note"
      # FIXME
      bind-key a display-popup -h 90% -w 90% -E "~/venvs/apy/bin/apy add -d default; sleep 2"
      bind-key m run-shell -b tmux-switch.sh

      # Open new windows in the current path
      bind c new-window -c "$HOME"
      bind \\ split-window -h -c '#{pane_current_path}'  # Split panes horizontal
      bind \' split-window -h -c '#{pane_current_path}'  # Split panes horizontal
      bind - split-window -v -c '#{pane_current_path}'  # Split panes vertically

      # bind-key b run "tmux send-keys -t #S:1.1 'tss' Enter"
      bind-key e command-prompt -p "Command:" \
               "run \"tmux list-panes  -F '##{session_name}:##{window_index}.##{pane_index}' \
                      | xargs -I PANE tmux send-keys -t PANE '%1' Enter\""

      bind-key b resize-pane -Z

      # Vi key bindings on Visual Mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi / command-prompt -i -p "search down" "send -X search-forward-incremental \"%%%\""
      bind-key -T copy-mode-vi ? command-prompt -i -p "search up" "send -X search-backward-incremental \"%%%\""

      bind-key r source-file ~/.config/tmux/tmux.conf; display "Config reloaded!"

      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      bind-key -r k resize-pane -U 5
      bind-key -r j resize-pane -D 5
      bind-key -r h resize-pane -L 5
      bind-key -r l resize-pane -R 5

      ######################
      ### DESIGN CHANGES ###
      ######################
      set-option -g status-position top
      set -g status-bg colour234
      set -g status-fg colour255
      # set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      # set -g status-right "#(pmd)"
      set -g status-right ""
      set -g status-left ""
      set -g status-justify left
      set -g status-right-length 500
      set -g status-left-length 0
      set -g status-interval 1

      # #{?window_zoomed_flag,#[fg=red](,}#W#{?window_zoomed_flag,#[fg=red]),}
      setw -g window-status-current-format '#{?window_zoomed_flag,#[fg=colour240] 📺 #W,#[fg=colour240]#W}'

      # setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
      setw -g window-status-format ""

      set -g pane-active-border-style fg=colour188
      set -g pane-border-style fg=colour240
      set -g window-style bg=default
      set -g window-active-style bg=default
    '';
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";
    initExtra = builtins.readFile ./configs/_zshrc;
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
        file = "zsh-completions.plugin.zsh";
      }
      {
        name = "zsh-fzf-tab";
        file = "fzf-tab.plugin.zsh";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
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
  programs.ssh = {
    enable = true;
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519

      Host jumpserver-prod
          HostName 3.68.82.3
          User ec2-user
          IdentityFile ~/.ssh/jumpserver-prod

      Host airbyte-prod
          HostName 10.0.4.51
          User ec2-user
          ProxyJump jumpserver-prod
          IdentityFile ~/.ssh/jumpserver-prod

      Host remarkable
          Hostname 192.168.0.179
          User root
          Port 22
          IdentityFile ~/.ssh/id_ed25519

      Host raspberry-pi
         Hostname 192.168.0.14
         User pi
         IdentityFile ~/.ssh/id_ed25519

      Host nixos-macbookair
         Hostname 192.168.0.70
         User denis
         IdentityFile ~/.ssh/id_ed25519

    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

  services.polybar = {
    enable = true;
    extraConfig = builtins.readFile ./configs/polybar/config.ini;
    script = builtins.readFile ./configs/polybar/launch.sh;
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
      "snaps"
      "tags"
      "venv"
      "play"
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
  nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.0" "electron-25.9.0"];
  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlay
    ];
  };
  systemd.user.startServices = true;
  systemd.user.services.redshift = {
    Unit = {
      Description = "Redshift colour temperature adjuster";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.redshift}/bin/redshift-gtk";
      RestartSec = 3;
      Restart = "always";
    };
  };

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
      ExecStart = "${pkgs.feh}/bin/feh  --bg-scale /home/denis/dotfiles/assets/wallpaper.jpg";
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

  # 0 10 * * * zip -r ~/Sync/Backups/$(date +\%F)_Notes.zip ~/Sync/Notes
  # systemd.user.services.backup-notes = {
  #   Unit = {
  #     Description = "Backup Notes";
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "/bin/sh -c 'zip -r ~/Sync/Backups/$(date +\\%F)_Notes.zip ~/Sync/Notes'";
  #   };
  # };
  #
  # systemd.user.timers.backup-notes = {
  #   Timer.OnCalendar = "*-*-* 10:00:00";
  #   Timer.Persistent = true;
  #   Install.WantedBy = [ "timers.target" ];
  # };
}
