{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.gaming;
in
{
  options.gaming = {
    enable = mkEnableOption "gaming support";

    steam = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam gaming platform";
      };
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        openttd
        zeroad
      ];
      description = "Additional gaming packages to install";
    };

    firewall = {
      openSteamPorts = mkOption {
        type = types.bool;
        default = true;
        description = "Open firewall ports for Steam Remote Play and Dedicated Server";
      };

      openGamePorts = mkOption {
        type = types.listOf types.int;
        default = [ 20595 ]; # 0 A.D. multiplayer
        description = "Additional UDP ports to open for games";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install gaming packages
    environment.systemPackages = cfg.packages;

    # Steam configuration
    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = cfg.firewall.openSteamPorts;
      dedicatedServer.openFirewall = cfg.firewall.openSteamPorts;
    };

    # Firewall configuration for games
    networking.firewall.allowedUDPPorts = cfg.firewall.openGamePorts;

    # Enable 32-bit support for gaming (required by Steam)
    hardware.graphics = mkIf cfg.steam.enable {
      enable32Bit = true;
    };

    # Enable sound support for gaming
    services.pipewire = {
      alsa.support32Bit = mkIf cfg.steam.enable true;
    };
  };
}
