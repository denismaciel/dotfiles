{
  description = "NixOS configuration";
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/master";
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
  };

  outputs = inputs @ {
    dennich,
    firefox-addons,
    home-manager,
    nixos-hardware,
    nixpkgs,
    nur,
    ...
  }: {
    nixosConfigurations = {
      ben = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./hosts/ben/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/ben.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
          {
            environment.systemPackages = [];
          }
        ];
      };
      chris = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./hosts/chris/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (final: prev: {
                dennich = inputs.dennich.packages.${final.system}.default;
              })
            ];
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/chris/default.nix;
            home-manager.extraSpecialArgs = let
              dennichPkg = inputs.dennich.packages.x86_64-linux.default;
              pkgsForProcessing = nixpkgs.legacyPackages.x86_64-linux;
            in {
              inherit inputs;
              dennichPkg = dennichPkg;
              # Pass polybar processed configs to Home Manager
              polybarProcessedConfig = pkgsForProcessing.replaceVars ./configs/polybar/config.ini {
                dennichTodoPath = "${dennichPkg}/bin/dennich-todo";
              };
              polybarProcessedScript = ./configs/polybar/launch.sh;
            };
            # Configure the awesome-dennich module
            awesome-dennich = {
              enable = true;
              dennichPkg = inputs.dennich.packages.x86_64-linux.default;
            };
            # Configure the polybar-dennich module
            polybar-dennich = {
              enable = true;
              dennichPkg = inputs.dennich.packages.x86_64-linux.default;
            };
          }
          ({pkgs, ...}: {
            environment.systemPackages = with pkgs; [
              inputs.dennich.packages.x86_64-linux.default
            ];
          })
        ];
      };
      anton = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/anton/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/sam.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
      sam = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/sam/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/sam.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
    };
  };
}
