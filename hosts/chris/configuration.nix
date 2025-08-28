{
  pkgs,
  lib,
  ...
}: let
  colors = import ../../modules/color.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/graphics.nix
    ../../modules/unfree.nix
    ../../modules/warp.nix
    ../../modules/redshift.nix
    ../../modules/polybar.nix
  ];

  nix.settings.trusted-users = ["denis"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # necessary to build nixos for raspberrypi
  warp.enable = false;
  redshift.enable = false;

  stylix = {
    enable = true;
    polarity = colors.theme;
    image = ../../assets/black.png;
    base16Scheme =
      if colors.theme == "light"
      then "${pkgs.base16-schemes}/share/themes/github.yaml"
      else "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    targets.qt.enable = false;
    fonts = {
      serif = {
        name = "Poppins";
        package = pkgs.google-fonts.override {fonts = ["Poppins"];};
      };
      sansSerif = {
        name = "Poppins";
        package = pkgs.google-fonts.override {fonts = ["Poppins"];};
      };
      monospace = {
        name = "Blex Mono Nerd Font";
        package = pkgs.nerd-fonts.blex-mono;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji;
      };
    };
    fonts.sizes = {
      applications = 9;
      terminal = 10;
      desktop = 9;
      popups = 9;
    };
  };

  hardware.keyboard.zsa.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    # --exit-node-allow-lan-access=true is necessay so I can access docker containers
    # via loccalhost.
    extraUpFlags = [
      "--accept-dns=true"
      "--exit-node=100.74.57.103"
      "--exit-node-allow-lan-access=true"
    ];
  };
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["denis"];
  users.groups.input.members = ["denis"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    nameservers = ["1.1.1.1"];
    hostName = "chris";
    networkmanager.enable = true;
    firewall = {
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [3000];
    };
  };

  # Automatically set timezone based on location
  location.provider = "geoclue2";
  services.geoclue2 = {
    enable = true;
    appConfig.automatic-timezoned = {
      isAllowed = true;
      isSystem = true;
    };
  };
  services.automatic-timezoned.enable = true;
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

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFJLQFWmH33Gmo2pGMtaQ0gPfAuqMZwodMUvDJwFTMy denispmaciel@gmail.com"
    ];
  };

  programs.nh = {
    enable = true;
    flake = "../../.#chris";
  };
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = ["denis"];
  };
  security.polkit.enable = true;

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;
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
    kdePackages.dolphin
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

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
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
}
