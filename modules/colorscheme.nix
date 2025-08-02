{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.colorscheme;

  # Color palettes for both themes
  palettes = {
    light = {
      # Base16 mapping using lumiere colors
      base00 = "#F1F1F1"; # Main background
      base01 = "#e4e4e4"; # Light gray
      base02 = "#d3d3d3"; # Medium light gray (selection bg)
      base03 = "#b8b8b8"; # Medium gray (comments, disabled)
      base04 = "#9e9e9e"; # Medium dark gray
      base05 = "#424242"; # Main foreground text
      base06 = "#000000"; # Light foreground (not used much)
      base07 = "#000000"; # Lightest foreground
      base08 = "#800013"; # Red (errors, deletions)
      base09 = "#cc4c00"; # Orange (modified, special)
      base0A = "#ffda40"; # Yellow (warnings, search)
      base0B = "#00802c"; # Green (success, additions)
      base0C = "#001280"; # Cyan/Blue (info, links)
      base0D = "#001280"; # Blue (info, links, types)
      base0E = "#410080"; # Magenta (keywords, constants)
      base0F = "#410080"; # Brown/Dark red
    };
    dark = {
      # Oxocarbon dark colors
      base00 = "#161616"; # Main background
      base01 = "#262626"; # Lighter background
      base02 = "#393939"; # Selection background
      base03 = "#525252"; # Comments, disabled
      base04 = "#dde1e6"; # Dark foreground
      base05 = "#f2f4f8"; # Main foreground
      base06 = "#ffffff"; # Light foreground
      base07 = "#08bdba"; # Lightest foreground
      base08 = "#3ddbd9"; # Red
      base09 = "#78a9ff"; # Orange
      base0A = "#ee5396"; # Yellow
      base0B = "#33b1ff"; # Green
      base0C = "#ff7eb6"; # Cyan
      base0D = "#42be65"; # Blue
      base0E = "#be95ff"; # Magenta
      base0F = "#82cfff"; # Brown
    };
  };

  currentPalette = palettes.${cfg.theme};

  # FZF color mapping
  fzfColors = {
    bg = currentPalette.base00;
    fg = currentPalette.base05;
    hl = currentPalette.base0D;
    "bg+" = currentPalette.base02;
    "fg+" = currentPalette.base06;
    "hl+" = currentPalette.base0D;
    info = currentPalette.base0B;
    prompt = currentPalette.base08;
    pointer = currentPalette.base0D;
    marker = currentPalette.base09;
    spinner = currentPalette.base0E;
    header = currentPalette.base03;
    border = currentPalette.base02;
  };
in {
  options.colorscheme = {
    enable = lib.mkEnableOption "centralized colorscheme management";

    theme = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "light";
      description = "The theme to use across all applications";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure Stylix with base16 schemes (NixOS level)
    stylix = {
      enable = true;
      polarity = cfg.theme;
      base16Scheme =
        if cfg.theme == "light"
        then "${pkgs.base16-schemes}/share/themes/github.yaml"
        else "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
      fonts = {
        serif = {
          name = "Poppins";
          package = pkgs.google-fonts.override {fonts = ["Poppins"];};
        };
        sansSerif = {
          name = "Poppins";
          package = pkgs.google-fonts.override {fonts = ["Poppins"];};
        };
        monospace = {
          name = "Blex Mono Nerd Font";
          package = pkgs.nerd-fonts.blex-mono;
        };
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-emoji;
        };
      };
      fonts.sizes = {
        applications = 9;
        terminal = 10;
        desktop = 9;
        popups = 9;
      };
    };

    # Home Manager configuration
    home-manager.users.denis = {
      # Configure Ghostty with custom theme
      programs.ghostty = {
        enable = true;
        settings = {
          theme = "dennich-${cfg.theme}";
          font-family = "BlexMono Nerd Font Mono";
          window-decoration = false;
          app-notifications = "no-clipboard-copy";
          confirm-close-surface = false;
          cursor-style = "block";
          cursor-style-blink = false;
          cursor-invert-fg-bg = true;
        };
        themes."dennich-${cfg.theme}" = {
          background = currentPalette.base00;
          foreground = currentPalette.base05;
          cursor-color = currentPalette.base05;
          selection-background = currentPalette.base02;
          selection-foreground = currentPalette.base05;
          palette = [
            "0=${currentPalette.base00}"
            "1=${currentPalette.base08}"
            "2=${currentPalette.base0B}"
            "3=${currentPalette.base0A}"
            "4=${currentPalette.base0D}"
            "5=${currentPalette.base0E}"
            "6=${currentPalette.base0C}"
            "7=${currentPalette.base05}"
            "8=${currentPalette.base03}"
            "9=${currentPalette.base08}"
            "10=${currentPalette.base0B}"
            "11=${currentPalette.base0A}"
            "12=${currentPalette.base0D}"
            "13=${currentPalette.base0E}"
            "14=${currentPalette.base0C}"
            "15=${currentPalette.base07}"
          ];
        };
      };

      # Configure FZF with theme colors
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultOptions = [
          "--height 100%"
          "--reverse"
          "--border"
          "--ansi"
          "--multi"
          "--preview-window=right:70%"
        ];
        colors = lib.mkForce fzfColors;
        defaultCommand = "rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore";
        fileWidgetCommand = "rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore";
        changeDirWidgetOptions = ["--preview 'ls -la {}'"];
        historyWidgetOptions = [
          "--sort"
          "--exact"
        ];
      };

      # Shell functions that depend on fzf
      programs.zsh.initContent = lib.mkAfter ''
        # fzf completion functions from _zshrc
        function _fzf_compgen_dir() {
          fd --type d --hidden --follow --exclude ".git" --exclude "venv" . "$1"
        }

        function _fzf_compgen_path() {
          fd --hidden --follow --exclude ".git" --exclude "venv" . "$1"
        }

        # fzf helper function
        function fzf-down() {
          fzf --height 50% "$@" --border
        }
      '';

      # Create theme preference file for Neovim
      home.file.".config/dennich-colorscheme".text = cfg.theme;
    };
  };
}
