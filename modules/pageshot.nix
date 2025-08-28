{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    pageshot.enable = lib.mkEnableOption "enables pageshot CLI tool";
  };

  config = lib.mkIf config.pageshot.enable {
    home.packages =
      let
        pageshot = pkgs.buildGoModule {
          pname = "pageshot";
          version = "0.1.0";

          src = ../pageshot;

          vendorHash = "sha256-5RQdlgec+4ZqlpPYlEdJrpJYJp78M6jW+XT0mNV7hJ4=";

          meta = with pkgs.lib; {
            description = "Browser screenshot tool using Chromium headless";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.linux ++ platforms.darwin;
          };
        };

        pageshot-wrapped = pkgs.writeScriptBin "pageshot" ''
          #!${pkgs.bash}/bin/bash

          # Set up font configuration
          export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
          export FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts

          # Ensure Chromium can find fonts
          export XDG_DATA_DIRS="${pkgs.noto-fonts}/share:${pkgs.noto-fonts-cjk-sans}/share:${pkgs.noto-fonts-emoji}/share:''${XDG_DATA_DIRS:-}"

          # Set Chrome executable path for chromedp
          export CHROME_PATH=${pkgs.chromium}/bin/chromium

          # Create temporary user data directory
          TMPDIR=$(mktemp -d)
          trap "rm -rf $TMPDIR" EXIT

          # Run pageshot with proper environment
          exec ${pageshot}/bin/pageshot "$@"
        '';
      in
      [
        pageshot-wrapped
      ];
  };
}
