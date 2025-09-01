{ pkgs, ... }:
let
  openttdConfig = pkgs.writeText "openttd.cfg" ''
    [network]
    server_name = Pinto Family LAN
    server_password =
    rcon_password =
    server_advertise = false
    server_port = 3979
    max_clients = 4
    max_companies = 2
    max_spectators = 2
    autocreate = true
    default_company_password =
    restart_game = true

    [game_creation]
    map_x = 9
    map_y = 9
    landscape = temperate
    town_name = english
    starting_year = 1990
    number_towns = medium
    number_industries = high
    economy = true
    diff_level = 0
    vehicle_breakdowns = false
    snow_line_height = 7

    [company]
    money = 1000000
  '';
in
{
  # Open ports for LAN multiplayer & discovery
  networking.firewall.allowedTCPPorts = [ 3979 ];
  networking.firewall.allowedUDPPorts = [ 3979 ];

  systemd.services.openttd-server = {
    description = "OpenTTD Dedicated Server (LAN)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "openttd";
      # Copy config file on start
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p /var/lib/openttd"
        "${pkgs.coreutils}/bin/cp ${openttdConfig} /var/lib/openttd/openttd.cfg"
      ];
      # Main server process (headless)
      ExecStart = "${pkgs.openttd}/bin/openttd -D -c /var/lib/openttd/openttd.cfg";
      Restart = "on-failure";
    };
  };
}
