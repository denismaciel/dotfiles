{
  # Host-specific networking configuration for chris
  networking = {
    # Let systemd-resolved handle DNS
    nameservers = [ ];
    hostName = "chris";

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };

    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 3000 ];
    };
  };

  # Global DNS via systemd-resolved
  services.resolved = {
    enable = true;
    llmnr = "false";
    dnssec = "false"; # change to "allow-downgrade" if DNSSEC desired
    extraConfig = ''
      DNS=100.117.76.42
      FallbackDNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
      Domains=~.
    '';
  };

  # Tailscale client configuration
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    # --exit-node-allow-lan-access=true is necessary to access docker containers via localhost
    extraUpFlags = [
      "--accept-dns=true"
      "--exit-node=100.74.57.103"
      "--exit-node-allow-lan-access=true"
    ];
  };
}
