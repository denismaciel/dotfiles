{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    go.enable = lib.mkEnableOption "enables go";
  };
  config = lib.mkIf config.go.enable {
    programs.go = {
      enable = true;
      package = pkgs.go_1_24;
      goPath = "go-path";
    };
    home.packages = with pkgs; [
      delve
      golines
      gotools # for goimports
      gopls
      golangci-lint
      mockgen
    ];
  };
}
