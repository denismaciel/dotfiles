{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    starship.enable = lib.mkEnableOption "enables starship with lumiere theme";
  };

  config = lib.mkIf config.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        palette = "lumiere";

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
          lumiere = {
            bg = "#F1F1F1";
            fg = "#424242";
            gray1 = "#e4e4e4";
            gray2 = "#d3d3d3";
            gray3 = "#b8b8b8";
            gray4 = "#9e9e9e";
            gray5 = "#727272";
            red = "#800013";
            green = "#00802c";
            blue = "#001280";
            yellow = "#cc7a00";
            orange = "#cc4c00";
            magenta = "#410080";
            black = "#000000";
            white = "#ffffff";
          };
        };
      };
    };
  };
}
