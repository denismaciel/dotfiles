{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.factorio-server;
in
{
  options.factorio-server = {
    enable = mkEnableOption "Factorio dedicated server";

    gameName = mkOption {
      type = types.str;
      default = "Family Factory";
      description = "Name of the Factorio server";
    };

    saveName = mkOption {
      type = types.str;
      default = "family-save";
      description = "Name of the save file to use";
    };

    description = mkOption {
      type = types.str;
      default = "LAN Factorio server";
      description = "Server description";
    };

    port = mkOption {
      type = types.port;
      default = 34197;
      description = "UDP port for the server";
    };
  };

  config = mkIf cfg.enable {
    # Allow Factorio unfree package
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "factorio-headless" ];

    services.factorio = {
      enable = true;
      openFirewall = true; # opens UDP port automatically
      lan = true; # broadcast on LAN
      public = false; # don't publish on the global list
      inherit (cfg) port;
      game-name = cfg.gameName;
      inherit (cfg) description;
      inherit (cfg) saveName;
      loadLatestSave = true; # Continue the most recent save
      requireUserVerification = false; # LAN with no factorio.com login

      # Optional quality-of-life settings
      extraSettings = {
        "autosave-interval" = 5; # Autosave every 5 minutes
      };
    };
  };
}
