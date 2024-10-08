# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/warp.nix
  ];

  warp.enable = true;

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
    hostName = "nixos-x1carbon-9gen"; # Define your hostname.
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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
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

  # programs.hyprland.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        settings = {
          main = {
            pause = "volumeup";
            scrolllock = "volumedown";
            sysrq = "mute";
          };
        };
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
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
    wofi
    dolphin
    kitty
    firefox
    git
    zenity
    groff
    neovim
    wget
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  virtualisation.docker.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # systemd.services.cloudflare-warp = {
  #   enable = true;
  #   description = "Warp server";
  #   path = [pkgs.cloudflare-warp];
  #   unitConfig = {
  #     Type = "simple";
  #   };
  #   serviceConfig = {
  #     ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
  #   };
  #   wantedBy = ["multi-user.target"];
  # };
  # services.fprintd.enable = true;
  # security.pam.services = {
  #   login.unixAuth = false;
  #   # fprint is not stable, locked sometimes after suspend
  #   login.fprintAuth = false;
  #   sddm.fprintAuth = true;
  #   xscreensaver.fprintAuth = true;
  #   kwallet.fprintAuth = true;
  # };

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
  stylix.image = /home/denis/dotfiles/assets/wallpaper.jpg;

  stylix.fonts = {
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
      package = pkgs.nerdfonts.override {fonts = ["IBMPlexMono"];};
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };

  stylix.fonts.sizes = {
    applications = 9;
    terminal = 9;
    desktop = 9;
    popups = 9;
  };
  location.provider = "geoclue2";
  services.redshift = {
    enable = true;
    temperature = {
      day = 6000;
      night = 3700;
    };
    brightness = {
      day = "0.9";
      night = "0.9";
    };
  };
}
