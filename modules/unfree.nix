{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # Password management
      "1password"
      "1password-cli"
      "1password-gui"

      # Browsers
      "google-chrome"
      "firefox-bin"
      "firefox-bin-unwrapped"

      # Communication tools
      "slack"

      # Entertainment
      "spotify"
      "spotify-unwrapped"

      # Development tools
      "terraform"

      # Hardware drivers
      "broadcom-sta"
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-57-6.12.43"
  ];
}
