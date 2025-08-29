# Raspberry Pi 3B+ configuration for zeze
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix
  ];

  # Use the extlinux boot loader for Raspberry Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking
  networking.hostName = "zeze";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH
    trustedInterfaces = [ "tailscale0" ]; # Trust Tailscale interface
  };

  # Localization
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # SSH settings (service already enabled in denis-user.nix)
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-dns"
    ];
  };

  # System packages (minimal for Pi)
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    htop
  ];

  # State version - DO NOT CHANGE
  system.stateVersion = "25.05";
}
