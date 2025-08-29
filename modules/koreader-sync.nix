{
  pkgs,
  lib,
  ...
}:

{
  # KOReader Sync Server via Docker
  # This provides reading progress sync between KOReader devices

  # Ensure Docker is enabled (already enabled on ben)
  virtualisation.docker.enable = lib.mkDefault true;

  # KOSync server container
  virtualisation.oci-containers = {
    backend = "docker";
    containers.kosync = {
      image = "koreader/kosync:latest";
      ports = [ "127.0.0.1:7200:7200" ];

      volumes = [
        "/var/lib/kosync:/home/ko/data"
      ];
    };
  };

  # Create data directory with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/kosync 0755 root root -"
  ];

  # Open firewall port (internal only via Tailscale)
  networking.firewall.allowedTCPPorts = [ 7200 ];

  # Service to set up Tailscale serve for kosync
  systemd.services.kosync-tailscale = {
    description = "Setup Tailscale serve for KOSync";
    after = [
      "docker-kosync.service"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Wait for kosync to be ready
      for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -s http://127.0.0.1:7200/healthcheck >/dev/null 2>&1; then
          break
        fi
        sleep 2
      done

      # Setup Tailscale serve on a different port than Calibre-Web
      ${pkgs.tailscale}/bin/tailscale serve --https=7200 http://127.0.0.1:7200 || true
    '';
  };
}
