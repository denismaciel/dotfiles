{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    warp.enable = lib.mkEnableOption "enables warp";
  };
  config = lib.mkIf config.warp.enable {
    environment.systemPackages = [pkgs.cloudflare-warp];
    systemd.services.cloudflare-warp = {
      enable = true;
      description = "Warp server";
      path = [pkgs.cloudflare-warp];
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
