{
  description = "NixOS configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      # Replace the official cache with a mirror located in China
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
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
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    nixos-hardware,
    alejandra,
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
      x1carbon9gen = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/x1carbon9gen/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
          {
            environment.systemPackages = [alejandra.defaultPackage.${system}];
          }
        ];
      };
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.denis = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
    };
  };
}
