{
  nix.settings = {
    trusted-users = ["denis"];
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
