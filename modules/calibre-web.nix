{
  pkgs,
  ...
}:

{
  # Ensure calibre is available for ebook-convert
  environment.systemPackages = [ pkgs.calibre ];

  # Create media group if it doesn't exist
  users.groups.media = { };

  # Add denis to media group
  users.users.denis.extraGroups = [ "media" ];

  # Calibre-Web service configuration
  services.calibre-web = {
    enable = true;
    user = "calibre-web";
    group = "media";
    listen = {
      ip = "127.0.0.1";
      port = 8083;
    };
    options = {
      calibreLibrary = "/srv/books/calibre";
      enableBookUploading = true;
      enableBookConversion = true;
      reverseProxyAuth.enable = false;
    };
  };

  # Create the library directory with proper permissions
  systemd.tmpfiles.rules = [
    "d /srv/books 0755 root media -"
    "d /srv/books/calibre 0775 calibre-web media -"
  ];

  # Open firewall for Calibre-Web (internal only via Tailscale)
  networking.firewall.allowedTCPPorts = [ 8083 ];
}
