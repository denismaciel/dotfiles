{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.polybar-dennich;

  # Create processed versions of the config files with dennich paths substituted
  processedConfig = pkgs.replaceVars ../configs/polybar/config.ini {
    dennichTodoPath = "${cfg.dennichPkg}/bin/dennich-todo";
  };

  processedLaunchScript = pkgs.replaceVars ../configs/polybar/launch.sh {
    dennichTodoPath = "${cfg.dennichPkg}/bin/dennich-todo";
  };
in {
  options.polybar-dennich = {
    enable = mkEnableOption "Polybar status bar with dennich integration";

    dennichPkg = mkOption {
      type = types.package;
      description = "The dennich package to use for polybar modules";
    };

    # Expose the processed configuration files for Home Manager to use
    processedConfigPath = mkOption {
      type = types.path;
      readOnly = true;
      default = processedConfig;
      description = "Path to the processed polybar config with dennich paths substituted";
    };

    processedScriptPath = mkOption {
      type = types.path;
      readOnly = true;
      default = processedLaunchScript;
      description = "Path to the processed polybar launch script with dennich paths substituted";
    };
  };

  config = mkIf cfg.enable {
    # Install polybar system-wide
    environment.systemPackages = with pkgs; [
      polybar
    ];
  };
}
