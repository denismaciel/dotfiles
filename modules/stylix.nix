{pkgs, ...}: {
  config = {
    stylix.enable = true;
    stylix.polarity = "light";
    stylix.image = ../assets/wallpaper.jpg;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/github.yaml";
    # stylix.base16Scheme = ../no-clown-fiesta.yaml;
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/selenized-black.yaml";
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
