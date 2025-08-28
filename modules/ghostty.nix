{
  lib,
  config,
  ...
}: let
  colors = import ./color.nix;
  inherit (colors) theme palette;
in {
  options = {
    ghostty.enable = lib.mkEnableOption "enables ghostty";
  };
  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "dennich-${theme}";
        font-family = "BlexMono Nerd Font";
        window-decoration = false;
        app-notifications = "no-clipboard-copy";
        confirm-close-surface = false;
        cursor-style = "block";
        cursor-style-blink = false;
        cursor-invert-fg-bg = true;
        shell-integration-features = "no-cursor";
      };
      themes."dennich-${theme}" = {
        background = palette.base00;
        foreground = palette.base05;
        cursor-color = palette.base05;
        selection-background = palette.base02;
        selection-foreground = palette.base05;
        palette = [
          "0=${palette.base00}"
          "1=${palette.base08}"
          "2=${palette.base0B}"
          "3=${palette.base0A}"
          "4=${palette.base0D}"
          "5=${palette.base0E}"
          "6=${palette.base0C}"
          "7=${palette.base05}"
          "8=${palette.base03}"
          "9=${palette.base08}"
          "10=${palette.base0B}"
          "11=${palette.base0A}"
          "12=${palette.base0D}"
          "13=${palette.base0E}"
          "14=${palette.base0C}"
          "15=${palette.base07}"
        ];
      };
    };
  };
}
