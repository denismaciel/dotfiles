_:

{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      dns = {
        bind_port = 53;
        bind_hosts = [
          "0.0.0.0"
          "::"
        ];
      };
    };
  };
}
