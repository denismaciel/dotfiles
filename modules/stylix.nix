{pkgs, ...}: {
  config = {
    stylix.enable = true;
    stylix.image = ../assets/wallpaper.jpg;
    stylix.base16Scheme = ../no-clown-fiesta.yaml;
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/decaf.yaml";
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/selenized-black.yaml";
    # stylix.image = pkgs.fetchurl {
    #   url = "https://w.wallhaven.cc/full/0w/wallhaven-0w3pdr.jpg";
    #   sha256 = "sha256-xrLfcRkr6TjTW464GYf9XNFHRe5HlLtjpB0LQAh/l6M=";
    # };
    stylix.fonts = {
      serif = {
        name = "Poppins";
        package = pkgs.google-fonts.override {fonts = ["Poppins"];};
      };

      sansSerif = {
        name = "Poppins";
        package = pkgs.google-fonts.override {fonts = ["Poppins"];};
      };

      # monospace = {
      #   name = "ComicShannsMono Nerd Font Mono";
      #   package = pkgs.nerd-fonts.comic-shanns-mono;
      # };

      monospace = {
        name = "Blex Mono Nerd Font";
        package = pkgs.nerd-fonts.blex-mono;
      };

      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji;
      };
    };

    stylix.fonts.sizes = {
      applications = 9;
      terminal = 10;
      desktop = 9;
      popups = 9;
    };
  };
}
