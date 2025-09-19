# Raspberry Pi 3B+ configuration for zeze
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix
    ../../modules/adguard.nix
    ../../modules/brother-hl1110-printer.nix
  ];

  # Use the extlinux boot loader for Raspberry Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking
  networking.hostName = "zeze";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "127.0.0.1" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
    ];
    allowedUDPPorts = [ ];
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
    extraSetFlags = [
      "--accept-dns=true"
      "--advertise-exit-node"
    ];
    useRoutingFeatures = "server";
  };

  # Enable IP forwarding for exit node functionality
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Brother HL-1110 printer setup
  services.brotherHL1110 = {
    enable = true;
    deviceUri = "usb://Brother/HL-1110%20series?serial=D0N609455";
    networkSharing = true;
    setAsDefault = true;
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
