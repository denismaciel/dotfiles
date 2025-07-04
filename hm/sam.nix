{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/git.nix
  ];
  home.packages = with pkgs; [
    biome
    btop
    cargo
    csvlens
    dbmate
    dig
    direnv
    dockerfile-language-server-nodejs
    fd
    ffmpeg
    fzf
    gcc
    gnumake
    gofumpt
    gomi
    htop
    hyperfine
    jq
    jsonnet
    jsonnet-language-server
    kubectl
    lazydocker
    lsof
    lua
    markdownlint-cli
    nil
    nixfmt-rfc-style
    nodePackages_latest.bash-language-server
    nodePackages_latest.prettier
    nodePackages_latest.typescript-language-server
    openssl
    pyright
    python313Packages.mdformat
    rclone
    ripgrep
    rust-analyzer
    rustc
    sqlite
    statix
    stow
    stylua
    sumneko-lua-language-server
    tailwindcss-language-server
    terraform-ls
    tree
    typescript
    universal-ctags
    unzip
    uv
    vscode-langservers-extracted
    yaml-language-server
    yq-go
    zoxide
  ];
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.file = {
    ".npmrc".source = ../configs/_npmrc;
    ".ipython/profile_default/ipython_config.py".source = ../configs/_ipython/profile_default/ipython_config.py;
    ".ipython/profile_default/custom_init.py".source = ../configs/_ipython/profile_default/custom_init.py;
    ".config/direnv/direnv.toml".source = ../configs/direnv/direnv.toml;
    ".config/fd/ignore".source = ../configs/fd/ignore;
    ".config/pgcli/config".source = ../configs/pgcli/config;
    ".ctags.d/default.ctags".source = ../configs/_ctags.d/default.ctags;
    ".ripgrep_ignore".source = ../configs/_ripgrep_ignore;
    ".tmuxp/core.yml".source = ../configs/_tmuxp/core.yaml;
  };
  targets.genericLinux.enable = true;

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

  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      tmux-fzf
    ];
    extraConfig = builtins.readFile ../configs/.tmux.conf;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";
    initContent = builtins.readFile ../configs/_zshrc;
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
      # {
      #   name = "zsh-completions";
      #   src = pkgs.zsh-completions;
      # }
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

  services.udiskie.enable = true; # Auto mount devices
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];
  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };
  systemd.user.startServices = true;
}
