{
  networking = {
    hostName = "chris";
    nameservers = [ "100.117.76.42" ];
    networkmanager = {
      enable = true;
    };

    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 3000 ];
    };
  };

  services.tailscale = {
    enable = true;
    # useRoutingFeatures = "client";
    # --exit-node-allow-lan-access=true is necessary to access docker containers via localhost
    extraUpFlags = [
      "--accept-dns=true"
      "--exit-node=100.74.57.103"
      "--exit-node-allow-lan-access=true"
    ];
  };
}
