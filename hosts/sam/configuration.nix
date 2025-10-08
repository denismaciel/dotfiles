# Lean print server configuration for sam
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix
    ../../modules/unfree.nix
    ../../modules/warp.nix
    ../../modules/openttd.nix
    ../../modules/gaming.nix
    # ../../modules/minecraft-server.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disable sleep/suspend for server
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  gaming = {
    enable = false;
    steam.enable = false; # Server doesn't need Steam
    firewall.openGamePorts = [
      20595 # 0 A.D. multiplayer
      34197 # Factorio multiplayer default port
    ];
  };

  # Networking
  networking.hostName = "sam";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      443
      2222
      7422
      631
    ]; # SSH + printer
    allowedUDPPorts = [
      5353
      631
    ]; # Avahi + printer
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

  # Enable Plasma Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # System packages (essential + previously user packages)
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    btop
    direnv
    firefox
    prismlauncher
    tmux
    zip
  ];

  # Enable touchpad support (laptop server - emergency use)
  services.libinput.enable = true;

  # Services
  warp.enable = true;
  services.tailscale.enable = true;
  services.openssh = {
    ports = [
      22
      443
      2222
      7422
    ];
    settings.PasswordAuthentication = true; # Keep for local access
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

  ##############################################################################
  # Factorio dedicated server (LAN-only, kid-friendly peaceful mode)
  ##############################################################################

  # Allow unfree for Factorio headless server
  nixpkgs.config.allowUnfree = true;

  services.factorio = {
    enable = true;
    openFirewall = true; # Opens UDP 34197 automatically
    lan = true; # Broadcast on LAN only
    public = false; # Do not publish on the master server
    port = 34197; # Default UDP port
    game-name = "KidsFactory";
    description = "Ben & Chris' peaceful factory";
    saveName = "KidsFactory"; # Will load KidsFactory.zip if present
    loadLatestSave = true; # Continue the most recent save
    requireUserVerification = false; # LAN with no factorio.com login
    # Optional quality-of-life:
    extraSettings = {
      "autosave-interval" = 5; # Autosave every 5 minutes
    };
  };

  system.stateVersion = "24.05";
}
