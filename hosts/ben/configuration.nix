{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/warp.nix
    ../../modules/stylix.nix
  ];

  nix.settings.trusted-users = ["denis"];
  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # necessary to build nixos for raspberrypi
  warp.enable = false;
  hardware.keyboard.zsa.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.tailscale.enable = true;
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["denis"];
  users.groups.input.members = ["denis"];

  services.vaultwarden.enable = true;

  # DroidCamX
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.kernelModules = ["v4l2loopback"];
  programs.adb.enable = true; # enable android proper data tethering
  networking.firewall.allowedTCPPorts = [4747];
  networking.firewall.allowedUDPPorts = [4747];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos-ben";
    networkmanager.enable = true;
    extraHosts = ''
      127.0.0.1 linkedin.com
      127.0.0.1 www.linkedin.com
      127.0.0.1 youtube.com
      127.0.0.1 www.youtube.com
      127.0.0.1 twitter.com
      127.0.0.1 www.twitter.com
      127.0.0.1 x.com
      127.0.0.1 www.x.com
    '';
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

  services.gnome.gnome-keyring.enable = true;
  services.displayManager = {
    sddm.enable = true;
    defaultSession = "none+awesome";
  };
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    autoRepeatDelay = 200;
    autoRepeatInterval = 40;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [luarocks];
    };
    xkb = {
      layout = "us";
      variant = "";
      options = "ctrl:nocaps"; # Remap CapsLock to Control
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = ["networkmanager" "wheel" "docker" "audio"];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password"
    ];
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = ["denis"];
  };
  security.polkit.enable = true;
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
  programs.zsh.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
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
  services.redshift = {
    enable = true;
    temperature = {
      day = 4500; # Lowered from 6000K to 4500K for a warmer daytime
      night = 2700; # Lowered from 3700K to 2700K for a redder night
    };
    brightness = {
      day = "1";
      night = "0.9";
    };
  };
}
