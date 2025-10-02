{
  pkgs,
  ...
}:
let
  colors = import ../../modules/color.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix
    ../../modules/graphics.nix
    ../../modules/unfree.nix
    ../../modules/warp.nix
    ../../modules/gaming.nix
    ../../modules/chris-networking.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; # necessary to build nixos for raspberrypi
  warp.enable = false;

  gaming.enable = true;

  stylix = {
    enable = true;
    polarity = colors.theme;
    image = ../../assets/black.png;
    base16Scheme =
      if colors.theme == "light" then
        "${pkgs.base16-schemes}/share/themes/github.yaml"
      else
        "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    targets.qt.enable = false;
    fonts = {
      serif = {
        name = "Poppins";
        package = pkgs.google-fonts.override { fonts = [ "Poppins" ]; };
      };
      sansSerif = {
        name = "Poppins";
        package = pkgs.google-fonts.override { fonts = [ "Poppins" ]; };
      };
      monospace = {
        name = "Blex Mono Nerd Font";
        package = pkgs.nerd-fonts.blex-mono;
      };
      emoji = {
        name = "Blex Mono Nerd Font";
        package = pkgs.nerd-fonts.blex-mono;
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
  # Networking moved to ../../modules/chris-networking.nix
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "denis" ];
  users.groups.input.members = [ "denis" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 2097152; # 2M
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_queued_events" = 65536;
  };

  # networking configuration imported from module

  # DNS configuration imported from module

  # systemd-resolved configuration for split DNS

  # Automatically set timezone based on location
  location.provider = "geoclue2";
  services.geoclue2 = {
    enable = true;
    appConfig = {
      automatic-timezoned = {
        isAllowed = true;
        isSystem = true;
      };
      gammastep = {
        isAllowed = true;
        isSystem = false;
      };
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
    # Use SDDM on Wayland and start Niri by default
    sddm.wayland.enable = true;
    defaultSession = "niri";
  };
  # Keyboard configuration for console
  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps"; # Remap CapsLock to Control
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
  # Additional groups for desktop user (extends base config)
  users.users.denis.extraGroups = [ "audio" ];

  programs.nh = {
    enable = true;
    flake = "../../.#chris";
  };
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "denis" ];
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
    factorio-demo
    git
    groff
    kdePackages.dolphin
    niri
    swaylock
    xwayland-satellite
    portaudio
    prismlauncher
    wget
    zenity
    zip
  ];

  environment.extraInit = ''
    export PATH=$PATH:$HOME/.local/bin
  '';

  programs.dconf.enable = true;

  # Wayland desktop portals (screen share, file dialogs, screenshots)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Helpful Wayland environment flags for apps
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # Firefox
    NIXOS_OZONE_WL = "1"; # Electron/Chromium (Ozone/Wayland)
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

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
