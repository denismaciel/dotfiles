{
  description = "Browser screenshot tool using Go and Chromium";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        pageshot = pkgs.buildGoModule {
          pname = "pageshot";
          version = "0.1.0";

          src = ./.;

          vendorHash = "sha256-5RQdlgec+4ZqlpPYlEdJrpJYJp78M6jW+XT0mNV7hJ4=";

          meta = with pkgs.lib; {
            description = "Browser screenshot tool using Chromium headless";
            license = licenses.mit;
            maintainers = [];
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
      in {
        packages = {
          default = pageshot-wrapped;
          pageshot = pageshot;
          pageshot-wrapped = pageshot-wrapped;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = pageshot-wrapped;
            name = "pageshot";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            delve
            chromium
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-emoji
          ];

          shellHook = ''
            echo "Development environment for pageshot"
            echo "- Go version: $(go version)"
            echo "- Chromium available at: ${pkgs.chromium}/bin/chromium"
            export CHROME_PATH=${pkgs.chromium}/bin/chromium
          '';
        };
      }
    );
}
