# Lean server configuration for anton
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/unfree.nix
  ];

  # Nix settings
  nix.settings.trusted-users = ["denis"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disable sleep/suspend for server
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Networking
  networking.hostName = "anton";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 443 2222 7422];
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

  # User configuration
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFJLQFWmH33Gmo2pGMtaQ0gPfAuqMZwodMUvDJwFTMy denispmaciel@gmail.com"
    ];
    packages = with pkgs; [
      btop
      tmux
      zip
    ];
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
  ];

  # Enable touchpad support (laptop server - emergency use)
  services.libinput.enable = true;

  # System programs
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Services
  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
    ports = [22 443 2222 7422];
    settings.PasswordAuthentication = false;
  };

  # Virtualization
  virtualisation.docker.enable = true;

  system.stateVersion = "24.05";
}
