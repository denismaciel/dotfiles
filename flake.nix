{
  description = "NixOS configuration";
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    stylix.url = "github:danth/stylix";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dennich = {
      url = "path:./python-packages/dennich";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      niri-flake,
      git-hooks,
      home-manager,
      nixpkgs,
      sops-nix,
      stylix,
      ...
    }:
    let
      # Define systems for each host
      systems = {
        ben = "x86_64-linux";
        chris = "x86_64-linux";
        anton = "x86_64-linux";
        sam = "x86_64-linux";
        zeze = "aarch64-linux";
      };

      # Helper to construct a NixOS system for a host
      mkNixosSystem =
        hostname: modules:
        let
          system = systems.${hostname};
          dennichPkg = inputs.dennich.packages.${system}.default;
        in
        nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = { inherit inputs dennichPkg; };
        };

      # Small helper to reduce repeated Home Manager boilerplate
      hmFor =
        path: extraSpecialArgsFn:
        { config, ... }:
        {
          home-manager.useUserPackages = true;
          home-manager.users.denis = import path;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inherit inputs;
          }
          // (extraSpecialArgsFn { inherit config; });
        };

      # All supported systems for git-hooks
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs allSystems;

      # Git hooks configuration
      gitHooksFor =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Nix tooling
            nixfmt-rfc-style.enable = true;
            statix = {
              enable = true;
              settings.ignore = [ ".direnv" ];
            };
            deadnix.enable = true;

            # Shell scripting
            # shfmt.enable = true;  # temporarily disabled due to formatting conflicts
            # shellcheck.enable = true;  # temporarily disabled

            # Lua
            stylua.enable = true;

            # Python - ruff for linting and formatting
            ruff = {
              enable = true;
              excludes = [ "configs/_ipython/.*" ];
            };
            ruff-format = {
              enable = true;
              excludes = [ "configs/_ipython/.*" ];
            };

            # Secrets scanning
            ripsecrets.enable = true;

            # Basic file checks - using correct hook names
            check-json.enable = true;
            check-merge-conflicts.enable = true;
            check-yaml.enable = true;
          };
        };
    in
    {
      nixosConfigurations = {
        ben = mkNixosSystem "ben" [
          ./hosts/ben/configuration.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          (hmFor ./hm/server-base.nix (_: { }))
        ];

        chris = mkNixosSystem "chris" [
          ./hosts/chris/configuration.nix
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
          # Niri via sodiboo/niri-flake
          niri-flake.nixosModules.niri
          home-manager.nixosModules.home-manager

          # Enable Niri system-wide (module is provided by nixosModules.niri)
          (_: {
            programs.niri.enable = true;
          })
          # Then pass the processed paths to Home Manager
          (hmFor ./hm/chris/default.nix (
            _:
            let
              dennichPkg = inputs.dennich.packages.${systems.chris}.default;
            in
            {
              inherit dennichPkg;

            }
          ))
        ];

        anton = mkNixosSystem "anton" [
          ./hosts/anton/configuration.nix
          home-manager.nixosModules.home-manager
          (hmFor ./hm/server-base.nix (_: { }))
        ];

        sam = mkNixosSystem "sam" [
          ./hosts/sam/configuration.nix
          home-manager.nixosModules.home-manager
          (hmFor ./hm/server-base.nix (_: { }))
        ];

        zeze = mkNixosSystem "zeze" [
          ./hosts/zeze/configuration.nix
          home-manager.nixosModules.home-manager
          (hmFor ./hm/server-base.nix (_: { }))
        ];
      };

      # Git hooks configuration for development and CI
      checks = forAllSystems (system: {
        pre-commit = gitHooksFor system;
      });

      # Development shells with git-hooks integration
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          preCommit = gitHooksFor system;
        in
        {
          default = pkgs.mkShell {
            # Tools needed by hooks become available to developers
            packages = preCommit.packages or [ ];

            # Installs .git/hooks and keeps them updated when entering the shell
            shellHook = ''
              unset LD_LIBRARY_PATH
              ${preCommit.shellHook}
            '';
          };
        }
      );
    };
}
