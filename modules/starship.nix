{
  lib,
  config,
  ...
}: {
  options = {
    starship.enable = lib.mkEnableOption "enables starship with Stylix-based theme";
  };

  config = lib.mkIf config.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        palette = lib.mkForce "stylix_auto";

        character = {
          success_symbol = "[\\$](fg)";
          error_symbol = "[*](red)";
          vicmd_symbol = "[*](blue)";
        };
        env_var = {
          variable = "ENV";
          format = "[$env_value]($style) ";
          symbol = " ";
          style = "gray4";
        };
        directory = {
          style = "blue bold";
        };
        aws = {
          disabled = true;
        };
        gcloud = {
          disabled = true;
        };
        package = {
          disabled = true;
        };
        git_branch = {
          style = "green";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
        };
        git_status = {
          style = "orange";
          disabled = true;
        };
        cmd_duration = {
          style = "gray4";
          format = "[$duration]($style) ";
        };
        python = {
          symbol = " ";
          format = "[\${symbol}(\($virtualenv\) )]($style)";
          style = "magenta";
        };
        golang = {
          disabled = true;
        };
        lua = {
          disabled = true;
        };
        nodejs = {
          disabled = true;
        };

        palettes = {
          stylix_auto = with config.lib.stylix.colors.withHashtag; {
            # Main colors from Stylix base16 scheme
            bg = base00; # Background
            fg = base05; # Foreground

            # Grays (gradients for UI elements)
            gray1 = base01; # Lighter background
            gray2 = base02; # Selection background
            gray3 = base03; # Comments
            gray4 = base04; # Dark foreground
            gray5 = base06; # Light foreground

            # Semantic colors
            red = base08; # Variables, errors
            orange = base09; # Constants, modified
            yellow = base0A; # Strings, warnings
            green = base0B; # Functions, success
            blue = base0D; # Keywords, info
            magenta = base0E; # Types, special

            # Pure black/white for contrast
            black =
              if config.stylix.polarity == "light"
              then "#000000"
              else "#ffffff";
            white =
              if config.stylix.polarity == "light"
              then "#ffffff"
              else "#000000";
          };
        };
      };
    };
  };
}
