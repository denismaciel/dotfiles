# Brother HL-1110 Printer Module
# Provides CUPS printing with network sharing and USB support
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.brotherHL1110;
in
{
  options.services.brotherHL1110 = {
    enable = mkEnableOption "Brother HL-1110 printer support";

    deviceUri = mkOption {
      type = types.str;
      default = "usb://Brother/HL-1110%20series?serial=D0N609455";
      description = "Device URI for the Brother HL-1110 printer";
    };

    networkSharing = mkOption {
      type = types.bool;
      default = true;
      description = "Enable network printer sharing";
    };

    setAsDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Set as the default printer";
    };
  };

  config = mkIf cfg.enable {
    # Enable CUPS printing service
    services.printing = {
      enable = true;
      browsing = cfg.networkSharing;
      defaultShared = cfg.networkSharing;
      listenAddresses = mkIf cfg.networkSharing [ "*:631" ];
      allowFrom = mkIf cfg.networkSharing [ "all" ];
      openFirewall = cfg.networkSharing;
      drivers = with pkgs; [
        brlaser # Open source Brother laser printer driver
      ];
    };

    # Brother HL-1110 printer configuration
    hardware.printers = {
      ensurePrinters = [
        {
          name = "Brother-HL-1110";
          location = "Home";
          description = "Brother HL-1110 series";
          inherit (cfg) deviceUri;
          model = "drv:///brlaser.drv/br1110.ppd";
          ppdOptions = mkIf cfg.networkSharing {
            printer-is-shared = "true";
          };
        }
      ];
      ensureDefaultPrinter = mkIf cfg.setAsDefault "Brother-HL-1110";
    };

    # Avahi for network printer discovery (Bonjour/mDNS)
    services.avahi = mkIf cfg.networkSharing {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # Open firewall ports for CUPS
    networking.firewall = mkIf cfg.networkSharing {
      allowedTCPPorts = [ 631 ];
      allowedUDPPorts = [ 631 ];
    };

    # Add useful utilities for printer management
    environment.systemPackages = with pkgs; [
      usbutils # For lsusb command to detect USB printers
    ];
  };
}
