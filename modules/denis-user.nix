# Universal user module for denis across ALL machines
{ pkgs, ... }:
{
  # Standard user configuration for denis
  users.users.denis = {
    isNormalUser = true;
    description = "denis";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFJLQFWmH33Gmo2pGMtaQ0gPfAuqMZwodMUvDJwFTMy denispmaciel@gmail.com"
    ];
    # Base groups that all machines need
    # Additional groups can be added per-host by extending this list
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  # SSH daemon configuration
  services.openssh.enable = true;

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
