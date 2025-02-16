{
  config,
  pkgs,
  ...
}: {
  imports = [
    # <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
    ./hardware-configuration.nix
  ];

  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.denis = {
    createHome = true;
    home = "/home/denis";
    description = "denis";
    group = "users";
    extraGroups = ["wheel"];
    useDefaultShell = true;
    isNormalUser = true;
    packages = with pkgs; [
      git
      curl
      wget
      neovim
      tmux
      htop
      tree
      ripgrep
      fd
      bat
      btop
      iotop
      duf
    ];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFJLQFWmH33Gmo2pGMtaQ0gPfAuqMZwodMUvDJwFTMy denispmaciel@gmail.com"];
  };
}
