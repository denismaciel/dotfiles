let
  theme = "light";
  palettes = {
    light = {
      # Base16 mapping using lumiere colors
      base00 = "#F1F1F1"; # Main background
      base01 = "#e4e4e4"; # Light gray
      base02 = "#d3d3d3"; # Medium light gray (selection bg)
      base03 = "#b8b8b8"; # Medium gray (comments, disabled)
      base04 = "#9e9e9e"; # Medium dark gray
      base05 = "#424242"; # Main foreground text
      base06 = "#000000"; # Light foreground (not used much)
      base07 = "#000000"; # Lightest foreground
      base08 = "#800013"; # Red (errors, deletions)
      base09 = "#cc4c00"; # Orange (modified, special)
      base0A = "#ffda40"; # Yellow (warnings, search)
      base0B = "#00802c"; # Green (success, additions)
      base0C = "#001280"; # Cyan/Blue (info, links)
      base0D = "#001280"; # Blue (info, links, types)
      base0E = "#410080"; # Magenta (keywords, constants)
      base0F = "#410080"; # Brown/Dark red
    };
    dark = {
      # Oxocarbon dark colors
      base00 = "#161616"; # Main background
      base01 = "#262626"; # Lighter background
      base02 = "#393939"; # Selection background
      base03 = "#525252"; # Comments, disabled
      base04 = "#dde1e6"; # Dark foreground
      base05 = "#f2f4f8"; # Main foreground
      base06 = "#ffffff"; # Light foreground
      base07 = "#08bdba"; # Lightest foreground
      base08 = "#3ddbd9"; # Red
      base09 = "#78a9ff"; # Orange
      base0A = "#ee5396"; # Yellow
      base0B = "#33b1ff"; # Green
      base0C = "#ff7eb6"; # Cyan
      base0D = "#42be65"; # Blue
      base0E = "#be95ff"; # Magenta
      base0F = "#82cfff"; # Brown
    };
  };
in
{
  inherit theme;
  palette = palettes.${theme};
}
