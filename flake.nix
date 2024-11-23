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
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    stylix.url = "github:danth/stylix";
    nur.url = "github:nix-community/NUR";
    xremap-flake.url = "github:xremap/nix-flake";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    alejandra,
    firefox-addons,
    home-manager,
    hyprland,
    nixos-hardware,
    nixpkgs,
    nur,
    xremap-flake,
    ...
  }: {
    homeConfigurations = {
      denis = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${"x86_64-linux"};
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home.nix
        ];
      };
    };
    nixosConfigurations = {
      ben = nixpkgs.lib.nixosSystem rec {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./hosts/ben/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
          {
            environment.systemPackages = [alejandra.defaultPackage.${system}];
          }
        ];
      };
      anton = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/anton/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/home-sam.nix;
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
            home-manager.users.denis = import ./hm/home-sam.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
    };
  };
}
