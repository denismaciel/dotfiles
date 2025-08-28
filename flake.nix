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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    sops-nix,
    stylix,
    ...
  }: let
    # Define systems for each host
    systems = {
      ben = "x86_64-linux";
      chris = "x86_64-linux";
      anton = "x86_64-linux";
      sam = "x86_64-linux";
    };

    # Helper to construct a NixOS system for a host
    mkNixosSystem = hostname: modules: let
      system = systems.${hostname};
      dennichPkg = inputs.dennich.packages.${system}.default;
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs dennichPkg;};
        modules = modules;
      };

    # Small helper to reduce repeated Home Manager boilerplate
    hmFor = path: extraSpecialArgsFn: {config, ...}: {
      home-manager.useUserPackages = true;
      home-manager.users.denis = import path;
      home-manager.extraSpecialArgs = {inherit inputs;} // (extraSpecialArgsFn {inherit config;});
    };
  in {
    nixosConfigurations = {
      ben = mkNixosSystem "ben" [
        ./hosts/ben/configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        (hmFor ./hm/server-base.nix (_: {}))
      ];

      chris = mkNixosSystem "chris" [
        ./hosts/chris/configuration.nix
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        # Home Manager with extra args for polybar + dennich
        (hmFor ./hm/chris/default.nix ({config, ...}: let
          dennichPkg = inputs.dennich.packages.${systems.chris}.default;
        in {
          inherit dennichPkg;
          inherit (config.polybar-dennich) processedConfigPath processedScriptPath;
        }))
        # Configure the polybar-dennich module
        ({pkgs, ...}: let
          dennichPkg = inputs.dennich.packages.${systems.chris}.default;
        in {
          polybar-dennich = {
            enable = true;
            dennichPkg = dennichPkg;
          };
          environment.systemPackages = [dennichPkg];
        })
      ];

      anton = mkNixosSystem "anton" [
        ./hosts/anton/configuration.nix
        home-manager.nixosModules.home-manager
        (hmFor ./hm/server-base.nix (_: {}))
      ];

      sam = mkNixosSystem "sam" [
        ./hosts/sam/configuration.nix
        home-manager.nixosModules.home-manager
        (hmFor ./hm/server-base.nix (_: {}))
      ];
    };
  };
}
