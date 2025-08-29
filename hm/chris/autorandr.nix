{
  lib,
  config,
  ...
}:
{
  options = {
    autorandr.enable = lib.mkEnableOption "enables autorandr";
  };
  config = lib.mkIf config.autorandr.enable {
    services.autorandr.enable = true;
    programs.autorandr =
      let
        dell = "00ffffffffffff0010acc2d0545135302c1d010380351e78eaad75a9544d9d260f5054a54b008100b300d100714fa9408180d1c00101565e00a0a0a02950302035000e282100001a000000ff004d59334e44394232303551540a000000fc0044454c4c205032343138440a20000000fd0031561d711c000a202020202020012702031bb15090050403020716010611121513141f2065030c001000023a801871382d40582c45000e282100001e011d8018711c1620582c25000e282100009ebf1600a08038134030203a000e282100001a7e3900a080381f4030203a000e282100001a00000000000000000000000000000000000000000000000000000000d8";
        laptop = "00ffffffffffff0009e5860b0000000000200104a51d127803e453a6534b982410515600000001010101010101010101010101010101743c80a070b02840302036001eb31000001a000000fd00283c4b4b10010a202020202020000000fe00424f452048460a202020202020000000fe004e5631333357554d2d4e36370a00fa";
      in
      {
        enable = true;
        profiles = {
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
          "home" = {
            fingerprint = {
              "DP-1" = dell;
              "DP-3" = dell;
            };
            config = {
              DP-1 = {
                mode = "2560x1440";
                position = "1920x0";
                rotate = "normal";
                primary = true;
              };
              DP-3 = {
                mode = "2560x1440";
                position = "0x0";
                rotate = "normal";
              };
            };
          };
          "home-single" = {
            fingerprint = {
              "DP-3" = dell;
            };
            config = {
              DP-3 = {
                mode = "2560x1440";
                position = "0x0";
                rotate = "normal";
                primary = true;
              };
            };
          };
        };
      };
  };
}
