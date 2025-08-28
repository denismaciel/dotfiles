# Lean print server configuration for sam
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/unfree.nix
    ../../modules/warp.nix
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
  networking.hostName = "sam";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 443 2222 7422 631]; # SSH + printer
    allowedUDPPorts = [5353 631]; # Avahi + printer
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
      direnv
      git
      tmux
      zip
    ];
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    usbutils # For printer USB detection
    wget
  ];

  # Enable touchpad support (laptop server - emergency use)
  services.libinput.enable = true;

  # System programs
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Services
  warp.enable = true;
  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
    ports = [22 443 2222 7422];
    settings.PasswordAuthentication = true; # Keep for local access
  };

  # Printer services
  services.printing = {
    enable = true;
    browsing = true;
    defaultShared = true;
    listenAddresses = ["*:631"];
    allowFrom = ["all"];
    openFirewall = true;
    drivers = with pkgs; [
      brlaser
      brgenml1cupswrapper
      brgenml1lpr
    ];
  };

  # Brother HL-1110 printer configuration
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother-HL-1110";
        location = "Home";
        description = "Brother HL-1110 series";
        deviceUri = "usb://Brother/HL-1110%20series?serial=D0N609455";
        model = "drv:///brlaser.drv/br1110.ppd";
        ppdOptions = {
          printer-is-shared = "true";
        };
      }
    ];
    ensureDefaultPrinter = "Brother-HL-1110";
  };

  # Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # SSH agent configuration
  programs.ssh.extraConfig = ''
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
  '';

  # Development tools
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
    ];
  };

  # Virtualization
  virtualisation.docker.enable = true;

  system.stateVersion = "24.05";
}
