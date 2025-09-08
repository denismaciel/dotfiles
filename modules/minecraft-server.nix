{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.minecraft-server;
in
{
  options.minecraft-server = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Minecraft Paper server";
    };

    motd = mkOption {
      type = types.str;
      default = "Paper on NixOS";
      description = "Message of the day for the server";
    };

    maxPlayers = mkOption {
      type = types.int;
      default = 10;
      description = "Maximum number of players allowed on the server";
    };

    memoryMin = mkOption {
      type = types.str;
      default = "2G";
      description = "Minimum memory allocation for JVM";
    };

    memoryMax = mkOption {
      type = types.str;
      default = "4G";
      description = "Maximum memory allocation for JVM";
    };

    whitelist = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Whitelist of players (username = uuid)";
    };
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;
      package = pkgs.papermc;
      jvmOpts = "-Xms${cfg.memoryMin} -Xmx${cfg.memoryMax} -Djava.net.preferIPv4Stack=true";
      serverProperties = {
        motd = cfg.motd;
        max-players = cfg.maxPlayers;
        white-list = false; # Allow anyone to join
        online-mode = false; # Allow offline/cracked clients
        gamemode = "creative"; # Creative mode by default
        force-gamemode = true; # Enforce gamemode for all players
      };
      whitelist = cfg.whitelist;
    };
  };
}
