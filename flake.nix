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
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nur.url = "github:nix-community/NUR";
    stylix.url = "github:danth/stylix";
    xremap-flake.url = "github:xremap/nix-flake";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
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
    ghostty,
    ...
  }: {
    # homeConfigurations = {
    #   denis = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.${"x86_64-linux"};
    #     extraSpecialArgs = {inherit inputs;};
    #     modules = [
    #       ./home.nix
    #     ];
    #   };
    # };
    nixosConfigurations = {
      ben = nixpkgs.lib.nixosSystem rec {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./hosts/ben/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            environment.systemPackages = [
              ghostty.packages.x86_64-linux.default
            ];
          }
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./hm/ben.nix;
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
