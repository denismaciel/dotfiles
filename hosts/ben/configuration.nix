{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix

    ../../modules/unfree.nix
    ../../modules/vaultwarden-backup.nix
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # necessary to build nixos for raspberrypi

  # Disable sleep/suspend for server
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.tailscale = {
    enable = true;
    extraUpFlags = ["--accept-dns" "--advertise-exit-node"];
  };
  # Enable IP forwarding for exit node functionality
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      dns = {
        bind_port = 53;
        bind_hosts = ["0.0.0.0" "::"];
      };
    };
  };

  # Trust Tailscale and local network interfaces in firewall
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["denis"];
  users.groups.input.members = ["denis"];

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "0.0.0.0";
      DOMAIN = "https://ben.tail0b5947.ts.net:8222";
      ROCKET_TLS = ''{certs="/etc/vaultwarden/ben.tail0b5947.ts.net.crt",key="/etc/vaultwarden/ben.tail0b5947.ts.net.key"}'';
    };
  };

  services.vaultwarden-backup = {
    enable = true;
    schedule = "daily";
  };

  system.activationScripts.vaultwarden-certs = ''
    mkdir -p /etc/vaultwarden
    cp /home/denis/dotfiles/ben.tail0b5947.ts.net.crt /etc/vaultwarden/
    cp /home/denis/dotfiles/ben.tail0b5947.ts.net.key /etc/vaultwarden/
    chown vaultwarden:vaultwarden /etc/vaultwarden/ben.tail0b5947.ts.net.*
    chmod 600 /etc/vaultwarden/ben.tail0b5947.ts.net.*
  '';

  # DroidCamX
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.kernelModules = ["v4l2loopback"];
  programs.adb.enable = true; # enable android proper data tethering
  networking.firewall.allowedTCPPorts = [22 4747];
  networking.firewall.allowedUDPPorts = [4747];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "ben";
    networkmanager.enable = true;
    nameservers = ["127.0.0.1"];
  };

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # services.gnome.gnome-keyring.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Don't suspend when lid is closed (server mode)
  services.logind.lidSwitch = "ignore";

  # Define a user account. Don't forget to set a password with ‘passwd’.

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib # numpy
    ];
  };
  environment.systemPackages = with pkgs; [
    git
    groff
    neovim
    portaudio
    wget
    zenity
    zip
  ];

  environment.extraInit = ''
    export PATH=$PATH:$HOME/.local/bin
  '';

  programs.dconf.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.

  # SSH server configuration
  services.openssh = {
    ports = [22 443 2222 7422];
    settings.PasswordAuthentication = false;
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_rsa
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  virtualisation.docker.enable = true;
  # location.provider = "geoclue2";
  location = {
    latitude = 39.3999;
    longitude = 8.2245;
  };
}
