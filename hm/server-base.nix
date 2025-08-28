{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../modules/unfree.nix
    ../modules/git.nix
    ../modules/fzf.nix
  ];
  home.packages = with pkgs; [
    # System monitoring
    btop
    htop
    lsof

    # Core utilities
    git
    neovim
    tmux
    unzip

    # Network tools
    dig
    jq

    # File operations
    fd
    ripgrep
    zoxide

    # Development essentials
    gcc
    gnumake

    # Container management
    kubectl
    lazydocker

    # Database tools
    dbmate
    sqlite

    # Nix tools
    nixfmt-rfc-style
    statix

    # System tools
    openssl
    stow
  ];
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.file = {
    # Essential server configs only
    ".config/fd/ignore".source = ../configs/fd/ignore;
    ".ctags.d/default.ctags".source = ../configs/_ctags.d/default.ctags;
    ".ripgrep_ignore".source = ../configs/_ripgrep_ignore;
    ".tmuxp/core.yml".source = ../configs/_tmuxp/core.yaml;
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
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
  };

  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };
  systemd.user.startServices = true;
}
