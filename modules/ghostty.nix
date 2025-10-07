{
  lib,
  config,
  ...
}:
{
  options = {
    ghostty.enable = lib.mkEnableOption "enables ghostty";
  };
  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "BlexMono Nerd Font Mono";
        font-thicken = true;
        window-decoration = false;
        app-notifications = "no-clipboard-copy";
        confirm-close-surface = false;
        cursor-style = "block";
        cursor-style-blink = false;
        cursor-invert-fg-bg = true;
        shell-integration-features = "no-cursor";
        keybind = "f11=unbind";
      };

    };
  };
}
