{
  lib,
  config,
  ...
}: {
  options = {
    autorandr.enable = lib.mkEnableOption "enables autorandr";
  };
  config = lib.mkIf config.autorandr.enable {
    services.autorandr.enable = true;
    programs.autorandr = let
      dell = "00ffffffffffff0010acc2d0545135302c1d010380351e78eaad75a9544d9d260f5054a54b008100b300d100714fa9408180d1c00101565e00a0a0a02950302035000e282100001a000000ff004d59334e44394232303551540a000000fc0044454c4c205032343138440a20000000fd0031561d711c000a202020202020012702031bb15090050403020716010611121513141f2065030c001000023a801871382d40582c45000e282100001e011d8018711c1620582c25000e282100009ebf1600a08038134030203a000e282100001a7e3900a080381f4030203a000e282100001a00000000000000000000000000000000000000000000000000000000d8";
      laptop = "00ffffffffffff000e6f041400000000001e0104a51e1378034a6ca4554c9b240d4f5500000001010101010101010101010101010101353c80a070b02340302036002ebd10000018000000fd00303c4a4a0f010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030374a41312d310a2000bd";
    in {
      enable = true;
      profiles = {
        "monitor-only" = {
          fingerprint = {
            "DP-3" = dell;
          };
          config = {
            DP-3 = {
              mode = "2560x1440";
              position = "1680x0";
              rotate = "normal";
              primary = true;
            };
          };
        };
        "away" = {
          fingerprint = {
            "eDP-1" = laptop;
          };
          config = {
            eDP-1 = {
              mode = "1680x1050";
              position = "599x769";
              rotate = "normal";
            };
          };
        };
        "home-horizontal" = {
          fingerprint = {
            "DP-3" = dell;
            "eDP-1" = laptop;
          };
          config = {
            DP-3 = {
              mode = "2560x1440";
              position = "1680x0";
              rotate = "normal";
              primary = true;
            };
            eDP-1 = {
              mode = "1680x1050";
              position = "0x599";
              rotate = "normal";
            };
          };
        };
        "home" = {
          fingerprint = {
            "DP-3" = dell;
            "eDP-1" = laptop;
          };
          config = {
            DP-3 = {
              mode = "2560x1440";
              position = "1680x0";
              rotate = "left";
              primary = true;
            };
            eDP-1 = {
              mode = "1680x1050";
              position = "0x599";
              rotate = "normal";
            };
          };
        };
      };
    };
  };
}
