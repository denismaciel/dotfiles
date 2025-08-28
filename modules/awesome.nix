{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.awesome-dennich;

  rcLua = pkgs.replaceVars ../configs/awesome/rc.lua {
    dennichTodoPath = "${cfg.dennichPkg}/bin/dennich-todo";
  };
in {
  options.awesome-dennich = {
    enable = mkEnableOption "Awesome window manager with dennich integration";

    dennichPkg = mkOption {
      type = types.package;
      description = "The dennich package to use for shortcuts";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [luarocks];
    };

    environment.etc."awesome/rc.lua".source = rcLua;
    environment.etc."awesome/main/utils.lua".source = ../configs/awesome/main/utils.lua;
    environment.etc."awesome/main/dkjson.lua".source = ../configs/awesome/main/dkjson.lua;
  };
}
