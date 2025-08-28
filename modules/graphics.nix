{
  config,
  lib,
  pkgs,
  ...
}: {
  # Modern graphics configuration (NixOS 24.05+)
  # Replaces the legacy hardware.opengl options
  hardware.graphics = {
    enable = true;

    # Enable 32-bit support for compatibility with older applications and games
    enable32Bit = true;

    # Hardware video acceleration support
    extraPackages = with pkgs; [
      # Intel media driver for VAAPI
      intel-media-driver

      # VDPAU to VA-API adapter
      vaapiVdpau
      libvdpau-va-gl

      # Intel VA-API implementation
      vaapiIntel
    ];

    # 32-bit versions for compatibility
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
      vaapiIntel
    ];
  };

  # Use modesetting driver by default (best for modern Intel/AMD GPUs)
  services.xserver.videoDrivers = lib.mkDefault ["modesetting"];

  # Hardware video acceleration environment variables
  environment.sessionVariables = {
    # Use Intel media driver for newer Intel GPUs (Broadwell+)
    LIBVA_DRIVER_NAME = "iHD";

    # Fallback to i965 for older Intel GPUs can be set per-host if needed
    # LIBVA_DRIVER_NAME = "i965";

    # Use VA-API through VDPAU wrapper
    VDPAU_DRIVER = "va_gl";
  };
}
