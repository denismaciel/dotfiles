{
  lib,
  config,
  ...
}:
{
  options = {
    redshift.enable = lib.mkEnableOption "enables redshift with geoclue2 location provider";
  };

  config = lib.mkIf config.redshift.enable {
    location.provider = "geoclue2";

    services.geoclue2 = {
      enable = true;
      appConfig.redshift = {
        isAllowed = true;
        isSystem = true;
      };
    };

    services.redshift = {
      enable = true;
      temperature = {
        day = 4500; # Lowered from 6000K to 4500K for a warmer daytime
        night = 2700; # Lowered from 3700K to 2700K for a redder night
      };
      brightness = {
        day = "1";
        night = "0.9";
      };
    };
  };
}
